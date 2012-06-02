function calc_timeeq,period,luminosity,magfield,fudge=fudge

if (n_params() eq 0) then begin
   print,'USAGE: t_{eq} = calc_timeeq(period,luminosity,magfield,fudge=fudge)'
   print,'In:  period, in seconds'
   print,'     luminosity, in ergs/second'
   print,'     magnetic field, in Gauss'
   print,'Out: timescale for equilibrium'
   print,'Taken from Bildsten et al. 1997'
   return, 0
endif

M = 1.4d * 1.99d33 ; grams
R = 1d6            ; cm
G = 6.67d-8        ; cm^3/gm/s^2

P = double(period)
L = double(luminosity)
B = double(magfield)

if (keyword_set(fudge) eq 0) then begin
   f = 1.0d
endif else begin
   f = double(fudge)
endelse

; Mass accretion rate
Mdot = (R * L) / (G * M) ; grams/second
Mdot = Mdot * 31556925.9747d / 1.99d33 ; Solar Masses/Year

; Magnetospheric Radius Radius
rm = f * calc_ralfven(B/1d12,L/1d37)

; Corotation Radius
rco = calc_rcorot(P)

teq = 2d5 * (1d-10/Mdot) * (1.d/P)^(4.d/3.d) * (rco/rm)^(1.d/2.d)


return,teq
end
