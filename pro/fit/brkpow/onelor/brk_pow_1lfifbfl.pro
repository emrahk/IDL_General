pro brk_pow_1lfifbfl, x, a, f, pder

par=fltarr(3)
openr,1,'/home/ek/par.dat'
readf,1,par
close,1

fi=par(0)
fb=par(1)
fl=par(2)

n = n_elements(x) & f = fltarr(n)
print,'hello'

g1 = where(x le fb) 
g2 = where(x gt fb) 
if min(x) gt fb then g1=0

a(0) = abs(a(0))
a(1) = abs(a(1))
a(2) = abs(a(2))

den = (x - a(2))^2 + (0.5*a(1))^2
den_minus = (x - a(2))^2 - (0.5*a(1))^2
f(g1) = fl +  (a(0)*a(1))/(2.0*!pi*den(g1))
f(g2) = fl*(fb^(-fi))*(x(g2)^fi) + (a(0)*a(1))/(2.0*!pi*den(g2))

pder = fltarr(n_elements(x), n_elements(a))

pder(g1,0) = a(1)/(2.0*!pi*den(g1))
pder(g1,1) = (a(0)*den_minus(g1))/(2.0*!pi*den(g1)^2)
pder(g1,2) = (a(0)*a(1)*(x(g1)-a(2)))/(!pi*den(g1)^2)

pder(g2,0) = a(1)/(2.0*!pi*den(g2))
pder(g2,1) = (a(0)*den_minus(g2))/(2.0*!pi*den(g2)^2)
pder(g2,2) = (a(0)*a(1)*(x(g2)-a(2)))/(!pi*den(g2)^2)

return

end
