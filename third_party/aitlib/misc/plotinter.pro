
PRO plotinter,when,loc,what=what,dloc=dloc,ignore0=ignore0,time0=time0
;+
; NAME: plotinter
;
;
;
; PURPOSE: plot a line to designate an interval (e.g., to show the
;    time intervals when a project has to be worked on...)
;
;
;
; CATEGORY: plotting tools
;
;
;
; CALLING SEQUENCE:plotinter,when,loc,what=what,dloc=dloc,ignore0=ignore0
;
;
;
; INPUTS:
;          when: 2d array containing the start and stop x-positions
;                defining the intervals. when(0,*) is the start,
;                when(1,*) the stop
;          loc : y position(s) for the intervals, one per interval
;
; OPTIONAL INPUTS:
;          what: array of strings with the labels for each interval.
;                if given, the string is centered on the interval
;                and the lines are drawn on the sides of the interval
;          dloc: dislocate every 2nd label by a factor dloc
;          time0: time offset of the data in the when-array wrt to the
;                currently set x-coordinate of the plot
;
; KEYWORD PARAMETERS:
;          ignore0: if set, completely ignore intervals for which the
;                 start and stop times are the same
;
;
; EXAMPLE:
;           TBD!!!!!
;
;
; MODIFICATION HISTORY:
;   Version 1.0: Joern Wilms, sometime around 1994
;   Version 1.1: 2001/01/04, JW/KP: added ignore0 keyword and doc header
;-
   
   IF (n_elements(time0) EQ 0) THEN time0=0.
   IF (n_elements(dloc) EQ 0) THEN dloc=0.

   charsize=1.
   FOR i=0,n_elements(when(0,*))-1 DO BEGIN 
       ts=when(0,i)
       te=when(1,i)
       IF ( ts NE te OR keyword_set(ignore0)) THEN BEGIN 
           IF (n_elements(what) GT i) THEN BEGIN 
               tl=(ts+te)/2.
               pp=loc
               IF ( (i MOD 2) EQ 0) THEN pp=loc+dloc
               pos=convert_coord([ts,te]-time0,[pp,pp],/data,/to_device)
               xs=pos(0,0)
               xe=pos(0,1)
               x=(xs+xe)/2.
               y=pos(1,0)
               xyouts,x,y-0.4*charsize*!d.y_ch_size,what(i),alignment=0.5,/device
               wid=charsize*!d.x_ch_size*strlen(what(i))
               IF (x-1.1*wid/2. GT xs) THEN BEGIN 
                   plots,[xs,x-1.1*wid/2.],[y,y],/device,noclip=0
                   plots,[x+1.1*wid/2.,xe],[y,y],/device,noclip=0
               END
           END ELSE BEGIN 
               plots,[ts,te],[loc,loc],noclip=0
           END 
       END 
   END 
END 

