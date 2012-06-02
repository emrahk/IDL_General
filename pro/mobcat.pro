pro mobcat

openr,1,'/data1/ek/czt/meas/catmes.dat'
dat=fltarr(4,45)
readf,1,dat
close,1


D=0.218
f=7.15/9.5
Vt=150.
T=(Vt/dat(3,*))*dat(2,*)*1e-6
mu=D^2/(f*dat(0,8)*T)
print,mu
plot,dat(0,*),mu,psym=6,title='hole mobility from slope',xtitle='voltage',$
ytitle='mobility (cm^2/V s)'
print,total(mu(20:44))/25.
xyouts,100,30,'avg=22'
end
