
PRO sf,time,rate,lag,sf,evenly=evenly                      $
       ,delta=delta,logdelta=logdelta,lagsample=lagsample  $
       ,mincouples=mincouples
   
;+
; NAME:
;         sf
;
; PURPOSE:
;         Compute the structure function of a lightcurve, according to the
;         definitions given by Nandikotkur et al., 1997, AIP
;         Conf. Proc 410, 1361P for the evenly case and Paltani et
;         al., 1997 A&A 327, 539P for the unevenly case.
;
; CATEGORY:
;         time series analysis
;
;
; CALLING SEQUENCE:
;         sf,time,rate,lag,sf
;
; INPUTS:
;         time      : The times at which the time series was measured
;         rate      : the corresponding count rates
;
;
; OPTIONAL INPUTS:
;         none
;
;      
; KEYWORD PARAMETERS:
;         delta     : width for the lag rebining in the unevenly case
;                     (if not set, is equal to 1e-6)
;         logdelta  : delta in logaritmic expression   
;         evenly    : if set, compute the estimation of the structure
;                     function for evenly sample data, otherwise
;                     compute the estimation for unevenly sample data
;         lagsample : sample of time lags, if not set, all possible
;                     lags in the time sample are take as lag sample.
;         mincouples: minimum number of couples in a bin of the
;                     structure function not to be ignored, if not set,
;                     is equal to 1.
;
; OUTPUTS:
;         sf        : the "structure function"-values to each time lag
;         lag       : sample of time lags
;
; OPTIONAL OUTPUTS:
;         none
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
;         none
;
;
; PROCEDURE:
;         none
;   
; EXAMPLE:
;         sf,time,rate,lag,sf,delta=2.
;
;
; MODIFICATION HISTORY:
;         Version 1.0, 1998.12.21, Sara Benlloch (IAAT) 
;         Version 1.1, 1999.01.07, lag sample in the unevenly case modificied.
;                                  (benlloch@astro.uni-tuebingen.de)     
;         Version 1.2, 1999.01.26, new keywords; logdelta, lagsample,
;                                  mincoupples.    
;-
   
   ;;
   ;; lightcurve (lc) parameters
   ;;
     
   ;; number of points in the time series
   npt = n_elements(time)  

   ;; subtract mean from data
   rat = rate-mean(rate)
   
   ;;
   ;; Structure Function 
   ;;
   
   IF (keyword_set(evenly)) THEN BEGIN        
   ;; for evenly-sampled discrete time series (ti=i*bint; xi)
       bt = (time(npt-1)-time(0))/(npt-1)
       
       ;; Estimation of the structure function: 
       ;; sf(lag) = 1/npt(tau)SUM_{i=0,...npt-1-lag}(x(i+lag)-x(i))^2 
       ;; the average been taken over all measurements separated by
       ;; the respective lag and npt(lag) being the number of such
       ;; pairs ( Nandikotkur et al., 1997, AIP Conf. Proc 410, 1361P)  
       sf = dblarr(2,npt-1) 
       FOR lag=1L,npt-1 DO BEGIN ; ( lag = 1,...,npt-1 ) 
           sf[1,lag-1] = total((rat[lag:npt-1]-rat[0:npt-1-lag])^2)/(npt-lag)
           sf[0,lag-1] = npt-lag
       END 
       
       ;; Lag sample
       lag = bt*findgen(npt-1)+bt 
       
   ENDIF ELSE BEGIN  
   ;; for unevenly time series (ti,xi),i=1,...npt with arbritary ti
       
       ;; Estimation of the structure function:
       ;; sf(lag,delta)=(1/npt(lag,bin))SUM_{(i,j)/R}[xj-xi]^2 
       ;; such that npt(lag,delta) is the number of couples
       ;; [(ti,xi);(tj,xj)] that satisfy the relationship 
       ;; R := ( lag-delta/2 < tj-ti < lag+delta/2 )         
       ;; ( Paltani et al., 1997 A&A 327, 539P )
       ;; logarithmic R := | log(|tj-ti|)-log(lag) | <= delta
       
       ;; time and rate couples : tj-ti and xj-xi for all j>i
       t_couple = time-shift(time,1)
       r_couple = rat-shift(rat,1)
       time_couples = t_couple(1:npt-1)
       rate_couples = r_couple(1:npt-1)
       FOR i=2L,npt-1 DO BEGIN
           t_couple = time-shift(time,i)
           r_couple = rat-shift(rat,i)
           time_couples = [time_couples,t_couple(i:npt-1)]
           rate_couples = [rate_couples,r_couple(i:npt-1)]
       ENDFOR
       
       ;; lag sample
       IF keyword_set(lagsample) THEN BEGIN
           lag = lagsample
       ENDIF ELSE BEGIN 
           lag = time_couples(sort(time_couples))
           lag = lag(uniq(lag,sort(lag)))
       ENDELSE 
       
       ;; width for the lag rebining 
       IF (n_elements(delta) EQ 0) THEN delta=1e-6
       
       ;; structur function estimate
       sf = dblarr(2,n_elements(lag))       
       FOR t=0L,n_elements(lag)-1 DO BEGIN      
           
           IF keyword_set(logdelta) THEN BEGIN 
               rel          = abs( alog10(time_couples) - alog10(lag(t)) )
               relationship = where( rel LE  logdelta , count )
           ENDIF ELSE BEGIN 
               relationship = where( (time_couples LT lag(t)+delta/2.) $
                                  AND (time_couples GT lag(t)-delta/2.), count)
               
           ENDELSE 
           
           IF (count NE 0) THEN BEGIN 
               sum = 0.
               sum_couples = rate_couples(relationship)
               FOR h=0L,count-1 DO BEGIN 
                   sum = sum + sum_couples(h)^2.
                   sf(1,t) = (1./count)*sum
               ENDFOR 
           ENDIF ELSE BEGIN 
               sf(1,t)=0.
           ENDELSE
           sf(0,t) = count    
           
       ENDFOR 
       
       result = where( sf(1,*) NE 0. , count )
       
       IF count NE 0 THEN BEGIN 
           lag = lag(result)
           sf  = sf(*,result)
       ENDIF 
       IF keyword_set(mincouples) THEN BEGIN 
           result = where( sf(0,*) GE mincouples , count )
           IF count NE 0 THEN BEGIN 
               lag = lag(result)
               sf  = sf(*,result)
           ENDIF 
       ENDIF     
   ENDELSE 
   return 
   
END 








