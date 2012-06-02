pro morg
;,rv,ro,ta

f=findgen(5000)/10.+0.1
ro=x_rate
rv=40.
ta=[2.5,3.0,6.0,10.0,15.0]

;print,rv(1)

mo=fltarr(5000)
;print,f
for i=0,4 do mo=mo+2.*rv(i)*ro*sin(!PI*ta(i)*1e-3*f)^2/(!PI*!PI*f*f)

;print,mo
    
oplot,f,2.+mo
oplot,f,2.+2.*80.*ro*sin(!PI*2.5e-3*f)^2/(!PI*!PI*f*f),psym=3

end
