r_corb=fltarr(100,16384)
for i=0,99 do r_corb(i,*)=r+b+sqrt((so+b)*512.)*randomn(s,16384)

psb=fltarr(8159)

for i=0,99 do begin
fft_f,t,r_corb(i,*)/512.,f,p,frange=[0.04,255]
psb=psb+p
endfor
psb=psb/100.
end
