pro brk_pow_1lfifffwfb, x, a, f, pder

par=fltarr(4)
openr,1,'/home/ek/par.dat'
readf,1,par
close,1

n = n_elements(x) & f = fltarr(n)
print,'hello'

g1 = where(x le par(0)) 
g2 = where(x gt par(0)) 
if min(x) gt par(0) then g1=0

a(0) = abs(a(0))
a(1) = abs(a(1))

den = (x - par(3))^2 + (0.5*par(2))^2
den_minus = (x - par(3))^2 - (0.5*par(2))^2
f(g1) = a(0) +  (a(1)*par(2))/(2.0*!pi*den(g1))
f(g2) = a(0)*(par(0)^(-par(1)))*(x(g2)^par(1)) + (a(1)*par(2))/(2.0*!pi*den(g2))

pder = fltarr(n_elements(x), n_elements(a))

pder(g1,0) = 1.0
pder(g1,1) = par(2)/(2.0*!pi*den(g1))

pder(g2,0) = (par(0)^(-par(1)))*(x(g2)^par(1))
pder(g2,1) = par(2)/(2.0*!pi*den(g2))

return

end
