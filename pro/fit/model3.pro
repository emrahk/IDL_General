
pro model3, x, a, f, pder

a(0) = abs(a(0))
a(3) = abs(a(3))
a(6) = abs(a(6))

den0 = (x - a(2))^2 + (0.5*a(1))^2
den0_minus = (x - a(2))^2 - (0.5*a(1))^2

den1 = (x - a(5))^2 + (0.5*a(4))^2
den1_minus = (x - a(5))^2 - (0.5*a(4))^2

den2 = (x - a(8))^2 + (0.5*a(7))^2
den2_minus = (x - a(8))^2 - (0.5*a(7))^2

f = (a(0)*a(1))/(2.0*!pi*den0) + (a(3)*a(4))/(2.0*!pi*den1) + (a(6)*a(7))/(2.0*!pi*den2)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den0)
pder(*,1) = (a(0)*den0_minus)/(2.0*!pi*den0^2)
pder(*,2) = (a(0)*a(1)*(x-a(2)))/(!pi*den0^2)
pder(*,3) = a(4)/(2.0*!pi*den1)
pder(*,4) = (a(3)*den1_minus)/(2.0*!pi*den1^2)
pder(*,5) = (a(3)*a(4)*(x-a(5)))/(!pi*den1^2)
pder(*,6) = a(7)/(2.0*!pi*den2)
pder(*,7) = (a(6)*den2_minus)/(2.0*!pi*den2^2)
pder(*,8) = (a(6)*a(7)*(x-a(8)))/(!pi*den2^2)

return

end
