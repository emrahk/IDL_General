pro rebin_geo, step, freq, p, p_err

; changed from weighted average to average with no weighting on November 20, 1999

nf = n_elements(freq)
freq2 = fltarr(nf)-1.0
p2 = fltarr(nf)-1.0
p2_err = fltarr(nf)-1.0

i = 0
ilow = 0
ihigh = 0
while (ihigh lt nf) do begin
  rfactor = floor(step^i)
  if (rfactor eq 1) then begin
	freq2(i) = freq(i)
	p2(i) = p(i)
	p2_err(i) = p_err(i)
	ihigh = i
  endif
  if (rfactor gt 1) then begin
	ilow = ihigh + 1
	ihigh = ilow + rfactor - 1
	if (ihigh lt nf) then begin
	  freq2(i) = total(freq(ilow:ihigh))/float(rfactor)
	  p2(i) = total(p(ilow:ihigh))/float(rfactor)
	  var = (p_err(ilow:ihigh))^2
	  p2_err(i) = sqrt(total(var))/float(rfactor)
	endif
  endif
  i = i + 1
endwhile

g = where(freq2 ge 0)
freq = freq2(g)
p = p2(g)
p_err = p2_err(g)

end
