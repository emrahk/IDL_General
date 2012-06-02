;
; Create f(nu)-spectrum
;
PRO spec2fnu, spec
   on_error, 1
   if (spec.flux eq 0) then begin
       de=shift(spec.e(*),-1)-spec.e(*)
       spec.f(0:spec.len-1) = spec.e(0:spec.len-1)*spec.f(0:spec.len-1)/de(0:spec.len-1)
       spec.err(0:spec.len-1) = spec.e(0:spec.len-1)*spec.err(0:spec.len-1)/de(0:spec.len-1)
   endif
   if (spec.flux eq 2) then begin
       spec.f(0:spec.len-1) = spec.f(0:spec.len-1)/spec.e(0:spec.len-1)
       spec.err(0:spec.len-1)=spec.err(0:spec.len-1)/spec.e(0:spec.len-1)
   ENDIF
   IF (spec.flux EQ 3) THEN BEGIN
       spec.f(0:spec.len-1) = spec.e(0:spec.len-1)*spec.f(0:spec.len-1)
       spec.err(0:spec.len-1) = spec.e(0:spec.len-1)*spec.err(0:spec.len-1)
   ENDIF 
   spec.flux = 1
end
