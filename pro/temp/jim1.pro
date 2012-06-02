 en=[13.,20.,30.,40.,50.,60.,70.,80.,89.,91.,100.,200.,300.,400.,500.,600.,$
700.,800.,900.,1000.,2000.,3000.,4000.,5000.,6000.,7000.,8000.,9000.,10000.]
 x1=[0.06,0.12,0.15,0.15,0.12,0.09,0.08]    
 x2=154.3*en(7:27)^(-1.745)
rho=[5231.*en(0:8)^(-1.903),966640.*en(9:27)^(-2.624)]
x=[x1,x2]
d=11.34
tau=rho*d
thick=0.06
b1=x*0.12
b2=x*0.88*exp(-tau*thick)
loadct,11
plot,en,b1,/xlog,/ylog,xtitle='energy(keV)',ytitle='Photons/(cm^2 sec keV)',$
color=35
oplot,en,b2,color=105
oplot,[50.,50.],[1e-6,1e-1]
oplot,en,b1+b2,color=205
total=0.
for i=0,25 do total=total+(b1(i)+b2(i))*(en(i+1)-en(i))
oplot,[1000,3000],[0.008,0.008],color=35
xyouts,3200,0.007,'Aperture'
oplot,[1000,3000],[0.02,0.02],color=105
xyouts,3200,0.019,'Shield leak'
xyouts,3200,0.013,'(0.6 mm)'
oplot,[1000,3000],[0.04,0.04],color=205
xyouts,3200,0.039,'Total'
print,total
end
