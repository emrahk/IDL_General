pro lor_2l, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(0) = abs(a(0))
a(1) = abs(a(1))
a(2) = abs(a(2))

a(3) = abs(a(3))
a(4) = abs(a(4))
a(5) = abs(a(5))

den_1 = (x - a(2))^2 + (0.5*a(1))^2
den_minus_1 = (x - a(2))^2 - (0.5*a(1))^2

den_2 = (x - a(5))^2 + (0.5*a(4))^2
den_minus_2 = (x - a(5))^2 - (0.5*a(4))^2

f = (a(0)*a(1))/(2.0*!pi*den_1) + $
    (a(3)*a(4))/(2.0*!pi*den_2)


pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den_1)
pder(*,1) = (a(0)*den_minus_1)/(2.0*!pi*den_1^2)
pder(*,2) = (a(0)*a(1)*(x-a(2)))/(!pi*den_1^2)

pder(*,3) = a(4)/(2.0*!pi*den_2)
pder(*,4) = (a(3)*den_minus_2)/(2.0*!pi*den_2^2)
pder(*,5) = (a(3)*a(4)*(x-a(5)))/(!pi*den_2^2)



return

end



