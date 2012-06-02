pro pow, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

f = a(0)*(x^a(1))

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0) = (x^a(1))
pder(*,1) = a(0)*alog(x)*(x^a(1))

print,a

return

end


