
pro model2_ff, x, a, ff, f, pder

a(5) = abs(a(5))
a(6) = abs(a(6))


den0 = x^2 + (0.5*a(1))^2
den0_minus = x^2 - (0.5*a(1))^2

den1 = (x - a(4))^2 + (0.5*a(3))^2
den1_minus = (x - a(4))^2 - (0.5*a(3))^2

den2 = (x - ff)^2 + (0.5*a(6))^2
den2_minus = (x - ff)^2 - (0.5*a(6))^2

f = (a(0)*a(1))/(2.0*!pi*den0) + (a(2)*a(3))/(2.0*!pi*den1) + (a(5)*a(6))/(2.0*!pi*den2)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den0)
pder(*,1) = (a(0)*den0_minus)/(2.0*!pi*den0^2)
pder(*,2) = a(3)/(2.0*!pi*den1)
pder(*,3) = (a(2)*den1_minus)/(2.0*!pi*den1^2)
pder(*,4) = (a(2)*a(3)*(x-a(4)))/(!pi*den1^2)
pder(*,5) = a(6)/(2.0*!pi*den2)
pder(*,6) = (a(5)*den2_minus)/(2.0*!pi*den2^2)


return

end
