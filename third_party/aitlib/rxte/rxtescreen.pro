PRO rxtescreen,path=path,dirs=dirs,title=title,psfile=psfile,ghost=ghost, $
               noback=noback,electron=elethresh,earthvle=earthvle, $
               faint=faint,q6=q6,skyvle=skyvle,exclusive=exclusive,top=top, $
               nopcu0=nopcu0,fivepcu=fivepcu,cass=cass
;+
; NAME:
;             rxtescreen
;
;
; PURPOSE:
;             Plot an overview of an RXTE observation (lightcurve,
;             content of GTI files, SAA passages, particle background)
;             The file structure must correspond to the one used in 
;             Tuebingen, so not very useful elsewhere.
;
;
;
; CATEGORY:
;             RXTE data analysis
;
;
; CALLING SEQUENCE:
;             rxtescreen,path=path,dirs=dirs,title=title,electron=electron
;
; 
; INPUTS:
;             path: path to the observation
;             dirs: subdirectories to the individual observing blocks
;
;
; OPTIONAL INPUTS:
;             title: title of the observation
;             electron: set to electron ratio threshold for data extraction
;
;      
; KEYWORD PARAMETERS:
;             see above
;   
;             noback: set if no bkg subtraction is to be performed   
;             earthvle: set if EarthVLE background model is to be used
;             faint: set if Faint background model is to be used
;             q6: set if Q6 background model is to be used
;                (default is to test for earthvle,faint,q6)
;             skyvle: set if SkyVLE background model is to be used
;             (default is 0 for noback,earthvle,faint,q6,skyvle)
;
;             exclusive: set to search for data that was extracted
;                with the exclusive keyword to pca_standard being set.
;             top: set to read top-layer data 
;             nopcu0: set to search for data that was extracted
;                ignoring PCU0   
;             fivepcu: plot count-rates wrt to whole PCA, i.e.,
;                normalizing to five PCU; default is to plot the average
;                countrate per PCU
;
;
; OUTPUTS:
;             a plot is produced
;
;
; EXAMPLE:
;      obsid='P10241'
;      dirs=['01.00','01.000']
;      path='/xtearray/cyg/'
;      rxtescreen,path=path+obsid,dirs=dirs,title=obsid
;      END 
;
;
;
; MODIFICATION HISTORY:
;       Version 1.0, 1999/01/26, Joern Wilms, IAA Tuebingen
;       Version 1.1, 1999/02/04, JW/KP, IAAT
;       Version 1.2, 1999/06/02, JW/KP/SB, IAAT: added EarthVLE and
;          Faint keywords
;       Version 1.3, 1999/06/07, JW, IAAT: added exclusive treatment
;          and other invisible improvements
;       Version 1.4, 1999/10/26, KP, IAAT: added SkyVLE and Q6
;          keywords
;       Version 1.5, 2000/10/19, JW,KP, IAAT: added fivepcu keyword,
;          now, per default, the count rate is plotted in units of PER
;          pcu
;       Version 1.5corr, 2000/11/14, KP,EK CASS: added cass keyword,
;          now the obscat path can be switched to the cass path by setting
;          cass (default: iaat obscat path); created consistent version
;          numbers for idl header and cvs 
;       Version 1.6, 2000/12/04, KP, IAAT: added nopcu0 keyword
;       Version 1.7, 2001/01/04, JW, KP, IAAT: changes FINALLY
;          correcting bug in plotting PCU on times    
;       Version 1.8, 2001/01/05, KP, IAAT: forgotten "stop" removed    
;   
;-

   check = n_elements(noback)+n_elements(faint)+n_elements(q6)+n_elements(earthvle)+n_elements(skyvle)
   IF (check GT 1L) THEN message,'background model keywords not set correctly'
   IF (check EQ 0) THEN skyvle=1
   
   IF (n_elements(title) EQ 0) THEN title=''
   IF (n_elements(noback) EQ 0) THEN noback=0
   IF (n_elements(elethresh) EQ 0) THEN elethresh=0.1
   
   IF (n_elements(faint) EQ 0) THEN faint=0 
   IF (n_elements(q6) EQ 0) THEN q6=0
   IF (n_elements(earthvle) EQ 0) THEN earthvle=0
   IF (n_elements(skyvle) EQ 0) THEN skyvle=0
   
   IF (n_elements(exclusive) EQ 0) THEN exclusive=0
   IF (n_elements(top) EQ 0) THEN top=0
   IF (n_elements(nopcu0) EQ 0) THEN nopcu0=0
   IF (n_elements(fivepcu) EQ 0) THEN fivepcu=0
   
   ;;
   ;; Set up printing if desired
   ;;
   stretch=1.
   IF (n_elements(psfile) NE 0) THEN BEGIN 
       savefont=!p.font
       print,'Plotting to PS-File ',psfile
       set_plot,'PS'
       device,/portrait,filename=psfile,$
         yoffset=1.5,xoffset=1.5,xsize=18,ysize=25,/times
       stretch=0.5
       !p.font=0
   ENDIF 
   
   
   readxtedata,t,c,path=path,dirs=dirs,obs=obs,gti=gti,electron=electron, $
     saa=saa,good=good,pcu0=pcu0,pcu1=pcu1,pcu2=pcu2,pcu3=pcu3,pcu4=pcu4, $
     /verbose,noback=noback,faint=faint,earthvle=earthvle,q6=q6, $
     skyvle=skyvle,exclusive=exclusive,top=top,nopcu0=nopcu0, $
     fivepcu=fivepcu,cass=cass
   
   time0=min(t)
   time00=long(time0+0.5)
   cma=max(c)
   cmi=min(c)

   tmin=min(t)-time0
   tmax=max(t)-time0
   
   delta=0.1*(tmax-tmin)
   tmin=tmin-delta
   tmax=tmax+delta
   
   ytitle='PCA Count Rate [cps/PCU]'
   IF (keyword_set(fivepcu)) THEN ytitle='PCA Count Rate [cps]'
   
   jwplotlc,t-time0,c,ytitle=ytitle, $
     time0=time0,countrange=[0.,cma+100],/mjd, $
     position=[0.1,0.6,0.95,0.9],timerange=[tmin,tmax], $
     /noxaxis
   jwdateaxis,zeropoint=time0,/mjd,/nolabel,stretch=stretch
   jwmjdaxis,zeropoint=time0,labeloffset=long(time00+2400000.5D0),/mjd,$
     /upper,stretch=stretch
   jwplotlc,electron[0,*]-time0,electron[1,*],ytitle='Electron ratio',$
     time0=time0,countrange=[0.,0.23],/mjd, $
     position=[0.1,0.4,0.95,0.6],timerange=[tmin,tmax], $
     /noxaxis,/noerase
   oplot,[tmin,tmax],[elethresh,elethresh],linestyle=1
   
   jwdateaxis,zeropoint=time0,/mjd,/nolabel,stretch=stretch
   jwdateaxis,zeropoint=time0,/mjd,/upper,/nolabel,stretch=stretch
   
   xyouts,(0.1+0.95)/2.,0.96,title,alignment=0.5,/normal,size=1.6

   ;;
   ;; Plot info about important events
   ;;
   plotxteinfo,position=[0.1,0.1,0.95,0.4],tmin=tmin,tmax=tmax,obs=obs, $
     dirs=dirs,saa=saa,good=good,pcu0=pcu0,pcu1=pcu1,pcu2=pcu2, $
     pcu3=pcu3,pcu4=pcu4,time0=time0,gti=gti,stretch=stretch
   
   IF (n_elements(psfile) NE 0) THEN BEGIN 
       device,/close
       IF (keyword_set(ghost)) THEN BEGIN 
           spawn, 'gv '+psfile,/sh
       ENDIF 
       set_plot,'X'
       !p.font=savefont
   ENDIF 
   
END 
