;
; Extract an energy-range from a spectrum
;
function extract, spec, emin, emax
   on_error, 1
   low = 0
   up = 0
   tmp = spec
   if (spec.e(len+1) lt emin) then begin
       tmp.len=0
       return, tmp
   endif
   while (spec.e(low+1) lt emin) do low=low+1
   hi = spec.len+1
   while (spec.e(hi-1) gt emax) do hi=hi-1
   tmp.len = hi-lo
   tmp.e(0:tmp.len+1) = tmp.e(lo:hi+1)
   tmp.f(0:tmp.len) = tmp.f(lo:hi)
   return, tmp
end

