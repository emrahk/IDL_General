;
; Rebin Spectrum sp1 such that its energy-binning is that of
; sp2; we do that in the flux-space, by simple interpolation
;
FUNCTION rebinspec, spe1, sp2
   on_error, 1

   tmp = where(spe1.e NE sp2.e)
   IF (tmp(0) EQ -1) THEN return, spe1

   sp1 = spe1
   spec2fnu, sp1

   reb = sp2
   reb.flux = 1
   reb.f(*) = 0.
   reb.sat = sp1.sat
   reb.desc= sp1.desc + ' rebinned to resolution of '+sp2.desc
   ;;
   ;; The rebinning step
   ;;
   FOR i = 0, reb.len-1 DO BEGIN
       ;;
       ;; Search for energy-interval
       ;;
       j = min(where(sp1.e GT reb.e(i)))-1
       ;;
       ;; Interpolate linearily
       ;;
       reb.f(i)=reb.sat
       IF ((j GT 1) AND (j LT sp1.len-1))  THEN BEGIN
           reb.f(i)=sp1.f(j)+ (sp1.f(j+1)-sp1.f(j))* $
                              (reb.e(i)-sp1.e(j))/(sp1.e(j+1)-sp1.e(j))
           IF (sp1.sat GT 0) THEN BEGIN 
               IF ((sp1.f(j) GE sp1.sat) OR (sp1.f(j+1) GE sp1.sat)) THEN  $
                BEGIN
                   reb.f(i)=reb.sat
               END
           END 
       ENDIF
   ENDFOR 

   ;;
   ;; Change spectrum back to initial type
   ;;
   spec2type, reb, spe1.flux
   return, reb
END 
