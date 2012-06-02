pro detst, sp, gti, st, range=range, ps=ps

if (NOT keyword_set(ps)) THEN ps=0
if (NOT keyword_set(range)) THEN range=[0,16363]

;this program calculates the number of counts/s in each detector in a
;given range

spn=sp
;for i=19,60 do spn(*,i)=spn(*,i)/gti(i) ;assume divided


if ps eq 1 then begin
  set_plot,'ps'
  device,filename='detstall.ps'
  device, yoffset = 6.
  device, ysize = 16.
  ;device, xsize = 12.0
  !p.font=0
  device,/times
endif


;;all range
st=fltarr(2,42)
for i=19,60 do begin
 st(0,i-19)=total(spn(range(0):range(1),i)) 
 st(1,i-19)=sqrt(st(0,i-19)/gti(i))
endfor

xax=findgen(42)+19
ave=avg(st(0,*))
print,ave

ploterror,xax,(st(0,*)-ave)/ave,st(1,*)/ave,psym=4,/nohat,$
	  xtitle="Pseudo det number",xrange=[19,60],/xstyle,$
	  ytitle="Relative counts/s/det",charsize=1.2

if ps eq 1 then begin
  device,/close
  set_plot,'x'
endif
end
