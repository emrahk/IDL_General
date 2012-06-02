;pro simul_hexte

a=0.0146955

f=findgen(32l*512l)/64.+0.015625
pow=a*f^(-1.227)
plot,f,pow,/xlog,/ylog,yrange=[1e-7,1],xrange=[0.01,100]

;cons=fltarr(8191)
;for i=1,16381,2 do begin
;cons((i-1)/2)=(pow(i-1)*f(i-1)-pow(i+1)*f(i+1))/(.39)
;endfor

t=findgen(32l*512l)/512.
r=dblarr(32l*512l)
num=8500.*1.04354*0.196898/50.
for i=0,8190 do r=r+num*sqrt(cons(i))*(0.05+sin(2.*!pi*f(2*i+1)*t))
fft_f,t,r/512.,fr,po,frange=[0.04,255]
plot_oo,fr,po/so
oplot,f,pow,line=1
print,avg(r)
;r_cor=r+sqrt(so)*randomn(s,16384)
;print,avg(r_cor)
end
