PRO  plotgti,startt,stopt,time0,yoff,color=color
;+
; NAME:
;      plotgti
;
;
; PURPOSE:
;       plot the goodtimes of .gti file read with readgti in an
;       existing window 
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;       plotgti,starttime,stoptime,zerotime,yoffset,color=color
;
; 
; INPUTS:
;       starttime : an array containing the times where to begin the lines
;       stoptime  : where the lines ends
;       zerotime  : time0 of the existing plot       
;
;
; OPTIONAL INPUTS:
;       yoffset : where to place the gti line vertically , the default
;                 is 100 
;       color   : which color to use
;	
; EXAMPLE:
;       plotgti,6.7578000e7,6.7579000e7,6.7574000,1000,color=200
;
;
; MODIFICATION HISTORY:
;       written by Ingo Kreykenbohm 1996, AIT
;-

   t1=startt-time0
   t2=stopt-time0
   
   IF (n_elements(color) EQ 0) THEN color = 255
   
   IF (n_elements(yoff) EQ 0) THEN yoff = 100;

   FOR i=0,n_elements(startt)-1 DO BEGIN
       oplot,[t1(i),t2(i)],[yoff,yoff],color=color
   ENDFOR

END 
