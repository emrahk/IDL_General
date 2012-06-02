;first fft first 50
; modifying for idf2_


t=findgen(32768.)/1024.
;offset0=32l*1024l
offset0=0l
pt_j=fltarr(4,32768)
good_j=[0,1,2,3,4,5,6]
;sz0_j=size(cts_j)
sz=size(good_j)
tot_j=intarr(4,sz(1))
for j=0,3 do begin
    for i=0,(sz(1)-1) do begin
        offset=offset0+good_j(i)*65536l
        fft_f,t,cts(2,j,0,offset:offset+32767l),f,p,frange=[0.02,512]
        for k=0l,16383ldo pt_j(j,k)=pt_j(j,k)+p(k)
        tot_j(j,i)=total(cts(2,j,0,offset:offset+32767l))
        print,offset
    endfor
endfor
total_j=lonarr(4)
for m=0,3 do total_j(m)=total(tot_j(m,*))
;plot_oi,f,pt_j/sz(1)
end
