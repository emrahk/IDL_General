PRO mkframetime,time,mode,clock=clock,factor=factor,plotfile=plotfile,ps=ps,ghost=ghost,$
                chatty=chatty,comment=comment
;+
; NAME:
;                  mkframtime
;
;
; PURPOSE:
;                  Calculate the frame time of a readout mode of the
;                  EPIC pn-CCD from a given data set.
;
;
; CATEGORY:
;                  XMM-Data-Analysis/Timing
;
;
; CALLING SEQUENCE:
;                  mkframetime,data.time,'timing'
;
; 
; INPUTS:
;                  time     : Double vector with the photon arrival
;                             times.
;                  mode     : String describing the readout mode of
;                             the ccd. Valid modes are:
;                                  'full'   for Full Frame Mode
;                                  'extend' for extended Full Frame
;                                           Mode
;                                  'small'  for Small Window Mode
;                                  'large'  for Large Window Mode
;                                  'timing' for Timing Mode
;                                  'burst'  for Burst Mode
;
;
; OPTIONAL INPUTS:
;                  plotfile : Name of the file for the results of the
;                             frametime determination.
;                  ps       : Print results of mkframtime to a
;                             ps-file.
;                  ghost    : Show plot in ghostview (automatically). 
;                  factor   : Do not use this parameter unless you
;                             know very well what you are doing !
;
;
;      
; KEYWORD PARAMETERS:
;                  /chatty : Give more information on what's going
;                            on
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;                  clock   : The  clock time resulting from the frame
;                            time.
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none 
;
;
; RESTRICTIONS:
;                  none 
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;                  mkframetime,time,mode,clock=clock,plotfile=plotfile,ps=ps,ghost=ghost,/chatty      
;
;
; MODIFICATION HISTORY:
; V1.0   8.04.99 M. Kuster first initial version
; V1.1  18.05.00 M .Kuster added docu header
;
;-
   IF (keyword_set(ps)) THEN psplot=1 ELSE psplot=0
   IF (NOT keyword_set(factor)) THEN factor=1.d0
   
   IF (psplot EQ 1) THEN BEGIN 
       set_plot,'ps'
       loadct,13
       IF (NOT keyword_set(plotfile)) THEN plotfile='plot.ps'
       comment='Determination of the Frame Time'+comment
       plotfile=STRTRIM(plotfile,2)
       print,'% MKFRAMETIME: Printing to file: ',plotfile
       spawn,"date '+%d %b %Y  %H:%M:%S'",date ; get system date
       user=getenv('USER')      ; get username
       host=getenv('HOST')      ; get hostname
       ;;open postscript device 
       device,bits_per_pixel=8,ysize=20.9,xsize=28.7,/color,/landscape, $
         file=plotfile,yoffset=29.5,xoffset=-.2
   ENDIF 
   
   ;; Determine frame time from measured data if cycle is set to
   ;; 1. Otherwise set frametime to the value given by the hardware
   ;; oszillator.
   
   CASE mode OF
       'full': BEGIN            ; Full Frame Mode
           startp=0.0730d0
           stopp =0.0736d0
           frameclocks=1834108d ; sequenzer-clocks per frame
       END 
       'extend': BEGIN          ; extended Full Frame Mode
           startp=0.2800d0
           stopp =0.1850d0
           frameclocks=7076988d ; sequenzer-clocks per frame
       END 
       'small': BEGIN           ; Small Window Mode
           startp=0.0055d0
           stopp =0.0057d0
           frameclocks=141794d0  ; sequenzer-clocks per frame
       END
       'large': BEGIN           ; Large Window Mode
           startp=0.046d0
           stopp =0.052d0
           frameclocks=1191616d0 ; sequenzer-clocks per frame
       END           
       'timing': BEGIN          ; Timing Mode
           startp=0.005940d0
           stopp =0.00598d0              
           frameclocks=149116d0  ; sequenzer-clocks per frame (checked !)
       END
       'burst': BEGIN           ; Burst Mode
           startp=0.00432d0
           stopp =0.00436d0                  
           frameclocks=108614d0  ; sequenzer-clocks per frame
       END
   ENDCASE 
   startp=startp*factor
   stopp=stopp*factor
   
   ;; ****************************************
   ;; Determine frametime from observers-data
   ;; ****************************************
   bg=0.001d0                   ; use a fixed binsize
   
   ;; build a lightcurve
   rate=histogram(time,binsize=bg)
   rate=temporary(rate/bg)
   
   n=n_elements(rate)
   ttime=lindgen(n)*bg

   ;; do first step epoch folding to get a rought estimation of the
   ;; frametime
   epfold,ttime,rate,pstart=startp,pstop=stopp,nbins=20,period=trialper,chierg=chierg,$
     sampling=5,/chatty
   
   ;; print and plot the result
   print,'% MKFRAMETIME: ...Trial period found: '+string(format='(F15.8)',trialper)
   print,'% MKFRAMETIME: ...improving period'
   
   IF (psplot EQ 1) THEN BEGIN 
       ;; plot lightcurve to ps-file
       plot,ttime,rate,xstyle=1,position=[0.10,0.70,0.96,0.90],$
         title='Lightcurve',xtitle='Time (sec)',ytitle='Rate (cts/sec)',$
         /noerase,/normal
       ;; plot chi-square of trial-eriod
       plot,chierg(0,*),chierg(1,*),xstyle=1,position=[0.10,0.40,0.48,0.60],$
         title='Chi-Square Distribution of trial period',xtitle='Period (sec)',$
         ytitle=textoidl('\chi^2'),/noerase,/normal
       oplot,[trialper,trialper],[0.,2.*max(chierg(1,*))]
       xyouts,0.47,0.58,'Ptrial='+string(format='(F12.9)',trialper), $
         alignment=1.,/normal
   ENDIF ELSE begin
       plot,chierg(0,*),chierg(1,*),xstyle=1
       oplot,[trialper,trialper],[0.,2.*max(chierg(1,*))]
       xyouts,0.95,0.9,'Ptrial='+string(format='(F15.9)',trialper), $
         alignment=1.,/normal
   ENDELSE 
   
   ;; seaching for the frametime with better start values
   epfold,ttime,rate,pstart=trialper*0.99998,pstop=trialper*1.00002, $
     nbins=60,period=frametime,chierg=chierg,sampling=30,$
     persig=persig
   perstr=strtrim(string(format='(F15.8)',frametime),2)
   print,'% MKFRAMETIME: ...Final period found: ',perstr
   
   ;; print and plot the final result 
   IF (psplot EQ 1) THEN BEGIN 
       plot,chierg(0,*),chierg(1,*),xstyle=1,position=[0.58,0.40,0.96,0.60],$
         title='Chi-Square Distribution of final period',xtitle='Period (sec)',$
         ytitle=textoidl('\chi^2'),/noerase,/normal
       oplot,[frametime,frametime],[0.,2.*max(chierg(1,*))]
       xyouts,0.95,0.58,'Ptrial='+string(format='(F12.9)',frametime), $
         alignment=1.,/normal    
   ENDIF ELSE BEGIN 
       plot,chierg(0,*),chierg(1,*),xstyle=1
       oplot,[frametime,frametime],[0.,2.*max(chierg(1,*))]
       xyouts,0.95,0.9,'Frametime='+perstr, $
         alignment=1.,/normal
   ENDELSE
   
   ;; fold lightcurve with frametime and plot
   pfold,ttime,rate,profile,period=frametime,nbins=100,phbin=phbin
   
   ;; calculate clock time
   clock=frametime/frameclocks
   clock=clock/factor
   
   IF (psplot EQ 1) THEN BEGIN
       plot,phbin+(phbin[1]-phbin[0])/2.,profile,psym=10, $
         position=[0.10,0.10,0.48,0.30],$
         xtitle='Phase (P='+perstr+' s)',$
         ytitle='Count Rate', $
         title='Pulse Profile',/noerase
       xyouts,0.10,0.95,'Comment: '+comment,$
         alignment=0.,/normal
       xyouts,0.52,0.29,'Observation Mode: '+mode+'-Mode',$
         alignment=0.,/normal
       xyouts,0.52,0.26,'1. Trial Period:     '+'Start: '+$
         string(format='(F12.9)',startp)+' sec'+$
         '      End:'+string(format='(F12.9)',stopp)+' sec', $
         alignment=0.,/normal
       xyouts,0.52,0.23,'2. Trial Period:     '+'Start: '+$
         string(format='(F12.9)',trialper*0.99998)+' sec'+$
         '      End:'+string(format='(F12.9)',trialper*1.00002)+' sec', $
         alignment=0.,/normal
       xyouts,0.60,0.20,'Period ='+string(format='(F15.9)',frametime)+textoidl(' \pm')+$
         string(format='(F12.9)',persig)+' sec', $
         alignment=0.,/normal
       xyouts,0.60,0.17,'Max '+textoidl('\chi^2')+' ='+$
         string(format='(F15.9)',max(chierg(1,*))), $
         alignment=0.,/normal
       xyouts,0.60,0.14,'Binsize ='+string(format='(F15.9)',bg)+' sec', $
         alignment=0.,/normal            
       xyouts,0.60,0.11,'Period Sign ='+string(format='(F15.9)',persig)+' sec', $
         alignment=0.,/normal
       xyouts,0.60,0.08,'Clock Freq ='+string(format='(F15.9)',clock*1e9)+' ns', $
         alignment=0.,/normal    
       xyouts,0.98,0.05,'IAAT by '+user+'@'+host+' '+date,charsize=0.9, $
         alignment=1.,/normal
   ENDIF ELSE BEGIN 
       plot,phbin+(phbin[1]-phbin[0])/2.,profile,psym=10, $
         xtitle='Phase (P='+perstr+' s)',$
         ytitle='Count Rate', $
         title='Pulse Profile'
   ENDELSE 
   
   IF (psplot EQ 1) THEN BEGIN  ; close ps device if neccessary
       device,/close
       set_plot,'x'
   ENDIF 
   
   IF (keyword_set(ghost)) THEN BEGIN 
       spawn, 'gv '+plotfile,/sh
   ENDIF   
END 
