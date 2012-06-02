pro plot_detline,pha,dt,elin=elin,xr=xr,yr=yr,ps=ps

;this program plots a given spectrum for a given detector in a given
;range, and overplots a fit to the line with centroid energy of elin


if (NOT keyword_set(ps)) THEN ps=0
if (NOT keyword_set(xr)) THEN xr=[0.,16364.]
if (NOT keyword_set(yr)) THEN yr=[0.,0.001]
if (NOT keyword_set(elin)) THEN elin=1450



if (ps eq 1) then begin
   set_plot, 'ps'
   device, filename = 'phdet_'+strtrim(string(det),1)+'.ps'
   device, yoffset = 6.0
   device, ysize = 14.5
   !p.font=0
   device,/times
endif


ph=pha(*,dt)

;first plot it

plot,ph,xrange=xr,yrange=yr,/xstyle,/ystyle,$
xtitle='Channels',ytitle='Counts/sec',charsize=1.2,$
title='Spectrum of det.'+string(dt)

; this is for fitting

x=findgen(16384)
clin=fltarr(2)
wlin=fltarr(2)
cntlin=fltarr(2)
chisq=fltarr(2)

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

z=(x-a(1))/a(2)
oplot,a(0)*exp(-(z^2)/2.)+a(3)+a(4)*x

;print, fit parameters
print,a

if (ps eq 1) then begin
  device,/close
  set_plot,'x'
endif


end
