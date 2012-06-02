pro detstsin_cont, sp, gti, st, ps=ps, msc=msc, in=in

;This program is to understand the distribution of SE+PE events
;for the continuum (between the lines) of the spectrum

if (NOT keyword_set(ps)) THEN ps=0
if (NOT keyword_set(msc)) THEN msc=0  ;mass correction


if (ps eq 1) then begin
   set_plot, 'ps'
   device, filename = 'detstsincont.ps'
   device, yoffset = 6.0
   device, ysize = 14.5
   !p.font=0
   device,/times
endif


;;continumm range
range=[[2900,3100],[3350,3450],[3600,3700],[4200,4500],$
[5100,5400],[5800,5900],[6200,6400],[7400,7800],[8250,8450],$
[9100,10600],[11100,11400],[11800,13000],[13200,14000],$
[14600,16300]]


spn=sp   ; make sure not to alter sp

;for raw data
for i=0,18 do spn(*,i)=sp(*,i)/gti(i)  ; make is counts/s

;mass correction
  tmass=0.
  for i=0,18 do tmass=tmass+detmass(i)
  avgmass=tmass/19.

;  for i=0,18 do spn(*,i)=spn(*,i)*avgmass/detmass(i)

st=fltarr(2,19)

for i=0,18 do begin
  for j=0,in do st(0,i)=st(0,i)+total(spn(range(0,j):range(1,j),i)) 
  st(1,i)=sqrt(st(0,i)/gti(i))
  if msc eq 1 then begin
     st(0,i)=st(0,i)*avgmass/detmass(i)
     st(1,i)=st(1,i)*avgmass/detmass(i)
 endif

endfor

xx=findgen(19)

ploterror,xx,(st(0,*)-avg(st(0,*)))/avg(st(0,*)),$
          st(1,*)/avg(st(0,*)),psym=4,/nohat,/noerase,$
	  xrange=[-1,19],/xstyle,xtitle='Pseudo Det. Num.',$
	  ytitle='Relative counts/s/det',yrange=[-0.06,0.04]
oplot,[0,19],[0,0]

if ps eq 1 then begin
   device,/close
   set_plot,'x'
endif

end
