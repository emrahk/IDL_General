pro brk_pow_1lfifffb, x, a, fi, f, pder

ff=2.59
fw=0.12
fb=0.4

n = n_elements(x) & f = fltarr(n)
print,'hello'
g1 = where(x le fb) 
g2 = where(x gt fb) 
if min(x) gt fb then g1=0


den = (x - ff)^2 + (0.5*fw)^2
den_minus = (x - ff)^2 - (0.5*fw)^2
f(g1) = a(0) +  (fb*fw)/(2.0*!pi*den(g1))
f(g2) = a(0)*(fb^(-fi))*(x(g2)^fi) + (a(1)*fw)/(2.0*!pi*den(g2))

pder = fltarr(n_elements(x), n_elements(a))

pder(g1,0) = 1.0
pder(g1,1) = fw/(2.0*!pi*den(g1))


pder(g2,0) = (fb^(-fi))*(x(g2)^fi)
pder(g2,1) = fw/(2.0*!pi*den(g2))


return

end

