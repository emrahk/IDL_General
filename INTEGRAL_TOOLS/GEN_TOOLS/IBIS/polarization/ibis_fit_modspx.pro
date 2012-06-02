pro ibis_fit_modspx, data, data_pol, data_avgb, databack, guess, res, disp=disp, enc=enc, bins=bins, in=in, out=out, ps=ps, hisback, hisavgback

if (NOT keyword_set(disp)) then disp=[5.,100.]
if (NOT keyword_set(bins)) then bins=18.

if (keyword_set(ps)) then begin
   set_plot,'ps'
   device,filename='polsign.ps'
   !p.font=0
   device,/times
endif

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

normhis=his/avg(his)
hispoln=hispol/normhis


hisavgback=histogram(datamul_avgb.ang,min=0,binsize=bins)
hisback=histogram(datamul_back.ang,min=0,binsize=bins)

ff=1000000./130000.

err=sqrt(2.*((hisback*ff)+his)*ff)

hisavgback=hisavgback*total(hisback)/total(hisavgback)
hisbe=(hisback-hisavgback)*ff
hispoln=hispoln*ff+hisbe

xax=(findgen(360/bins)*bins)+(bins/2)

print,'err',err


ploterror,xax,hispoln,replicate((bins/2),(360/bins)),$
          [err,err],psym=1,$
          /nohat,xr=[0,360],/xstyle,$
;          yr=[-max(hispol-his),max(hispol-his)]*1.2,$
        yr=[0.,max(hispoln)]*1.2, charsize=1.2,$ 
       /ystyle,xtit='Scatter Azimuth Angle (degrees)',ytit='Cnts/bin',$
        xtickv=[0.,90.,180.,270.,360.],xticks=5


hishpoln=hispoln

modelname='cosfit'
angs=(findgen(360/bins)*bins)+(bins/2)
w=1./err

a=guess

yfit = curvefit(angs, hishpoln, w, a, sigmaa, function_name = modelname)
array = [transpose(a), transpose(sigmaa)]
print, array


x=findgen(360)
f=a(0)+a(1)*cos(2*((x-a(2))*!PI/180.))
plot,x,f,xr=[0,360],/xstyle,/ystyle,/noerase,$
xtickname=replicate(' ',5),ticklen=0.,$
;yr=[-max(hispol-his),max(hispol-his)]*1.2
yr=[0.,max(hispoln)]*1.2,charsize=1.2


res=array
modul=res(*,1)/res(0,0)
print,'Q=',reform(modul)

if (keyword_set(ps)) then begin
   device,/close
   set_plot,'x'
endif

end
