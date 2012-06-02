pro frac_phase,freq,t,frac,pdot=pdot,ppdot=ppdot,fdot=fdot,$
               ffdot=ffdot,ph=ph,inplace=inplace
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
if (ks(pdot) eq 0.)then pd = 0d else pd = double(pdot)
if (ks(ph) eq 0)then ph = 0d
if (ks(ppdot) eq 0.)then ppd = 0d else ppd = double(ppdot)
if (ks(fdot) eq 0.)then fd = 0d else fd = double(fdot)
if (ks(ffdot) eq 0.)then ffd = 0d else ffd = double(ffdot)

if (keyword_set(inplace)) then begin
   if (pd gt 0d) then begin
      print,'ERROR: Period derivatives not supported yet'
      print,'       Please use frequency derivatives'
   endif else begin
      if (fd eq 0. and ffd eq 0.) then begin
         t = f*temporary(t) + ph
      endif else begin
         t = f*t + fd*t^2./3d + ffd*t^3./6d + ph
      endelse
   endelse
   frac = temporary(t)

endif else begin
   if (pd gt 0d) then begin
      frac = 1d - (1d/2d)*pd*f*t -(1d/6d)*ppd*f*f*t*t + $
              (2d/6d)*pd*pd*t*t*f*f 
      frac = temporary(frac)*f*t + ph
   endif else begin
      if (fd eq 0. and ffd eq 0.) then begin
         frac = f*t + ph
      endif else begin
         frac = f*t + fd*t*t/3d + ffd*t*t*t/6d + ph
      endelse
   endelse

endelse
;stop
;*************************************************************
; Must subtract off parts if greater then 10^9, 
; THEN round off. This is designed to combat IDL-induced 
; roundoff error. Be careful with the negative phases.
;*************************************************************
lt0 = where(frac lt 0d)
frac = abs(temporary(frac))
in = where(frac gt 2d9)
ndx = 6d + dindgen(10)
if(in(0) ne -1)then begin
   phz_big = frac(in)
   i = 9 & bail = 0
   while (i ge 1 and bail eq 0)do begin
      lg_phz = alog10(phz_big)
      in2 = where(lg_phz ge ndx(i-1) and lg_phz lt ndx(i))
      if (in2(0) ne -1)then begin
         phz_big(in2) = phz_big(in2) - (10d)^(ndx(i-1)) 
         fuckit = phz_big(in2) eq 0d
      endif else begin
         fuckit = 0
         i = i - 1
      endelse
      if (fuckit(0))then begin
         bail = 1
         i = 0
      endif
   endwhile
   frac(in) = phz_big 
endif
frac = frac - double(long(frac))
if (lt0(0) ne -1)then begin
   frac(lt0) = 1d - temporary(frac(lt0))
endif

;*************************************************************
; Thats all ffolks.
;*************************************************************
return
END



