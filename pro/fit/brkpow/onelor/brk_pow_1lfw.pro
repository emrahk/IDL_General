pro brk_pow_1lfw, x, a, fw, f, pder

n = n_elements(x) & f = fltarr(n)
print,'hello'
g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 
if min(x) gt a(1) then g1=0

a(3) = abs(a(3))
a(4) = abs(a(4))

den = (x - a(4))^2 + (0.5*fw)^2
den_minus = (x - a(4))^2 - (0.5*fw)^2
f(g1) = a(0) +  (a(3)*fw)/(2.0*!pi*den(g1))
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) + (a(3)*fw)/(2.0*!pi*den(g2))

pder = fltarr(n_elements(x), n_elements(a))

pder(g1,0) = 1.0
pder(g1,1) = 0.0
pder(g1,2) = 0.0
pder(g1,3) = fw/(2.0*!pi*den(g1))
pder(g1,4) = (a(3)*fw*(x(g1)-a(4)))/(!pi*den(g1)^2)

pder(g2,0) = (a(1)^(-a(2)))*(x(g2)^a(2))
pder(g2,1) = -a(2)*a(0)*(a(1)^(-1.0-a(2)))*(x(g2)^a(2))
pder(g2,2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))*(alog(x(g2))-alog(a(1)))
pder(g2,3) = fw/(2.0*!pi*den(g2))
pder(g2,4) = (a(3)*fw*(x(g2)-a(4)))/(!pi*den(g2)^2)

return

end
