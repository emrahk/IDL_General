function calc_eqspin, luminosity, magfield, fudge=fudge

if (n_params() eq 0) then begin
   print,'USAGE: p = calc_eqspin(luminosity,magfield)'
   print,'In:  luminosity, x-ray luminosity in units of 10^{37} ergs/second'
   print,'     magfield, magnetic field strength in units of 10^{12} G'
   print,'Out: period, implied pulsar spin period'
   return, 0
endif

L = double(luminosity) * 1d37 ; ergs/second
B = double(magfield) * 1d12 ; Gauss

if (keyword_set(fudge) eq 0) then begin
   f = 1.0d
endif else begin
   f = double(fudge)
endelse

M = 1.4d * 1.99d33 ; grams
R = 1d6            ; cm
G = 6.67d-8        ; cm^3/gm/s^2

Mdot = (R * L) / (G * M) ; grams/second
mu = 0.5d * (B) * (R)^(3.d) ; Gauss-cm^{3}
const = f^(3.d/2.d) * (8.d*!DPI^2.d)^(1.d/2.d) * (2.d*G*M)^(-5.d/7.d)

print,mdot
print,mu
print,const

period = const * mu^(6.d/7.d) * mdot^(-3.d/7.d)

return, period
end
