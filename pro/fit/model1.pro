
pro model1, x, a, f, pder

a(2)=abs(a(2))
a(0)=abs(a(0))
den0 = x^2 + (0.5*a(1))^2
den0_minus = x^2 - (0.5*a(1))^2

den = (x - a(4))^2 + (0.5*a(3))^2
den_minus = (x - a(4))^2 - (0.5*a(3))^2

f = (a(0)*a(1))/(2.0*!pi*den0) + (a(2)*a(3))/(2.0*!pi*den)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = a(1)/(2.0*!pi*den0)
pder(*,1) = (a(0)*den0_minus)/(2.0*!pi*den0^2)
pder(*,2) = a(3)/(2.0*!pi*den)
pder(*,3) = (a(2)*den_minus)/(2.0*!pi*den^2)
pder(*,4) = (a(2)*a(3)*(x-a(4)))/(!pi*den^2)

print,a
return

end
