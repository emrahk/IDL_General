pro detst_line_sin, sp, gti, st ,elin, ps=ps, sa=sa

;This program is to get the distribution of counts under a 
;nuclear line for single and PSD events (Pseudo detectors 
;0-18) Fits a line with given centroid energy with 
;line+gaussian, saves the area under
;Assuming spe is in counts, not counts/s

spn=sp   ; make sure not to alter sp

;for raw data
for i=0,18 do spn(*,i)=sp(*,i)/gti(i)  ; make is counts/s

;mass correction
tmass=0.
for i=0,18 do tmass=tmass+detmass(i)
avgmass=tmass/19.

if (NOT keyword_set(ps)) THEN ps=0
if (NOT keyword_set(sa)) THEN sa=0  ; sanity check


if (ps eq 1) then begin
   set_plot, 'ps'
   device, filename = 'detst.ps'
   device, yoffset = 6.0
   device, ysize = 14.5
   !p.font=0
   device,/times
endif

;;all range

st=fltarr(2,19)
wl=fltarr(19)

for i=0,18 do begin

  x=findgen(16384)
  clin=fltarr(2)
  wlin=fltarr(2)
  cntlin=fltarr(2)
  chisq=fltarr(2)

  ph=spn(*,i)
  spxu=reform(ph)
  dspx=sqrt(spxu)>1.0
  nstart=fix(elin)-50
  nstop=nstart+100
  ymax=max(spxu(nstart:nstop),imax)
  xmax=x[imax+nstart]

  y=GAUSSFIT(x(nstart:nstop),spxu(nstart:nstop),a,NTERMS=5,$
                             ESTIMATES=[ymax,xmax,8.,0.,0.0000])
  clin(0)=a(1)
  wlin(0)=sqrt(8.*alog(2.))*a(2)
  cntlin(0)=total(spxu(nstart:nstop))-a(3)*$
                          float(nstop-nstart+1)
  chisq(0)=total((spxu(nstart:nstop)-y(0:nstop-nstart))^2/$
              dspx(nstart:nstop)^2)/float(nstop-nstart+1-4)


wl(i)=wlin(0)
   print,a(1)
   st(0,i)=a(0)*sqrt(2.*!PI)*(sqrt(2.)*a(2))
   st(1,i)=sqrt(st(0,i)/gti(i))

;mass correction

   st(0,i)=st(0,i)*avgmass/detmass(i)
   st(1,i)=st(1,i)*avgmass/detmass(i)

endfor

if sa eq 1 then !p.multi=[0,1,2]

xx=findgen(19)
ploterror,xx,(st(0,*)-avg(st(0,*)))/avg(st(0,*)),$
          st(1,*)/avg(st(0,*)),psym=4,/nohat,xrange=[-1,19],$
	  /xstyle,xtitle='Pseudo det. num.',$
	  ytitle='Relative Counts/s/keV',title=string(clin(0)/8.)

oplot,[-1,19],[0.0,0.0]

if sa eq 1 then begin
  plot,wl,xrange=[-1,19],/xstyle
  !p.multi=0
endif

if ps eq 1 then begin
  device,/close
  set_plot,'x'
endif



end
