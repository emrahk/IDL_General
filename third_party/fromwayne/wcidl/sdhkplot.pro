PRO sdhkplot, fname=fname, ps=ps, bright=bright
   
   IF (n_params() eq 0) then begin
      print,'USAGE: sdhkplot [,fname=filename][,ps=ps][,bright=bright]'
   endif

   IF (keyword_set(fname) EQ 0) THEN fname='sdhkplot.ps'
   
   IF (keyword_set(ps)) THEN BEGIN
       set_plot,'ps'
       device,file=fname,/portrait,/inches,xsize=7.5,ysize=10., $
         xoffset=0.5,yoffset=0.5
   endif
   
   spawn,'ls */*.xfl',filts,/sh
   spawn,'ls */*.gti',gtis,/sh
   spawn,'ls */src*.lc',srclc,/sh
   spawn,'ls */bak*.lc',baklc,/sh
   nobs=n_elements(filts)
   
   FOR i=0,nobs-1 DO BEGIN
       IF (i EQ 0) THEN BEGIN
           ;Open Filter File (open once for efficiency)
           hd=headfits(filts(i))
           tab=readfits(filts(i),hd,ext=0)
           object=fxpar(hd,'OBJECT')
           obs=fxpar(hd,'OBS_ID')           
           tab=readfits(filts(i),hd,ext=1)           
           ;Get Filter File Keywords
           mjdrefi=fxpar(hd,'MJDREFI')
           mjdreff=fxpar(hd,'MJDREFF')
           mjdref=double(mjdrefi)+double(mjdreff)
           tzero_xfl=fxpar(hd,'TIMEZERO')
           ;Get Filter File Columns
           time=fits_get(hd,tab,'TIME')
           elec0=fits_get(hd,tab,'ELECTRON0')
           pcu0=fits_get(hd,tab,'PCU0_ON')
           pcu1=fits_get(hd,tab,'PCU1_ON')
           pcu2=fits_get(hd,tab,'PCU2_ON')
           pcu3=fits_get(hd,tab,'PCU3_ON')
           pcu4=fits_get(hd,tab,'PCU4_ON')
           saa=fits_get(hd,tab,'TIME_SINCE_SAA')
           elev=fits_get(hd,tab,'ELV')
           offset=fits_get(hd,tab,'OFFSET')
           
           ;Read OnSource Lightcurve
           tzero_lc=loadfits(srclc(i),'TIMEZERO',/key)
           stime=loadfits(srclc(i),'TIME')
           srate=loadfits(srclc(i),'RATE')
           
           ;Read Background Light Curve
           brate=loadfits(baklc(i),'RATE')
           
           ;Read the GTI file
           tzero_gti=loadfits(gtis(i),'TIMEZERO',/key)
           start=loadfits(gtis(i),'START')
           stop=loadfits(gtis(i),'STOP')
           
       ENDIF ELSE begin
           ;Open Filter File (open once for efficiency)
           hd=headfits(filts(i))
           tab=readfits(filts(i),hd,ext=1)
           ;Get Filter File Columns
           time=[time,fits_get(hd,tab,'TIME')]
           elec0=[elec0,fits_get(hd,tab,'ELECTRON0')]
           pcu0=[pcu0,fits_get(hd,tab,'PCU0_ON')]
           pcu1=[pcu1,fits_get(hd,tab,'PCU1_ON')]
           pcu2=[pcu2,fits_get(hd,tab,'PCU2_ON')]
           pcu3=[pcu3,fits_get(hd,tab,'PCU3_ON')]
           pcu4=[pcu4,fits_get(hd,tab,'PCU4_ON')]
           saa=[saa,fits_get(hd,tab,'TIME_SINCE_SAA')]
           elev=[elev,fits_get(hd,tab,'ELV')]
           offset=[offset,fits_get(hd,tab,'OFFSET')]
           
           ;Get OnSource Lightcurve
           stime=[stime,loadfits(srclc(i),'TIME')]
           srate=[srate,loadfits(srclc(i),'RATE')]
           
           ;Get Background Lightcurve
           brate=[brate,loadfits(baklc(i),'RATE')]
           
           ;Get the GTIs
           start=[start,loadfits(gtis(i),'START')]
           stop=[stop,loadfits(gtis(i),'STOP')]
           
       endelse
   ENDFOR
   
   pmulti=!p.multi
   !p.multi=[0,1,5]
   idlsucks=replicate(' ',30)
   
   w=sort(stime)
   stime=stime(w)
   srate=srate(w)
   brate=brate(w)
   
   time=(time+tzero_xfl)/86400.d + mjdref
   stime=(stime+tzero_lc)/86400.0d + mjdref
   
   w=where(start NE 0, cnt)
   IF (cnt NE 0) THEN begin
      start=start(w)
      stop=stop(w)
   ENDIF
   start=(start+tzero_gti)/86400.d + mjdref
   stop=(stop+tzero_gti)/86400.d + mjdref

   mjdzero=long(min(time))
   time=time-mjdzero
   stime=stime-mjdzero
   start=start-mjdzero
   stop=stop-mjdzero
   
   ;Plot the Lightcurve
   plot,stime,srate-brate,xrange=[min(time),max(time)], $
     xstyle=1,ystyle=16,psym=3,position=[0.05,0.65,1.0,0.95], $
     ytitle='PCA Rate (cts/sec)',xtickname=idlsucks, $
     title='Src: '+object+', Prop: P'+strmid(obs,0,8)
   oplot,[min(time),max(time)],[0,0],linestyle=1
   
   ;Plot the Electron Ratio
   plot,time,elec0,xrange=[min(time),max(time)], $
     xstyle=1,ystyle=16,psym=3,position=[0.05,0.5,1.0,0.65], $
     ytitle='Electron Ratio', $
     xtickname=idlsucks
   oplot,[min(time),max(time)],[0.1,0.1],linestyle=1
   
   ;Plot the Elevation
   plot,time,elev,xrange=[min(time),max(time)], $
     xstyle=1,ystyle=16,psym=3,position=[0.05,0.35,1.0,0.50], $
     ytitle='Elevation', $
     xtickname=idlsucks
   oplot,[min(time),max(time)],[10.,10.],linestyle=1
   
   ;Plot the Offset
   plot,time,offset,xrange=[min(time),max(time)], $
     xstyle=1,ystyle=16,psym=3,position=[0.05,0.2,1.0,0.35], $
     ytitle='Offset', $
     xtickname=idlsucks
   oplot,[min(time),max(time)],[0.02,0.02],linestyle=1
   
   ;Plot the other Columns
   plot,time,pcu0,min_value=.8,max_value=1.2, $
     xrange=[min(time),max(time)],yrange=[0,8], $
     xstyle=1,ystyle=1,psym=3,position=[.05,.05,1.,.2], $
     yticks=8, xtitle='Day', yticklen=-0.001, $
     ytickname=[' ','PCU0','PCU1','PCU2','PCU3','PCU4','GTI','SAA',' ']
   oplot,time,pcu1*2.,min_value=1.8,max_value=2.2
   oplot,time,pcu2*3.,min_value=2.8,max_value=3.2
   oplot,time,pcu3*4.,min_value=3.8,max_value=4.2
   oplot,time,pcu4*5.,min_value=4.8,max_value=5.2
   
   ;Plot the Good Time Intervals
   gti=intarr(n_elements(time))
   FOR i=0,n_elements(start)-1 do BEGIN
       w=where((time GT start(i)) AND (time LT stop(i)),cnt)
       IF (cnt NE 0) THEN gti(w)=1
   endfor
   oplot,time,gti*6.,min_value=5.8,max_value=6.2,thick=2
   
   ;Plot the SAA passages
   IF (keyword_set(bright)) THEN BEGIN
       w=where((saa GT 0) AND (saa LT 5),cnt)
   ENDIF ELSE BEGIN
       w=where((saa GT 0) AND (saa LT 30),cnt)
   ENDelse
   saa=intarr(n_elements(time))
   IF (cnt NE 0) THEN saa(w)=1
   oplot,time,saa*7.,min_value=6.8,max_value=7.2
   
   !p.multi=pmulti
   
   IF (keyword_set(ps)) THEN BEGIN
       device,/close
       set_plot,'x'
   endif
   
   
   return
END






