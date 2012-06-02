PRO readpulse_pha2,profile,filename

;+
; NAME:
;       readpulse_pha2
;
;
; PURPOSE:
;       Read in a complete pulse profile from a FITS file containing
;       PHA-II data
;
; CATEGORY:
;       
;
; CALLING SEQUENCE:
;       readpulse_pha2,profile,filename
; 
; INPUTS:
;       filename : name of file with PHA2 structure
;
; OPTIONAL INPUTS:
;       none
;
; KEYWORD PARAMETERS:
;       none
;
; OUTPUTS:
;       profile : PULSEPROFILE structure
;
; OPTIONAL OUTPUTS:
;       none
;
; COMMON BLOCKS:
;       none
;
;
; SIDE EFFECTS:
;       none
;
;
; RESTRICTIONS:
;       none
;
; PROCEDURE:
;       Read information about number of bins from header
;       Read columns with count(rate) data and associated error
;       Eliminate last row (because it's superfluous)
;       Assign data to PULSEPROFILE structure
;
; EXAMPLE:
;       readpulse_pha2,profile,'pca.pha'
;
;
; MODIFICATION HISTORY:
;       Version 1.0: 1999/11/12 PK
;                    first version
;-

    proname='readpulse_pha2'

    IF (n_params() LT 2) THEN BEGIN
        print,proname,' error: 2 parameters are required'
        RETURN
    ENDIF

    profile = {PULSEPROFILE,$
               nprofiles:0,$
               nphasebins:0,$
               nchannels:0,$
               x:dblarr(512,256),$
               y:dblarr(512,256),$
               dx:dblarr(512,256),$
               dy:dblarr(512,256),$
               exposure:dblarr(512),$
               ebounds:dblarr(2,256),$
               chbounds:dblarr(2,256)}

;;
;; open FITS file - get header
;;
    fxbopen,unit,filename,'SPECTRUM',header

;;
;; determine from header:
;; - number of energy bands 
;; - number of phase bins 
;; - type of spectra (COUNT or RATE)
;; - binning used in spectrum generation
;;
    n_channels=0
    getpar,header,'DETCHANS',n_channels

    n_phasebins=0
    getpar,header,'NAXIS2',n_phasebins


    aa=''
    getpar,header,'HDUCLAS4',aa
    aa=strtrim(aa,2)
    spectype=-1
    IF (aa EQ 'RATE') THEN spectype=0
    IF (aa EQ 'COUNT') THEN spectype=1
    IF (spectype EQ -1 AND keyword_set(verbose)) THEN BEGIN 
        print, 'Warning, HDUCLAS3 not RATE or COUNT, assuming COUNT'
        spectype=1
    ENDIF 

    parse_cpix,header,binning
;;
;; Read exposure time per phasebin, and phase values.
;; These will be arrays(n_phasebins)
;;
    fxbread,unit,exposure,'EXPOSURE'
    fxbread,unit,phase,'PHASE'

;;
;; Read counts or rate and associated error column.
;; These will be arrays (n_channels,n_phasebins)
;;
    fxbread,unit,rateerr,'STAT_ERR'
    IF (spectype EQ 0) THEN BEGIN 
        fxbread,unit,rate,'RATE'
    END ELSE BEGIN 
        fxbread,unit,rate,'COUNTS'
        FOR ch=0,n_channels-1 DO BEGIN
            rate(ch,*)    = rate(ch,*)/exposure
            rateerr(ch,*) = rateerr(ch,*)/exposure
        ENDFOR
    END 

;; fasebin produces 1 bin 'too much' so we cut down things

   n_phasebins=n_phasebins-1
   phase    = phase(0:n_phasebins-1)
   exposure = exposure(0:n_phasebins-1)
   rate     = rate(*,0:n_phasebins-1)
   rateerr  = rateerr(*,0:n_phasebins-1)
   
;; calculating phase bin widths

   phasewidth=dblarr(n_phasebins)
   FOR ph=0,n_phasebins-1 DO BEGIN
       previous=ph-1
       IF (previous LT 0) THEN previous=previous+n_phasebins
       phasewidth(ph) = phase(ph)-phase(previous)
       IF (phasewidth(ph) LT 0) THEN BEGIN
           phasewidth(ph)=phasewidth(ph)+ceil(phase(previous))
       ENDIF
   ENDFOR

;; Determine number of profiles (repetitions of base profile)
    cycles = ceil(max(phase))

;; Assign values to profile

    profile.nprofiles  = cycles
    profile.nphasebins = n_phasebins
    profile.nchannels  = n_channels
    profile.exposure   = exposure

    profile.chbounds(*,0:n_channels-1) = binning

    FOR chan=0,n_channels-1 DO BEGIN
        profile.x(0:n_phasebins-1,chan)  = phase
        profile.dx(0:n_phasebins-1,chan) = phasewidth/2.0
        profile.y(0:n_phasebins-1,chan)  = rate(chan,*)
        profile.dy(0:n_phasebins-1,chan) = rateerr(chan,*)
    ENDFOR

    fxbclose,unit
    RETURN
END


