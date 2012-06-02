
PRO rebinpulse,inprofile,outprofile,$
               energybinning=enbin,phasebinning=phasbin,$
               notimeweight=notime,verbose=verbose

;+
; NAME:
;       rebinpulse
;
;
; PURPOSE:
;       Rebin a pulse profile
;
; CATEGORY:
;       Pulse profiles
;
; CALLING SEQUENCE:
;       rebinpulse,inprofile,outprofile,[keywords]
; 
; INPUTS:
;       inprofile : PULSEPROFILE structure
;
; OPTIONAL INPUTS:
;       energybinning : Single value or vector for binning in energy domain.
;                       If this is a single value N then the output profile 
;                       will have in each channel the sum of N channels from
;                       the input profile.
;                       If this is a vector [N,M,...] then the output profile 
;                       will have in the first channel the sum of N channels 
;                       from the input profile, in the second M, etc.
;                       If the vectro contains negative values, a 
;                       corresponding number of channels is skipped
;                       (useful to skip worthless low-energy channels).
;
;       phasebinning  : Single value or vector for binning in phase domain.
;
; KEYWORD PARAMETERS:
;       notimeweight  : LOGICAL - Do not weigh with accumulation times 
;                                 for time bins
;       verbose       : LOGICAL - produce some output while processing
;
; OUTPUTS:
;       outprofile : PULSEPROFILE structure with Sum(energy_binning) channels
;                    and Sum(phase_binning) phasebins
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
;       * Complex procedure
;
; PROCEDURE:
;       just read it
;
; EXAMPLE:
;       TBW
;
;
; MODIFICATION HISTORY:
;       Version 1.0: 1999/11/12 PK
;                    first version
;       Version 1.1: 2000/04/11 PK
;                    respond correctly if energy binning is single integer
;                    better error checks
;-

    proname='rebinpulse'

;; check for correct type of input profile

    IF (datatype(inprofile,2) NE 8) THEN BEGIN
        print,proname,' error: Need special Structure as input!'
        RETURN
    ENDIF ELSE BEGIN
        tags=tag_names(inprofile)
        IF (tags(0) NE 'NPROFILES') THEN BEGIN
            print,proname,' error: Input Structure seems to be wrong'
            RETURN
        ENDIF
    ENDELSE

;;
;; set output to input
;;
    outprofile=inprofile

;;
;; start working: phase binning first
;;
    IF (keyword_set(phasbin)) THEN BEGIN
        size_ph = size(phasbin) 
        type_ph = size_ph(size_ph(0)+1)
        IF NOT ((size_ph(0) LT 2) AND $
                (type_ph EQ 2 OR type_ph eq 3)) THEN BEGIN
            print,proname + ' error: ' + $
                  'use integer or array of integers for binning info!'
            RETURN
        ENDIF

        single_val = size_ph(0) EQ 0
        IF single_val THEN BEGIN

            IF (phasbin*(inprofile.nphasebins/phasbin) NE $
                inprofile.nphasebins) THEN BEGIN
                print,proname + ' error: '+ $
                  ' a single int *must* be a divisor of the # of phase bins!'
                RETURN
            ENDIF

            ;; new # of phase bins 
            outprofile.nphasebins = inprofile.nphasebins/phasbin  

            ;; convert single value to vector -> easier life below
            phbin = replicate(phasbin,outprofile.nphasebins)   

        ENDIF ELSE BEGIN
            IF (total(phasbin) GT inprofile.nphasebins) THEN BEGIN
                 print,proname + ' error: '+ $
                  'sum of phase intervals must be <= total # available!'
                 RETURN
            ENDIF
            phbin=phasbin
            outprofile.nphasebins = n_elements(phbin)
        ENDELSE

        IF (keyword_set(verbose)) THEN BEGIN
            print,form='(2a,i3,a,i3,a,i3,a)',proname,$
                  ': rebinning ',total(phbin),' out of ',$
                  inprofile.nphasebins,' to ',$
                  outprofile.nphasebins,' phase bins.'
        ENDIF

        ;; we loop over energy bands
            FOR e=0,inprofile.nchannels-1 DO BEGIN
            off = 0
            FOR p=0,outprofile.nphasebins-1 DO BEGIN
                cts = 0.0 & dcts = 0.0 & x = 0.0 & dx = 0.0 & tim = 0.0 
                FOR b=0,phbin(p)-1 DO BEGIN
                    k    = off+b
	            IF keyword_set(notime) THEN BEGIN
                        w = 1.0 
                    ENDIF ELSE BEGIN
                        w=inprofile.exposure(k)
                    ENDELSE
        	    x    = x+inprofile.x(k,e)
               	    dx   = dx+inprofile.dx(k,e)
                    cts  = cts+inprofile.y(k,e)*w
        	    dcts = dcts+(inprofile.dy(k,e)*w)^2
        	    tim  = tim+w
                ENDFOR
                outprofile.x(p,e)   = x/float(phbin(p))
                outprofile.dx(p,e)  = dx
                IF tim GT 0 THEN BEGIN
                    outprofile.y(p,e)  = cts/tim 
                    outprofile.dy(p,e) = sqrt(dcts)/tim
                ENDIF ELSE BEGIN
                    outprofile.y(p,e)  = 0
	            outprofile.dy(p,e) = 0
                ENDELSE
                IF (keyword_set(notime)) THEN BEGIN
                    outprofile.exposure(p) = 0 
                ENDIF ELSE BEGIN 
                    outprofile.exposure(p) = tim
                ENDELSE
                off = off + phbin(p)
            ENDFOR
        ENDFOR
        outprofile.x(outprofile.nphasebins:*,*)  = 0  ; reset arrays beyond  
        outprofile.dx(outprofile.nphasebins:*,*) = 0  ; new phase bin limit
        outprofile.y(outprofile.nphasebins:*,*)  = 0
        outprofile.dy(outprofile.nphasebins:*,*) = 0
        outprofile.exposure(outprofile.nphasebins:*)= 0
    ENDIF

;;
;; continue with energy binning 
;;
    tempprofile = outprofile ; needed for correct rebin
    IF keyword_set(enbin) THEN BEGIN
        size_en = size(enbin) 
        type_en = size_en(size_en(0)+1)
        IF NOT ((size_en(0) LT 2) AND $
                (type_en EQ 2 OR type_en EQ 3)) THEN BEGIN
            PRINT,proname + ' error: ' + $
                  'energy binning must be integer or array of integers!'
            RETURN
        ENDIF

        single_val = size_en(0) EQ 0
        IF single_val THEN BEGIN

            IF (enbin*(inprofile.nchannels/enbin) NE $
                inprofile.nchannels) THEN BEGIN
                print,proname + ' error: '+ $
                  ' a single int *must* be a divisor of the # of energy bins!'
                RETURN
            ENDIF

            ;; new # of energy bins 
            outprofile.nchannels = inprofile.nchannels/enbin  

            ;; convert single value to vector -> easier life below
            ebin = replicate(enbin,outprofile.nchannels)   

        ENDIF ELSE BEGIN
            ebin=enbin
            outprofile.nchannels = n_elements(enbin)
        ENDELSE

        positive = where(ebin gt 0)
        IF total(ebin(positive)) GT inprofile.nchannels THEN BEGIN
            print,proname,' error: The total # of bins to rebin is too large!'
            print,form='(2a,i3)',proname,$
            ' info: The old pulse profile contains only ',inprofile.nchannels
            RETURN
        ENDIF
        outprofile.nchannels = n_elements(positive)
        discarded = where(ebin lt 0)
        IF (keyword_set(verbose)) THEN BEGIN
            IF discarded(0) ne -1 THEN BEGIN
                print,form='(2a,i3,a)',proname,$
                      ': discarding ',-1*total(ebin(discarded)),$
                      ' energy bands'
             ENDIF
             print,form='(2a,i3,a,i3,a,i3,a)',proname,$
                   ': rebinning ',total(ebin(positive)),$
                   ' out of ',inprofile.nchannels,$
                   ' to ',outprofile.nchannels,' energy bands'
        ENDIF
        FOR p=0,outprofile.nphasebins-1 DO BEGIN
            off = 0
            e   = 0
            FOR r=0,n_elements(ebin)-1 DO BEGIN
                cts = 0.0
                dcts = 0.0 
                IF (ebin(r) GT 0) THEN BEGIN
                    FOR b=0,ebin(r)-1 DO BEGIN
                        cts  = cts + tempprofile.y(p,off+b)
                        dcts = dcts + tempprofile.dy(p,off+b)^2
                    ENDFOR
                    outprofile.y(p,e)  = cts
                    outprofile.dy(p,e) = sqrt(dcts)
                    outprofile.ebounds(0,e) = inprofile.ebounds(0,off)
                    outprofile.ebounds(1,e) = $
                        inprofile.ebounds(1,off+ebin(r)-1)
                    outprofile.chbounds(0,e) = inprofile.chbounds(0,off)
                    outprofile.chbounds(1,e) = $
                        inprofile.chbounds(1,off+ebin(r)-1)
	            e = e+1
                ENDIF
                off = off+abs(ebin(r))
            ENDFOR
        ENDFOR
        outprofile.x(*,outprofile.nchannels:*)  = 0  ; reset arrays beyond 
        outprofile.dx(*,outprofile.nchannels:*) = 0  ; new energy band limit
        outprofile.y(*,outprofile.nchannels:*)  = 0
        outprofile.dy(*,outprofile.nchannels:*) = 0
        outprofile.ebounds(*,outprofile.nchannels:*) = 0
        outprofile.chbounds(*,outprofile.nchannels:*) = 0
    ENDIF

RETURN
END



