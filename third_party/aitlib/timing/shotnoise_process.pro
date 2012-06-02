
PRO  shotnoise_process,time,rate                                             $
                       ,freq=freq,spectrum=spectrum,lag=lag,acf=acf,var=var  $
                       ,relaxation=relaxation,shotn=shotn,shoth=shoth        $
                       ,schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto 
;+
; NAME:
;         shotnoise_process
;
;
; PURPOSE:
;         return a Standard Shot Noise model evenly time series
;            s(t) = SUM_{i} h(t-t(i)) where h(t) = exp(-t/tau)*U(t) 
;            with U(t) = {0 for t let than 0,h0 for t great equal 0}   
;
; CATEGORY:
;         timing tools
;
;
; CALLING SEQUENCE:
;         shotnoise_process,time,rate,relaxation=relaxation,shotn=shotn
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
;         relaxation : parameter value of the Shot Noise  process ;
;                      relaxation time of the shot in bins
;         shotn      : maximal number of shots in the light curve
;         shoth      : mean shot height (if not set, equal 1.0)
;         schlittgen : if set, return theoretical spectrum in
;                      Schlittgen normalization (Schlittgen, H.J.,
;                      Streitberg, B., 1995, Zeitreihenanalyse, R. Oldenbourg)
;         leahy      : if set, return theoretical spectrum in Leahy
;                      normalization (Leahy et al. 1983, Ap.J. 266, 160)
;         miyamoto   : if set, return theoretical spectrum in Miyamoto
;                      normalization (Miyamoto et al. 1992, Ap.J. 391, L21)
;
; OUTPUTS:
;         rate       : count rate array of the Shot Noise lightcurve
;
; OPTIONAL OUTPUTS:
;         freq       : fourier frequency sample (in Hz)
;         spectrun   : theoretical density spectrum to each frequency
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
;         none
;
;
; PROCEDURE:
;         uses the idl-randomn function
;
;
; EXAMPLE:
;         shotnoise_process,time,rate,relaxation=50.,shotn=10
;
; MODIFICATION HISTORY:
;         Version 1.0, 1999.01.12, Sara Benlloch (IAAT)
;                                 (benlloch@astro.uni-tuebingen.de)   
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
   ;; lightcurve (lc) parameters
   ;;
   
   ;; dimension of lc in bins  ( wished length plus 100 bins )
   npt = n_elements(time)+100  
   
   ;; bintime
   bt = double(time(1)-time(0))
   
   ;;
   ;; Shot Noise parameters : s(t) = SUM_{i} h(t-t(i)) where for
   ;;         the Standard Shot Noise Model is  h(t) = exp(-t/tau)*U(t) with
   ;;         U(t)={0 for t let than 0, h0 for t great equal 0}
   ;;
   
   ;; Relaxation time in bins 
   tau = double(relaxation)       
   
   ;; Mean distance between shots 
   dtmean = double(npt)/double(shotn) 
   
   ;; Shot Noise profile
   IF keyword_set(shoth) THEN h0 = double(shoth) ELSE h0 = 1.
   shot = findgen(npt) 
   shot = exp(-shot(*)/tau)*h0  
   shot = shot(where(shot GT 1e-10))
   dimshot = n_elements(shot)
   
   ;;
   ;; Shot Noise time series
   ;;
   orate = dblarr(npt)
   
   ;; Poisson-distributed shot events ( with parameter lambda = '1/dtmean' )
   nsh = 0
   shotstart = 0.
   while (nsh le shotn or shotstart le npt) do begin
       r = randomu( seed )
       dt = -alog(r) * dtmean   ; dt is Poissson-distribute
       shotstart = shotstart + dt ; shot start-time
       index = long(shotstart)
       IF index LT npt-1 THEN BEGIN 
           stopindex = index + dimshot - 1
           IF (stopindex GT npt-1) THEN stopindex = npt - 1
           orate(index:stopindex) = orate(index:stopindex) + $
             shot(0:stopindex-index)
       ENDIF 
       nsh = nsh + 1.
   ENDWHILE
   
   ;; time series with wished length
   rate = orate(100 : npt-1)
   npt = n_elements(time)
   
   ;;
   ;; theoretical variance
   ;;
   var = h0^2 * tau/(dtmean*2.)

   ;;
   ;; theoretical autocorrelation for Shot Noise process
   ;;
   acf = dblarr(npt)        
   FOR lag=0,npt-1 DO BEGIN     ; ( lag = 0,...,npt-1 ) 
       acf[lag] = exp(-double(lag)/tau)
   END 
   lag = bt * findgen(npt)    
   
   ;;
   ;; theoretical Shot Noise spectrum
   ;;
   freq= ((findgen(npt/2.))+1.) / (double(npt)*bt) ; frequency in Hz
   pi = 4.*atan(1.)
   spec  = h0^2. * (1./dtmean) / ((1./tau)^2+(2.*pi*freq)^2.)
   
   ;; normalization of the theoretical spectrum
   avg = mean(rate)
   IF (keyword_set(schlittgen)) THEN BEGIN 
       spectrum = spec / double(npt)
   ENDIF 
   IF (keyword_set(leahy)) THEN BEGIN
       IF avg LT 0 THEN BEGIN 
           print,' Warning! : negative mean. Instead of leahy, '+ $
             'miyamoto normalization is take '
           miyamoto = 1
       ENDIF ELSE spectrum = (2.*spec*bt) / double(avg*npt)
   ENDIF 
   IF (keyword_set(miyamoto)) THEN BEGIN
       spectrum = (spec*bt) / ((avg^2.)*double(npt))
   ENDIF
      
   return 
END 





