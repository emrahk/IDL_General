pro plotpseudo,map,map_err,rate,rate_err,avgr

;first symmetrize


mapx=[[1,2,3,4,5,6],[8,9,2,0,6,7],[9,10,11,3,0,1],[2,11,12,13,4,0],$
[0,3,13,14,15,5],[6,0,4,15,16,17],[7,1,0,5,17,18],[100,8,1,6,18,100],$
[100,100,9,1,7,100],[100,100,10,2,1,8],[100,100,100,11,2,9],$
[10,100,100,12,3,2],[11,100,100,100,13,3],[3,12,100,100,14,4],$
[4,13,100,100,100,15],[5,4,14,100,100,16],[17,5,15,100,100,100],$
[18,6,5,16,100,100],[100,7,6,17,100,100]]

;plot,[0.,0.],[0.,0.],xr=[0.,100.],yr=[0.,20.]

num=0.
tot=0.

rate=fltarr(61)
rate_err=fltarr(61)

for i=0,18 do begin
 for j=0,5 do begin
    if mapx(j,i) ne 100 then begin
      a=i
      psd=psdetnum(a,mapx(j,a))
      ;print,psd
      ;psd=3
      rate1=map(i,j)
      rate1_err=map_err(i,j)
      ind=where(mapx(*,mapx(j,i)) eq i)
      rate2=map(mapx(j,i),ind(0))
      rate2_err=map_err(mapx(j,i),ind(0))
      rate(psd)=rate1+rate2
      rate_err(psd)=(rate1_err+rate2_err)/sqrt(2.)
      num=num+1.
      tot=tot+rate(psd)
      print,i
  endif else print,'skip'
endfor
endfor


avgr=tot/num

ploterror,((rate-avgr)/avgr),rate_err/avgr,psym=5,/nohat,xr=[18,61],/xstyle,$
xtitle='Pseudo det. num.',ytitle='(rate-avg)/avg'

end
