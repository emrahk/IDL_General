pro get_pwr2,conf,nfreq,nint,pwr
;**************************************************************
; Program estimates the power for a given confidence
; level by integrating the chi=squared distribution
; The variables are:
;       conf..............confidence level(s)
;      nfreq..............number of frequencies
;        pwr..............power for confidence levels
;       nint..............number of fft intervals
; Works for pure noise spectrum.
; First do usage:
;**************************************************************
if (n_params() eq 0)then begin
   print,'USAGE : GET_PWR2,CONF,NFREQ,NINT,PWR'
   return
end
;**************************************************************
; Set some variables
;**************************************************************
n = n_elements(conf)
pwr = fltarr(n)
pconf = (double(conf))^(1d/double(nfreq))
;**************************************************************
; Now loop through each confidence level
;**************************************************************
for i = 0,n-1 do begin
 pc= pconf(i)
 pwr(i) = chi_sqr(1d - pc,2.*nint)
endfor
;**************************************************************
; Thats all
;**************************************************************
return
end
