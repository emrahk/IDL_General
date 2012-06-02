pro fit_mod, datamul, datamul_pol, guess, res

plot_pairs,datamul,histnp,hispol
plot_pairs,datamul_pol,histpol,his

normhis=his/avg(his)
hispoln=hispol/normhis

;hispol=[hispol,hispol]
;his=[his,his]

xax=findgen(6)*60.

ploterror,xax,hispoln,replicate(6.,6),sqrt(2.*his),psym=1,/nohat,$
          xr=[-30,390],/xstyle,yr=[0,max(his)]*1.2,$
         /ystyle,xtit='Scatter Azimuth Angle',ytit='Cnts/bin'


hish=his(0:5)
hispolh=hispol(0:5)

modelname='cosfit'
angs=findgen(6)*60.
w=1./(2.*his)

a=guess


yfit = curvefit(angs, hispoln, w, a, sigmaa, function_name = modelname)
array = [transpose(a), transpose(sigmaa)]
print, array

x=findgen(360)
f=a(0)+a(1)*cos(2*((x-a(2))*!PI/180.))
plot,x,f,xr=[-30,390],/xstyle,/ystyle,/noerase,$
xtickname=replicate(' ',6),ticklen=0.,yr=[0.,max(his)]*1.2

res=array
modul=res(*,1)/avg(his)
print,reform(modul)

chi2=total((f(xax)-hispoln)^2./(2.*his))
print,chi2,chi2/3.

chi2avg=total((avg(hispoln)-hispoln)^2./(2.*his))
print,chi2avg,chi2avg/5.

print,avg(hispoln),hispoln,2*his

end
