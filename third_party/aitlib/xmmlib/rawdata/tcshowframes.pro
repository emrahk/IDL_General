PRO tcshowframes,data,ccdid=ccd,ccd0=ccd0,emin=emin,emax=emax,tmax=tmax,$
                 minframe=minframe,nframes=nframes,nocorr=nocorr,$
                 zoom=zoom,delay=delay,stop=stop,chatty=chatty,frameinfo=frameinfo
   
;+
; NAME: 
;            tcshowframes
;
;
; PURPOSE:
;            show ccd images of one or several frames
;
;
; CATEGORY:  
;            XMM Data analysis
;           
;
; CALLING SEQUENCE:
;
;
; 
; INPUTS:
;            data: data struct array
;
;
; OPTIONAL INPUTS:
;            ccdid: if a valid ccdid (1..11) is given, then only this
;                   ccd is shown (for ccdid = 0 see below)
;            emin, emax: minimum and maximum energy values in ADU
;            tmax: maximal time, events with higher time values
;                  (relative to dat(0).time) are discarded (default: 10000)
;            minframe: number of first frame to be shown (default: 0)
;            nframes: number of frames to be shown in one image
;                     (default: 1) 
;            zoom: zoom factor for display (default: 4)
;            delay: number of seconds each image is shown (if keyword
;                   stop is not set)
;   
;      
; KEYWORD PARAMETERS:
;            ccd0: show ccd # 0 only
;            nocorr: do not sort data in time, do not discard wrong time words
;                    (saves time, but should be used with preselected data only)
;            stop: stop after each picture
;            chatty: print information for each frame
;            frameinfo: if keyword chatty is set and data struct
;                       contains the element data.frame, print frame number
;
;
; OUTPUTS:
;            none
;
;
; OPTIONAL OUTPUTS:
;            none
;
;
; COMMON BLOCKS:
;            none
;
;
; SIDE EFFECTS:
;            none
;
;
; RESTRICTIONS:
;            none
;
;   
; PROCEDURE:
;            see code, 
;            to change from or to stopping after each frame,
;            stop program and set stop=0 or stop=1, set delay as
;            desired 
;            for ps-plots stop program before desired frame
;            an set psplot=1
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
; V1.0 T. Clauss 08.07.00 first initial version, derived from
;                         dispccd.pro and tcpattern.pro
; V1.1 T. Clauss 05.09.00 added keyword nocorr   
;
;-   
   
   IF (NOT keyword_set(ccd)) THEN ccd=-1 ; show all ccds
   IF keyword_set(ccd0) THEN ccd=0
        
   IF (NOT keyword_set(emin)) THEN emin=0
   IF (NOT keyword_set(emax)) THEN emax=4095
   IF (NOT keyword_set(tmax)) THEN tmax=10000L
   IF (NOT keyword_set(zoom)) THEN zoom=4
   IF (NOT keyword_set(nframes)) THEN nframes=1
   IF (NOT keyword_set(minframe)) THEN minframe=1
   IF (NOT keyword_set(delay)) THEN delay=1
   IF keyword_set(stop) THEN stop=1 ELSE stop=0
   
   psplot=0                     ; can be set to 1 to generate ps-file
   ccds0=['CCD2','CCD1','CCD0','CCD3','CCD4','CCD5']
   ccds1=['CCD11','CCD10','CCD9','CCD6','CCD7','CCD8']
   
;   dat=data

   IF ccd NE -1 THEN BEGIN
       dat=data(where(data.ccd EQ ccd))
   ENDIF ELSE BEGIN
       dat=data
   ENDELSE
   
   IF NOT keyword_set(nocorr) THEN BEGIN 
       ind=where((dat.energy gt emin) and (dat.energy lt emax))
       dat=dat(ind)
;       ind=sort(dat.time)
;       dat=dat(ind)
       ind=where(dat.time lt 30000)
       dat=dat(ind)
       dat.time=dat.time-dat(0).time
       ind=where(dat.time lt tmax)
       dat=dat(ind)
   ENDIF
      
   frame=dat.time-shift(dat.time,-1)
   frameind=where(frame ne 0)
   numframes=n_elements(frameind)
   
;   stop
   
   IF ccd NE -1 THEN BEGIN      ; show one ccd only
       xsize=200*zoom
       ysize=64*zoom
       
;       loadct,13
       tcreversect,3
       
       window,10,xsize=xsize,ysize=ysize,xpos=200,ypos=200+ysize
       window,11,xsize=xsize,ysize=ysize,xpos=200,ypos=200-50
       
       FOR i=long(minframe),numframes-1,nframes DO BEGIN 
           IF (i NE 1) THEN BEGIN
               framedat=dat(frameind(i-1)+1:frameind(i+nframes-1))
           ENDIF ELSE BEGIN 
               framedat=dat(0:frameind(i+nframes-1))
           ENDELSE
           
           framedat1=framedat
           IF keyword_set(chatty) THEN BEGIN
               minen=min(framedat.energy)
               maxen=max(framedat.energy)
               ftime=framedat(0).time
           ENDIF
           
           IF keyword_set(chatty) THEN BEGIN 
               IF NOT keyword_set(frameinfo) THEN BEGIN 
                   print,'%TCSHOWFRAMES: Number of frame: ',strtrim(i,2)
               ENDIF ELSE BEGIN
                   print,'%TCSHOWFRAMES: Number of frame: ',strtrim(framedat(0).frame,2),$
                     '  (',strtrim(i,2),'. frame shown)'
               ENDELSE 
               IF keyword_set(nocorr) THEN BEGIN
                   print,'%TCSHOWFRAMES: Number of first event in frames: ',strtrim(frameind(i-1)+1,2)
               ENDIF
               print,'%TCSHOWFRAMES: Time of first event in frames: ',strtrim(ftime,2)
               print,'%TCSHOWFRAMES: Energy range in frames: ',$
                 strtrim(minen,2),'..',strtrim(maxen,2),' ADU'
           ENDIF
           
           wset,10
           mkplotintens,framedat,ccd,zoom=zoom,/nowin
           wset,11
           mkplotenergy,framedat1,ccd,/scale,zoom=zoom,/nowin
                      
           IF (stop EQ 1) THEN stop ELSE wait,delay 
                      
       ENDFOR
   ENDIF ELSE BEGIN             ; show all ccds
       
       loadct,13
       
       FOR i=long(minframe),numframes-1,nframes DO BEGIN
           IF (i NE 1) THEN BEGIN 
               indata=dat(frameind(i-1)+1:frameind(i+nframes-1))
           ENDIF ELSE BEGIN 
               indata=dat(0:frameind(i+nframes-1))
           ENDELSE
           indata=mkdata2img(indata)
           indata=ccdcombine(indata)
           
           temp=reform(indata,389,401)    ; make vector out of array for diagrams
   
           nozero=where(temp GT 0) ; all pixels except bad pixels

           
           IF (nozero(0) GT -1) THEN BEGIN 
               mindata=min(temp(nozero))
               maxdata=max(temp(nozero))
           
               ;; calculate size of ccd-picture
               xsize=n_elements(indata(*,0))
               ysize=n_elements(indata(0,*))
;           vertx = TOTAL(indata, 1)/ xsize
;           verty = TOTAL(indata, 2)/ ysize
;           nozerox = where(vertx GT 0)
;           nozeroy = where(verty GT 0)
;           minvx=min(vertx(nozerox))
;           maxvx=max(vertx(nozerox))
;           minvy=min(verty(nozeroy))
;           maxvy=min(verty(nozeroy))
           
               ma=maxdata
               mi=mindata
                              
               zoom=2
               xwin=xsize*zoom
               ywin=ysize*zoom
               window,0,xsize=xwin+100,ysize=ywin+100
               
               TV, BYTSCL(REBIN(indata,xwin,ywin,/SAMPLE), MAX=ma, $
                          MIN=mi, TOP=!D.TABLE_SIZE),0,0.02,/normal
                            
               IF psplot EQ 1 THEN BEGIN
                   set_plot,'ps'
                   
;                   loadct,13
                   tcreversect,3
                   device,bits_per_pixel=8,xsize=18.0,ysize=14.0,/color,/portrait, $
                     file='tc_plot.ps',set_font='Times',font_size=16,/TT_FONT,xoffset=0.5,yoffset=0
                   
;                   skala=transpose(rebin(findgen(256),256,32))
                   ;; plot data of ccds and lut 
                   pysize=2*200*30*1.0
                   pxsize=6*64*30*1.0
                   tv,bytscl(indata,MAX=ma,MIN=mi,TOP=!D.TABLE_SIZE),$
;                     3,2,ysize=2*200*.03,xsize=6*64*0.03,/centimeters
                     3000,1000,ysize=pysize,xsize=pxsize,/device
                     plots,[3000,3000+pxsize,3000+pxsize,3000,3000],$
                       [1000,1000,1000+pysize,1000+pysize,1000],/device,color=255
                   
;                   tv,bytscl(skala,TOP=!D.TABLE_SIZE),16,2,xsize=.48,ysize=2*200*0.03,/centimeters
                   ;; plot coordinates of ccds
                   FOR j=0, 5 DO xyouts,3050+(1920+3)*j,700,'63',/device,charsize=0.6,color=255
                   FOR j=0, 5 DO xyouts,4750+(1920+3)*j,700,'0',/device,charsize=0.6,color=255
                   FOR j=0, 5 DO xyouts,2980+(1920+3)*j,13100,'0',/device,charsize=0.6,color=255
                   FOR j=0, 5 DO xyouts,4420+(1920+3)*j,13100,'63',/device,charsize=0.6,color=255
                   FOR j=0, 1 DO xyouts,2770,840+(12090+3)*j,'0',/device,charsize=0.6,color=255
                   FOR j=0, 1 DO xyouts,2370,6770+(300)*j,'200',/device,charsize=0.6,color=255
                   FOR j=0, 5 DO xyouts,3600+(1920+3)*j,400,ccds1(j),/device,charsize=0.6,color=255
                   FOR j=0, 5 DO xyouts,3600+(1920+3)*j,13400,ccds0(j),/device,charsize=0.6,color=255
                   
                   device,/close
                   set_plot,'x'
                   stop 
                   
               ENDIF
               
           ENDIF
           
           
           IF (stop EQ 1) THEN stop ELSE wait,delay 
           
       ENDFOR
       
   ENDELSE
   
END

