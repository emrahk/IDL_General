PRO readlc,time,count,error,name,bary=bary,mjd=mjd,timerange=timerange, $
           counts=counts
;+
; NAME:
;       readlc
;
;
; PURPOSE:
;       Read a FITS lightcurve 
;
;
; CATEGORY:
;       lightcurves, FITS
;
;
; CALLING SEQUENCE:
;       readlc,time,rate,error,filename,/bary,/mjd,timerange=[min,max] 
;       readlc,time,rate,filename,/bary,/mjd,/time         
; 
; INPUTS:
;       FILENAME: Name of the lightcurve to be read
;       
;
; OPTIONAL INPUTS:
;       min,max: timerange of the lightcurve to be read 
;
;	
; KEYWORD PARAMETERS:
;       /mjd   : calculates the Modified Julian Date from the data in
;       the lightcurve and return this time instead of Mission Elapsed
;       Time in the time column
;       /bary  : read the barycenter corrected timecolumn instead. If
;       no such column is present, a warning is printed and the normal
;       timecolumn is read
;       /counts: The lightcurve contains COUNTS/BIN, not the timerate
;
; OUTPUTS:
;       time : the time column of the lightcurve
;       rate : the measured counting rate (resp. photon-number if the
;              counts keyword is set) column
;
; OPTIONAL OUTPUTS:
;       error  : the uncertainty of the count-rate
;
; RESTRICTIONS:
;       readlc needs LOTS of memory - this results in problems
;                                     with huge lightcurves
;
;
; PROCEDURE: 
;
;
;
; EXAMPLE:
;       readlc,time,rate,error,'vela.lc',timerange=[0,1000]
;
;
; MODIFICATION HISTORY:
;       v1.0 written 1996 by Ingo Kreykenbohm, AIT
;       v2.0 1997/03/04 I.K., J.W.: made error an optional argument to
;                     save memory and time; further small
;                     optimizations
;       v2.1 2000/01/20 Joern Wilms: added counts keyword
;       v2.2 2000/06/15 JW: cosmetic change in documentation
;    CVS Version 1.3 Joern Wilms, 2001/03/22
;       improved handling of mjd keyword (now takes into account time
;       column in units other than seconds, improved reading of the
;       MJDREF keyword and its companions).
;-

   ;; v2.0
   ;; If the 3rd argument is not an array and a string, then we don't
   ;; want the errors to be read (let's hope this trick also works with
   ;; the parameters...) 
   ;;
   noerror=0
   esiz=size(error)
   IF (esiz(0) EQ 0 AND esiz(1) EQ 7) THEN BEGIN 
       noerror=1
       name=error
   ENDIF
   ;; end of v2.0 changes

   IF (n_elements(timerange) NE 2) THEN BEGIN 
       ;; no timerange is given, so read the complete lightcurve
       tab=readfits(name,h,/exten)
       IF (keyword_set(counts)) THEN BEGIN
           count=tbget(h,tab,'COUNTS')
       END ELSE BEGIN 
           count=tbget(h,tab,'RATE')
       END 
       IF (noerror EQ 0) THEN error=tbget(h,tab,'ERROR')
       IF (keyword_set(bary)) THEN BEGIN
           i=strpos(h,'BARYTIME',0)
           idx = where(i GE 0)
           IF (idx(0) GE 0) THEN BEGIN
               time = tbget(h,tab,'BARYTIME')
           END ELSE BEGIN 
               print,'Warning : No Barytime found. Returning normal time !'
               time = tbget(h,tab,'TIME')
           END 
       END ELSE BEGIN 
           time=tbget(h,tab,'TIME')
       END  
    
   END ELSE BEGIN 
       ;; read a given part of the lightcurve.
       ;; First you have to determine in which rows the timerange is found
       print,'Identifying timerange...'
       ;; open the file and read the header
       fxbopen,unit,name,1,hdr
       ;; determine how many rows there are
       num = sxpar(hdr,'NAXIS2')
       start = 1
       rstart = -1
       rstop = -1
       WHILE (start LT num) DO BEGIN 
           stop = start + 10000L
           IF stop GT num THEN stop = num
           print,fix(double(start)/double(num)*100.),'% completed'
           ;; read a 10000 row block and look for the timerange
           fxbread,unit,ttime,'TIME',[start,stop]
           IF rstart EQ -1 THEN BEGIN 
               r1 = where(ttime GT timerange(0))
               IF r1(0) NE -1 THEN rstart = r1(0)+start
           ENDIF 
           IF rstop EQ -1 THEN BEGIN 
               r1 = where(ttime GT timerange(1))
               IF r1(0) NE -1 THEN BEGIN
                   rstop = r1(0)+start
                   stop = num + 1
               ENDIF 
           ENDIF
           start = stop
       ENDWHILE 
       IF (rstart EQ -1) OR (rstop EQ -1) THEN BEGIN
           print,'TIMERANGE not found in this lightcurve.'
           return 
       ENDIF 
       ;; now read in the above determined rows
       range = [rstart,rstop]
       fxbread,unit,time,'TIME',range
       IF (keyword_set(counts)) THEN BEGIN 
           fxbread,unit,count,'COUNTS',range
       END ELSE BEGIN 
           fxbread,unit,count,'RATE',range
       END 
       IF (noerror EQ 0) THEN fxbread,unit,error,'ERROR',range
       fxbclose,unit
   END 

   ;; return time as modified julian date if possible
   IF (keyword_set(mjd)) THEN BEGIN 
       mjdrefi=0.d0
       mjdreff=0.d0
       head=headfits(name,exten=1)
       ;;
       ;; unit of count or rate column
       ;;
       
       tunit=strtrim(fxpar(head,'TUNIT*',count=num),2)
       
       ;; no units: assume seconds
       IF (num EQ 0) THEN BEGIN 
           time = time/86400D0
       END ELSE BEGIN 
           ttype=strtrim(fxpar(head,'TTYPE*'),2)
           ;; ... find unit of TIME column
           ndx=where(ttype EQ 'TIME')
           ;; get unit
           tunit=tunit[ndx[0]]
           
           ;; convert to days if necessary
           IF (tunit EQ 's') THEN BEGIN 
               time=time/86400D0
           END 
       END 
    
       ;;
       ;; Possible offset to MJD
       ;;
    
       ;; first check for long form of mjfref parameter
       mjdrefi=fxpar(head,'MJDREFI',count=num)
       IF (num NE 0) THEN BEGIN 
           mjdreff=fxpar(head,'MJDREFF')
           time = (time+double(mjdreff))+double(mjdrefi)
       END ELSE BEGIN 
           mjdref=fxpar(head,'MJDREF',count=num)
           IF (num GT 0) THEN time=time+mjdref
       END 
    
   ENDIF 

END 
