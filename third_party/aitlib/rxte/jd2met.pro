FUNCTION jd2met,jd,mjd=mjd
   ;;
   ;; convert (M)JD to MET
   ;;
   jjd=double(jd)
   IF (NOT keyword_set(mjd)) THEN jjd=jd-2400000.5D0
   met=(jjd-6.965740740000D-04-49353D0)*86400D0
   return,met 
END 
