pro ibis_fit_modnkc, data, data_pol, databack, guess, res, disp=disp, in=in,$
out=out, bins=bins, hisback, hisavgback

if (NOT keyword_set(disp)) then disp=[5.,100.]
if (NOT keyword_set(bins)) then bins=18.

;datamul=data
;datamul_pol=data_pol
;datamul_avgb=data_avgb
;datamul_back=databack

cutsan2, data, datamul, foo, boo, enc=[20.,160.,300.], in=in, out=out, disp=disp
cutsan2, data_pol, datamul_pol, foo, boo, enc=[20.,160.,300.], in=in, out=out, disp=disp
cutsan2, databack, datamul_back, datamul_avgb, boo, enc=[20.,160.,300.], in=in, out=out, disp=disp

nback=n_elements(datamul_back)

;pixellate to match the real data
pixellate, datamul, angnp
pixellate, datamul_pol, angpol

hispol=histogram(angpol,min=0,binsize=bins)
his=histogram(angnp,min=0,binsize=bins)

print,avg(hispol),avg(his)

his=his*total(hispol)/total(his)

hisavgback=histogram(datamul_avgb.ang,min=0,binsize=bins)
hisback=histogram(datamul_back.ang,min=0,binsize=bins)
help,hisback

print,avg(hisavgback),avg(hisback)

err=sqrt(2.*(hisback+hispol))

hisavgback=hisavgback*total(hisback)/total(hisavgback)

hisbe=hisback-hisavgback
hispol=hispol+hisbe

print,avg(hispol),avg(his)

hispol=[hispol,hispol]
his=[his,his]

xax=(findgen(720/bins)*bins)+(bins/2.)


ploterror,xax,hispol-his,replicate(6.,40),[err,err],psym=1,$
          /nohat,xr=[-30,750],/xstyle,$
;          yr=[-max(hispol-his),max(hispol-his)]*1.2,$
          yr=[-100.,100.],$
         /ystyle,xtit='Scatter Azimuth Angle',ytit='Cnts/bin - syst.'


hish=his(0:(360/bins)-1)
hispolh=hispol(0:(360/bins)-1)

modelname='cosfit'
angs=(findgen(360/bins)*bins)+(bins/2.)
w=1./err^2.

a=guess

yfit = curvefit(angs, hispolh-hish, w, a, sigmaa, function_name = modelname)
array = [transpose(a), transpose(sigmaa)]
print, array

x=findgen(720)
f=a(0)+a(1)*cos(2*((x-a(2))*!PI/180.))
plot,x,f,xr=[-30,750],/xstyle,/ystyle,/noerase,$
xtickname=replicate(' ',6),ticklen=0.,$
$yr=[-max(hispol-his),max(hispol-his)]*1.2
yr=[-100.,100.]

res=array
modul=res(*,1)/avg(his)
print,reform(modul)

end
