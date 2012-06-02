pro detst_line, sp, gti, st ,elin, ps=ps, sa=sa


;This program is to get the distribution of counts under a 
;nuclear line for multiple events (Pseudo detectors 19-60)
;Fits a line with given centroid energy with line+gaussian,
;saves the area under. Corrects for the mass distribution
;Assuming spe is in counts, not counts/s


spn=sp   ; make sure not to alter sp

;for raw data
;for i=19,60 do spn(*,i)=sp(*,i)/gti(i)  ; make is counts/s

;mass correction should be done at the end to avoid miscalculation of errors
tmass=0.
for i=19,60 do tmass=tmass+detmass(i)
avgmass=tmass/42.

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

st=fltarr(2,42)   ;relative rates and the errors
wl=fltarr(42)	  ; widths of the fits for sanity

for i=19,60 do begin

;fit for all pseudo detectors

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


wl(i-19)=wlin(0)

   st(0,i-19)=a(0)*sqrt(2.*!PI)*(sqrt(2.)*a(2)) ;area under the gaussian
   st(1,i-19)=sqrt(st(0,i-19)/gti(i))  ;error (Poission)

; correct for mass
   
   st(0,i-19)=st(0,i-19)*avgmass/detmass(i)
   st(1,i-19)=st(1,i-19)*avgmass/detmass(i)


endfor

;plot for sanity
if sa eq 1 then !p.multi=[0,1,2]

xx=findgen(42)
ploterror,xx+19,(st(0,*)-avg(st(0,*)))/avg(st(0,*)),$
          st(1,*)/avg(st(0,*)),psym=4,/nohat,xrange=[18,61],$
	  /xstyle,xtitle='Pseudo det. num.',$
	  ytitle='Relative Counts/s/det',title=string(clin(0)/8.)

if sa eq 1 then begin
   plot,wl
  !p.multi=0
endif 

if ps eq 1 then begin
  device,/close
  set_plot,'x'
endif


end
