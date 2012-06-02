pro lor_1lzc, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(0) = abs(a(0))
a(1) = abs(a(1))

den = x^2 + (0.5*a(1))^2
den_minus = x^2 - (0.5*a(1))^2
f = (a(0)*a(1))/(2.0*!pi*den)


pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den)
pder(*,1) = (a(0)*den_minus)/(2.0*!pi*den^2)


return

end



