pro pow_1lfffi, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(2) = abs(a(2))
a(1) = abs(a(1))

par=fltarr(2)
openr,1,'/home/ek/par.dat'
readf,1,par
close,1
ff=par(0)
fi=par(1)

den = (x - ff)^2 + (0.5*a(2))^2
den_minus = (x - ff)^2 - (0.5*a(2))^2

f = a(0)*(x^fi) + (a(1)*a(2))/(2.0*!pi*den)

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = (x^fi)
pder(*,1) = a(2)/(2.0*!pi*den)
pder(*,2) = (a(1)*den_minus)/(2.0*!pi*den^2)


;print,a

return

end


