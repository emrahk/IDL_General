PRO psdcorr,totrate,inplength,inpdseg, $
            freq,noipsd, $
            ninstr=ninstr,deadtime=inpdeadtime, $
            nonparalyzable=nonparalyzable, $
            avgrate=avgrate,incrate=incrate, $
            schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
            avgback=avgback,unnormalized=unnormalized,chatty=chatty

;+
; NAME:
;          psdcorr
;
;
; PURPOSE:
;          calculates the frequencies & observational noise of the FFT-psd,
;          the latter modified by detector dead-time, primarily based
;          on the paper by Zhang, W. et al. 1995, ApJ, 449, 930.
;          = instrument independent dead-time correction
;
;
; CATEGORY:
;          timing tools          
;
;
; CALLING SEQUENCE:
;          psdcorr,totrate,inplength,inpdseg, $
;                  freq,noipsd, $
;                  ninstr=ninstr,deadtime=inpdeadtime, $
;                  nonparalyzable=nonparalyzable, $
;                  avgrate=avgrate,incrate=incrate, $
;                  schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
;                  avgback=avgback,unnormalized=unnormalized,chatty=chatty
;
;
; INPUTS:
;          totrate   : total count rate, summed over all detectors
;          inplength : time length of the lightcurve segments for
;                      which the Fourier frequencies are calculated,
;                      to be given in seconds
;          inpdseg   : dimension of the lightcurve segments for which
;                      the Fourier frequencies are calculated,
;                      to be given in time bins
;
;
; OPTIONAL INPUTS:
;          ninstr      : number of detectors
;                        default: ninstr=1, the countrate is averaged
;                        over one detector for deadtime correction
;          inpdeadtime : deadtime the noise level is calculated for
;                        default: deadtime=0, the noise level is
;                        calculated for zero deadtime
;          avgrate     : average count rate for psd normalization
;                        done by psdnorm.pro
;                        default: avgrate=totrate
;
;
; KEYWORD PARAMETERS:
;          nonparalyzable : if set, deadtime correction is for the
;                           nonparalyzable type
;                           (default: nonparalyzable=0: correction for
;                           paralyzable deadtime)
;          incrate        : if set, the given average countrate is the incident rate 
;                           (default: incrate=0: the given average
;                           countrate is the detected rate)
;          schlittgen     : if set, the corrected Fourier quantities
;                           are Schlittgen-normalized
;                           (default: miyamoto=1: Miyamoto normalization) 
;          leahy          : if set, the corrected Fourier quantities
;                           are Leahy-normalized
;                           (default: miyamoto=1: Miyamoto normalization) 
;          miyamoto       : if set, the corrected Fourier quantities
;                           are Miyamoto-normalized (=default)
;          unnormalized   : if set, the corrected Fourier quantities
;                           are not normalized
;                           (default: miyamoto=1: Miyamoto normalization) 
;          chatty         : controls screen output 
;                           (default: no screen output) 
;
;
; OUTPUTS:
;          freq   : Fourier frequency array
;          noipsd : array of observational noise of the psd,
;                   modified  by detector deadtime 
; 
;
; OPTIONAL OUTPUTS:
;          none  
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          setting of keyword defaults  
;
;
; RESTRICTIONS:
;          none
;
;
; PROCEDURES USED:
;
;          fourierfreq.pro
;          zhangfunction.pro
;          psdnorm.pro
;
;
; EXAMPLE:
;          see foucalc.pro, dtcorr.pro
;
;
; MODIFICATION HISTORY:
;          Version 1.0: 12/2000, Katja Pottschmidt IAAT,
;                                based on code written by
;                                Sara Benlloch IAAT
;          Version 1.1: 11/2001, Katja Pottschmidt IAAT,
;                                header comment added
;          Version 1.7: 12/2001, Katja Pottschmidt IAAT,
;                                minor changes in header,
;                                idl/cvs version numbers synchronized
;          Version 1.8: 12/2001, Katja Pottschmidt IAAT,
;                                minor changes in header
;-                               

   
   
;; ninstr-keyword, default:
;; ninstr=1: the countrate is averaged over one detector for
;; deadtime correction
IF (NOT keyword_set(ninstr)) THEN BEGIN
    ninstr=1
ENDIF 
IF (keyword_set(chatty)) THEN BEGIN
    print,'psdcorr: Number of detectors: ',ninstr 
ENDIF 
navg=totrate/double(ninstr)

;; avgrate-keyword for psd norm, default: 
;; avgrate=totrate
IF (n_elements(avgrate) EQ 0) THEN avgrate=totrate

;; deadtime-keyword, default:
;; deadtime=0.: the noise level is calculated for zero deadtime
IF (NOT keyword_set(inpdeadtime)) THEN BEGIN 
    inpdeadtime=0.
ENDIF 
IF (keyword_set(chatty)) THEN BEGIN 
    print,'psdcorr: The noise level is calculated for a deadtime of: '
    print,inpdeadtime
ENDIF 


;; nonparalyzable-keyword, default:
;; nonparalyzable=0: correction for paralyzable deadtime
IF (NOT keyword_set(nonparalyzable)) THEN BEGIN 
    nonparalyzable=0
ENDIF 
IF (keyword_set(chatty)) THEN BEGIN 
    print,'psdcorr: Type of deadtime correction '
    print,'(0=paralyzable, 1=nonparalyzable): ',nonparalyzable
ENDIF 


;; incrate-keyword, default:
;; incrate=0: the given average countrate is the detected rate 
IF (keyword_set(incrate)) THEN BEGIN
    incrate=navg
ENDIF ELSE BEGIN 
    incrate=0
    detrate=navg
ENDELSE 
IF (keyword_set(chatty)) THEN BEGIN 
    print,'psdcorr: Type of the given average countrate '
    print,'(0=incident, 1=detected): ',incrate
ENDIF 


;; normalization-keywords (schlittgen, leahy, miyamoto, unnormalized),
;; default: miyamoto=1: Miyamoto normalization 
sum = n_elements(schlittgen)+n_elements(leahy)+   $
      n_elements(miyamoto)+n_elements(unnormalized)
IF (sum GT 1) THEN BEGIN 
    message, 'psdcorr: Only one normalization-keyword can be set' 
ENDIF
IF (sum EQ 0) THEN BEGIN
    miyamoto=1
ENDIF
IF (keyword_set(schlittgen)) AND (keyword_set(chatty)) THEN BEGIN 
        print,'psdcorr: The corrected Fourier quantities '
        print,'are Schlittgen-normalized' 
ENDIF 
IF (keyword_set(leahy)) AND (keyword_set(chatty)) THEN BEGIN 
    print,'psdcorr: The corrected Fourier quantities '
    print,'are Leahy-normalized'
ENDIF
IF (keyword_set(miyamoto)) AND (keyword_set(chatty)) THEN  BEGIN 
    print,'psdcorr: The corrected Fourier quantities '
    print,'are Miyamoto-normalized'
ENDIF
IF (keyword_set(unnormalized)) AND (keyword_set(chatty)) THEN BEGIN 
    print,'psdcorr: The corrected Fourier quantities '
    print,'are unnormalized'
ENDIF
   

;; lightcurve parameters
deadtime = double(inpdeadtime)
dseg     = long(inpdseg)
n        = double(dseg)
length   = double(inplength)
bt       = double(length/dseg)
time     = double(bt*findgen(dseg))
   

;; Fourier frequency array
fourierfreq,time,freq
om=2.*!pi*bt*freq 
time=0.
     

;; calculate the Zhang psd (zpsd);
;; see Zhang, W., et al., 1995, Ap.J., 449, 930
IF (keyword_set(nonparalyzable)) THEN BEGIN 
    
    IF (keyword_set(incrate)) THEN BEGIN 
        detrate=double(incrate)/(1.+double(incrate)*deadtime)
    ENDIF ELSE BEGIN 
        incrate=double(detrate)/(1.-double(detrate)*deadtime)
    ENDELSE 
    
    ;; Zhang, eq. 35
    dim=long((dseg*bt/deadtime)+2.)
    h=dblarr(dseg+1,dim+1)
    FOR i=0L,dseg DO BEGIN
        FOR j=1L,dim DO BEGIN
            h(i,j)=zhangfunction(double(i),double(j),deadtime,incrate,bt)
        ENDFOR 
    ENDFOR 
    
    hh=0
    sumdim=fix(bt/deadtime+1)
    FOR nind=1,sumdim+1 DO BEGIN 
        hh=hh+h(1,nind)
    ENDFOR
    
    ;; Zhang, eq. 38
    a=dblarr(dseg)
    a(0)=detrate*bt*(1.+2.*hh)
    
    FOR k=1,dseg-1 DO BEGIN
        hhh=0.
        sumdimk=fix((double(k)+1.)*bt/deadtime+1.)
        nind=0
        FOR nind=1,sumdimk+1 DO BEGIN 
            hhh=hhh+h(k+1,nind)-2.*h(k,nind)+h(k-1,nind)
        ENDFOR 
        ;; Zhang, eq. 39
        a(k)=detrate*bt*hhh
    ENDFOR 

    ;; Zhang, eq. 45
    b=4.*(a-detrate^2.*bt^2.)/(detrate*bt)
    b(0)=b(0)/2.

    ;; Zhang, eq. 44
    zpsd=dblarr(dseg/2)
    FOR k=1,dseg-1 DO BEGIN
        zpsd=zpsd+(double(dseg-k)/double(dseg))*b(k)*cos(om*double(k))
    ENDFOR 
    zpsd=b(0)+zpsd
    
ENDIF ELSE BEGIN  
    
    IF (keyword_set(incrate)) THEN BEGIN 
        detrate=incrate*exp(-incrate*deadtime)
    ENDIF ELSE BEGIN 
        ;; approximation of Clarke, D. et al., 1996, Astrophysics 
        ;; and Space Science, 239, 229
        incrate=double(detrate)/(1.-double(detrate)*deadtime) 
    ENDELSE 
    
    IF (bt GE deadtime) THEN BEGIN 
        ;; Zhang, eq. 24
        zpsd=2.*((1.-2.*detrate*deadtime*(1.-deadtime/(2.*bt)))        $
                 -((n-1.)/n)*detrate*deadtime*(deadtime/bt)*cos(om))
    ENDIF ELSE BEGIN
        ;; integer part of deadtime/bt, so that always m>1 or m=1
        m=float(fix(deadtime/bt))
        
        ;; Zhang, eq. 27
        zpsd=2.*(1.-detrate*bt*                                        $
                 ((1.-((n-m)/n)*((m+1.-(deadtime/bt))^2.)*cos(m*om))+  $
                  ((n-m-1.)/n)*((m-(deadtime/bt))^2.)*                 $
                  cos((m+1.)*om)+2.*cos(((m+1.)/2.)*om)*               $
                  sin((m/2.)*om)/sin(om/2.)-((m+1.)/n)*                $
                  (sin(((2.*m+1.)/2.)*om)/sin(om/2.))+(1./n)*          $
                  (sin(((m+1.)/2.)*om)/sin(om/2.))^2.))
    ENDELSE     
    
ENDELSE      


;; normalization of the Zhang psd (zpsd is Leahy normalized)
noipsd=(zpsd*dseg*dseg*avgrate)/(2.*length)
IF (NOT keyword_set(unnormalized)) THEN BEGIN 
    psdnorm,avgrate,length,dseg,noipsd, $
      schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
      avgback=avgback,chatty=chatty
ENDIF


END













