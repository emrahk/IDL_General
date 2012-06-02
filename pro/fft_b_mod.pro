r_corb_mod=fltarr(100,16384)
for i=0,99 do r_corb_mod(i,*)=r+b+sqrt(so*512.)*randomn(s,16384)+sqrt(b*512.)*randomn(s,16384)

psb_mod=fltarr(8159)

for i=0,99 do begin
fft_f,t,r_corb_mod(i,*)/512.,f,p,frange=[0.04,255]
psb_mod=psb_mod+p
endfor
psb_mod=psb_mod/100.
end
