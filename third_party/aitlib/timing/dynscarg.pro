PRO dynscarg,tt,rr,file,ghost=ghost,dt=dt,tlen=tlen,pmin=pmin, $
               pmax=pmax,numf=numf,gray=gray,sig=sig,nolabel=nolabel, $
             raterr=raterr,color=color, tbin=tbin, sublabel=sublabel, $
             chatty=chatty
;+
; NAME:
;       dynscarg
;
;
; PURPOSE:
;       produce a dynamical scargle periodogram of a timeseries
;       and display PSD
;        OBSOLETE, DO NOT USE!!!!!!!!!!!!!
;
;
; CATEGORY:
;       time series analysis
;
;
; CALLING SEQUENCE:
;       dynscarg,tt,rr,file,ghost=ghost,dt=dt,tlen=tlen,
;          pmin=pmin,pmax=pmax,numf=numf
; 
; INPUTS:
;       tt: time
;       rr: count rate
;       file: file name of encapsulated PS-File to be produced
;
; OPTIONAL INPUTS:
;       dt: time distance between individual PSDs (default: 4)
;       tlen: length of the individual time series that are used
;             to generate the PSD
;      pmin:  minimum period to consider (0)
;      pmax:  maximum period to consider (tlen/2)
;      numf:  number of frequency points (500)
;      sig : significance levels (99, and 99.9 %)   
;      raterr: error bars for rate. Plot symbols instead of lines.
;
; KEYWORD PARAMETERS:
;       ghost: invoke ghostscript after plot is done 
;       grey:  grey scale plot instead of color
;       color: It's color instead of count rate
;       tbin:  Do psym=10 plots, with errors, in a way that will make
;              even Joern happy (i.e., gaps are explicit)
;       nolabel: Don't put a label on the ASM significance levels!
;       chatty: be chappy   
;   
; OUTPUTS:
;       an encapsulated postscript file is produced
;
; RESTRICTIONS:
;       it is not checked whether the desired period range is
;       meaningful
;
; PROCEDURE:
;       pieces of length tlen of the time series are transformed
;       with the lomb scargle periodogram and normalized to the
;       maximum value. The result is plotted.
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;       Version 0.5: 1999/08/07: Joern Wilms 
;           (wilms@astro.uni-tuebingen.de)
;       Version 0.6: 1999/08/25: Joern Wilms
;           I hope the normalization is now finally all right...
;       Version 0.7: 1999/08/26: Michael Nowak
;           Added raterr as an optional input, color as a keyword,
;           tbin as a keyword
;       Version 0.8: 1999/08/27: JW, added sublabel keyword
;-
      message,"This subroutine is OBSOLETE and has been replaced by dynpsrch"
  
   ;; Check Keyword parameters
   
   ;; Invoke ghostscript?
   IF (n_elements(ghost) EQ 0) THEN ghost=0
   
   ;; Time distance between the individual PSDs
   IF (n_elements(dt) EQ 0) THEN dt=4.
   
   ;; Length of the time segment for one PSD
   IF (n_elements(tlen) EQ 0) THEN tlen=2.*365.
   
   ;; pmin,pmax,numf: minimum and maximum period to be 
   ;;   checked, and number of frequency points to consider
   IF (n_elements(pmin) EQ 0) THEN pmin=0.
   IF (n_elements(pmax) EQ 0) THEN pmax=tlen/2.
   IF (n_elements(numf) EQ 0) THEN numf=500
   
   IF (n_elements(sig) EQ 0) THEN sig=[0.99,0.999]
   
   t0=min(tt)
   tm=max(tt)-tlen
   numstep=fix((tm-t0)/dt)
   
   IF (numstep LT 10) THEN BEGIN
       print,'Time series not long enough for dynamical PSD'
       return
   ENDIF 

   numout=numf
   dyn=fltarr(numstep,numf)
   per=pmin+findgen(numout)/(numout-1)*(pmax-pmin)
   
   cavg=fltarr(2,numstep)
   
   FOR i=0,numstep-1 DO BEGIN 
       tmin=t0+i*dt
       tmax=tmin+tlen
       
       IF (keyword_set(chatty)) THEN BEGIN 
           IF ((i MOD 10) EQ 0) THEN print, 100*i/numstep
       ENDIF 
       
       ndx=where(tt GT tmin AND tt LE tmax)
       t=tt(ndx)
       r=rr(ndx)
       
       cavg[0,i]=(tmin+tmax)/2.
       cavg[1,i]=mean(r)
       
       scargle,t,r,om,px,period=period,numf=numf,pmin=pmin,pmax=pmax
       
       ;; normalization
       dom=shift(om,-1)-om
       dom[n_elements(om)-1]=dom[n_elements(om)-2]
       norm=total(px*dom)
       
       px=px* (variance(r)/(mean(r)^2. * norm))
       
       ;; interpolate onto desired frequencies
       dyn[i,*]=interpol(px,period,per)
   END 

   ;; total periodogram
   scargle,tt,rr,om,px,period=period,numf=numf,pmin=pmin,pmax=pmax, $
     fap=1.-sig,signi=signi

   ;; Now for the plotting 
   
   ;; Open the graphics device
   open_print,file
   device,/color,bits_per_pixel=8,xsize=25,ysize=25
   IF (keyword_set(gray)) THEN BEGIN 
       loadct,0
   END ELSE BEGIN 
       loadct,39
   END 

   xst=0.08
   yst=0.5
   xwi=0.6
   ywi=0.4

   ;; center of each time interval 
   dx=xwi*tlen/(max(tt)-min(tt))

   tvscl,dyn,xst+dx/2.,yst,xsize=xwi-dx,ysize=ywi,/normal

   plot,tt,period,xstyle=1+4,ystyle=1,/noerase, $
     position=[xst,yst,xst+xwi,yst+ywi],/nodata
   xyouts,xst-0.05,yst+ywi/2.,'Period [d]',/normal,$
     orientation=90,alignment=0.5
   
   IF (keyword_set(sublabel)) THEN BEGIN 
       xyouts,xst+xwi-0.03,yst+ywi-0.03,'a)',alignment=1.,/normal
   ENDIF 
     
   oplot,cavg[0,*],cavg[1,*]*0.95*max(period)/max(cavg[1,*]),color=254

   jwmjdaxis,/mjd,/upper,labeloffset=2450000,stretch=0.5
   jwdateaxis,/mjd,/nolabel,stretch=0.5
   
   
   ;; Right: Total Lomb Scargle Periodogram
   
   ma=max(px)
   xminor=0
   IF (ma GT 20.) THEN xminor=2
   
   plot,px,period,position=[xst+xwi,yst,0.90,yst+ywi],/noerase, $
     xtitle='Lomb Scargle Periodogram',xstyle=1,ystyle=1, $
     ytickformat='nolabel',yticklen=0.05,xminor=xminor
   axis,yaxis=1,ystyle=1
   xyouts,0.90+0.05,yst+ywi/2.,'Period [d]',orientation=90,$
     alignment=0.5,/normal
   
   IF (keyword_set(sublabel)) THEN BEGIN 
       xyouts,0.90-0.03,yst+ywi-0.03,'b)',alignment=1.,/normal
   ENDIF 
   
   ;; significance level
   FOR i=0,n_elements(signi)-1 DO BEGIN 
       oplot,[signi[i],signi[i]],[pmin,pmax],linestyle=i+1
       IF (NOT keyword_set(nolabel)) THEN BEGIN 
           xyouts,signi[i]*1.01,pmin+0.03*(pmax-pmin), $
           strtrim(sig[i]*100,2)+'%',$
             orientation=180
       ENDIF 
   END 
   
   ;; Bottom: ASM Count Rate
   ;; with mikes cool stuff for the gaps...
   
   
   nodata=0
   IF (n_elements(raterr) NE 0) THEN nodata=1
   
   plot,tt,rr,xstyle=1+4,ystyle=1,$
     position=[xst,0.1,xst+xwi,yst], $
     ytitle=ytit, $
     /noerase,nodata=nodata
   jwdateaxis,/mjd,/nolabel,stretch=0.5,/upper
   jwdateaxis,/mjd,stretch=0.5
   
   IF (nodata EQ 1) THEN BEGIN 
       ;; should use katjas timegap instead...
       IF(n_elements(tbin) NE 0)THEN BEGIN 
           dtm = tt-shift(tt,1)
           wdt = where(dtm GT tbin)
           IF (wdt(0) NE -1 ) THEN BEGIN 
               fwdt = wdt(n_elements(wdt)-1)
               IF(fwdt LT n_elements(dtm)-1) THEN BEGIN 
                   wdt = [0,wdt,n_elements(dtm)-1]
               ENDIF ELSE BEGIN 
                   wdt = [0,wdt]
               ENDELSE 
           ENDIF ELSE BEGIN
               wdt = [0,n_elements(tt)-1]
           ENDELSE 
       ENDIF ELSE BEGIN 
           wdt = [0,n_elements(tt)-1]
       ENDELSE 
;       
       FOR i=1,n_elements(wdt)-1 DO BEGIN 
           ia = wdt(i-1)
           ib = wdt(i)-1
           IF(n_elements(tbin) NE 0)THEN BEGIN 
               jwoploterr, tt(ia:ib), rr(ia:ib), raterr(ia:ib), $
                 psym=10, ymin=0.
           ENDIF ELSE BEGIN 
               jwoploterr, tt(ia:ib), rr(ia:ib), raterr(ia:ib), $
                 psym=4, ymin=0.
           ENDELSE 
       ENDFOR 
   END
   
   IF (keyword_set(color)) THEN BEGIN 
       ytit='ASM Color'
   ENDIF ELSE BEGIN 
       ytit='ASM Count Rate'
   END
   xyouts,xst-0.05,(0.1+yst)/2.,ytit,/normal,orientation=90,alignment=0.5
   
   IF (keyword_set(sublabel)) THEN BEGIN 
       xyouts,xst+xwi-0.03,yst-0.03,'c)',alignment=1.,/normal
   ENDIF 
              
   close_print,ghost=ghost

END 



