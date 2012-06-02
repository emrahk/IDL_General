function calc_rcorot, period

if (n_params() eq 0) then begin
   print,'USAGE: r_{A} = calc_rcorot(period)'
   print,'In:  period, in seconds'
   print,'Out: Co-rotoation radius, in cm'
   return, 0
endif

P = double(period)

M = 1.4d * 1.99d33 ; grams
R = 1d6            ; cm
G = 6.67d-8        ; cm^3/gm/s^2

rco = ((G*M*P^2.d)/(4.d*!DPI^2.d))^(1.d/3.d)

return,rco
end
