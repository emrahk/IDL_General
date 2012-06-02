pro ibis_fit_modnorm, data, data_pol, guess, res, disp=disp, in=in, out=out, bins=bins,ps=ps,enc=enc


if (NOT keyword_set(disp)) then disp=[5.,100.]
if (NOT keyword_set(bins)) then bins=18.
if (NOT keyword_set(in)) then in=5.
if (NOT keyword_set(out)) then out=10.
if (NOT keyword_set(enc)) then enc=[20.,160.,700.]

if (keyword_set(ps)) then begin
   set_plot,'ps'
   device,filename='polsignb.ps'
   !p.font=0
   device,/times
endif

cutsan2, data, datamul, foo, boo, enc=enc, in=in, out=out, $
disp=disp

cutsan2, data_pol, datamul_pol, foo, boo, enc=enc, in=in, out=out, disp=disp

;pixellate to match the real data
pixellate, datamul, angnp
pixellate, datamul_pol, angpol

hispol=histogram(angpol,min=0,binsize=bins)
his=histogram(angnp,min=0,binsize=bins)

normhis=his/avg(his)
hispoln=hispol/normhis

;normhis=hispol/avg(hispol)
;hispoln=his/normhis

xax=(findgen(360/bins)*bins)+(bins/2)


;ff=1000000./130000.
ff=1.

ploterror,xax,hispoln*ff,replicate(6.,40),sqrt(2.*his*ff),psym=1,/nohat,$
          xr=[0,360],/xstyle,yr=[0.,max(hispoln)*ff]*1.2,$
         /ystyle,xtit='Scatter Azimuth Angle (degrees)',ytit='Cnts/bin'


hishpoln=hispoln

modelname='cosfit'
angs=(findgen(360/bins)*bins)+(bins/2)
w=1./(2.*hishpoln*ff)

a=guess

yfit = curvefit(angs, hishpoln*ff, w, a, sigmaa, function_name = modelname)
array = [transpose(a), transpose(sigmaa)]
print, array

x=findgen(360)
f=a(0)+a(1)*cos(2*((x-a(2))*!PI/180.))
plot,x,f,xr=[0,360],/xstyle,/ystyle,/noerase,$
xtickname=replicate(' ',6),ticklen=0.,yr=[0.,max(hispoln)*ff]*1.2

res=array
modul=res(*,1)/res(0,0)
print,'Q=',reform(modul)
;print,res

;print,'Q=',(max(hispoln*ff)-min(hispoln*ff))/(max(hispoln*ff)+min(hispoln*ff))

if (keyword_set(ps)) then begin
   device,/close
   set_plot,'x'
endif

end
