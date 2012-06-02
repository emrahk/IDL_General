@ar1_process
@ar2_process

PRO lssm_process,time,rate                                          $
                 ,ar1=ar1,ar2=ar2                                   $
                 ,relaxation=relaxation,period=period,c=c,sig=sig   $ 
                 ,lssmc=lssmc,lssmsig=lssmsig                       $
                 ,ar_rate=ar_rate
;+
; NAME:
;         lssm_process
;
;
; PURPOSE:
;         return a one dimensional LSSM model evenly time series
;     state equation       : x(t) = 'AR[p]_process' 
;     observation equation : y(t) = C*x(t)+noise    , noise = N(0,lssmsig)
;   
; CATEGORY:
;         timing tools
;
;
; CALLING SEQUENCE:
;         lssm_process,time,rate,ar1=ar1,ar2=ar2                      $
;                   ,relaxation=relaxation,period=period              $ 
;                   ,lssmc=lssmc,lssmsig=lssmsig
;
; 
; INPUTS:
;         time : time array of evenly binned lightcurve        
;
;
; OPTIONAL INPUTS:
;         none
;
;      
; KEYWORD PARAMETERS:
;         a1         : if set, work with AR[1] process
;         a2         : if set, work with AR[2] process
;         relaxation : parameter value of the AR[1&2] process ; damping
;                      rate (in  bins)
;         period     : parameter value of the AR[2] process ; period
;         sig        : parameter value of the AR[1&2] process ; variance
;                      of the dynamical white noise ( if not set, equal 1.0 )
;         c          : parameter value of the AR[1&2] process ;
;                      influence in the mean (if not set, equal 0)
;         lssmc      : design matrix, C, who maps the unobservable
;                      dynamics to the observation. (y(t) = C*x(t) + noise)
;         lssmsig    : variance of the observable white noise
;                      component ( noise = N(0,sig)
;       
; OUTPUTS:
;         rate       : count rate array of the LSSM lightcurve
;
;
; OPTIONAL OUTPUTS:
;         ar_rate    : count rate array of the unobservable AR[p] lightcurve
;
;
; COMMON BLOCKS:
;         none
;
;
; SIDE EFFECTS:
;         none
;
;
; RESTRICTIONS:
;         AR stationary conditions 
;
;
; PROCEDURE:
;         uses ar1_process, ar2_process procedures, and the
;         idl-randomn function 
;
; EXAMPLE:
;         lssm_process,time,rate,/ar2,relaxation=100,period=50,   $
;                  lssmc=2,lssmsig=3.5,ar_rate=ar_rate
;
;
; MODIFICATION HISTORY:
;         Version 1.0, 1999.01.13, Sara Benlloch (IAAT)
;                                 (benlloch@astro.uni-tuebingen.de)   
;-
   
   
   ;;
   ;; check the parameters of the autocorrelation process
   ;;
   IF keyword_set(c) THEN c = double(c) ELSE c = 0.
   IF keyword_set(sig) THEN sig = double(sig) ELSE sig = 1.
   IF keyword_set(ar1) THEN BEGIN 
       IF (n_elements(relaxation) EQ 0) THEN BEGIN
           print,' Warning : the relaxation ar1 parameter is missing'
           stop
       ENDIF           
       ar1_process,time,ar_rate,relaxation=relaxation,sig=sig,c=c
   ENDIF 
   IF keyword_set(ar2) THEN BEGIN 
       IF (n_elements(relaxation) EQ 0) OR (n_elements(period) EQ 0) THEN BEGIN
           print,' Warning : the relaxation and/or period ar2 parameter '+ $
             'are/is missing'
           stop
       ENDIF       
       ar2_process,time,ar_rate,relaxation=relaxation,period=period,sig=sig,c=c
   ENDIF 
   
   ;;
   ;; lightcurve (lc) parameters
   ;;
   
   ;; dimension of lc in bins
   npt =  n_elements(time)
   
   ;;
   ;; lssm parameter : x(t) = AR[p]_process
   ;;                  y(t) = C*x(t) + observational_noise
   
   ;; design matrix C
   IF keyword_set(lssmc) THEN lssmc = double(lssmc) ELSE lssmc = 1.

   ;; observational noise (white noise with variance lssmsig)
   IF keyword_set(lssmsig) THEN lssmsig = double(lssmsig) ELSE lssmsig = 1. 
   lssmnoise =  sqrt(lssmsig) * randomn(seed,npt)
   
   ;; time series
   rate=(lssmc*ar_rate)+lssmnoise

END 










