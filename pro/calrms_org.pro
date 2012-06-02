pro calrms,res,sig,intzt,intzi

a=res
spawn,'pwd',pwd
save,a,filename=pwd+'/temp_lor.dat'
int=sqrt(qromb('lorentz',0D,20D,/DOUBLE))

a=res
a(0)=res(0)+sig(0)
save,a,filename=pwd+'/temp_lor.dat'
intx=sqrt(qromb('lorentz',0D,20D))
err=intx-int
intzt=[int,err]

a=res
Q=double(2.*a(2)/a(1))
int=sqrt(a(0)*(0.5-(atan(-Q)/!PI)))
err=sig(0)/(4.*int)
intzi=[int,err]

end
