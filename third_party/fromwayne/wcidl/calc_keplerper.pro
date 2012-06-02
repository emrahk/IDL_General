function calc_keplerper, radius

if (n_params() eq 0) then begin
   print,'USAGE: nu = calc_keplerfreq(radius)'
   print,'In:  radius in cm'
   print,'Out: period in seconds'
   return, 0
endif

M = 1.4d * 1.99d33  ; grams
R = 1d6             ; cm
G = 6.67d-8         ; cm^3/gm/s^2
c = 2.9979245800d10 ; cm/s

rd = double(radius)

nu = (G*M)^(1.d/2.d) * (rd)^(-3.d/2.d) * (2.d*!DPI)^(-1.d)

period = 1.d/nu

return,period
end
