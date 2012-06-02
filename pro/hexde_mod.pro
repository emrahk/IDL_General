pro hexde_mod,ro,xf,fs,mo_t


;plot_oi,f_b,ps,psym=10,yrange=[1.6,2.8]
fr=findgen(5000)/10.+0.1
;ro=s_avg/4.
;ro=58.63
;xf=avg(gxuld)/85.

ta_fit=[2.5,4.,5.,7.,10.,14,25,35]
rv_fit=[90.3*4.8+25.35,35.6*4.8+12.38,30.1*4.8+10.51,7.79*4.8+26.07,$
13.25+25.,16.,8.,3.]*0.12*xf

tot=0
for i=0,7 do tot=tot+ta_fit(i)*rv_fit(i)
print,1.-tot/1000.
print,total(rv_fit)
print,rv_fit

oplot,fr,2.+2.*rv_fit(0)*ro*sin(!PI*ta_fit(0)*1e-3*fr)^2/(!PI*!PI*fr*fr),line=2
oplot,fr,2.+2.*rv_fit(1)*ro*sin(!PI*ta_fit(1)*1e-3*fr)^2/(!PI*!PI*fr*fr),line=2
oplot,fr,2.+2.*rv_fit(2)*ro*sin(!PI*ta_fit(2)*1e-3*fr)^2/(!PI*!PI*fr*fr),line=2
oplot,fr,2.+2.*rv_fit(7)*ro*sin(!PI*ta_fit(3)*1e-3*fr)^2/(!PI*!PI*fr*fr),line=2
oplot,fr,2.+2.*rv_fit(4)*ro*sin(!PI*ta_fit(4)*1e-3*fr)^2/(!PI*!PI*fr*fr),line=2
oplot,fr,2.+2.*rv_fit(5)*ro*sin(!PI*ta_fit(5)*1e-3*fr)^2/(!PI*!PI*fr*fr),line=2
oplot,fr,2.+2.*rv_fit(6)*ro*sin(!PI*ta_fit(6)*1e-3*fr)^2/(!PI*!PI*fr*fr),line=2

szfs=size(fs)
mo_t=fltarr(szfs(1))
fr=fs
for i=0,7 do mo_t=mo_t+2.*rv_fit(i)*ro*sin(!PI*ta_fit(i)*1e-3*fr)^2/(!PI*!PI*fr*fr)
oplot,fr,2.+mo_t,line=0

;

end
