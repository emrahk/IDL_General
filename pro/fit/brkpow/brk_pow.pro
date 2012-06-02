pro brk_pow, x, a, f, pder

n = n_elements(x) & f = fltarr(n)
print,'hello'
g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 
if min(x) gt a(1) then g1=0

f(g1) = a(0)
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) 

pder = fltarr(n_elements(x), n_elements(a))

pder(g1,0) = 1.0
pder(g1,1) = 0.0
pder(g1,2) = 0.0

pder(g2,0) = (a(1)^(-a(2)))*(x(g2)^a(2))
pder(g2,1) = -a(2)*a(0)*(a(1)^(-1.0-a(2)))*(x(g2)^a(2))
pder(g2,2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))*(alog(x(g2))-alog(a(1)))

return

end
