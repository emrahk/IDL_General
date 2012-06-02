pro plot_coinc, flname, psflname, erng=erng, strips=stnum, nocomp=nocomp

;;
;; Load in the data
;;
wcmca,flname,/restore,/antic,spec=spec_antic,nrg=nrg_antic
wcmca,flname,/restore,/coinc,spec=spec_coinc,nrg=nrg_coinc

;;
if (keyword_set(erng) eq 0) then erng=[min(nrg_antic),max(nrg_antic)]
if (keyword_set(stnum) eq 0) then stnum=[0,1,2,3]


;;
;; Because IDL sucks   
;;
pmulti = !p.multi
!p.multi=[0,3,4]
csize=1.5
idlsucks=replicate(' ',30)


;;
;; Standard Positioning Variables
;;
xoff=0.05
xgap=0.07
xsiz=(0.99-xoff-2*xgap)/3.
xlab=1.10*xoff

yoff=0.07
ysiz=(0.99-yoff)/4.0

;;
;; Create a postscript plot
;;
set_plot,'ps'
device,filename=psflname,/encapsulated,/inches,xsize=11.0,ysize=5.0


;;
;; Plot Anticoincidence Spectra
;;
nst=4
spec=spec_antic
nrg=nrg_antic

xord = nrg
xttl = 'Energy'

for i=0,nst-2 do begin

   ttl=''
   specnm = 'Strip '+ strcompress(string(stnum(i)),/remove_all)

   plot,xord(i,*),spec(i,*),psym=10,charsize=csize, $
      xstyle=1,xtickname=idlsucks,ytickname=idlsucks,xrange=erng, $
      min_value=ymin,ystyle=0,ytitle='Counts',title=ttl, $
      position=[xoff,yoff+(nst-1-i)*ysiz,xoff+xsiz,yoff+(nst-i)*ysiz]
   xyouts,xlab,yoff+(nst-i-0.25)*ysiz,specnm,/normal,charsize=csize/2.

   wcpeakfind,xord(i,*),spec(i,*),erng,/plot,charsize=csize/2.d

endfor

;;
;; Plot the bottom spectra, along with the x-axis labels
;;
i=nst-1
if (keyword_set(stnum)) then begin
   specnm = 'Strip '+ strcompress(string(stnum(i)),/remove_all)
endif else begin
   specnm = 'Spec '+ strcompress(i,/remove_all)
endelse
plot,xord(i,*),spec(i,*),psym=10,charsize=csize, $
   xstyle=1,xtitle=xttl,ytickname=idlsucks,xrange=erng, $
   ystyle=0,ytitle='Counts',min_value=ymin, $
   position=[xoff,yoff+(nst-i-1)*ysiz,xoff+xsiz,yoff+(nst-i)*ysiz]
xyouts,xlab,yoff+(nst-i-0.25)*ysiz,specnm,/normal,charsize=csize/2.

wcpeakfind,xord(i,*),spec(i,*),erng,/plot, $
      charsize=csize/2.d




;;
;; Plot Coincidence Spectra
;;

specnm=strcompress(string(stnum),/remove_all)
specnm=[specnm(0)+'/'+specnm(1),specnm(0)+'/'+specnm(2), $
        specnm(0)+'/'+specnm(3),specnm(1)+'/'+specnm(2), $
        specnm(1)+'/'+specnm(3),specnm(2)+'/'+specnm(3)]
specnm='Strips '+specnm

;;
;; Plot Gap Spectra
;;

nst=4
spcs=[0,3,5]

spec=spec_coinc
nrg=nrg_coinc

xord = nrg
xttl = 'Energy'

for i=0,nst-3 do begin

   ttl=''

   plot,xord(spcs(i),*),spec(spcs(i),*),psym=10,charsize=csize, $
      xstyle=1,xtickname=idlsucks,ytickname=idlsucks,xrange=erng, $
      min_value=ymin,ystyle=0,ytitle='Counts',title=ttl, $
      position=[xoff+xsiz+xgap,yoff+(nst-1-i)*ysiz, $
         xoff+2*xsiz+xgap,yoff+(nst-i)*ysiz]
   xyouts,xsiz+xgap+xlab,yoff+(nst-i-0.25)*ysiz,specnm(spcs(i)), $
      /normal,charsize=csize/2.

   wcpeakfind,xord(spcs(i),*),spec(spcs(i),*),erng,/plot,charsize=csize/2.d

endfor

;;
;; Plot the bottom spectra, along with the x-axis labels
;;
i=nst-2
plot,xord(spcs(i),*),spec(spcs(i),*),psym=10,charsize=csize, $
   xstyle=1,xtitle=xttl,ytickname=idlsucks,xrange=erng, $
   ystyle=0,ytitle='Counts',min_value=ymin, $
   position=[xoff+xsiz+xgap,yoff+(nst-i-1)*ysiz, $
      xoff+2*xsiz+xgap,yoff+(nst-i)*ysiz]
xyouts,xsiz+xgap+xlab,yoff+(nst-i-0.25)*ysiz,specnm(spcs(i)), $
   /normal,charsize=csize/2.

wcpeakfind,xord(spcs(i),*),spec(spcs(i),*),erng,/plot, $
      charsize=csize/2.d


;;
;; Plot Jumping 1 Strip Spectra
;;

nst=4
spcs=[1,2,4]

spec=spec_coinc
nrg=nrg_coinc

xord = nrg
xttl = 'Energy'

for i=0,nst-3 do begin

   ttl=''

   plot,xord(spcs(i),*),spec(spcs(i),*),psym=10,charsize=csize, $
      xstyle=1,xtickname=idlsucks,ytickname=idlsucks,xrange=erng, $
      min_value=ymin,ystyle=0,ytitle='Counts',title=ttl, $
      position=[xoff+2*xsiz+2*xgap,yoff+(nst-1-i)*ysiz, $
         xoff+3*xsiz+2*xgap,yoff+(nst-i)*ysiz]
   xyouts,2*xsiz+2*xgap+xlab,yoff+(nst-i-0.25)*ysiz,specnm(spcs(i)), $
      /normal,charsize=csize/2.

   if (keyword_set(nocomp) eq 0) then begin
      wcpeakfind,xord(spcs(i),*),spec(spcs(i),*),erng,/plot, $
         charsize=csize/2.d
   endif

endfor

;;
;; Plot the bottom spectra, along with the x-axis labels
;;
i=nst-2
plot,xord(spcs(i),*),spec(spcs(i),*),psym=10,charsize=csize, $
   xstyle=1,xtitle=xttl,ytickname=idlsucks,xrange=erng, $
   ystyle=0,ytitle='Counts',min_value=ymin, $
   position=[xoff+2*xsiz+2*xgap,yoff+(nst-i-1)*ysiz, $
      xoff+3*xsiz+2*xgap,yoff+(nst-i)*ysiz]
xyouts,2*xsiz+2*xgap+xlab,yoff+(nst-i-0.25)*ysiz,specnm(spcs(i)), $
   /normal,charsize=csize/2.

if (keyword_set(nocomp) eq 0) then begin
   wcpeakfind,xord(spcs(i),*),spec(spcs(i),*),erng,/plot, $
      charsize=csize/2.d
endif


;;
;; Close our plot and execute gv to view it
;;
device,/close
set_plot,'X'
spawn,['gv',psflname],/noshell


;;
;; Because IDL still sucks
;;
!p.multi=pmulti



return
end
