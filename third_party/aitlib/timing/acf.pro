
PRO  acf,time,rate,lag,acf,covf=covf
   
;+
; NAME:
;         acf
;
; PURPOSE:
;         Compute the autocorrelation function of an evenly sample lightcurve
;
;
; CATEGORY:
;         time series analysis
;
;
; CALLING SEQUENCE:
;         acf,time,rate,lag,acf,covf
;
; 
; INPUTS:
;         time      : the times at which the time series was measured
;         rate      : the corresponding count rates
;
;
; OPTIONAL INPUTS:
;         none
;
;      
; KEYWORD PARAMETERS:
;         none
;
;
; OUTPUTS:
;         lag       : sample time lags
;         acf       : autocorrelation values to each time lag given in
;                     a two-dimensional array, once without
;                     correction-factor and once with.
;   
; OPTIONAL OUTPUTS:
;         covf      : autocovariance values to each time lag given in
;                     a one-dimensional array.
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
;         evenly time series
;
;
; PROCEDURE:
;         The autocorrelation function is computed according to the
;         approximation of evenly sample given by 
;         covf(lag)=(1/(npt-lag))SUM_{j=1,..npt-lag}[x(j)-<x>][x(j+lag)-<x>]
;         acf(lag)=covf(lag)/covf(0)
;         Additionally, a corection-factor given by Sutherland et
;         al. 1978, Ajp 219, 1029P, is added.  
;   
; EXAMPLE:
;         acf,time,rate,lag,acf,covf=covf
;
;
; MODIFICATION HISTORY:
;         Version 1.0, 1998.12.21, Sara Belloch IAAT, Joern Wilms IAAT.
;                                 (benlloch@astro.uni-tuebingen.de)   
;-
   
   ;;
   ;; lightcurve (lc) parameters
   ;;
   
   ;; dimension of lc in bins 
   npt = n_elements(time) 
   
   ;; Autocorrelation is defined for series with mean zero
   rat = rate-mean(rate)
   
   ;;
   ;; Autocovariance function estimate by 
   ;; covf(lag)=(1/(npt-lag))SUM_{j=1,..npt-lag}[x(j)-<x>][x(j+lag)-<x>]
   ;; 
   covf = dblarr(npt)        
   FOR lag=0,npt-1 DO BEGIN     ; ( lag = 0,...,npt-1 ) 
       covf[lag] = total(rat[0:npt-lag-1]*rat[lag:npt-1]) / (npt-lag)
   END 
   lag = (time[1]-time[0]) * findgen(npt) 
   
   ;;
   ;; Autocorrelation function
   ;; acf(lag)=covf(lag)/covf(0)
   ;;
   acf = dblarr(2,npt)
   acf(0,*) = covf / covf(0)           
   
   ;;
   ;; correction-factors  (Sutherland et al. 1978, ApJ 219, 1029P)
   ;;
   k1 = 1. / npt
   k2 = 1. / (npt*npt)
   FOR i=0,npt-1 DO BEGIN 
       acf(1,i) = acf(0,i) + k1 - float(i)*k2
   ENDFOR 
END 







