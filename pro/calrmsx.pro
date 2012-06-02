pro calrmsx,res,sig,f1,f2,intzt,intzi

f1=double(f1)
f2=double(f2)

a=res
save,a,filename='/home/emrahk/temp_lor.dat'
int=sqrt(qromb('lorentz',f1,f2,/DOUBLE))

a=res
a(0)=res(0)+sig(0)
save,a,filename='/home/emrahk/temp_lor.dat'
intx=sqrt(qromb('lorentz',f1,f2))
err=intx-int
intzt=[int,err]

a=res
Q=double(2.*a(2)/a(1))
int=sqrt(a(0)*(0.5-(atan(-Q)/!PI)))
err=sig(0)/(4.*int)
intzi=[int,err]

end
