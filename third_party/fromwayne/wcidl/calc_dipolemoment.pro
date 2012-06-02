function calc_dipolemoment, period, luminosity, fudge=fudge, b=magfield

if (n_params() eq 0) then begin
   print,'USAGE: mu = calc_dipolemoment(period,luminosity)'
   print,'In:  period, pulsar period in seconds'
   print,'     luminosity, x-ray luminosity in units of ergs/second'
   print,'Out: pulsar dipole moment from accretion torque theory'
   print,' Using equation from Ghosh and Lamb, Apj, 234, 296'
   return, 0
endif

p = double(period)
l = double(luminosity) ; ergs/second

if (keyword_set(fudge) eq 0) then begin
   f = 1.0d
endif else begin
   f = double(fudge)
endelse

M = 1.4d * 1.99d33 ; grams
R = 1d6            ; cm
G = 6.67d-8        ; cm^3/gm/s^2

Mdot = (R * L) / (G * M) ; grams/second

mu = (f)^(-7.d/4.d) * (4.d*!DPI^2.d)^(-7.d/12.d) * (G*M)^(5.d/6.d) * (Mdot)^(1.d/2.d) * (P)^(7.d/6.d) * (2.d)^(1.d/4.d)

; B = 2 mu / R^3
;
magfield = 2.d * mu / (R^3.d)

return, mu
end
