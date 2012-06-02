pro lor_5l, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(0) = abs(a(0))
a(1) = abs(a(1))
a(2) = abs(a(2))

a(3) = abs(a(3))
a(4) = abs(a(4))
a(5) = abs(a(5))

a(6) = abs(a(6))
a(7) = abs(a(7))
a(8) = abs(a(8))

a(9) = abs(a(9))
a(10) = abs(a(10))
a(11) = abs(a(11))

a(12) = abs(a(12))
a(13) = abs(a(13))
a(14) = abs(a(14))

den_1 = (x - a(2))^2 + (0.5*a(1))^2
den_minus_1 = (x - a(2))^2 - (0.5*a(1))^2

den_2 = (x - a(5))^2 + (0.5*a(4))^2
den_minus_2 = (x - a(5))^2 - (0.5*a(4))^2

den_3 = (x - a(8))^2 + (0.5*a(7))^2
den_minus_3 = (x - a(8))^2 - (0.5*a(7))^2

den_4 = (x - a(11))^2 + (0.5*a(10))^2
den_minus_4 = (x - a(11))^2 - (0.5*a(10))^2

den_5 = (x - a(14))^2 + (0.5*a(13))^2
den_minus_5 = (x - a(14))^2 - (0.5*a(13))^2

f = (a(0)*a(1))/(2.0*!pi*den_1) + $
    (a(3)*a(4))/(2.0*!pi*den_2) + $
    (a(6)*a(7))/(2.0*!pi*den_3) + $
    (a(9)*a(10))/(2.0*!pi*den_4) + $
    (a(12)*a(13))/(2.0*!pi*den_5)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den_1)
pder(*,1) = (a(0)*den_minus_1)/(2.0*!pi*den_1^2)
pder(*,2) = (a(0)*a(1)*(x-a(2)))/(!pi*den_1^2)

pder(*,3) = a(4)/(2.0*!pi*den_2)
pder(*,4) = (a(3)*den_minus_2)/(2.0*!pi*den_2^2)
pder(*,5) = (a(3)*a(4)*(x-a(5)))/(!pi*den_2^2)

pder(*,6) = a(7)/(2.0*!pi*den_3)
pder(*,7) = (a(6)*den_minus_3)/(2.0*!pi*den_3^2)
pder(*,8) = (a(6)*a(7)*(x-a(8)))/(!pi*den_3^2)

pder(*,9) = a(10)/(2.0*!pi*den_4)
pder(*,10) = (a(9)*den_minus_4)/(2.0*!pi*den_4^2)
pder(*,11) = (a(9)*a(10)*(x-a(11)))/(!pi*den_4^2)

pder(*,12) = a(13)/(2.0*!pi*den_5)
pder(*,13) = (a(12)*den_minus_5)/(2.0*!pi*den_5^2)
pder(*,14) = (a(12)*a(13)*(x-a(14)))/(!pi*den_5^2)

return

end



