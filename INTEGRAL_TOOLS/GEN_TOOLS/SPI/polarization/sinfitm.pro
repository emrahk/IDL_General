pro sinfitm, x, a, f, pder

n = n_elements(x) & f = fltarr(n)

a(2)=a(2)*!PI/180.
x=x*!PI/180.

f=a(0)+a(1)*sin(2*(x - a(2)))

pder = fltarr(n_elements(x), n_elements(a))

pder(*,0)=1.
pder(*,1)=cos(2*(x+a(2)))
pder(*,2)=-2*sin(2*(x+a(2)))

a(2)=a(2)*180./!PI
x=x*180./!PI

return

end
