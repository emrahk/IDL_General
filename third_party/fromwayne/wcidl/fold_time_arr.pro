pro fold_time_arr,time,counts,period,flc,nphase=nphase,$
                  pdot=pdot,ppdot=ppdot,fdot=fdot,$
                  ffdot=ffdot,ph=ph
;********************************************************
; Program folds a time series on a given period
; Variables are:
;     time.........time coordinate 
;   counts.........time series (counts/bin)
;   period.........periodicity to fold 
;      flc.........folded light curve
;   nphase.........number of phase bins in flc
;     pdot.........first period derivative
;    ppdot.........second period derivative
;     fdot.........first frequency derivative
;    ffdot.........second frequency derivative
;       ph.........phase shift
; First do usage:
;********************************************************
if (n_elements(time) eq 0)then begin
   print,'Usage:Fold_time_arr,time,counts,period,' + $
         'flc,[nphase=(20)],[pdot=(0)],[ppdot=(0)]' + $
         ',[fdot=(0)],[ffdot=(0)],[ph=(phase shift)]'
   return
endif
;*******************************************************
; Set some variables
;*******************************************************
if (n_elements(nphase) eq 0)then nphase = 20
sz = size(counts)
typ = sz(n_elements(sz)-2)
if (typ lt 4)then flc = lonarr(nphase) else $
flc = fltarr(nphase)
f = 1d/period
t = double(time)
if (n_elements(pdot) eq 0)then pdot = 0d $
else pdot = double(pdot)
if (n_elements(ppdot) eq 0)then ppdot = 0d $
else ppdot = double(ppdot)
if (n_elements(fdot) eq 0)then fdot = 0d $
else fdot = double(fdot)
if (n_elements(ffdot) eq 0)then ffdot = 0d $
else ffdot = double(ffdot)
if (n_elements(ph) eq 0)then ph = 0d
;*******************************************************
; Calculated the phase at each time bin and then the 
; fractional phase, scaled to the number of bins.
;********************************************************
frac_phase,f,t,frac,pd=pdot,pp=ppdot,fd=fdot,ff=ffdot,$
           ph=ph
phase = fix(frac*double(nphase))
for i = 0,nphase-1 do begin
   in = where(phase eq i)
   if (in(0) ne -1)then $
   flc(i) = total(counts(in))
endfor
;******************************************************
; That's all ffolks
;******************************************************
end
