;; writelcdata - write out lightcurve ascii data
;; $Log: writelcdata.pro,v $
;; Revision 1.1  2003/03/31 09:21:41  goehler
;; added write lightcurve function
;;
PRO writelcdata,file,time,rate,error,title=title,tdescr=tdescr

;; create dummy error if missing:
IF n_elements(error) EQ 0 THEN $
  error = make_array(n_elements(time),/double,value=1.)


; write data:
outfile=file
 get_lun, outlun
 openw,outlun,outfile
   printf,outlun,"# File:"+outfile
   IF n_elements(title) NE 0 THEN printf,outlun,"# Contains:"+title
   printf,outlun,"# Time: "+tdescr

   ;; print data with/without errors:
   IF n_elements(error) EQ 0 THEN BEGIN    
       printf,outlun,"# Time  Rate"
       printf,outlun,transpose([[time],[rate]]),format="(F18.10)"
   ENDIF ELSE BEGIN 
       printf,outlun,"# Time  Rate   Error"
       printf,outlun,transpose([[time],[rate],[error]]),format="(3F18.10)"
   ENDELSE 

 close,outlun
free_lun,outlun

END

