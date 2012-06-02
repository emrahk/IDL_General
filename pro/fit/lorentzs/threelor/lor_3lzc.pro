pro lor_3lzc, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(0) = abs(a(0))
a(1) = abs(a(1))

a(2) = abs(a(2))
a(3) = abs(a(3))
a(4) = abs(a(4))

a(5) = abs(a(5))
a(6) = abs(a(6))
a(7) = abs(a(7))

den_1 = x^2 + (0.5*a(1))^2
den_minus_1 = x^2 - (0.5*a(1))^2

den_2 = (x - a(4))^2 + (0.5*a(3))^2
den_minus_2 = (x - a(4))^2 - (0.5*a(3))^2

den_3 = (x - a(7))^2 + (0.5*a(6))^2
den_minus_3 = (x - a(7))^2 - (0.5*a(6))^2

f = (a(0)*a(1))/(2.0*!pi*den_1) + $
    (a(2)*a(3))/(2.0*!pi*den_2) + $
    (a(5)*a(6))/(2.0*!pi*den_3)


pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den_1)
pder(*,1) = (a(0)*den_minus_1)/(2.0*!pi*den_1^2)

pder(*,2) = a(3)/(2.0*!pi*den_2)
pder(*,3) = (a(2)*den_minus_2)/(2.0*!pi*den_2^2)
pder(*,4) = (a(2)*a(3)*(x-a(4)))/(!pi*den_2^2)

pder(*,5) = a(6)/(2.0*!pi*den_3)
pder(*,6) = (a(5)*den_minus_3)/(2.0*!pi*den_3^2)
pder(*,7) = (a(5)*a(6)*(x-a(7)))/(!pi*den_3^2)

return

end



