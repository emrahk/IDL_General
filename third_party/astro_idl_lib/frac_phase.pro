pro frac_phase,freq,time,frac,pdot=pdot,ppdot=ppdot,fdot=fdot,$
               ffdot=ffdot,ph=ph
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
;       ph..............phase shift
; First do usage:
;*************************************************************
if (n_params() eq 0)then begin
   print,'USAGE:FRAC_PHASE,FREQ,TIME,FRAC,[PDOT=],' + $
         '[PPDOT=],[FDOT=],[FFDOT=],[ph=(phase shift)]'
   return
endif
;*************************************************************
; Now calculate the phase of each event.
;*************************************************************
szf = size(freq)
if (szf(0) ne 0)then f = double(freq(0)) else f = double(freq)
t = double(time)
if (ks(pdot) eq 0.)then pd = 0d else pd = double(pdot)
if (ks(ph) eq 0)then ph = 0d
if (ks(ppdot) eq 0.)then ppd = 0d else ppd = double(ppdot)
if (ks(fdot) eq 0.)then fd = 0d else fd = double(fdot)
if (ks(ffdot) eq 0.)then ffd = 0d else ffd = double(ffdot)
if (pd gt 0d)then begin
   phase = 1d - (1d/2d)*pd*f*t -(1d/6d)*ppd*f*f*t*t + $
           (2d/6d)*pd*pd*t*t*f*f 
   phase = phase*f*t + ph
endif else phase = f*t + fd*t*t/2d + ffd*t*t*t/6d + ph
;stop
;*************************************************************
; Must subtract off parts if greater then 10^9, 
; THEN round off. This is designed to combat IDL-induced 
; roundoff error. Be careful with the negative phases.
;*************************************************************
lt0 = where(phase lt 0d)
phase = abs(phase)
in = where(phase gt 2d9)
ndx = 6d + dindgen(10)
if(in(0) ne -1)then begin
   phz_big = phase(in)
   i = 9 & bail = 0
   while (i ge 1 and bail eq 0)do begin
      lg_phz = alog10(phz_big)
;      print,'lg_phz=',lg_phz
      in2 = where(lg_phz ge ndx(i-1) and lg_phz lt ndx(i))
;      print,'in2=',in2
      if (in2(0) ne -1)then begin
;         print,'phz_big1=',phz_big
         phz_big(in2) = phz_big(in2) - (10d)^(ndx(i-1)) 
;         print,'phz_big2=',phz_big
         fuckit = phz_big(in2) eq 0d
      endif else begin
         fuckit = 0
         i = i - 1
      endelse
      if (fuckit(0))then begin
         bail = 1
         i = 0
;         print,'bailing!'
      endif
   endwhile
   phase(in) = phz_big 
endif
frac = phase - double(long(phase))
if (lt0(0) ne -1)then frac(lt0) = 1d - frac(lt0)
;*************************************************************
; Thats all ffolks.
;*************************************************************
return
END



