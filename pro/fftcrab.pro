;first fft first 50

t=findgen(8192)/512.
offset=0l
pt=fltarr(8192)

;plot,cts(2,1,0,offset:offset+8192)
for i=0,30 do begin
    fft_f,t,cts(2,1,0,offset:offset+8191),f,p,frange=[0.04,256]
    pt=pt+p
    offset=offset+16383
endfor
pt=pt/31.
rbned=rebin(pt,256)
rbnf=rebin(f,256)
plot_oi,rbnf,rbned,xrange=[0.08,200],psym=10,/xstyle
;plot,f,pt
psp=pt
;rebps
;plot_oi,rbf,rbpspec,xrange=[0.08,200],psym=10,/xstyle

end
