PRO dispccd,indata,surf=surf,distx=distx,max=max,min=min,disty=disty,zoom=zoom,$
            comment=comment,title=title,plotfile=plotfile,scaletxt=scaletxt,offset=offset,$
            data=data,noise=noise,bsize=bsize,ps=ps,ghost=ghost
;+
; NAME: dispccd
;
;
;
; PURPOSE:
;
;
;
; CATEGORY:  XMM Data analysis
;           
;
;
; CALLING SEQUENCE:
;
;
; 
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
; V1.0 E. Bihler 1998
; V2.0 M. Kuster 31.03.99
; V2.1 M. Kuster 01.04.99 added possibility to print to a ps-file
; V2.2 M. Kuster 06.04.99 added handling of noise- and offset-maps
; V2.3 M. Kuster 23.11.00 removed problems with datatype
;-   
   ccds0=['CCD3','CCD2','CCD1','CCD4','CCD5','CCD6']
   ccds1=['CCD12','CCD11','CCD10','CCD7','CCD8','CCD9']
   IF (NOT keyword_set(zoom)) THEN zoom=2
   IF (keyword_set(ps)) THEN psplot=1 ELSE psplot=0
   IF (NOT keyword_set(plotfile)) THEN plotfile='ccd.ps'
   IF (NOT keyword_set(scaletxt)) THEN scaletxt='ADC-Units'
   IF (NOT keyword_set(title)) THEN title=''
   IF (NOT keyword_set(bsize)) THEN bsize=1.0
   
   ;; calculated statistics for table only; not used for plotting 
   medium=mean(indata(*,*,*))
   sdev=stddev(indata(*,*,*))
   medi=median(indata(*,*,*))
   ;; ---------------------------------------------------------------   
   
   IF (keyword_set(offset) OR keyword_set(noise) OR keyword_set(data)) THEN BEGIN
       IF (keyword_set(offset)) THEN BEGIN 
           data=ccdcombine(indata,/offset) ; combine 12 single ccds to one array for plotting offsetmaps
           datatype='Offset'
       ENDIF 
       IF (keyword_set(noise)) THEN BEGIN
           data=ccdcombine(indata,/noise) ; combine 12 single ccds to one array for plotting noisemaps
           datatype='Noise'
       ENDIF 
       IF (keyword_set(data)) THEN BEGIN
           data=ccdcombine(indata) ; combine 12 single ccds to one array for plotting data
           datatype='Intensity-Image'
       ENDIF 
   END ELSE BEGIN
       datatype='NONE'
       data=ccdcombine(indata) ; combine 12 single ccds to one array for plotting
   ENDELSE
   
   temp=reform(data,389,401)    ; make vector out of array for diagrams
   
   nozero=where(temp GT 0)      ; all pixels except bad pixels
   spectra = histogram(indata,binsize=bsize)

   mindata=min(temp(nozero))
   maxdata=max(temp(nozero))
   
   ;; calculate size of ccd-picture
   xsize=n_elements(data(*,0))
   ysize=n_elements(data(0,*))
   vertx = TOTAL(data, 1)/ xsize
   verty = TOTAL(data, 2)/ ysize
   nozerox = where(vertx GT 0)
   nozeroy = where(verty GT 0)
   minvx=min(vertx(nozerox))
   maxvx=max(vertx(nozerox))
   minvy=min(verty(nozeroy))
   maxvy=min(verty(nozeroy))
   
   xwin=0
   ywin=0
   ma=0.
   mi=0.
   IF (NOT keyword_set(max)) THEN ma=maxdata ELSE ma=max
   IF (NOT keyword_set(min)) THEN mi=mindata ELSE mi=min

   IF (psplot eq 1) THEN BEGIN   
       
       set_plot,'ps'
       loadct,13
       IF (NOT keyword_set(plotfile)) THEN plotfile='plot.ps'
       IF (NOT keyword_set(comment)) THEN comment=''
       plotfile=STRTRIM(plotfile,2)
       print,'% DISPCCD: Printing to file: ',plotfile
       spawn,"date '+%d %b %Y  %H:%M:%S'",date ; get system date
       user=getenv('USER')      ; get username
       host=getenv('HOST')      ; get hostname
       
       ;;open postscript device 
       device,bits_per_pixel=8,xsize=20.9,ysize=29.7,/color,/portrait, $
         file=plotfile,set_font='Times',/TT_FONT,xoffset=0.5,yoffset=0
       
       skala=transpose(rebin(findgen(256),256,32))
       skaltxt=interpolate([mi,ma],1./6.*findgen(7))
       s=size(skaltxt)
       skaltxt=strtrim(skaltxt,1)
       skaltxt=strmid(skaltxt,0,5)
       ma=strmid(strtrim(ma,2),0,6)
       mi=strmid(strtrim(mi,2),0,6)
       
       ;; plot data of ccds and lut 
       tv,bytscl(data,MAX=ma,MIN=mi,TOP=!D.TABLE_SIZE),$
         4,15,ysize=2*200*.03,xsize=6*64*0.03,/centimeters
       tv,bytscl(skala,TOP=!D.TABLE_SIZE),17,15,xsize=.48,ysize=2*200*0.03,/centimeters
       ;; plot coordinates of ccds
       FOR i=0, 5 DO xyouts,3980+(1920+3)*i,14700,'63',/device,charsize=0.6
       FOR i=0, 5 DO xyouts,5750+(1920+3)*i,14700,'0',/device,charsize=0.6
       FOR i=0, 5 DO xyouts,3980+(1920+3)*i,27100,'0',/device,charsize=0.6
       FOR i=0, 5 DO xyouts,5620+(1920+3)*i,27100,'63',/device,charsize=0.6
       FOR i=0, 1 DO xyouts,3770,14840+(12090+3)*i,'0',/device,charsize=0.6
       FOR i=0, 1 DO xyouts,3500,20770+(300)*i,'200',/device,charsize=0.6
       FOR i=0, 5 DO xyouts,4600+(1920+3)*i,14400,ccds1(i),/device,charsize=0.6
       FOR i=0, 5 DO xyouts,4600+(1920+3)*i,27400,ccds0(i),/device,charsize=0.6

       
       xyouts,1200,28500,'Filename: '+plotfile,/device,charsize=1.0
       xyouts,1200,28000,'Comments: '+comment,/device,charsize=1.0
       xyouts,12000,28500,title,/device,charsize=3.0        
       xyouts,16500,27500,scaletxt,/device,charsize=1.3
       if ma lt ma then skma=5 else skma=6
       if mi gt mi then skmi=1 else skmi=0
       for i=skmi,skma do xyouts,17800,15000+1960*i,skaltxt(i),charsize=.7,/device
       
       xyouts,12200,6500 ,'Medium :  '+strtrim(medium,2)+'!M+!N'+strtrim(sdev,1)+$
         ' ADU',/device,charsize=0.9
       xyouts,12200,6000 ,'Median :  '+strtrim(medi,2)+' ADU',$
         /device,charsize=0.9       
       xyouts,12200,5500 ,'Maximum :  '+strtrim(maxdata,2)+' ADU',/device,$
         charsize=0.9
       xyouts,12200,5000 ,'Minimum :  '+strtrim(mindata,2)+' ADU',/device,$
         charsize=0.9       
       
       xyouts,12200,3000 ,'IAAT by '+user+'@'+host+' '+date,/device,charsize=0.9
       plot,vertx,yrange=[minvx,maxvx],position=[2500,9000,10000,13000],$
         TITLE='Line Distribution',XTITLE='Line-Number',ytitle='Intensity (Counts)',$
         psym=10,/device,/noerase,/xstyle
       plot,verty,yrange=[minvy,maxvy],position=[12000,9000,19500,13000],$
         TITLE='Column Distribution',XTITLE='Column-Number',ytitle='Intensity (Counts)',$
         psym=10,/device,/noerase,/xstyle
       plot,FINDGEN(N_ELEMENTS(spectra))*bsize+mindata+0.5*bsize,spectra,xrange=[mi,ma],$
         position=[2500,3000,10000,7000],$
         TITLE='Spectrum',XTITLE='ADU',ytitle='Intensity (Counts)',$
         psym=10,/device,/noerase 
   END ELSE BEGIN
       
       set_plot,'x'
       loadct,13
   
       IF keyword_set(surf) THEN BEGIN
           SET_SHADING, VALUES=[20,140], LIGHT=[2,2,3]
           SHADE_SURF, data, AZ=7, AX=60, COLOR=147, CHARSIZE=2, ZCHARSIZE=1.5,$
             /ZSTYLE, XTITLE='Line', YTITLE='Column', ZTITLE='ADU Value'
       END ELSE IF keyword_set(distx) THEN BEGIN
           IF (datatype EQ 'NONE') THEN BEGIN 
               print,"% DISPCCD: You have to set the datatype with /DATA, /NOISE or /OFFSET first !"
           ENDIF ELSE BEGIN 
               PLOT, INDGEN(ysize), vertx, TITLE = ' Distribution of the ' + $
                 datatype, PSYM = 10, XTITLE = ' No.', YTITLE = 'Mean ' + $
                 datatype, /XSTYLE, /YSTYLE
           ENDELSE 
       END ELSE IF keyword_set(disty) THEN BEGIN
           IF (datatype EQ -1) THEN BEGIN 
               print,"% DISPCCD: You have to set the datatype with /DATA, /NOISE or /OFFSET first !"
           ENDIF ELSE BEGIN 
               PLOT, INDGEN(xsize), verty, TITLE = ' Distribution of the ' + $
                 'test', PSYM = 10, XTITLE = ' No.', YTITLE = 'Mean ' + $
                 'temp', /XSTYLE, /YSTYLE
           ENDELSE 
       END ELSE BEGIN
           xwin=xsize*zoom
           ywin=ysize*zoom
           window,0,xsize=xwin+100,ysize=ywin+100
           
           TV, BYTSCL(REBIN(data,xwin,ywin,/SAMPLE), MAX=ma, $
                      MIN=mi, TOP=!D.TABLE_SIZE),0,0.02,/normal
           
           xyouts,0.00,0.90,'CCD3',/normal
           xyouts,0.00,0.92,'0',/normal
           xyouts,0.131,0.92,'63',/normal
           
           xyouts,0.15,0.90,'CCD2',/normal
           xyouts,0.15,0.92,'0',/normal
           xyouts,0.280,0.92,'63',/normal
           
           xyouts,0.30,0.90,'CCD1',/normal
           xyouts,0.30,0.92,'0',/normal
           xyouts,0.428,0.92,'63',/normal
           
           xyouts,0.45,0.90,'CCD4',/normal
           xyouts,0.45,0.92,'0',/normal
           xyouts,0.575,0.92,'63',/normal
           
           xyouts,0.60,0.90,'CCD5',/normal
           xyouts,0.595,0.92,'0',/normal
           xyouts,0.723,0.92,'63',/normal
           
           xyouts,0.75,0.90,'CCD6',/normal
           xyouts,0.745,0.92,'0',/normal
           xyouts,0.873,0.92,'63',/normal
           
           xyouts,0.75,0.025,'CCD9',/normal
           xyouts,0.880,0.010,'0',/normal
           xyouts,0.890,0.020,'0',/normal
           xyouts,0.890,0.455,'200',/normal
           xyouts,0.890,0.470,'200',/normal
           xyouts,0.890,0.905,'0',/normal
           xyouts,0.740,0.010,'63',/normal
           
           xyouts,0.60,0.025,'CCD8',/normal
           xyouts,0.725,0.010,'0',/normal
           xyouts,0.590,0.010,'63',/normal
           
           xyouts,0.45,0.025,'CCD7',/normal
           xyouts,0.578,0.010,'0',/normal
           xyouts,0.445,0.010,'63',/normal
           
           xyouts,0.30,0.025,'CCD10',/normal
           xyouts,0.430,0.010,'0',/normal
           xyouts,0.295,0.010,'63',/normal
           
           xyouts,0.15,0.025,'CCD11',/normal
           xyouts,0.283,0.010,'0',/normal
           xyouts,0.145,0.010,'63',/normal
           
           xyouts,0.01,0.025,'CCD12',/normal
           xyouts,0.133,0.010,'0',/normal
           xyouts,0.000,0.010,'63',/normal       
       ENDELSE
   ENDELSE 
   
   IF (psplot EQ 1) THEN BEGIN  ; close ps device if neccessary
       device,/close
       set_plot,'x'
   ENDIF 
   
   IF (keyword_set(ghost)) THEN BEGIN 
       spawn, 'gv '+plotfile,/sh
   ENDIF
END














