function qpo_beat, per_ns, dist, flux, E0, verbose=verbose


;Useful Constants
GM = 1.86d26 ; cm^3/sec^2

mu = .5d * (E0/11.6d)*(1.306)*1d12 * (1d6)^3 ; Gauss-cm^3

Area = 4.d * !DPI * (dist*3.0857d21)^2.d ; cm^2

Lx = flux * Area ; ergs/sec

Mdot = 5.38d-21 * Lx

r = (mu)^(4.d/7.d) * (GM)^(-1.d/7.d) * (Mdot)^(-2.d/7.d) ; cm

nuk = 1.d/(2.d*!DPI) * sqrt(GM/(r^3.d))

nup = 1.d/per_ns

nu = abs(nuk - nup)

if (keyword_set(verbose)) then begin
    print,"mu:    ",mu
    print,"area:  ",area
    print,"Lx:    ",Lx
    print,"Mdot:  ",Mdot
    print,"R0:    ",r
    print,"nu_k:  ",nuk
    print,"nu_ns: ",nup
    print,"QPO:   ",1.d/nu
endif

return, nu
end
 