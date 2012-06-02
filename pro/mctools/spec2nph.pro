;
; Create Photon-Spectrum
;
pro spec2nph,spec
   on_error, 1
   if (spec.flux eq 0) then begin
       for j=0,spec.len-1 do begin
           spec.f(j)= spec.f(j)/(spec.e(j+1)-spec.e(j))
           spec.err(j)= spec.err(j)/(spec.e(j+1)-spec.e(j))
       endfor
   endif
   if (spec.flux eq 1) then begin
       for j=0,spec.len-1 do begin
           spec.f(j) = spec.f(j)/spec.e(j)
           spec.err(j) = spec.err(j)/spec.e(j)
       endfor
   ENDIF
   IF (spec.flux EQ 2) THEN BEGIN
       FOR j=0,spec.len-1 DO BEGIN 
           spec.f(j) = spec.f(j)/(spec.e(j)^2)
           spec.err(j) = spec.err(j)/(spec.e(j)^2)
       ENDFOR 
   ENDIF 
   spec.flux = 3
end
