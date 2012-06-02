pro gdhm2_5

kpc=3.086e21
tlast=4*kpc/30.e5
time=tlast*findgen(500)/500.

z=10*time
r=(8.5*kpc*1e-5)-(30*time)

;!p.multi=[0,1,2]
plot,z,r

om=280.e5/(8.5*kpc)
x=(40.*time)+8.5*kpc*1e-5*cos(om*time)
y=8.5*kpc*1e-5*sin(om*time)

xpr=8.5*kpc*1e-5*cos(om*time)
;plot,x,y,yrange=[-3.e17,3.e17],xrange=[-4.e17,4.e17],/xstyle,/ystyle
;oplot,xpr,y
end
