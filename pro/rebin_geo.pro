; Program for geometrically rebinning a power spectrum.
; Written by John A. Tomsick 2/2/2000
; Comments added and method for error calculation updated on 2/11/2000

pro rebin_geo, step, freq, p, p_err

; The degree of rebinning is increased by increasing "step"
; This program overwrites freq, p, and p_err with the rebinned power
spectra

nf = n_elements(freq)
freq2 = fltarr(nf)-1.0
p2 = fltarr(nf)-1.0
p2_err = fltarr(nf)-1.0

i = 0
ilow = 0
ihigh = 0
while (ihigh lt nf) do begin
  rfactor = floor(step^i) ; rebinning factor
  if (rfactor eq 1) then begin
 ; This handles the frequency bins where no bins are combined
 freq2(i) = freq(i)
 p2(i) = p(i)
 p2_err(i) = p_err(i)
 ihigh = i
  endif
  if (rfactor gt 1) then begin
 ilow = ihigh + 1
 ihigh = ilow + rfactor - 1
 if (ihigh lt nf) then begin
   freq2(i) = total(freq(ilow:ihigh))/float(rfactor) ; the average
frequency
   p2(i) = total(p(ilow:ihigh))/float(rfactor) ; the average power
          den = total(1.0/p_err(ilow:ihigh)^2)
          p2_err(i) = sqrt(1.0/den) ; calculating the error on the power

 endif
  endif
  i = i + 1
endwhile

g = where(freq2 ge 0)
freq = freq2(g)
p = p2(g)
p_err = p2_err(g)

end

