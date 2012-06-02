PRO jwplotlc,time,count,error,color=color,timerange=timerange,$
             time0=time0,xtitle=xtitle,ytitle=ytitle,  $
             mjd=mjd,countrange=countrange,title=title, psym=psym, $
             position=position,noxaxis=noxaxis,noerase=noerase, $
             dt=twidth
;+
; NAME:
;       jwplotlc
;
;
; PURPOSE:
;       plot a lightcurve
;
; CATEGORY:
;       lightcurve
;
;
; CALLING SEQUENCE:
;       jwplotlc,time,count,error,/over,color=color,timerange=[tmin,tmax],
;             time0=time0,/mjd,countrange=[cmin,cmax],psym=psym
; 
; INPUTS:
;       time  : an array containing the time column
;       count : an array containing the counts column
;
;
; OPTIONAL INPUTS:
;       error     : an array containing the uncertainty of the
;                   count-rate; if set, errorbars are drawn
;
;       dt        : the time-interval goes from time-dt to time+dt
;       color     : specify the color of the plot
;       time0     : if the light-curve is offset from the zero-point
;                   of the MJD (=JD2400000.5), specify time0 to get
;                   the correct date labeling.
;       timerange : 2D array (in units of time) to specify the
;                   timerange of the light-curve to be plotted.
;       countrange: 2D-array, specifies range for y-axis if set.
;       psym      : plot-symbol for plotting the data-points
;       position  : a la plot-command
;	
; KEYWORD PARAMETERS:
;        mjd      : set mjd to specify that the time-array is in MJD
;                   (plus an offset given by time0 if set). In this
;                   case the x-axis gets labeled with "real" dates.
;        noxaxis  : don't plot an x-axis
;
; OUTPUTS:
;       none  
;
;
; COMMON BLOCKS:
;       none
;
;
; SIDE EFFECTS:
;       none
;
; RESTRICTIONS:
;       none
;
; PROCEDURE:
;       jwplotlc detects spaces in the lightcurve and makes
;       sure that no ugly lines are plotted across
;
;
; EXAMPLE:
;       jwplotlc,time,count,error,timerange=[100,1500],color=200
;
;
; MODIFICATION HISTORY:
;       Version 1.0, JW, 1997/08/15: based on an earlier version of plotlc
;             written by I. Kreykenbohm and J. Wilms.
;
;       Joern Wilms, wilms@astro.uni-tuebingen.de
;
;-

   IF (n_elements(color) EQ 0) THEN color=!p.color
   IF (n_elements(time0) EQ 0) THEN time0=0D0
   IF (n_elements(noerase) EQ 0) THEN noerase=0

   IF (n_elements(timerange) EQ 0) THEN BEGIN 
       timi=min(time)
       tima=max(time)
       rang=0.05*(tima-timi)
   END ELSE BEGIN 
       timi=timerange(0)
       tima=timerange(1)
       rang=0.
   END
       
   IF (n_elements(countrange) EQ 0) THEN BEGIN
       IF (n_elements(error) EQ 0) THEN BEGIN 
           comi = min(count)
           coma = max(count)
       END ELSE BEGIN 
           comi = min(count-error)
           coma = max(count+error)
       END 
   END ELSE BEGIN 
       coma=countrange(1)
       comi=countrange(0)
   END 

   IF (n_elements(ytitle) EQ 0) THEN ytitle='Countrate (counts/s)'
   nolabel=0
   IF (n_elements(xtitle) NE 0) THEN BEGIN 
       nolabel=1
   END ELSE BEGIN 
       nolabel=0
       xtitle=' '
   END 

   IF (n_elements(title) EQ 0) THEN title=' '

   IF (n_elements(position) EQ 0) THEN BEGIN 
       plot,[timi-rang,tima+rang],[comi,1.05*coma], $
         ytitle=ytitle,xstyle=1+4,ystyle=1,/nodata, $
         xtitle=xtitle,title=title,noerase=noerase
   END ELSE BEGIN 
       plot,[timi-rang,tima+rang],[comi,1.05*coma], $
         ytitle=ytitle,xstyle=1+4,ystyle=1,/nodata, $
         xtitle=xtitle,title=title,position=position, $
         noerase=noerase
   END 

   IF (NOT keyword_set(noxaxis)) THEN BEGIN 
       IF (nolabel EQ 1 OR NOT keyword_set(mjd)) THEN BEGIN 
           axis,xaxis=0,xrange=[timi-rang,tima+rang],xtitle=xtitle,xstyle=1
           axis,xaxis=1,xrange=[timi-rang,tima+rang],xtitle=xtitle,xstyle=1
       END ELSE BEGIN 
           jwdateaxis,mjd=mjd,zeropoint=time0
           jwdateaxis,mjd=mjd,zeropoint=time0,/upper,/nolabel
       END 
   END 

   jwoplotlc,time,count,error,color=color,psym=psym,dt=twidth
END 
