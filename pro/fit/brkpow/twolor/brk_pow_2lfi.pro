pro brk_pow_2lfi, x, a, fi, f, pder

n = n_elements(x) & f = fltarr(n)
print,'hello'
g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

a(4) = abs(a(4))
a(7) = abs(a(7))
a(6) = abs(a(6))
a(5) = abs(a(5))
a(2) = abs(a(2))
a(3) = abs(a(3))

if min(x) gt a(1) then g1=0

den1 = (x - a(4))^2 + (0.5*a(3))^2
den_minus1 = (x - a(4))^2 - (0.5*a(3))^2

den2 = (x - a(7))^2 + (0.5*a(6))^2
den_minus2 = (x - a(7))^2 - (0.5*a(6))^2

f(g1) = a(0) +  (a(2)*a(3))/(2.0*!pi*den1(g1)) + $
(a(5)*a(6))/(2.0*!pi*den2(g1)) 

f(g2) = a(0)*(a(1)^(-fi))*(x(g2)^fi) + (a(2)*a(3))/(2.0*!pi*den1(g2)) + $
(a(5)*a(6))/(2.0*!pi*den2(g2))

pder = fltarr(n_elements(x), n_elements(a))

pder(g1,0) = 1.0
pder(g1,1) = 0.0
pder(g1,2) = a(3)/(2.0*!pi*den1(g1))
pder(g1,3) = (a(2)*den_minus1(g1))/(2.0*!pi*den1(g1)^2)
pder(g1,4) = (a(2)*a(3)*(x(g1)-a(4)))/(!pi*den1(g1)^2)
pder(g1,5) = a(6)/(2.0*!pi*den2(g1))
pder(g1,6) = (a(5)*den_minus2(g1))/(2.0*!pi*den2(g1)^2)
pder(g1,7) = (a(5)*a(6)*(x(g1)-a(7)))/(!pi*den2(g1)^2)

pder(g2,0) = (a(1)^(-fi))*(x(g2)^fi)
pder(g2,1) = -fi*a(0)*(a(1)^(-1.0-fi))*(x(g2)^fi)
pder(g2,2) = a(3)/(2.0*!pi*den1(g2))
pder(g2,3) = (a(2)*den_minus1(g2))/(2.0*!pi*den1(g2)^2)
pder(g2,4) = (a(2)*a(3)*(x(g2)-a(4)))/(!pi*den1(g2)^2)
pder(g2,5) = a(6)/(2.0*!pi*den2(g2))
pder(g2,6) = (a(5)*den_minus2(g2))/(2.0*!pi*den2(g2)^2)
pder(g2,7) = (a(5)*a(6)*(x(g2)-a(7)))/(!pi*den2(g2)^2)


return

end
