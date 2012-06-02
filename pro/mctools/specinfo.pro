;
; Return information about spectrum
; fmin: min flux, not counting 0's
; fmax: max flux, not counting saturated values
; empty: 1 if Spectrum does not contain any values (HAS TO BE FLOAT!)
;
pro specinfo, sp, fmin, fmax, empty
   on_error, 1
   ;;
   max_val = 1E30
   if (sp.sat gt 0.) then max_val = sp.sat
   ;;
   fmax = 1E30
   fmin = 0.
   empty=1.
   ;;
   IF (sp.len GT 0) THEN BEGIN
       ff = sp.f(0:sp.len-1)
       valid = where((ff gt 0.) and (ff lt max_val))
       if (valid(0) ne -1) then begin
           fmax = max(ff(valid))
           fmin = min(ff(valid))
           empty=0.
       ENDIF 
   ENDIF 
END 

