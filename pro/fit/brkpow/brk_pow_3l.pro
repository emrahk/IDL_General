
pro brk_pow_3l, x, a, f, pder

n = n_elements(x) & f = fltarr(n)
print,'hello'
g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

a(3) = abs(a(3))
a(4) = abs(a(4))
a(5) = abs(a(5))
a(6) = abs(a(6))
a(7) = abs(a(7))
a(8) = abs(a(8))
a(9) = abs(a(9))
a(10) = abs(a(10))
a(11) = abs(a(11))

den1 = (x - a(5))^2 + (0.5*a(4))^2
den_minus1 = (x - a(5))^2 - (0.5*a(4))^2

den2 = (x - a(8))^2 + (0.5*a(7))^2
den_minus2 = (x - a(8))^2 - (0.5*a(7))^2

den3 = (x - a(11))^2 + (0.5*a(10))^2
den_minus3 = (x - a(11))^2 - (0.5*a(10))^2

f(g1) = a(0) +  (a(3)*a(4))/(2.0*!pi*den1(g1)) + $
(a(6)*a(7))/(2.0*!pi*den2(g1)) + (a(9)*a(10))/(2.0*!pi*den3(g1))  

f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) + (a(3)*a(4))/(2.0*!pi*den1(g2)) + $
(a(6)*a(7))/(2.0*!pi*den2(g2)) + (a(9)*a(10))/(2.0*!pi*den3(g2)) 

pder = fltarr(n_elements(x), n_elements(a))

pder(g1,0) = 1.0
pder(g1,1) = 0.0
pder(g1,2) = 0.0
pder(g1,3) = a(4)/(2.0*!pi*den1(g1))
pder(g1,4) = (a(3)*den_minus1(g1))/(2.0*!pi*den1(g1)^2)
pder(g1,5) = (a(3)*a(4)*(x(g1)-a(5)))/(!pi*den1(g1)^2)
pder(g1,6) = a(7)/(2.0*!pi*den2(g1))
pder(g1,7) = (a(6)*den_minus2(g1))/(2.0*!pi*den2(g1)^2)
pder(g1,8) = (a(6)*a(7)*(x(g1)-a(8)))/(!pi*den2(g1)^2)
pder(g1,9) = a(10)/(2.0*!pi*den3(g1))
pder(g1,10) = (a(9)*den_minus3(g1))/(2.0*!pi*den3(g1)^2)
pder(g1,11) = (a(9)*a(10)*(x(g1)-a(11)))/(!pi*den3(g1)^2)

pder(g2,0) = (a(1)^(-a(2)))*(x(g2)^a(2))
pder(g2,1) = -a(2)*a(0)*(a(1)^(-1.0-a(2)))*(x(g2)^a(2))
pder(g2,2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))*(alog(x(g2))-alog(a(1)))
pder(g2,3) = a(4)/(2.0*!pi*den1(g2))
pder(g2,4) = (a(3)*den_minus1(g2))/(2.0*!pi*den1(g2)^2)
pder(g2,5) = (a(3)*a(4)*(x(g2)-a(5)))/(!pi*den1(g2)^2)
pder(g2,6) = a(7)/(2.0*!pi*den2(g2))
pder(g2,7) = (a(6)*den_minus2(g2))/(2.0*!pi*den2(g2)^2)
pder(g2,8) = (a(6)*a(7)*(x(g2)-a(8)))/(!pi*den2(g2)^2)
pder(g2,9) = a(10)/(2.0*!pi*den3(g2))
pder(g2,10) = (a(9)*den_minus3(g2))/(2.0*!pi*den3(g2)^2)
pder(g2,11) = (a(9)*a(10)*(x(g2)-a(11)))/(!pi*den3(g2)^2)

return

end
