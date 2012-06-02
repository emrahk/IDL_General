FUNCTION caljd,da,mo,y,h,m,s,mjd=mjd
   ;;
   ;; Wrapper for jdcnv
   ;;
   ;; J.W., 1997
   ;;
   jdcnv,y,mo,da,h+m/60D0+s/3600D0,jd
   IF (keyword_set(mjd)) THEN BEGIN 
       return,jd-2400000.5D0
   END 
   return,jd
END 
