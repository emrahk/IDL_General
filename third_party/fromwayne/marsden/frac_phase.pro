pro frac_phase,freq,time,frac,pdot=pdot,ppdot=ppdot,fdot=fdot,$
               ffdot=ffdot
;*************************************************************
; Program calculates the fractional part of the elapsed phase 
; over a time interval. Variables are:
;        f..............frequency
;        t..............time interval (s)
;     frac..............fraction of cycle
;     pdot..............first period derivative
;    ppdot..............second period derivative
;     fdot..............first frequency derivative
;    ffdot..............second frequency derivative
; First do usage:
;*************************************************************
if (n_params() eq 0)then begin
   print,'USAGE:FRAC_PHASE,FREQ,TIME,FRAC,[PDOT=],' + $
         '[PPDOT=],[FDOT=],[FFDOT=]'
   return
endif
;*************************************************************
; Now calculate the phase of each event.
;*************************************************************
szf = size(freq)
if (szf(0) ne 0)then f = double(freq(0)) else f = double(freq)
t = double(time)
if (ks(pdot) eq 0.)then pd = 0d else pd = double(pdot)
if (ks(ppdot) eq 0.)then ppd = 0d else ppd = double(ppdot)
if (ks(fdot) eq 0.)then fd = 0d else fd = double(fdot)
if (ks(ffdot) eq 0.)then ffd = 0d else ffd = double(ffdot)
if (pd gt 0d)then begin
   phase = 1d - (1d/2d)*pd*f*t -(1d/6d)*ppd*f*f*t*t + $
           (2d/6d)*pd*pd*t*t*f*f
   phase = phase*f*t
endif else phase = f*t + fd*t*t/2d + ffd*t*t*t/6d
;*************************************************************
; Must subtract off parts if greater then 10^9, 
; THEN round off. This is designed to combat IDL-induced 
; roundoff error. Be careful with the negative phases.
;*************************************************************
;lt0 = where(phase lt 0d)
;phase = abs(phase)
;in = where(phase gt 2d9)
;ndx = 6d + dindgen(10)
;if(in(0) ne -1)then begin
;   phz_big = phase(in)
;   lg_phz = alog10(phz_big)
;   for i = 0,8 do begin 
;    in2 = where(lg_phz ge ndx(i) and lg_phz lt ndx(i+1))
;    while (in2(0) ne -1)do begin
;       phz_big(in2) = phz_big(in2) - (10d)^ndx(i)
;       lg_phz = alog10(phz_big)
;       in2 = where(lg_phz ge ndx(i) and lg_phz lt ndx(i+1))
;    endwhile
;   endfor
;   phase(in) = phz_big 
;endif
lt0 = where(phase lt 0d)
frac = phase - double(long(phase))
if (lt0(0) ne -1)then begin
   p = phase(lt0)
   frac(lt0) = 1d - (abs(p) - abs(double(long(p)))) 
endif
;*************************************************************
; Thats all ffolks.
;*************************************************************
return
end
