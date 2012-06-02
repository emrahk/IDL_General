pro lor_1lpc, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(0) = abs(a(0))
a(1) = abs(a(1))
a(2) = abs(a(2))
a(3) = abs(a(3))


den = (x - a(2))^2 + (0.5*a(1))^2
den_minus = (x - a(2))^2 - (0.5*a(1))^2
f = (a(0)*a(1))/(2.0*!pi*den) + a(3)


pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den)
pder(*,1) = (a(0)*den_minus)/(2.0*!pi*den^2)
pder(*,2) = (a(0)*a(1)*(x-a(2)))/(!pi*den^2)
pder(*,3) = 1

return

end



