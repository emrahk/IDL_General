;
; Multiply a spectrum with a number
;
FUNCTION mulspec, sp1, number
   mul = replicate(sp1,1)
   mul.f(*) = sp1.f(*)*number
   ;;
   ;; Do not multiply saturated values
   ;;
   IF (sp1.sat GT 0.) THEN BEGIN
       tmp = where(sp1.f GT sp1.sat)
       IF (tmp(0) NE -1) THEN mul.f(tmp)=mul.sat
   ENDIF 
   mul.desc = "("+sp1.desc + ") * "+string(number)

   return, mul
END 

