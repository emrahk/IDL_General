
PRO dynpsrch,tt,rr,file,ghost=ghost,dt=dt,tlen=tlen,pmin=pmin,      $
             pmax=pmax,numf=numf,gray=gray,sig=sig,nolabel=nolabel, $
             raterr=raterr,color=color, tbin=tbin, log=log,         $
             epoch=epoch,window=window,chsize=chsize,               $
             sunangdist=sunangdist,period=period,px=px,             $
             maxchi2per=maxchi2per,psdpeaksort=psdpeaksort,         $
             multiple=multiple,simsigni=simsigni,                   $
             ylaxisv=ylaxisv
                    
;+
; NAME:
;       dynpsrch
;
;
; PURPOSE:
;       produce a dynamical period search of a timeseries
;       and display PSD or \chi^2 of Epoch Fold
;
;
; CATEGORY:
;       time series analysis
;
;
; CALLING SEQUENCE:
;       dynpsrch,tt,rr,file,ghost=ghost,dt=dt,tlen=tlen,
;          pmin=pmin,pmax=pmax,numf=numf, /log, /epoch, /nolabel
; 
; INPUTS:
;       tt:     time
;       rr:     count rate
;       file:   file name of encapsulated PS-File to be produced
;
; OPTIONAL INPUTS:
;       dt:     time distance between individual PSDs (default: 4)
;       tlen:   length of the individual time series that are used
;                 to generate the PSD
;       pmin:   minimum period to consider (2.*dt default)
;       pmax:   maximum period to consider (tlen/2)
;       numf:   number of frequency points (500)
;       sig :   significance levels (99, and 99.9 %)
;       raterr: error bars for rate. Plot symbols instead of lines.
;       sunangdist: angular distance between the sun and the ASM
;               object. Make an angular distance versus time plot.     
;       multiple: number of simulations to obtain the significance
;               levels, if not set or <=0, then the significance is
;               computed from the standard formula, and not using
;               simulations (faster, but not recommended...)
;       ylaxisv: The data values for each tick mark for the y left
;               axis.    
;
; KEYWORD PARAMETERS:
;       ghost:  invoke ghostscript after plot is done 
;       gray:   gray scale plot instead of color
;       color:  It's color instead of count rate
;       tbin:   Do psym=10 plots, with errors, in a way that will make
;                even Joern happy (i.e., gaps are explicit)
;       nolabel: Don't put a label on the ASM significance levels!
;       log:    Make logarithmic period axes on the plot
;       epoch:  Epoch fold instead of Lomb-Scargle (default)
;       window: Apply a Welch Window to the data   
;   
; OUTPUTS:
;       an encapsulated postscript file is produced
; OPTIONAL OUTPUTS:
;       px: PSD values for lomb-Scargle periodogram or \chi^2 values
;           for Epoch Fold 
;       period: period corresponding to each PSD value for
;           lomb-Scargle periodogram or trial periods for Epoch Fold
;       maxchi2per: period of maximum chi^2 for Epoch Fold
;       psdpeaksort : array with the maximum peak from the lom-Scargle
;           periodogram pro each simulation
;       simsigni : power threshold corresponding to the given 
;           false alarm probabilities fap according to white
;           noise simulations for the PSD;          
;   
; RESTRICTIONS:
;       it is not checked whether the desired period range is
;       meaningful
;
; PROCEDURE:
;       pieces of length tlen of the time series are transformed
;       with the lomb scargle periodogram or epoch folded and then
;       are normalized to the maximum value. The result is plotted.
;
;
; EXAMPLE:
;
;
; PROCEDURES CALLED:
;       Requires: scargle.pro, epfold.pro (=> pfold.pro), jwoploterr,
;                 jwmjdaxis, jwdateaxis, open_print, close_print
;            
;
; MODIFICATION HISTORY:
;       Version 0.5: 1999/08/07 (dynscarg): Joern Wilms 
;           (wilms@astro.uni-tuebingen.de)
;
;       Version 0.6: 1999/08/25: Joern Wilms
;           I hope the normalization is now finally all right...
;       Version 0.7: 1999/08/26: Michael Nowak
;           (mnowak@rocinante.colorado.edu)
;           Added raterr as an optional input, color as a keyword,
;           tbin as a keyword
;       Version 0.8 (dynpsrch): 1999/10/21: Michael Nowak
;           Added log as a keyword, to produce logarithmic plots
;           Added epoch as a keyword, to do an epoch fold instead
;           tvscal now centers pixels on mid-point of PSD/Fold, &
;             width of plot is now more carefully calculated
;           pmin is defaulted to 2.*dt
;       Version 0.9: 1999/11/02: Michael Nowak
;           Following Padi Boyd's suggestion, added padding of lightcurves
;             to allow dynamical PSD to be done over whole lightcurve range.
;           Added keyword to window function the lightcurve with a
;             Welch window.
;       Version 1.0: 1999/11/30: Sara Benlloch
;           Added sunangdist as a optional input, to plot the angular
;           distance between the sun and the ASM object versus the
;           time, in order to check the sun influence. 
;       Version 1.1: 2000/08/31: Sara Benlloch / J. Wilms
;           adopted to new (fast) scargle routine
;-
   
   ;; Check Keyword parameters
   
   ;; Simulations  for periodogram
   IF n_elements(multiple) EQ 0 THEN multiple = 0
   ;; Size of Fonts
   IF (n_elements(chsize) EQ 0) THEN chsize = 1.
   
   ;; Invoke ghostscript?
   IF (n_elements(ghost) EQ 0) THEN ghost = 0
   
   ;; Time distance between the individual PSDs
   IF (n_elements(dt) EQ 0) THEN dt = 4.
   
   ;; Length of the time segment for one PSD
   IF (n_elements(tlen) EQ 0) THEN tlen = 500.
   
   ;; pmin,pmax,numf: minimum and maximum period to be 
   ;;   checked, and number of frequency points to consider
   IF (n_elements(pmin) EQ 0) THEN pmin = 2.*dt
   IF (n_elements(pmax) EQ 0) THEN pmax = tlen/2.
   IF (n_elements(numf) EQ 0) THEN numf = 500
   
   IF (n_elements(sig) EQ 0) THEN BEGIN 
       IF keyword_set(epoch) THEN BEGIN 
               sig = [0.99D0]
               fap = [0.01D0]
       ENDIF ELSE BEGIN 
               sig = [0.99D0,0.999D0]
               fap = [0.01D0,0.001D0]
       ENDELSE     
   ENDIF ELSE BEGIN 
       fap = 1.D0 - double(sig)
   END
   
   t0   = min(tt)
   tm   = max(tt)
   npad = fix((tlen/2.d0)/dt)
   ;;
   ;; Padded lightcurve.  The padded points before/after the known
   ;; lightcurve have the mean and variance of the first/last tlen/2.d0
   ;; of the lightcurve
   ;;
   tp  = [(findgen(npad)-npad)*dt+t0,tt,tm+(findgen(npad)+1.)*dt]
   tp0 = min(tp)

   ibeg = where(tt LE t0+tlen/2.d0)
   mnb  = mean(rr(ibeg))
   sigb = sqrt(variance(rr(ibeg)))

   iend = where(tt GE tm-tlen/2.d0)
   mne  = mean(rr(iend))
   sige = sqrt(variance(rr(iend)))

   rp = [randomu(s,npad,/normal)*sigb+mnb,rr,randomu(s,npad,/normal)*sige+mne]

   numstep_pad  = fix((max(tp)-tlen-min(tp))/dt)
   numstep_npad = fix((tm-tlen-t0)/dt)
   
   IF (numstep_pad LT 10 OR numstep_npad LT 10 ) THEN BEGIN
       message,'Time series not long enough for dynamical PSD', $
         /informational
       return
   ENDIF 
   
   numout = numf
   dyn = fltarr(numstep_pad,numf)

   IF (keyword_set(log)) THEN BEGIN 
       per = pmin*( (pmax/pmin)^(dindgen(numout)/double(numout-1)) )
   ENDIF ELSE BEGIN 
       per = pmin+findgen(numout)/(numout-1)*(pmax-pmin)
   ENDELSE 
   
   cavg = fltarr(2,numstep_npad)
   ii = 0   

   FOR i=0,numstep_pad-1 DO BEGIN 
       tmin = tp0+i*dt
       tmax = tmin+tlen
       
       ndx = where(tp GT tmin AND tp LE tmax)
       t   = tp(ndx)
       r   = rp(ndx)
       
       IF (tmin ge t0 AND ii LE numstep_npad-1) THEN BEGIN
           cavg[0,ii] = (tmin+tmax)/2.d0
           cavg[1,ii] = mean(r)
           ii = ii+1
       ENDIF
       

       IF (keyword_set(epoch)) THEN BEGIN 
           epfold,t,r,pstart=pmin,pstop=pmax,chierg=chierg,sampling=60
           period = chierg[0,*]
           px     = chierg[1,*]
       ENDIF ELSE BEGIN 
           ;;  This is not recommended for frequencies ~< (a few)/tlen, but 
           ;;  good to check high frequency stuff
           IF (keyword_set(window)) THEN BEGIN 
               rtmp = r*( 1.d0 - (2.d0*(t-tmin-tlen/2.d0)/tlen)^2 )
               scargle,t,rtmp,om,px,period=period,numf=numf, $
                 fmin=1./pmax,fmax=1./pmin
           ENDIF ELSE BEGIN 
               scargle,t,r,om,px,period=period,numf=numf,    $
                 fmin=1./pmax,fmax=1./pmin
           ENDELSE
           ;; normalization
           dom = shift(om,-1)-om
           dom[n_elements(om)-1] = dom[n_elements(om)-2]
           norm = total(px*dom)
           px = px* (variance(r)/(mean(r)^2. * norm))
       ENDELSE 
       
       ;; interpolate onto desired frequencies
       dyn[i,*]=interpol(px,period,per)
       
   END  
   
   IF (keyword_set(epoch)) THEN BEGIN 
       ;; total epoch fold  
       epfold,tt,rr,pstart=pmin,pstop=pmax,chierg=chierg,sampling=60, $
         period=period,persig=persig
       maxchi2per = period
       period     = chierg[0,*]
       px         = chierg[1,*]
   ENDIF ELSE BEGIN 
       ;; total periodogram 
       IF (keyword_set(window)) THEN BEGIN 
           rtmp = rr*( 1.d0 - (2.d0*( tt-(t0+tm)/2.d0 )/(tm-t0))^2 )
           scargle,tt,rtmp,om,px,period=period,numf=numf, $
             fmin=1./pmax,fmax=1./pmin, psdpeaksort=psdpeaksort,$
             multiple=multiple,fap=fap,simsigni=simsigni
           ;; Multiply by 15/8 if window function is used (i.e. the mean
           ;; value of the square of the window function).  That
           ;; should be the proper normalization with the window function
           px = px*15.d0/8.d0
       ENDIF ELSE BEGIN 
           scargle,tt,rr,om,px,period=period,numf=numf, $
             fmin=1./pmax,fmax=1./pmin,psdpeaksort=psdpeaksort, $
             multiple=multiple,fap=fap,simsigni=simsigni,/debug
       ENDELSE 
   ENDELSE 

   ni = n_elements(px)
   IF (n_elements(tt)/2 LT ni) THEN ni = n_elements(tt)/2
   IF (keyword_set(epoch)) THEN BEGIN 
       signi = persig
   ENDIF ELSE BEGIN 
       IF (n_elements(simsigni) NE 0) THEN BEGIN 
           signi = simsigni
       END ELSE BEGIN 
           signi = -alog(1.D0-(1.D0-fap)^(1.D0/double(ni)))
       END 
   ENDELSE  

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
   IF n_elements(sunangdist) NE 0 THEN sst = 0.08 ELSE sst = 0

   ;; the width of one pixel
   dxt=xwi*dt/(tm-t0)
   ;; the starting point
   tst = t0-npad*dt+tlen/2.d0-dt/2.d0

   IF (tst GE t0) THEN BEGIN 
       is = 0
       dxst = xwi*(tst-t0)/(tm-t0)
   ENDIF ELSE BEGIN 
       is=1
       dxst = xwi*(tst-t0)/(tm-t0) + dxt
   ENDELSE 

   tvscl,dyn(is:*,*),xst+dxst,yst,xsize=float(numstep_pad-is)*dxt, $
     ysize=ywi,/normal
   
   IF (keyword_set(log)) THEN BEGIN 
       IF n_elements(ylaxisv) NE 0 THEN BEGIN 
           plot,tt,period,xstyle=1+4,ystyle=1,$
             /noerase, xrange=[t0,tm], $
             ytitle='Period [d]', yrange=[pmin,pmax], /ylog, $
             position=[xst,yst,xst+xwi,yst+ywi],/nodata, charsize=chsize, $
             yticks=n_elements(ylaxisv)-1,ytickv=ylaxisv
           xtickformat='nolabel'
       ENDIF ELSE BEGIN 
           plot,tt,period,xstyle=1+4,ystyle=1,$
             /noerase, xrange=[t0,tm], $
             ytitle='Period [d]', yrange=[pmin,pmax], /ylog, $
             position=[xst,yst,xst+xwi,yst+ywi],/nodata, charsize=chsize
           xtickformat='nolabel'
       ENDELSE 
   ENDIF ELSE BEGIN 
       IF n_elements(ylaxisv) NE 0 THEN BEGIN 
           plot,tt,period,xstyle=1+4,ystyle=1,$
             /noerase, xrange=[t0,tm], $
             ytitle='Period [d]', yrange=[pmin,pmax], $
             position=[xst,yst,xst+xwi,yst+ywi],/nodata, charsize=chsize, $
             yticks=n_elements(ylaxisv)-1,ytickv=ylaxisv
           xtickformat='nolabel'
       ENDIF ELSE BEGIN 
           plot,tt,period,xstyle=1+4,ystyle=1,$
             /noerase, xrange=[t0,tm], $
             ytitle='Period [d]', yrange=[pmin,pmax], $
             position=[xst,yst,xst+xwi,yst+ywi],/nodata, charsize=chsize
           xtickformat='nolabel'
       ENDELSE 
   ENDELSE 

   jwmjdaxis,/mjd,/upper,labeloffset=2450000,stretch=0.5
   jwdateaxis,/mjd,/nolabel,stretch=0.5
   
   
   IF (keyword_set(epoch)) THEN BEGIN 
       ;; Right: Epoch Fold
       xtit='\chi^2'
   ENDIF ELSE BEGIN 
       ;; Right: Lomb Scargle Periodogram
       xtit='Power'
       ;; x range
       IF max(signi) GT max(px) THEN xmax=max(signi) ELSE xmax=max(px)
   ENDELSE 
   
   
   IF (keyword_set(log)) THEN BEGIN 
       plot,px,period,position=[xst+xwi,yst,0.90,yst+ywi],/noerase, $
         xtitle=textoidl(xtit),xstyle=1,ystyle=1,xrange=[min(px),xmax+1], $
         ytickformat='nolabel', charsize=chsize, /ylog
       IF n_elements(ylaxisv) NE 0 THEN BEGIN 
           axis,yaxis=1,ystyle=1,ytitle=textoidl('Period [d]'), $
             charsize=chsize,yticks=n_elements(ylaxisv)-1,ytickv=ylaxisv
       ENDIF ELSE BEGIN 
           axis,yaxis=1,ystyle=1,ytitle=textoidl('Period [d]'),charsize=chsize
       ENDELSE
       
   ENDIF ELSE BEGIN 
       plot,px,period,position=[xst+xwi,yst,0.90,yst+ywi],/noerase, $
         xtitle=textoidl(xtit),xstyle=1,ystyle=1,xrange=[min(px),xmax+1], $
         ytickformat='nolabel', charsize=chsize
       IF n_elements(ylaxisv) NE 0 THEN BEGIN 
           axis,yaxis=1,ystyle=1,ytitle=textoidl('Period [d]'), $
             charsize=chsize,yticks=n_elements(ylaxisv)-1,ytickv=ylaxisv
       ENDIF ELSE BEGIN 
           axis,yaxis=1,ystyle=1,ytitle=textoidl('Period [d]'),charsize=chsize
       ENDELSE
   ENDELSE 

   ;; significance level
   IF (keyword_set(epoch)) THEN BEGIN 
       ;; Right: Epoch Fold
   ENDIF ELSE BEGIN 
       ;; Right: Lomb Scargle
       FOR i=0,n_elements(signi)-1 DO BEGIN 
           oplot,[signi[i],signi[i]],[pmin,pmax],linestyle=i+1

           IF (NOT keyword_set(nolabel)) THEN BEGIN 
               xyouts,signi[i]*1.01,pmin+0.03*(pmax-pmin), $
                 strtrim(sig[i]*100,2)+'%',$
                 orientation=180
           ENDIF 
       END 
   ENDELSE 

   ;; Bottom: ASM Count Rate
   IF (keyword_set(color)) THEN BEGIN 
       ytit='ASM Color'
   ENDIF ELSE BEGIN 
       ytit='ASM Count Rate'
   ENDELSE 
   
   IF (n_elements(raterr) EQ 0) THEN BEGIN 
       plot,tt,rr,xstyle=1+4,ystyle=1,$
         position=[xst,0.1,xst+xwi,yst-sst], $
         ytitle=ytit, $
         /noerase, charsize=chsize
       jwdateaxis,/mjd,/nolabel,stretch=0.5,/upper
       jwdateaxis,/mjd,stretch=0.5
       
       ;; Sun angular distance       
       IF n_elements(sunangdist) NE 0 THEN BEGIN 
           plot,tt,sunangdist,xstyle=1+4,ystyle=1,  $
             position=[xst,yst-sst,xst+xwi,yst], $
             ytitle='Sun',/noerase,charsize=chsize,yrange=[0,200],psym=3
           jwdateaxis,/mjd,/nolabel,stretch=0.5,/upper
       ENDIF 
       
   ENDIF ELSE BEGIN 
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

       plot,tt,rr,xstyle=1+4,ystyle=1,$
         position=[xst,0.1,xst+xwi,yst-sst], $
         ytitle=ytit, $
         /noerase, /nodata, charsize=chsize
       jwdateaxis,/mjd,/nolabel,stretch=0.5,/upper
       jwdateaxis,/mjd,stretch=0.5
       
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
       
       ;; Sun angular distance       
       IF n_elements(sunangdist) NE 0 THEN BEGIN 
           plot,tt,sunangdist,xstyle=1+4,ystyle=1,  $
             position=[xst,yst-sst,xst+xwi,yst], $
             ytitle='Sun',/noerase,charsize=chsize,yrange=[0,200],psym=3
           jwdateaxis,/mjd,/nolabel,stretch=0.5,/upper
       ENDIF 
   ENDELSE 
              
   close_print,ghost=ghost

END 





