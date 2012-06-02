pro fit_mod, datamul, datamul_pol, guess, res

plot_pairs,datamul,histnp,hispol
plot_pairs,datamul_pol,histpol,his

his=his*total(hispol)/total(his)

hispol=[hispol,hispol]
his=[his,his]

xax=findgen(12)*60.

ploterror,xax,his-hispol,replicate(6.,12),sqrt(2.*his),psym=1,/nohat,$
          xr=[-30,750],/xstyle,yr=[-max(hispol-his),max(hispol-his)]*1.2,$
         /ystyle,xtit='Scatter Azimuth Angle',ytit='Cnts/bin - syst.'


hish=his(0:5)
hispolh=hispol(0:5)

modelname='cosfit'
angs=findgen(6)*60.
w=1./(2.*hish)

a=guess


yfit = curvefit(angs, hish-hispolh, w, a, sigmaa, function_name = modelname)
array = [transpose(a), transpose(sigmaa)]
print, array

x=findgen(720)
f=a(0)+a(1)*cos(2*((x-a(2))*!PI/180.))
plot,x,f,xr=[-30,750],/xstyle,/ystyle,/noerase,$
xtickname=replicate(' ',6),ticklen=0.,yr=[-max(hispol-his),max(hispol-his)]*1.2

res=array
modul=res(*,1)/avg(his)
print,reform(modul)


end
