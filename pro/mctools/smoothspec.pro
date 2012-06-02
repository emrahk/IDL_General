;
; Smoothspec.pro: Smooth a spectrum by averaging subsequent spectral
; bins.
;  width:  3:          1 2 1
;  width:  5:        
;
FUNCTION smoothspec,spec,width
   tmp = spec
   IF (n_elements(width) EQ 0) THEN width=3

   IF (width EQ 3) THEN BEGIN 
       FOR i=1, spec.len-2 DO BEGIN
           tmp.f(i)=(spec.f(i-1)+2.*spec.f(i)+spec.f(i+1))/5.
       ENDFOR 
   ENDIF
   IF (width EQ 5) THEN BEGIN
       FOR i=2, spec.len-3 DO BEGIN
           tmp.f(i)=(spec.f(i-2)+5.*spec.f(i-1)+10.*spec.f(i)+ $
                     5.*spec.f(i+1)+spec.f(i+2))/22.
       ENDFOR 
   ENDIF 
   return, tmp
END 
  
