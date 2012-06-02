PRO gtiselect, lightcurve, gti=gti, nops=nops
;+
; NAME:
;           gtiselect
;
;
; PURPOSE:
;           Plot the light curve and generate via interactive modus
;           a gti file. 
;            - left mouse key: zoom in/out
;               +to zoom in:  press mouse key, move left,  release key.
;               +to zoom out: press mouse key, move right, release key.
;            - right mouse key: mark range that should NOT be used as gti.
;               +to mark a range: press mouse key, move, release key.
;               +to write the range into gti file click button without moving. 
;            - middle mouse key: write gti and leave program
;
; CATEGORY:
;           gti file generation
;
;
; CALLING SEQUENCE:
;           gtiselect, 'filename'
;
;
; INPUTS:
;          filename of lightcurve
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;          gti: name for output file          
;          nops: do not create postscript file 
;
; OUTPUTS:
;          gti file: gti.ds
;          PS file: gtiselection.ps
;
;
; OPTIONAL OUTPUTS:
;          gti file: name according to keyword gti          
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;          gtiselect, 'sourcelightcurce.lc' [, gti='mygtifile.fits']          
;
;
; MODIFICATION HISTORY:
;          Version 1.1: created by Martin Stuhlinger
;          Version 1.2: added keyword gti for gti file name
;                       05.09.2001, Martin Stuhlinger
;          Version 1.3: create PS file of light curve with marked gti intervals
;                       and added keyword nops to prevent it.
;                       16.05.2002, Martin Stuhlinger
;          Version 1.4: find out whether table column inside the
;                       lightcurve fits file is named "RATE" or
;                       "COUNTS" 
;                        06.08.2002, Martin Stuhlinger
;          Version 1.5: Bug fix: strmatch for TTYPE RATE is not any more
;                       restricted to TTYPE1. 
;                       14.03.2003, Martin Stuhlinger
;-                      

;; define name of output gti file
IF (keyword_set(gti)) THEN gtifile=gti ELSE gtifile='gti.ds'


; check whether table column is named "RATE" or "COUNTS"
test=readfits(lightcurve, header, EXTEN_NO=1)

; if in fits BINTABLE the keyword "RATE" does not exist, the task
; readlc needs the parameter "/counts" to read the lightcurve
IF (where(strmatch(header, "TTYPE*RATE*")) EQ -1) THEN BEGIN
  ;; read lightcurve:
  readlc,time,rate,lightcurve,/counts
ENDIF ELSE BEGIN
  ;; read lightcurve:
  readlc,time,rate,lightcurve
ENDELSE


;; get binning of the lightcurve
t=time-time(0)
binning=string( t(1)-t(0),format='(F5.1)')


;; define start time of observation
tstart=time(0)

;; define stop time of observation
tstop=time(n_elements(time)-1)

;; define range coordinates for the plot
left=time(0)
right=time(n_elements(time)-1)

;;plot light curve 
plot,time,rate, $
         ytitle='Countrate (Counts/'+binning+' sec)', $
         xrange=[left,right], xtitle='Time', $
         title='Lightcurve: '+lightcurve

;; be sure that !MOUSE.button IS NOT 4  before the loop.
!MOUSE.button=0

;; print explanation how the program is working:
print,'*******************************************************************'
print,'Plot the light curve and generate via interactive modus a gti file.'
print,''
print,'    - left mouse key: zoom in/out'
print,'        +to zoom in:  press mouse key, move left,  release key.'
print,'        +to zoom out: press mouse key, move right, release key.'
print,''
print,'    - right mouse key: mark range that should NOT be used as gti.'
print,'        +to mark a range press mouse key, move, release key.'
print,'        +to write the range into gti file click button without moving.' 
print,''
print,'    - middle mouse key: write gti and leave program'
print,'*******************************************************************'
print,''


WHILE (!MOUSE.button NE 2) DO BEGIN


  ;; get times at cursor positions when mousekey is pressed/released
  CURSOR, cstart, r, /DATA, /DOWN

  ;;plot light curve 
  plot,time,rate, $
    ytitle='Countrate (Counts/'+binning+' sec)', $
    xrange=[left,right], xtitle='Time', $
    title='Lightcurve: '+lightcurve
  oplot,[cstart,cstart],[0,max(rate)],linestyle=1

  CURSOR, cstop, r, /DATA, /UP
  oplot,[cstop,cstop],[0,max(rate)],linestyle=1


   ;; selection of the lightcurve range
   IF (!MOUSE.button EQ 1) THEN  BEGIN
     ;; zoom in
     IF (cstart LT cstop) THEN  BEGIN
       left=cstart
       right=cstop
     ENDIF 
     ;; zoom out
     IF (cstart GT cstop) THEN  BEGIN
       left=time(0)
       right=time(n_elements(time)-1)
     ENDIF 

     ;;plot light curve 
     plot,time,rate, $
         ytitle='Countrate (Counts/'+binning+' sec)', $
         xrange=[left,right], xtitle='Time', $
         title='Lightcurve: '+lightcurve
   ENDIF 

   ;; selection of no gti times 
   IF (!MOUSE.button EQ 4) THEN  BEGIN
     ;; gti must stop with begin of selected lightcurve range
     ;; and start again with the end of selected lightcurve range
     IF (cstart LT cstop) THEN  BEGIN
       stop=cstart
       start=cstop
     ENDIF 
     IF (cstart GT cstop) THEN  BEGIN
       stop=cstop
       start=cstart
     ENDIF 
     ;; take range into gti array
     IF (cstart EQ cstop) THEN  BEGIN
       tstop=[tstop,stop]
       tstart=[tstart,start]
       print, 'Selected time range: gti stop=',stop, ';  gti start=',start
     ENDIF 

   ENDIF 

ENDWHILE


;; write gti file only if there was any selection
;;IF (n_elements(tstart) GT 1) THEN BEGIN 
  ;; sort arrays to increasing times
  a=sort(tstart)
  tstart=tstart(a)
  a=sort(tstop)
  tstop=tstop(a)

  ;;catch exception: first tstart is later than start of observation 
  ;;                 => first tstop earlier than start of observation  
  ;;                 correction: ignore first index of gti arrays
  IF (tstop(0) LT time(0)) THEN startindex=1 ELSE startindex=0


  ;;catch exception: last tstop is earlier than end of observation 
  ;;                 => last tstart later than stop of observation  
  ;;                 correction: ignore last index of gti arrays
  IF (tstart(n_elements(tstart)-1) GT time(n_elements(time)-1)) THEN stopindex=n_elements(tstop)-2 ELSE stopindex=n_elements(tstop)-1 


  ;; generate gti file
  writegti, tstart[startindex:stopindex], tstop[startindex:stopindex], gtifile
  print,''
  print,'************************************'
  print,'Output written in file ',gtifile 
  print,'************************************'
;;ENDIF 


;; Output into postscript-file
IF NOT (keyword_set(nops)) THEN BEGIN 
  ;; load color table for plots
  loadct, 39
  ;; cut extension '.lc' out of inputfile name: find position of the '.'
  ;; and extract the string from begin up to the character before the '.' 
  outname=STRMID(lightcurve, 0, strsplit(lightcurve,'.')-1)
  ;; open output file
  open_print,'gtiselection.ps', /postscript, /color
  device, /landscape
  ;; plot lightcurve including all selections:
  left=time(0)
  right=time(n_elements(time)-1)
  ;;plot frame for light curve 
  plot,time,rate, /nodata, $
         ytitle='Countrate (Counts/'+binning+' sec)', $
         xrange=[left,right], xtitle='Time', $
         title='Lightcurve: '+lightcurve

  ;; selected good times: tstart-tstop  
  FOR loop=startindex, stopindex DO BEGIN
     ;; get all indices of time array for good time interval 
     index=where((time GE tstart(loop)) AND (time LE tstop(loop)))
     ;; plot part of light curve in green color
     oplot, time(index), rate(index), color=145, linestyle=0
  ENDFOR 

  ;; selected bad times: tstop-tstart
  FOR loop=startindex, stopindex-1 DO BEGIN
     ;; get all indices of time array for good time interval 
     index=where((time GT tstop(loop)) AND (time LT tstart(loop+1)))
     ;; plot part of light curve in red color
     oplot, time(index), rate(index), color=250, linestyle=1
  ENDFOR 

  ;; Look for exception: first tstart is later than start of observation 
  IF (tstop(0) LT time(0)) THEN BEGIN
     ;; get all indices of time array before first gti start time 
     index=where(time LT tstart(1))
     ;; plot part of light curve in red color
     oplot, time(index), rate(index), color=250, linestyle=1
  ENDIF 

  ;; Look for exception: last tstop is earlier than end of observation 
  IF (tstart(n_elements(tstart)-1) GT time(n_elements(time)-1)) THEN BEGIN
     ;; get all indices of time array after last gti stop time
     index=where(time GT tstop(n_elements(tstart)-2))
     ;; plot part of light curve in red color
     oplot, time(index), rate(index), color=250, linestyle=1
  ENDIF 


  ;; close postscript-file and start ghostview
  close_print,/ghost
ENDIF 



END

