pro calrms,res,sig,intzt,intzi,frange=frange

if NOT keyword_set(frange) then frange=[0D, 20D]

a=res
;spawn,'pwd',pwd
save,a,filename='~/temp_lor.dat'
int=sqrt(qromb('lorentz',frange[0],frange[1],/DOUBLE))

a=res
a(0)=res(0)+sig(0)
save,a,filename='~/temp_lor.dat'
intx=sqrt(qromb('lorentz',frange[0],frange[1]))
err=intx-int
intzt=[int,err]
;intzt=[0,0]

a=res
Q=double(2.*a(2)/a(1))
int=sqrt(a(0)*(0.5-(atan(-Q)/!PI)))
err=sig(0)/(4.*int)
intzi=[int,err]

end
