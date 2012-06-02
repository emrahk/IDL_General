function gabs_fwhm, depth, sigma

if (n_params() eq 0) then begin
   print,'USAGE: fwhm = gabs_fwhm(depth,sigma)'
   print,'In:  depth, sigma, fit values from XSPEC'
   print,'Out: fwhm, the full width half max of the line'
   return, 0
endif

wcy=double(sigma)
dcy=double(depth)

fwhm = 2.d*wcy*sqrt(2.d*alog(dcy/alog(2.d/(1.d + exp(-1.d*dcy)))))

return,fwhm
end

