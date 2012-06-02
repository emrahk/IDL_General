pro pow_2l, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(2) = abs(a(2))
a(3) = abs(a(3))
a(4) = abs(a(4))

a(5) = abs(a(5))
a(6) = abs(a(6))
a(7) = abs(a(7))


den1 = (x - a(4))^2 + (0.5*a(3))^2
den_minus1 = (x - a(4))^2 - (0.5*a(3))^2

den2 = (x - a(7))^2 + (0.5*a(6))^2
den_minus2 = (x - a(7))^2 - (0.5*a(6))^2

f = a(0)*(x^a(1)) + (a(2)*a(3))/(2.0*!pi*den1) + (a(5)*a(6))/(2.0*!pi*den2)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = (x^a(1))
pder(*,1) = a(0)*alog(x)*(x^a(1))
pder(*,2) = a(3)/(2.0*!pi*den1)
pder(*,3) = (a(2)*den_minus1)/(2.0*!pi*den1^2)
pder(*,4) = (a(2)*a(3)*(x-a(4)))/(!pi*den1^2)
pder(*,5) = a(6)/(2.0*!pi*den2)
pder(*,6) = (a(5)*den_minus2)/(2.0*!pi*den2^2)
pder(*,7) = (a(5)*a(6)*(x-a(7)))/(!pi*den2^2)


print,a

return

end


