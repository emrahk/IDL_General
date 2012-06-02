;pro allahim sen sabir ver

;this program is written to calculate energy deposition on CsI
;protons

cutoff=3051.
k=32.04

engs=[3510.,4620.,20000.,50000.,100000.,500000.,1000000.]
avgs=fltarr(6)
flux=fltarr(6)
for i=0,5 do begin
   avgs(i)=(engs(i)^(-0.6)-engs(i+1)^(-0.6))*1.6/(0.6*$
                     (engs(i)^(-1.6)-engs(i+1)^(-1.6)))
   flux(i)=((engs(i)/1000.)^(-1.6)-(engs(i+1)/1000.)^(-1.6))*k/1.6
endfor
print,avgs
print,flux
edop=fltarr(6)
elost=fltarr(6)
m=6.9*938.
zi=3.
zm=82.
i=10.
a=207.
for j=0,5 do begin
en=avgs(j)
x=en/m
beta=sqrt((x^2+2*x)/(1+x^2+2*x))
fb=alog(1.022e6*beta*beta/(1-beta*beta))-beta*beta
;print,beta,fb
bs=beta*beta

bb=(0.30708/bs)*zi^2*(zm/a)*(fb-alog(i*zm))
elost(j)=bb*0.4*11.35
endfor
print,elost



;m=20.18*938.
;zi=10.
zm=54.
i=9.
a=129.
for j=0,5 do begin
en=avgs(j)-elost(j)
x=en/m
beta=sqrt((x^2+2*x)/(1+x^2+2*x))
fb=alog(1.022e6*beta*beta/(1-beta*beta))-beta*beta
;print,beta,fb
bs=beta*beta

bb=(0.30708/bs)*zi^2*(zm/a)*(fb-alog(i*zm))
;print,bb
edop(j)=bb*4.53
;print,edop

endfor
print,edop
end
