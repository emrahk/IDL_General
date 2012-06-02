pro pow_1lff, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(2) = abs(a(2))
a(3) = abs(a(3))

ff=0.
openr,1,'/home/ek/par.dat'
readf,1,ff
close,1

den = (x - ff)^2 + (0.5*a(3))^2
den_minus = (x - ff)^2 - (0.5*a(3))^2

f = a(0)*(x^a(1)) + (a(2)*a(3))/(2.0*!pi*den)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = (x^a(1))
pder(*,1) = a(0)*alog(x)*(x^a(1))
pder(*,2) = a(3)/(2.0*!pi*den)
pder(*,3) = (a(2)*den_minus)/(2.0*!pi*den^2)


;print,a

return

end


