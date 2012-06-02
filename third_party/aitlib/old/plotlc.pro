PRO plotlc,time,count,error,over=over,color=color,timerange=timerange,$
           time0=time0,phase=phase,grid=grid,errorbars=errorbars,  $
           mjd=mjd,countrange=countrange
;+
; NAME:
;       PLOTLC
;
;
; PURPOSE:
;       plot a given lightcurve
;
;
; CATEGORY:
;       lightcurve
;
;
; CALLING SEQUENCE:
;       plotlc,time,count,error,/over,/color=color,timerange=[min,max],
;             time0=zerotime,phase=period,/grid,/errorbars,/mjd,
;             countrange=[cmin,cmax] 
; 
; INPUTS:
;       time  : an array containing the time column
;       count : an array containing the counts column
;       error : an array containing the error column
;
;
; OPTIONAL INPUTS:
;       color     : specify the color of the plot
;       zerotime  : if time0 is different from the first entry in the
;                   timecolumn,specify zerotime 
;       period    : if you want a grid, specify the period
;       min,max   : specify the part of the lightcurve to pe plotted
;       cmin,cmax : as min & max, but for the counts 
;	
; KEYWORD PARAMETERS:
;       /over : use an existing plot and plot  the lightcurve in it
;       /grid : plot a grid with the specified period
;       /errorbars : calculate and plot errorbars
;       /mjd  : tells plotlc that the times in the timearray are mjd
;
; OUTPUTS:
;       none  
;
;
; COMMON BLOCKS:
;       plotlccom, stores data for overplotting
;
;
; SIDE EFFECTS:
;       
;
;
; RESTRICTIONS:
;       if you are overplotting an existing window, you cannot specify
;       zerotime or a timerange, nor countrange - these are stored in
;       a common block
;
;
; PROCEDURE:
;       plotlc detects spaces in the lightcurve (SAA,...) and makes
;       sure that no ugly lines are plotted across
;
;
; EXAMPLE:
;       plotlc,time,count,error,timerange=[100,1500],color=200,/errorbars
;
;
; MODIFICATION HISTORY:
;       1997/05/28: now /over works as expected...
;
;       heavily modified, extended and maintained by Ingo Kreykenbohm
;       first code 1996 by Joern Wilms,  both AIT
;
;-

   COMMON plotlccom,tzero,ttimin,ttimax,countmin,countmax



   ;; make sure that all necessary
   ;; keywords are set and if not set them
   ;; to default values

   IF (keyword_set(over)) THEN BEGIN 
       time0=tzero
   END ELSE BEGIN 
       IF (n_elements(time0) EQ 0) THEN time0=time(0)
   END

   ; assume seconds as standard time unit
   IF (keyword_set(mjd)) THEN BEGIN
       xunits = 'days'
   END ELSE BEGIN 
       xunits = 'sec'
   END 
   yunits = 'sec'

   IF (n_elements(color) EQ 0) THEN color=255

   dtime=time-time0
   
   ;; prevent rounding errors
   a = time(1)-time(0)
   break = where(shift(time,-1)-time-a GT 1e-6)

   ;; get timeranges from previous run for overplotting
   IF (keyword_set(over)) THEN BEGIN
       timi = ttimin
       tima = ttimax
       comi = countmin
       coma = countmax
   ENDIF 

   ; if creating a new plot, find minimum and maximum counts
   ; and if no timerange is given, set that one, too

   IF (NOT keyword_set(over)) THEN BEGIN 
       IF (n_elements(timerange) EQ 0) THEN BEGIN 
           timi=min(dtime)
           tima=max(dtime)
       END ELSE BEGIN 
           timi=timerange(0)
           tima=timerange(1)
       END
       IF (n_elements(countrange) EQ 0) THEN BEGIN
           comi = min(count)
           coma = max(count)
       END ELSE BEGIN 
           coma=countrange(1)
           comi=countrange(0)
       END 

       rang=0.05*(tima-timi)
       
       ;; if a phase is given, create the axis apropriate
       IF (n_elements(phase) EQ 0) THEN BEGIN 
           plot,[timi-rang,tima+rang],[comi,1.05*coma], $
           xtitle='Time - '+strtrim(string(time0),2)+' '+xunits, $
           ytitle='Countrate (counts/'+yunits+')',xstyle=1,ystyle=1,/nodata
           ;; create just frame, so we can use oplot in every case
       END ELSE BEGIN 
           plot,[timi-rang,tima+rang],[comi,1.05*coma], $
           ytitle='Countrate (counts/'+yunits+')',xstyle=1+4,ystyle=1,/nodata
           
           axis,xaxis=0,xrange=[timi-rang,tima+rang], $
           xtitle='Time - '+strtrim(string(time0),2)+' '+xunits,/save
           
           nbi=1
           break=0
           WHILE (break NE 1) DO BEGIN 
               IF (nbi NE 1) THEN BEGIN
                   nbi=nbi+10
               END ELSE  BEGIN 
                   nbi=10
               END
               ppp=phase*nbi
               
               nph=fix((tima+2*rang-timi)/ppp)+1
               pha=(fix((timi-rang)/ppp)+indgen(nph))*ppp
               WHILE (pha(0) LT (timi-rang)) DO pha=pha+ppp
               xs=strtrim(string(format='(I4)',nbi*fix(pha/ppp+0.5)),2)
               IF (n_elements(xs) LT 20) THEN break=1
           END 
           xmi=4
           IF (nbi NE 1) THEN xmi=5
           axis,xaxis=1,xtickv=pha,xticks=n_elements(pha)-1, $
           xtickname=xs,xminor=xmi, $
           xtitle='Phase assuming '+strtrim(string(phase),2)+' '+units 
           
           ;; if keyword grid is set, plot a grid
           IF (keyword_set(grid)) THEN BEGIN 
               FOR i=0,n_elements(pha)-1 DO BEGIN 
                   oplot,[pha(i),pha(i)],[0.,1.05*coma],linestyle=1
               ENDFOR 
           ENDIF 
           
       END 
   ENDIF 
   
   IF (break(0) EQ -1) THEN break(0)=n_elements(dtime)-1
   IF (break(n_elements(break)-1) EQ n_elements(dtime)-1) THEN  $
   break=[0,break] ELSE break=[0,break,n_elements(dtime)-1]
   
   pb = max(where(dtime LE timi))
   pe = min(where(dtime GE tima))

   ; plot the data for each time block
   FOR i=long(1),long(n_elements(break)-1) DO BEGIN
       oplot,dtime(break(i-1)+1:break(i)),count(break(i-1)+1:break(i)),$
         color=color
   ENDFOR

   ; plot the errorbars
   IF keyword_set(errorbars) THEN BEGIN 
       FOR i=pb,pe DO BEGIN
           oplot,[dtime(i),dtime(i)],[count(i)-error(i),count(i)+error(i)], $
             color=200
       ENDFOR 
   END 
   ;; save timeranges in common block in case you want to do an
   ;; overplot later 
   tzero  = time0
   ttimax = tima
   ttimin = timi
   countmax = coma
   countmin = comi
END 

