r_cor=fltarr(100,16384)
for i=0,99 do r_cor(i,*)=r+sqrt(so*512)*randomn(s,16384)

ps=fltarr(8159)

for i=0,99 do begin
fft_f,t,r_cor(i,*)/512.,f,p,frange=[0.04,255]
ps=ps+p
endfor
ps=ps/100.
end
