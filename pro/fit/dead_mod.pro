pro dead_mod, x, a, f, pder

n = n_elements(x) & f = fltarr(n)
print,'hello'

ta=[2.5,4.5,7.,10.,14.,25.,35.]


for i=0,6 do a(i)=abs(a(i))
for i=1,6 do if a(i) gt a(i-1) then begin
    p=a(i)
    a(i)=a(i-1)
    a(i-1)=p
    endif
for i=0,6 do f=f+2.*a(i)*sin(!PI*ta(i)*1e-3*x)^2/(!PI*!PI*x*x)
f=f+2.

pder = fltarr(n_elements(x),n_elements(a))

for i=0,6 do pder(*,i)=2.*sin(!PI*ta(i)*1e-3*x)^2/(!PI*!PI*x*x)

return

end
