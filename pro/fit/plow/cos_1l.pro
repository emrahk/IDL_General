pro cos_1l, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

;a(0) = -abs(a(0))
a(1) = abs(a(1))
a(2) = abs(a(2))
a(3) = abs(a(3))

den = (x - a(3))^2 + (0.5*a(2))^2
den_minus = (x - a(3))^2 - (0.5*a(2))^2

f = a(0) + (a(1)*a(2))/(2.0*!pi*den)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = 1.
pder(*,1) = a(2)/(2.0*!pi*den)
pder(*,2) = (a(1)*den_minus)/(2.0*!pi*den^2)
pder(*,3) = (a(1)*a(2)*(x-a(3)))/(!pi*den^2)

print,a

return

end



