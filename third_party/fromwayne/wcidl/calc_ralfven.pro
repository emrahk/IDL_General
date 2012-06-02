function calc_ralfven, B_temp, L_temp, fudge=fudge

if (n_params() eq 0) then begin
   print,'USAGE: r_{A} = calc_aalfven(B_{12},L_{37})'
   print,'In:  B_{12}, surface magnetic field strength'
   print,'     L_{37}, Luminosity'
   print,'Out: Alfven Radius'
   print,' Using equation from Ghosh and Lamb, Apj, 234, 296'
   return, 0
endif

B=double(B_temp) * 1d12
L=double(L_temp) * 1d37

if (keyword_set(fudge) eq 0) then begin
   f = 1.0d
endif else begin
   f = double(fudge)
endelse

M = 1.4d * 1.99d33 ; grams
R = 1d6            ; cm
G = 6.67d-8        ; cm^3/gm/s^2

Mdot = (R * L) / (G * M) ; grams/second

mu = 0.5d * B * R^3.d    ; gauss cm^3


ra = (2.d*G*M)^(-1.d/7.d)* (mu)^(4.d/7.d) * (Mdot)^(-2.d/7.d)

return,ra
end
