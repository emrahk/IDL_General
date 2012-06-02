
PRO ar1_process,time,rate                                                  $
                ,freq=freq,spectrum=spectrum,lag=lag,acf=acf,mu=mu,var=var $
                ,relaxation=relaxation,a1=a1,sig=sig,c=c                   $
                ,schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto 
;
; NAME:
;         ar1_process
;
;
; PURPOSE:
;         return a "Autorregressive Process" first order model evenly
;         time series    
;                   x(t) = c + a1*x(t-1) + white_noise(t)
;
; CATEGORY:
;         timing tools
;
;
; CALLING SEQUENCE:
;         ar1_process,time,rate,relaxation=relaxation
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
;         relaxation : parameter value of the AR[1] process ; damping
;                      rate (in  bins)
;         a1         : (not necessary, if relaxation is set)
;                      parameter value of the AR[1] process  
;                      a1=exp(-1/relaxation)  
;         sig        : parameter value of the AR[1] process ; variance
;                      of the white noise (if not set, equal 1.0) 
;         c          : parameter value of the AR[1] process ;
;                      influence in the mean ( mean = c/(1-a) ) 
;                      (if not set, equal 0)    
;         schlittgen : if set, return theoretical spectrum in
;                      Schlittgen normalization (Schlittgen, H.J.,
;                      Streitberg, B., 1995, Zeitreihenanalyse, R. Oldenbourg)
;         leahy      : if set, return theoretical spectrum in Leahy
;                      normalization (Leahy et al. 1983, Ap.J. 266, 160)
;         miyamoto   : if set, return theoretical spectrum in Miyamoto
;                      normalization (Miyamoto et al. 1992, Ap.J. 391, L21)
;
; OUTPUTS:
;         rate       : count rate array of the AR[1] lightcurve
;   
; OPTIONAL OUTPUTS: 
;         freq       : fourier frequency sample (in Hz)
;         spectrun   : theoretical density spectrum to each frequency
;         mu         : theoretical mean of the process  
;         var        : theoretical variance of the process
;         acf        : theoretical autocorrelation values to each time lag
;         lag        : time-lag sample
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
;         for a stationary process take  -1 < a1 < 1.
;
; PROCEDURE:
;         uses the idl-randomn function
;
; EXAMPLE:
;         ar_process,time,rate,freq=freq,spectrum=spectrum    $
;                    ,relaxation=11.6,sig=1.4,/leahy          
;
; MODIFICATION HISTORY:
;         Version 1.0, 1998/12/22, Sara Benlloch (IAAT)
;                                 (benlloch@astro.uni-tuebingen.de)   
;         Version 1.1, 1999/01/11, a error in sig was corrected, mu
;                                  and c added
;-

   ;; 
   ;; check if normalization-keyword is set correctly
   ;;
   sum = n_elements(schlittgen)+n_elements(leahy)+n_elements(miyamoto)
   IF (sum GT 1) THEN BEGIN 
       message, ' Warning! : Only one normalization-keyword can be set' 
   ENDIF
   IF (sum EQ 0) THEN BEGIN
       schlittgen = 1
   ENDIF

   ;;
   ;; AR[1] parameter : x(i) = c + a*x(i-1) + noise(i),  a = exp(-1/r)
   ;;
   
   ;; check if the AR parameter-keywords are set, and if they are, check
   ;; if they are set correctly
   IF keyword_set(relaxation) THEN  BEGIN 
       r = double(relaxation)   ; damping rate in bins 
       IF keyword_set(a1) THEN BEGIN 
           a1 = double(a1)
           IF a1 NE exp(-1./r) THEN BEGIN
               print,' Warning! : Error in a1 or relaxation parameter'
               stop
           ENDIF      
       ENDIF ELSE  a1 = exp(-1./r)
   ENDIF ELSE BEGIN 
       IF keyword_set(a1) THEN BEGIN 
           a1 = double(a1)
           relaxation = -1./alog(a1) 
       ENDIF ELSE BEGIN 
           print,' Warning! :  Nor a1 either relaxation parameter are set'
           stop 
       ENDELSE 
   ENDELSE 
   IF keyword_set(c) THEN c = double(c) ELSE c = 0.
   IF keyword_set(sig) THEN sig = double(sig) ELSE sig = 1.0 

   ;;
   ;; lightcurve (lc) parameters
   ;;

   ;; dimension of lc in bins ( wished length plus 100 times the damping rate )
   npt = long(n_elements(time)+100.*relaxation) 

   ;; bintime
   bt = double(time(1)-time(0))
   
   ;; starting component 
   x = dblarr(npt)                 
   x(0) = 0.              
   
   ;; white noise component
   noise = sqrt(sig) * randomn(seed,npt) 
   
   ;; time series
   orate = dblarr(npt)
   orate(0) = x(0)
   FOR i=1L,npt-1,1 DO BEGIN
       x(i) = c + a1*x(i-1) + noise(i)  
       orate(i) = x(i)
   ENDFOR
   
   ;; time series with wished length
   rate = orate( fix(100.*relaxation) : npt-1)
   npt = n_elements(time)
   
   ;;
   ;; mean : mu = c / (1-a)
   ;;
   mu = c / (1.-a1)
   
   ;;
   ;; variance : sigma^2 = sig^2 / (1-a^2)
   ;;
   var = sig / (1.-(a1^2))
   
   ;;
   ;; theoretical AR[1] spectrum
   ;;
   freq = ((findgen(npt/2.))+1.) / (double(npt)*bt) ; frequency in Hz
   spec = sig / (1.+(a1^2)-2.*a1*cos(2.*!pi*freq*bt))

   ;; normalization of the theoretical spectrum
   IF (mu EQ 0) THEN avg = mean(rate) ELSE avg = mu
   IF (keyword_set(schlittgen)) THEN BEGIN 
       spectrum = spec / double(npt)
   ENDIF 
   IF (keyword_set(leahy)) THEN BEGIN
       IF avg LT 0 THEN BEGIN 
           print,' Warning! : negative mean. Instead of leahy, '+ $
             'miyamoto normalization is take '
           miyamoto=1
       ENDIF ELSE spectrum = (2.*spec*bt) / (avg*double(npt))
   ENDIF 
   IF (keyword_set(miyamoto)) THEN BEGIN
       spectrum = (spec*bt) / ((avg^2.)*double(npt))
   ENDIF
   
   ;;
   ;; autocorrelation function : acf(lag) = a^abs(lag)
   ;;
   acf = dblarr(npt)        
   FOR lag=0L,npt-1 DO BEGIN     ; ( lag = 0,...,npt-1 ) 
       acf[lag] = a1^double(lag)
   END 
   lag = (time[1]-time[0]) * findgen(npt)    

   return 
END











