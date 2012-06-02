pro hexde_fit,ro,xf,fs,mo_t



ta_fit=[2.5,4.5,7.,10.,14.,25.,35.]
rv_fit=[58.496,15.229,15.007,9.456,1.619,0.621,0.518]*xf

tot=0
for i=0,6 do tot=tot+ta_fit(i)*rv_fit(i)
print,1.-tot/1000.
print,total(rv_fit)
print,rv_fit

oplot,fs,2.+2.*rv_fit(0)*ro*sin(!PI*ta_fit(0)*1e-3*fs)^2/(!PI*!PI*fs*fs),line=2
;oplot,fs,2.+2.*rv_fit(1)*ro*sin(!PI*ta_fit(1)*1e-3*fs)^2/(!PI*!PI*fs*fs),line=2
;oplot,fs,2.+2.*rv_fit(2)*ro*sin(!PI*ta_fit(2)*1e-3*fs)^2/(!PI*!PI*fs*fs),line=2
oplot,fs,2.+2.*rv_fit(4)*ro*sin(!PI*ta_fit(4)*1e-3*fs)^2/(!PI*!PI*fs*fs),line=2
oplot,fs,2.+2.*rv_fit(5)*ro*sin(!PI*ta_fit(5)*1e-3*fs)^2/(!PI*!PI*fs*fs),line=2
oplot,fs,2.+2.*rv_fit(6)*ro*sin(!PI*ta_fit(6)*1e-3*fs)^2/(!PI*!PI*fs*fs),line=2

szfs=size(fs)
mo_t=fltarr(szfs(1))

for i=0,6 do mo_t=mo_t+2.*rv_fit(i)*ro*sin(!PI*ta_fit(i)*1e-3*fs)^2/(!PI*!PI*fs*fs)
oplot,fs,2.+mo_t,line=0

;

end
