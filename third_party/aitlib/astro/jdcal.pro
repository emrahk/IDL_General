PRO jdcal,jd,da,mo,y,h,m,s,mjd=mjd
   ;;
   ;; Compute the dmy from the jd using the algorithm given
   ;; by meeus.
   ;; J.W., 1997
   ;;

   IF (keyword_set(mjd)) THEN BEGIN 
       z = long(jd)
       f = jd - z
       z = z+2400000L 
   END ELSE BEGIN 
       z = long(jd+0.5D0)
       f = jd+0.5D0 - z
   END 

   alp = fix((z-1867216.25)/36524.25)

   a = z+1.+alp-fix(alp/4.)
   b = a+1524.
   c = fix((b-122.1)/365.25)
   d = fix(365.25*c)
   e = fix((b-d)/30.6001)

   day = b-d-fix(30.6001*e)+f

   da = fix(day)
   IF (e LT 13.5) THEN mo=e-1 ELSE mo=e-13.
   IF (mo GT 2.5) THEN y=c-4716. ELSE y=c-4715.

   day = day - fix(day)
   h  = fix(day*24.)
   day = day*24.- h
   m  = fix(day*60.)            
   day = day*60. - m
   s  = day*60.
END 
