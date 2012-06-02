;
; Saturate spectrum: set all values below fmi to saturation value
;
pro saturate, spec, fmi
   on_error, 1
   if (spec.sat lt 0.) then spec.sat = 10.*max(spec.f(0:spec.len-1))
   tmp = where(spec.f(*) lt fmi)
   if (tmp(0) ne -1) then spec.f(tmp)=spec.sat
end
