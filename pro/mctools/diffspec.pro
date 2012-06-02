;
; Differentiate a spectrum wrt energy in flux-space
;
FUNCTION diffspec, sp
   on_error, 1

   diff=sp
   sat=sp.sat
   spec2fnu, diff

   FOR i=0, diff.len-1 DO BEGIN
       IF ((sat GT 0) AND ((diff.f(i) EQ sat) OR (diff.f(i+1) EQ sat))) $
         THEN BEGIN
           diff.f(i)=diff.sat
       END ELSE BEGIN 
           diff.f(i)=(diff.f(i+1)-diff.f(i))/(diff.e(i+1)-diff.e(i))
           IF ((diff.sat GT 0) AND (diff.f(i) GT diff.sat))THEN BEGIN
               sa=diff.f(i)*10.
               ndx=where(diff.f(0:i) EQ diff.sat)
               IF (ndx(0) NE -1) THEN diff.f(ndx)=sa
               diff.sat=sa
           ENDIF
       END
   ENDFOR
   return, diff
END 
