PRO readgti,starttimes,stoptimes,name,mjd=mjd
;+
; NAME:
;       readgti
;
;
; PURPOSE:
;       read a gti file and return the start and stoptimes
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;       readgti,startimes,stoptimes,filenam,/mjd
;
; 
; INPUTS:
;       filename : name of the gti file to be read
;
;
; OPTIONAL INPUTS:
;       
;
;	
; KEYWORD PARAMETERS:
;       mjd : if set, return times as MJD values
;
;
; OUTPUTS:
;       starttimes : an array containing the starttimes in that gti file
;       stoptimes  : an array containing the stoptimes in that gti file
;
;
; EXAMPLE:
;       readgti,start,stop,'good.gti'
;
;
; MODIFICATION HISTORY:
;       Version 1.0: written 1996 by Ingo Kreykenbohm
;       Version 1.1: 1998/08/07, Joern Wilms: added mjd-keyword
;       Version 1.2: 1999/01/25, JW/KP: reduce roundoff errors, read
;             mjdrefi and mjdreff from extension
;-


   tab=readfits(name,head,/exten)

   starttimes=tbget(head,tab,'START')
   stoptimes=tbget(head,tab,'STOP')

   IF (keyword_set(mjd)) THEN BEGIN 
       mjdrefi=0.d0
       mjdreff=0.d0
       getpar,head,'MJDREFI',mjdrefi
       getpar,head,'MJDREFF',mjdreff
       starttimes = (starttimes/86400D0+double(mjdreff))+double(mjdrefi)
       stoptimes  = (stoptimes/86400D0+double(mjdreff))+double(mjdrefi)
   ENDIF 

END
