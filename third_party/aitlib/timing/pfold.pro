PRO pfold, time,rate,profile,period=period,nbins=nbins,time0=time0, $
           proferr=proferr,gap=gap,nogap=nogap,tolerance=tolerance, $
           phbin=phbin,ttot=ttot, raterr=raterr,chatty=chatty,npts=npts, $
           quantiles=quantiles, statquant=quant,dt=dt
;+
; NAME:
;       pfold
;
;
; PURPOSE:
;       folds a lightcurve with a given period and returns the resulting
;       profile
;
;
; CATEGORY:
;       lightcurve
;
;
; CALLING SEQUENCE:
;       pfold,time,rate,profile,period=period,nbins=nbins,time0=time0,
;             nbins=nbins,proferr=proferr,phbin=phbin,ttot=ttot, 
;             quantiles=quantiles,quant=quant,dt=dt
; 
; INPUTS:
;       time    : the starting time of each rate bin
;       rate    : the count rate of each bin
;
;
; OPTIONAL INPUTS:
;       nbins   : the number of bins to use
;       time0   : use time0 instead of the first entry in the
;                 timecolumn as zerotime of phase bin
;       gap     : An array containing the indices of gaps in the
;                 lightcurve (i.e. time(gap(2)) is the starting time
;                 of the 3rd gap in the lightcurve). If gap is not
;                 given and nogap is not set, the code determines gap
;                 using the subroutine timegap
;       raterr  : uncertainty of the counting rates in rate(*)
;       dt      : width of each time bin   
;      tolerance: parameter defining the lower limit for the gap
;                 length; the reference is the time difference
;                 between the first and second entry in the time
;                 array; tolerance defines the maximum allowed relative
;                 deviation from this reference bin length; 
;                 default: 1e-8; this parameter is passed to timegap
;                     (see timgap.pro for further explanation)
;
;	
; KEYWORD PARAMETERS:
;       nogap   : If set, the lightcurve is assumed to NOT contain any
;                 bins
;       quantiles: If set, return the 1st,2nd, and 3rd quantile in 
;                 keyword statquant
;
; OPTIONAL OUTPUTS:
;       proferr : Array containing the statistical uncertainty of each
;                 bin of the profile.
;       phbin   : array containing the start-phase of each bin of the
;                 profile
;       ttot    : array containing the total observing time
;                 accumulated in each bin of the profile
;       npts    : total number of rate points in each bin of the
;                 profile
;       statquant: a 2d array, quant(0,*) contains the 1st, quant(1,*)
;                 the 2nd, and quant(2,*) the 3rd quantile for each
;                 pulse point.
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
;       nbins=128
;       pfold,time,counts,profile,283.,nbins=nbins
;       phase=findgen(nbins)/(nbins-1)
;       plot,phase,profile
;
;
; MODIFICATION HISTORY:
;       Version 1.0: Derived from foldlc, Joern Wilms, 1998/05/14
;       Version 1.1: J.W., 1998/08/09, added quantile keyword
;       Version 2.0: J.W., 1999/08/04:
;          * now use the histogram function for determining the
;            countrates contributing to each phase bin
;            (speed improvement roughly a factor of 20%)
;          * compute width of time bins only if desired
;            (slight speed improvement)
;       CVS Version 1.2: JW/PR, 2001.07.20
;          code now produces exact results in case time-time0 is negative
;       CVS Version 1.3: MK, 2001.10.18
;          added keyword tolerance
;       Version 1.4: JW, 2002.02.12
;          repaired tolerance keyword. now calls with tolerance eq
;          0. are possible
;       Version 1.5: JW/SF, 2002.08.15
;          correction of code in the example
;
;-

   IF (time[0] EQ 0. AND n_elements(time0) NE 0) THEN BEGIN 
      message,'time[0]=0 and you have set a time0; this will',/informational
      message,'most probably not give the result you expect.',/informational
   ENDIF 

   IF (n_elements(time0) EQ 0) THEN time0=time(0)
   IF (n_elements(nbins) EQ 0) THEN nbins=20.

   ;; Set gap tolerance to default value 
   IF (n_elements(tolerance) EQ 0) THEN BEGIN 
       ttol=1e-8 
   ENDIF ELSE BEGIN 
       ttol=tolerance
   ENDELSE 
   

   ; disable chatty if not set
   IF (n_elements(chatty) EQ 0) THEN chatty=0


   ;; Width of each time-bin, take care of wrap-around
   IF (n_elements(dt) EQ 0) THEN BEGIN 
       dt=temporary(shift(time,-1))-time
       dt(n_elements(time)-1)=dt(0)
   ENDIF 
   
   ;;
   ;; Compute phase of each timebin
   ;;
   phase = ((time-time0) MOD period)/period

   ;; take care of case that there could be times with time < time0
   ndx=where(phase LT 0.,nummin)
   IF (nummin NE 0) THEN phase[ndx]=phase[ndx]+1.

   ;;
   ;; If lc  contains gaps: mark them invalid
   ;;
   IF (NOT keyword_set(nogap)) THEN BEGIN 
       IF (n_elements(gap) EQ 0) THEN BEGIN 
           timegap,time,gap,dblock,tolerance=ttol,chatty=chatty
       ENDIF 
       IF (gap(0) NE -1) THEN phase(gap)=2.
   END 

   profile=fltarr(nbins)
   proferr=fltarr(nbins)
   ttot=fltarr(nbins)
   npts=lonarr(nbins)
   IF (keyword_set(quantiles)) THEN BEGIN 
       quant=fltarr(3,nbins)
   ENDIF 
   ;;
   phbin=findgen(nbins+1)/nbins
   
   dummy=histogram(phase,binsize=1./nbins,min=0.,max=1., $
                   reverse_indices=r)
   FOR i=0,nbins-1 DO BEGIN 
       IF (r[i] EQ r[i+1]) THEN BEGIN 
           IF (keyword_set(chatty)) THEN BEGIN 
               print, 'Warning: phase '+strtrim(string(i),2)+ $
                 ' contains no bins'
               profile(i)=0.
               ttot(i)=0.
               npts(i)=0
           ENDIF 
       END ELSE BEGIN
           ndx=r[r[i]:r[i+1]-1]
           dte=dt(ndx)
           ttot(i)=total(dte)
           npts(i)=n_elements(ndx)
           ;; need dt because of boundaries and GTI's
           profile(i)=total(rate(ndx)*dte)/ttot(i)
           
           IF (n_elements(raterr) NE 0) THEN BEGIN 
               proferr(i)=sqrt(total((raterr(ndx)*dte)^2.))/ttot(i)
           ENDIF 
           
           ;; compute statistical quantiles if desired
           IF (keyword_set(quantiles)) THEN BEGIN 
               dist=rate(ndx)
               nnn=sort(dist)
               n25=fix(npts(i)*0.25)
               n50=fix(npts(i)*0.50)
               n75=fix(npts(i)*0.75)
               quant(0,i)=dist(nnn(n25))
               quant(1,i)=dist(nnn(n50))
               quant(2,i)=dist(nnn(n75))
           ENDIF 
       END 
   ENDFOR 
   phbin=phbin[0:nbins-1]
END 

