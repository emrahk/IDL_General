FUNCTION met2jd,met,mjd=mjd
   ;;
   ;; Convert met to (M)JD
   ;;
   mmjd=6.965740740000D-04+double(met)/86400D0+49353D0

   IF (keyword_set(mjd)) THEN return,mmjd
   return,mmjd+2400000.5D0
END 
