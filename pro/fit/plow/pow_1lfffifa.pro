pro pow_1lfffifa, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(0) = abs(a(0))
a(1) = abs(a(1))

par=fltarr(3)
openr,1,'/home/ek/par.dat'
readf,1,par
close,1
ff=par(0)
fi=par(1)
fa=par(2)

den = (x - ff)^2 + (0.5*a(1))^2
den_minus = (x - ff)^2 - (0.5*a(1))^2

f = fa*(x^fi) + (a(0)*a(1))/(2.0*!pi*den)

pder = fltarr(n_elements(x), n_elements(a))


pder(*,0) = a(1)/(2.0*!pi*den)
pder(*,1) = (a(0)*den_minus)/(2.0*!pi*den^2)


;print,a

return

end


