pro pow_1lpc, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(2) = abs(a(2))
a(3) = abs(a(3))
a(4) = abs(a(4))
a(5) = abs(a(5))

den = (x - a(4))^2 + (0.5*a(3))^2
den_minus = (x - a(4))^2 - (0.5*a(3))^2

f = a(0)*(x^a(1)) + (a(2)*a(3))/(2.0*!pi*den)+a(5)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = (x^a(1))
pder(*,1) = a(0)*alog(x)*(x^a(1))
pder(*,2) = a(3)/(2.0*!pi*den)
pder(*,3) = (a(2)*den_minus)/(2.0*!pi*den^2)
pder(*,4) = (a(2)*a(3)*(x-a(4)))/(!pi*den^2)
pder(*,5) = 1.

print,a

return

end



