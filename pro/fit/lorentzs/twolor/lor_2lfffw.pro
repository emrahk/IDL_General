pro lor_2lfffw, x, a, f, pder

restore,'/home/emrahk/fit_par.dat'

n = n_elements(x) & f = fltarr(n)

a = abs(a)

den_1 = (x - al(2))^2 + (0.5*al(1))^2
den_minus_1 = (x - al(2))^2 - (0.5*al(1))^2

den = (x - cf)^2 + (0.5*wi)^2
den_minus = (x - cf)^2 - (0.5*wi)^2

f = (al(0)*al(1))/(2.0*!pi*den_1) + (a*wi)/(2.0*!pi*den)


pder = fltarr(n_elements(x), n_elements(a))

pder = a/(2.0*!pi*den)
;pder(*,1) = (a(0)*den_minus)/(2.0*!pi*den^2)
;pder(*,2) = (a(0)*a(1)*(x-a(2)))/(!pi*den^2)

return

end



