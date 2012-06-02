function calc_polartemp, B_temp, L_temp, theta_temp

if (n_params() eq 0) then begin
   print,'USAGE: temp = calc_polartemp(B_{12},L_{37}, theta)'
   print,'In:  B_{12}, surface magnetic field strength
   print,'     L_{37}, Luminosity'
   print,'     theta, opening angle at polar cap'
   print,'Out: Polar Cap Temp > temp'
   print,' Using equation from Lamb, Pethick, and Pines, Apj, 184, 271'
   return, 0
endif

b = double(B_temp) * 1d12
l = double(L_temp)
theta=double(theta_temp)

M = 1.4d ; Want this in units of solar masses
R = 1.0d ; Want this in units of 10^6 cm (10km)

;
; need the magnetic dipole moment, not surface magnetic field
; there is an extra factor of 1/2 due to the shape of the dipole
; field.
mu = 0.5d * (B) * (R*1d6)^(3.d) / 1d30

;
; theta_c is given by sin(theta_c)^2. = R/r_alfven
theta_c = sqrt(4d-3 * (R)^(9.d/7.d) * (L)^(2.d/7.d) * mu(-4.d/7.d) * (M)^(-1.d/7.d))

;
; This is temp in degrees Kelvin
temp = 5d7 * (M)^(1.d/28.d) * (mu)^(1.d/7.d) * (l)^(5.d/28.d) * (R)^(-23.d/28.d) * (theta_c/theta)^(1.d/2.d)

;
; Convert K to keV
k = (1.38d-16) / (1.60217733d-9) ; (ergs/K * keV/erg)

temp = k * temp

return, temp
end
