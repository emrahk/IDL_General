pro ibis_fit_modsp, data, data_pol, data_avgb, databack, guess, res, disp=disp, enc=enc, bins=bins, in=in, out=out, hisback, hisavgback

if (NOT keyword_set(disp)) then disp=[5.,100.]
if (NOT keyword_set(tol)) then tol=0.15
if (NOT keyword_set(bins)) then bins=18.


cutsan2, data, datamul, foo, boo, enc=enc,in=in,out=out,disp=disp
cutsan2, data_pol, datamul_pol, foo, boo, enc=enc,in=in,out=out,disp=disp
cutsan2, data_avgb, datamul_avgb, foo, boo, enc=enc,in=in,out=out,disp=disp
cutsan2, databack, datamul_back, foo, boo, enc=enc,in=in,out=out,disp=disp

nback=n_elements(datamul_back)

;pixellate to match the real data
pixellate, datamul, angnp
pixellate, datamul_pol, angpol

hispol=histogram(angpol,min=0,binsize=bins)
his=histogram(angnp,min=0,binsize=bins)

his=his*total(hispol)/total(his)


hisavgback=histogram(datamul_avgb.ang,min=0,binsize=bins)
hisback=histogram(datamul_back.ang,min=0,binsize=bins)

err=sqrt(2.*(hisback+hispol))

hisavgback=hisavgback*total(hisback)/total(hisavgback)
hisbe=hisback-hisavgback
hispol=hispol+hisbe


hispol=[hispol,hispol]
his=[his,his]

xax=(findgen(720/bins)*bins)+(bins/2.)


ploterror,xax,his-hispol,replicate(6.,40),[err,err],psym=1,$
          /nohat,xr=[-30,750],/xstyle,$
          yr=[-max(hispol-his),max(hispol-his)]*1.2,$
         /ystyle,xtit='Scatter Azimuth Angle',ytit='Cnts/bin - syst.'


hish=his(0:(360/bins)-1)
hispolh=hispol(0:(360/bins)-1)

modelname='cosfit'
angs=(findgen(360/bins)*bins)+(bins/2.)
w=1./err^2.


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
