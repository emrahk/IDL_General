pro flc_plot, ps=ps

specfits,'/boris/wc/4U1538-52/persist/pca_01-02-04.bak',bg_channel,bg_counts,bg_syserr,bg_quality

if (keyword_set(ps)) then begin
   set_plot,'ps'
   device,file='plotlcs.ps',/portrait,xoffset=1,yoffset=1,xsize=6.5,ysize=9.0,/inches
   xmar=!x.margin
   ymar=!y.margin
   pfont=!p.font
   !x.margin=[0,0]
   !y.margin=[0,0]
   !p.font=0
endif

livetime=33280.0
numbins=1.
bg=fltarr(8)

bg(0)=total(bg_counts(5:20))/(livetime*numbins)
bg(1)=total(bg_counts(21:36))/(livetime*numbins)
bg(2)=total(bg_counts(37:50))/(livetime*numbins)
bg(3)=total(bg_counts(51:58))/(livetime*numbins)
bg(4)=total(bg_counts(59:66))/(livetime*numbins)
bg(5)=total(bg_counts(67:73))/(livetime*numbins)
bg(6)=total(bg_counts(74:81))/(livetime*numbins)
bg(7)=total(bg_counts(82:88))/(livetime*numbins)

psym=!p.psym
!p.psym=10
pmulti=!p.multi
!p.multi=[0,1,8]


fl=['/boris/wc/4U1538-52/pca_event/pcaevents.bit.03-08.fes', $
    '/boris/wc/4U1538-52/pca_event/pcaevents.bit.08-13.fes', $
    '/boris/wc/4U1538-52/pca_event/pcaevents.bit.13-18.fes', $
    '/boris/wc/4U1538-52/pca_event/pcaevents.bit.18-23.fes', $
    '/boris/wc/4U1538-52/pca_event/pcaevents.bit.23-28.fes', $
    '/boris/wc/4U1538-52/pca_event/pcaevents.bit.28-33.fes', $
    '/boris/wc/4U1538-52/pca_event/pcaevents.bit.33-38.fes', $
    '/boris/wc/4U1538-52/pca_event/pcaevents.bit.38-43.fes']

yt=['3-8keV','8-13keV','13-18keV','18-23keV','23-28keV','28-33keV','33-38keV','38-43keV']


for i=0,7 do begin
   lcfits,fl(i),phase,xaxe,rate,error
   rate=rate-bg(i)
   plot,[phase,phase+1],[rate,rate],ytitle=yt(i)
   oploterr,[phase,phase+1],[rate,rate],[error,error],3
endfor


!p.psym=psym
!p.multi=pmulti

if (keyword_set(ps)) then begin
   device,/close
   set_plot,'x'
   !x.margin=xmar
   !y.margin=ymar
   !p.font=pfont
endif

return
end


