pro plotst,st,noer=noer,psm=psm,yr=yr,psc=psc, cl=cl

;to plot statistics for ME

if (NOT keyword_set(noer)) THEN noer=0 ;no erase
if (NOT keyword_set(psm)) THEN psm=4  ;plot symbol
if (NOT keyword_set(yr)) THEN yr=[-0.05,0.15]  ;yrange
if (NOT keyword_set(psc)) THEN psc=0
if (NOT keyword_set(cl)) THEN cl=1


if (psc eq 1) then begin
   set_plot, 'ps'
   device, filename = 'detst.ps'
   device, yoffset = 6.0
   device, ysize = 14.5
   !p.font=0
   device,/times
endif

xx=findgen(42)

if (noer eq 0) then begin 
ploterror,xx+19,(st(0,*)-avg(st(0,*)))/avg(st(0,*)),$
          st(1,*)/avg(st(0,*)),psym=psm,/nohat,$
	  xrange=[18,61],/xstyle,xtitle='Pseudo Det. Num.',$
	  ytitle='Relative counts' 
endif
if noer eq 1 then begin
ploterror,xx+19,(st(0,*)-avg(st(0,*)))/avg(st(0,*)),$
          st(1,*)/avg(st(0,*)),psym=psm,/nohat,$
	  xrange=[18,61],/xstyle,xtitle='Pseudo Det. Num.',$
	  ytitle='Relative counts',/noerase,yrange=yr
endif

oplot,[18,61],[0,0]

if ((psc eq 1) and (cl eq 1)) then begin
  device,/close
  set_plot,'x'
endif
end
