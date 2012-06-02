PRO rebinlc,time,rate,tn,rn,dt=dt,tstart=tstart,chatty=chatty,raterr=raterr, $
            ern=ern,numperbin=numperbin,minnum=minnum,gaps=gaps, $
            usetime=usetime,devn=devn
;+
; NAME:
;       rebinlc
;
;
; PURPOSE:
;       rebin a time series to a new, evenly spaced, time binning
;
;
; CATEGORY:
;       time series analysis
;
;
; CALLING SEQUENCE:
;       rebinlc,time,count,tn,rn
;
; 
; INPUTS:
;       time : The times of the original light curve. Must be sorted.
;       rate : The count RATES of the original light curve,
;              rate(i) corresponding to time(i)
;      
;
; OPTIONAL INPUTS:
;     nonequally spaced timing:
;       usetime: array with times onto which to bin the lightcurve,
;               the last element contains the end of the last bin
;     equally spaced timing:
;       dt    : the temporal resolution of the rebinned lightcurve
;               (default is a resolution of 100th of the length of the
;               original lightcurve)
;       tstart: start time of the rebinned lightcurve, default is the
;               first value of the time array.   
;     others:
;       raterr: uncertainty of the input light-curve
;       minnum: min. number of data points in each time bin. When
;               this number is smaller than minnum, the bin is left
;               empty. 
;      
; KEYWORD PARAMETERS:
;       chatty: if set, print out lots of annoying messages
;       gaps  : if set, give the time series with zero counts in
;               the bins without events.
;       devn  : if set, compute the uncertainty of the rebinned
;               lightcurve (ern parameter) as the standard deviation
;               of the points entering that bin of the lightcurve,
;               rather than using error propagation
;
; OUTPUTS:
;       tn,rn: The rebinned light-curve. This light curve can contain
;              gaps, which are defined to be all time intervals in the
;              original lightcurve longer than dt, which don't contain
;              any data.
;
;
; OPTIONAL OUTPUTS:
;       ern       : Uncertainty of the output-lc, either computed from
;                   error propagation of raterr (default), or computed
;                   as the standard deviation of the points entering
;                   the bin (if devn-keyword is set; raterr is not used)
;       numperbin : number of points used in each bin   
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
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;       Version 1.0, 1998/06/30 KP / JW (IAA Tuebingen)
;       Version 1.1, 1998/07/07 JW / SB (IAA Tuebingen)
;         * added minnum parameter
;         * added nn keyword parameter
;       Version 1.2, 1999/02/09 SB 
;         * added gaps keyword parameter  
;       Version 1.3, 1999/05/26 KP   
;         * added tstart keyword parameter   
;       Version 1.4, 1999/10/27 JW
;         * bug fix in last line from MN
;       Version 1.5, 1999/11/09 JW
;         * exit with an error message if the lightcurve is too short.
;       Version 1.6, 1999/11/25 SB
;         * added numperbin optional output
;       Version 1.7, 1999/11/26 SB
;          * nn optional output eliminate (nn = numperbin)
;   CVS Version 1.6, 2001/03/23, JW
;          * added usetime keyword
;   CVS Version 1.7, Apr 20 2001, Sara Benlloch
;          * long set
;   CVS Version 1.8, 2002/01/17, Thomas Gleissner (IAA Tuebingen)
;          * added devn keyword
;   CVS Version 1.9, 2002/01/18, TG
;          * solve STDDEV(rate[index]) if n_elements(rate[index]) EQ 1
;   CVS Version 1.10, 2002/01/22, TG/JW
;          * return standard deviation in ern keyword if devn is set
;            rather than returning the standard deviation in the devn
;            keyword 
;   CVS Version 1.11, 2002/01/22, TG
;          * eliminate 'Type of end does not match'-error: set ENDIF
;            instead of ENDELSE in line 161
;   CVS Version 1.12, 2002/10/31, TG
;          * correct allocation of numperbin
;          * use vector notation for time bin limits to make sure that
;            the upper limit of time bin [i] is equal to the lower limit
;            of time bin [i+1]
;   CVS Version 1.13, 2002/10/31, TG
;          * just some unrelevant cosmetic change
;   CVS Version 1.14, 2002/12/11, TG
;          * if usetime keyword is used, do not create time bin limits
;            tlimit
;-

   t=double(time)
   
   IF (n_elements(usetime) EQ 0) THEN BEGIN 
       IF (n_elements(tstart) EQ 0) THEN BEGIN 
           ts=t(0)
       ENDIF ELSE BEGIN 
           ts=double(tstart) 
       ENDELSE 
       IF (n_elements(dt) EQ 0) THEN dt=(t[n_elements(t)-1]-ts)/100.
       num=long((t[n_elements(t)-1]-ts)/dt+1.)
   END ELSE BEGIN 
       num=n_elements(usetime)-1
   END 
   
   IF (n_elements(minnum) EQ 0) THEN minnum=1
   
   tn=dblarr(num)
   rn=dblarr(num)
   numperbin=intarr(num)

   IF (keyword_set(devn) OR (n_elements(raterr) NE 0)) THEN BEGIN 
       ern=dblarr(num)
   ENDIF 

   IF (n_elements(usetime) EQ 0) THEN BEGIN 
     ;; Use vector notation for time bin limits
     tlimit=ts+dt*findgen(num+1)
   ENDIF 

   k=0L
   FOR i=0L,num-1 DO BEGIN 
     IF (n_elements(usetime) EQ 0) THEN BEGIN 
       tn[k]=tlimit[i]
       index=where((t ge tlimit[i]) AND (t lt tlimit[i+1]),number)
     END ELSE BEGIN 
       tn[k]=usetime[i]
       index=where((t GE usetime[i]) AND (t LT usetime[i+1]),number)
     END 
     numperbin[k]=number
     IF (number GE minnum) THEN BEGIN 
       rn[k]=total(rate[index])/number
       IF keyword_set(devn) THEN BEGIN
         ;; compute error from standard deviation if requested
         ;; (return 0 if only one point --> good idea? should
         ;; return a NAN?!?
         IF (number GT 1) THEN BEGIN
           ern[k]=STDDEV(rate[index])
         ENDIF
       ENDIF ELSE BEGIN 
         ;; ... or from error propagation
         IF (n_elements(raterr) NE 0) THEN BEGIN 
           ern[k]=sqrt(total(raterr[index]^2))/number
         ENDIF 
       ENDELSE 
       k=k+1
     ENDIF ELSE BEGIN
       IF (keyword_set(chatty)) THEN BEGIN 
         print,'Empty time bin, rebinned index: ',i
       END 
       IF (keyword_set(gaps)) THEN BEGIN 
         rn[k]=0
         numperbin[k]=0
         k=k+1
       ENDIF 
     ENDELSE 
   ENDFOR
   
   IF (k EQ 0) THEN BEGIN 
       message,"Rebinned lightcurve would not contain any data"
   ENDIF 
   
   IF (k NE num) THEN BEGIN
       IF (keyword_set(chatty)) THEN BEGIN 
         print,'There are ',num-k,' empty bins'
       END 
       tn=tn[0:k-1] & rn=rn[0:k-1] & numperbin=numperbin[0:k-1]
       IF (keyword_set(devn) OR n_elements(raterr) NE 0) THEN ern=ern[0:k-1]
   END 
END 











