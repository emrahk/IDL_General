pro brk_pow_1lfifffl, x, a, fi, f, pder

ff=2.44
fw=0.1
fl=0.1

n = n_elements(x) & f = fltarr(n)
print,'hello'
g1 = where(x le a(0)) 
g2 = where(x gt a(0)) 
if min(x) gt a(0) then g1=0

a(1) = abs(a(1))


den = (x - ff)^2 + (0.5*fw)^2
den_minus = (x - ff)^2 - (0.5*fw)^2
f(g1) = fl +  (a(1)*fw)/(2.0*!pi*den(g1))
f(g2) = fl*(a(0)^(-fi))*(x(g2)^fi) + (a(1)*fw)/(2.0*!pi*den(g2))

pder = fltarr(n_elements(x), n_elements(a))


pder(g1,0) = 0.0
pder(g1,1) = fw/(2.0*!pi*den(g1))



pder(g2,0) = -fi*fl*(a(0)^(-1.0-fi))*(x(g2)^fi)
pder(g2,1) = fw/(2.0*!pi*den(g2))


return

end
