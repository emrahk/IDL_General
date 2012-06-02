pro calc_magfield, nrg

if (n_params() eq 0) then begin
   print,'USAGE: calc_magfield,energy'
   print,'In:  energy, CRSF energy'
   print,'Out: magnetic field'
   return
endif
 

M = 1.4d * 1.99d33  ; grams
R = 1d6             ; cm
G = 6.67d-8         ; cm^3/gm/s^2
c = 2.9979245800d10 ; cm/s

z = (1.d - (2.d*G*M)/(R*c^2.d))^(-1.d/2.d) - 1.d

print,z

B = nrg/11.6d * 1d12

print,'B = ',B,'(1 + z)'

B = nrg/11.6d * (1.d + z) * 1d12

print,'B = ',B

return
end
