;first fft first 50
; modifying for background 

t=findgen(6144)/512.
offset=25600l
pt=fltarr(6144)

;plot,cts(2,1,0,offset:offset+6144)
for i=0,15 do begin
    fft_f,t,cts(0,1,0,offset:offset+6144),f,p,frange=[0.06,256]
    pt=pt+p
    offset=offset+64l*512l
endfor
plot,f,pt/16.,xrange=[0,32]
end
