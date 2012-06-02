
PRO ar2_process,time,rate                                                    $
                ,freq=freq,spectrum=spectrum,mu=mu,var=var                   $
                ,relaxation=relaxation,period=period,a1=a1,a2=a2,sig=sig,c=c $
                ,schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto 
;
; NAME:
;         ar2_process
;
;
; PURPOSE:
;         return a single oscillator "Autorregressive Process" second
;         order model evenly time series    
;                   x(t) = c + a1*x(t-1) + a2*x(t-2) + white_noise(t)
;
; CATEGORY:
;         timing tools
;
;
; CALLING SEQUENCE:
;         ar1_process,time,rate,relaxation=relaxation,period=period
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
;         relaxation : parameter value of the AR[2] process ; damping
;                      rate (in  bins)
;         period     : parameter value of the AR[2] process ; period
;                      (in bins)   
;         a1         : (not necessary, if relaxation is set)
;                      parameter value of the AR[2] process  
;                      a1=2*exp(-1/relaxation)*cos(2*pi/period)  
;         a2         : (not necessary, if period is set)
;                      parameter value of the AR[2] process  
;                      a2=-exp(-1/tau)   
;         sig        : parameter value of the AR[2] process ; variance
;                      of the white noise ( if not set, equal 1.0 )
;         c          : parameter value of the AR[2] process ;
;                      influence in the mean ( mean = c/(1-a1-a2) )
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
;         rate       : count rate array of the AR[2] lightcurve
;   
; OPTIONAL OUTPUTS: 
;         freq       : fourier frequency sample (in Hz)
;         spectrun   : theoretical density spectrum to each frequency
;         mu         : theoretical mean of the process  
;         var        : theoretical variance of the process
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
;         for a stationary process take  -1 < a1 , a1+a2 > -1 and a1-a2 < 1.
;
; PROCEDURE:
;         uses the idl-randomn function
;
; EXAMPLE:
;         ar2_process,time,rate,freq=freq,spectrum=spectrum    $
;                    ,relaxation=100,period=50,sig=1.4,/miyamoto          
;
; MODIFICATION HISTORY:
;         Version 1.0, 1999/01/11, Sara Benlloch (IAAT)
;                                 (benlloch@astro.uni-tuebingen.de)   
;-

   ;; 
   ;; check if normalization-keyword is set correctly
   ;;
   sum = n_elements(schlittgen)+n_elements(leahy)+n_elements(miyamoto)
   IF (sum GT 1) THEN BEGIN 
       message, 'Only one normalization-keyword can be set' 
   ENDIF
   

   
   ;;
   ;; AR[2] parameter : x(i) = c + a1*x(i-1) + a2*x(i-2) + white_noise(i)
   ;;
   
   ;; check if the AR parameter-keywords are set (if relaxation and
   ;; period ,a1 and  a2 are set the two latest are ignore)  
   IF keyword_set(relaxation) THEN  BEGIN 
       r  = double(relaxation)      ; damping rate in bins 
       a2 = -exp(-2./r)
   ENDIF 
   IF keyword_set(period) THEN BEGIN
       T  = double(period)
       a1 = 2.*exp(-1./r)*cos(2.*!pi/T)
   ENDIF 
   cond1 = n_elements(relaxation)+n_elements(period)
   cond2 = n_elements(a1)+n_elements(a2)
   IF (cond1 EQ 0) AND (cond2 EQ 0) THEN BEGIN 
       print,' Warning : AR[2] parameters are not set '
       stop
   ENDIF 
   a1 = double(a1)
   a2 = double(a2)
   IF keyword_set(c) THEN c = double(c) ELSE c = 0.
   IF keyword_set(sig) THEN sig = double(sig) ELSE sig = 1.0 

   ;;
   ;; lightcurve (lc) parameters
   ;;
   
   ;; dimension of lc in bins  (wished length plus 100 times the damping
   ;; rate if it are set, otherwise the half length are added)
   IF keyword_set(relaxation) THEN npt = long(n_elements(time)+0.*relaxation) ELSE npt =  long(n_elements(time) + (n_elements(time)/2.))

   ;; bintime                                       
   bt = double(time(1)-time(0))
   
   ;; starting components
   x = dblarr(npt)                 
   x(0:1) = 0.
   
   ;; white noise component
   noise = sqrt(sig)*randomn(seed,npt)
   
   ;; time series
   orate = dblarr(npt)          ; time series
   orate(0:1) = x(0:1)
   FOR i=2L,npt-1,1 DO BEGIN
       x(i) = c + a1*x(i-1) + a2*x(i-2) + noise(i)  
       orate(i) = x(i)
   ENDFOR
   
   ;; time series with wished length
   IF keyword_set(relaxation) THEN rate = orate( long(0.*relaxation) : npt-1) ELSE rate = orate( long(n_elements(time)/2.) : npt-1 ) 
   npt=n_elements(time)
   
   ;;
   ;; mean : mu = c / (1-a1-a2)
   ;;
   mu = c / (1.-a1-a2)

   ;;
   ;; variance : sigma^2 = sig*(1-a2)/[(1+a2)*[(1-a2)^2-a1^2]]
   ;;
   var = [sig * (1.-a2)] / [ (1.+a2) * [ (1.-a2)^2. - a1^2. ] ]
   
   ;;
   ;; theoretical AR[2] spectrum
   ;;
   freq = ((findgen(npt/2))+1.d) / (double(npt*bt)) ; frequency in Hz
   cos2 = double(cos( 2. * !pi * freq ))
   cos4 = double(cos( 4. * !pi * freq ))
   spec = sig / (1.d + a1*a1 + a2*a2 + 2.d *(a1*a2-a1)*cos2 - 2.d *a2*cos4 )

   ;; normalization of the theoretical spectrum
   IF sum EQ 0 THEN spectrum = spec

   
   IF (mu EQ 0) THEN avg = mean(rate) ELSE avg = mu
   IF (keyword_set(schlittgen)) THEN BEGIN 
       spectrum = spec / double(npt)
   ENDIF 
   IF (keyword_set(leahy)) THEN BEGIN
       IF avg LT 0 THEN BEGIN 
           print,' Warning! : negative mean. Instead of leahy, '+ $
             'miyamoto normalization is take '
           miyamoto=1
       ENDIF ELSE spectrum = (2.d *spec*bt) / (avg*double(npt))
   ENDIF 
   IF (keyword_set(miyamoto)) THEN BEGIN
       spectrum = (spec*bt) / ((avg^2.)*double(npt))
   ENDIF
   
   return 
END











