;first fft first 50
; modifying for idf2_

t=findgen(32768.)/1024.
offset0=16l*1024l
;offset0=0l
pt_n=fltarr(32768)
good_n=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18]
sz0_n=size(cts_n)
cts_all_n=lonarr(sz0_n(4))
for j=0l,(sz0_n(4)-1) do $
 cts_all_n(j)=cts_n(2,0,0,j)+cts_n(2,1,0,j)+cts_n(2,2,0,j)+cts_n(2,3,0,j)
sz=size(good_n)
tot_n=intarr(sz(1))
for i=0,(sz(1)-1) do begin
    offset=offset0+good_n(i)*65536l
    fft_f,t,cts_all_n(offset:offset+32767l),f,p,frange=[0.02,512]
    pt_n=pt_n+p
    tot_n(i)=total(cts_all_n(offset:offset+32767l))
    print,offset
endfor
total_n=total(tot_n)
plot_oi,f,pt_n/sz(1)
end
