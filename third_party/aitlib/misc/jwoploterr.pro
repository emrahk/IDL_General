PRO makearrow,x,y,down=down,up=up,left=left,right=right,color=color, $
              size=size,thick=thick,fill=fill,xscale=xscale,yscale=yscale
;+
; NAME:
;           makearrow
;
;
; PURPOSE:
;           plot an arrow, pointing up, down, left, or right
;
;
; CATEGORY:
;           plotting
;
;
; CALLING SEQUENCE:
;           makearrow,x,y, and one of the keywords
;
; 
; INPUTS:
;           x,y: position (in data-coordinates) where the tip of the arrow
;                will be placed
;
; OPTIONAL INPUTS:
;
;
;	
; KEYWORD PARAMETERS:
;          up,down,left,right: direction of the arrow
;          color: color of the arrow
;          size:  scaling-factor of the arrow
;          xscale,yscale: individual scale for x and y extent of arrow
;          thick: line thickness
;          fill: Fill the arrows
;
; RESTRICTIONS:
;          one of the keywords MUST be given
;
;
; PROCEDURE:
;          trivial
;
;
;
; MODIFICATION HISTORY:
;         Version 0.5, 1997/06/23 Joern Wilms (wilms@astro.uni-tuebingen.de)
;         Version 0.6, 1999/07/13 Joern Wilms
;              (wilms@astro.uni-tuebingen.de)
;         CVS Version 1.1, 2001.09.06: JW/SB, added xscale,yscale, and
;             fill options
;
;-

   IF (n_elements(size) EQ 0) THEN size=1.

   IF (n_elements(xscale) EQ 0) THEN xscale=1.
   IF (n_elements(yscale) EQ 0) THEN yscale=1.

   IF (n_elements(thick) EQ 0) THEN thick=1.

   nor=convert_coord(x,y,/data,/to_normal)
   xn=nor(0,0) & yn=nor(1,0)

   

   arr=[-0.015,0.,-0.015]*size*yscale
   off=[-0.005,0.,+0.005]*size*xscale

   IF (keyword_set(fill)) THEN BEGIN 
     IF (keyword_set(down)) THEN BEGIN 
       polyfill,xn+off,yn-arr,color=color,/normal,noclip=0
     ENDIF 
     IF (keyword_set(up)) THEN BEGIN 
       polyfill,xn+off,yn+arr,color=color,/normal,noclip=0
     ENDIF 
     IF (keyword_set(left)) THEN BEGIN 
       polyfill,xn-arr,yn+off,color=color,/normal,noclip=0
     ENDIF 
     IF (keyword_set(right)) THEN BEGIN 
       polyfill,xn+arr,yn+off,color=color,/normal,noclip=0
     ENDIF 
   ENDIF ELSE BEGIN 
     IF (keyword_set(down)) THEN BEGIN 
       plots,xn+off,yn-arr,color=color,/normal,noclip=0,thick=thick
     ENDIF 
     IF (keyword_set(up)) THEN BEGIN 
       plots,xn+off,yn+arr,color=color,/normal,noclip=0,thick=thick
     ENDIF 
     IF (keyword_set(left)) THEN BEGIN 
       plots,xn-arr,yn+off,color=color,/normal,noclip=0,thick=thick
     ENDIF 
     IF (keyword_set(right)) THEN BEGIN 
       plots,xn+arr,yn+off,color=color,/normal,noclip=0,thick=thick
     ENDIF 
   ENDELSE 
END 

PRO makedash,x,y,horizontal=horizontal,vertical=vertical,color=color,size=size,thick=thick
;+
; NAME:
;           makedash
;
;
; PURPOSE:
;           plot a dash, horizontal or vertical
;
;
; CATEGORY:
;           plotting
;
;
; CALLING SEQUENCE:
;           makedash,x,y, and one of the keywords
;
; 
; INPUTS:
;           x,y: position (in data-coordinates) where the dash will be placed
;
; OPTIONAL INPUTS:
;
;
;	
; KEYWORD PARAMETERS:
;          horizontal,vertical: direction of the dash
;          color: color of the dash
;          size:  scaling-factor of the dash (default: 1)
;
; RESTRICTIONS:
;          one of the keywords MUST be given
;
;
; PROCEDURE:
;          trivial
;
;
;
; MODIFICATION HISTORY:
;         Version 0.5, 1997/06/23 Joern Wilms (wilms@astro.uni-tuebingen.de)
;         Version 0.6, 1999/07/13 Joern Wilms (wilms@astro.uni-tuebingen.de)
;
;-

   IF (n_elements(size) EQ 0) THEN size=1.
   IF (n_elements(thick) EQ 0) THEN thick=1.

   nor=convert_coord(x,y,/data,/to_normal)
   xn=nor(0,0) & yn=nor(1,0)

   dash=[-0.0075,+0.0075]*size

   IF (keyword_set(horizontal)) THEN BEGIN 
       plots,xn+dash,[yn,yn],color=color,/normal,noclip=0,thick=thick
   ENDIF 
   IF (keyword_set(vertical)) THEN BEGIN 
       plots,[xn,xn],yn+dash,color=color,/normal,noclip=0,thick=thick
   ENDIF 
END 

PRO jwoploterr,x,y,sig,dx=dx,psym=psym,symsize=symsize,color=color,ymin=ymin, $
               ymax=ymax,xmin=xmin,xmax=xmax,size=size,linestyle=linestyle, $
               endmark=endmark,thick=thick,noarrow=noarrow
;+
; NAME:
;             jwoploterr
;
;
; PURPOSE:
;             Overplot data-points with possible uncertainties in the
;             X- and Y-direction to a pre-existing plot (in this sense
;             the functionality is similar to oploterr). If the
;             error-bars do not fit in the given x- or y-range, 
;             plot arrows.
;
;
; CATEGORY:
;             plotting
;
;
; CALLING SEQUENCE:
;             jwoploterr,x,y,sig
;
; 
; INPUTS:
;             x: Array of X-values
;             y: Array of Y-values
;           sig: Array of Y-error-bars
;
; OPTIONAL INPUTS:
;           
;
;	
; KEYWORD PARAMETERS:
;            dx: Array containing the width of the x-bins (from -dx to +dx)
;          psym: Psym to be used (default: 0)
;       symsize: Symsize to be used (default: 1)
;         color: color to be used (default: !p.color)
;     ymin,ymax: min. and max. y-values of the plot (taken from !p.clip if
;                not set)
;     xmin,xmax: min. and max. x-values (ditto). 
;          size: Scaling-Factor for the arrows and dashes
;       endmark: if set: draw a dash at the end of the error-bars 
;         thick: thickness of the lines
;
; SIDE EFFECTS:
;          a plot is created
;
;
; RESTRICTIONS:
;          none; x-range is not yet implemented
;
;
; PROCEDURE:
;          see procedure
;
;
; EXAMPLE:
;          x=findgen(10)
;          y=x*x
;         dy=x
;         jwoploterr,x,y,dy
;
;
; MODIFICATION HISTORY:
;         Version 0.5, 1997/06/23 Joern Wilms (wilms@astro.uni-tuebingen.de)
;         Version 0.6, 1998/06/13 Joern Wilms: added endmark keyword   
;         Version 0.7, 1998/08/04 Joern Wilms: now allow for VERY
;            large arrays by having the for-loop with i being a long.
;         Version 0.8, 1999/01/15 Joern Wilms: deal with special case
;            that x and y only contain one element
;         Version 0.9, 1999/07/13 Joern Wilms: added thick keyword
;         Version 0.91, 1999/07/13 Joern Wilms: added noarrow keyword
;         Version 0.92, 1999/08/11 Joern Wilms: repaired embarrassing
;            error when trying to plot unsymmetric error bars
;         Version 0,93, 1999/08/13 Joern Wilms: Started implementing
;            unsymmetrical x-errors
;
;-

   IF (n_elements(psym) EQ 0) THEN psym=3
   IF (n_elements(symsize) EQ 0) THEN symsize=1.
   IF (n_elements(color) EQ 0) THEN color=!p.color
   IF (n_elements(size) EQ 0) THEN size=1.
   IF (n_elements(linestyle) EQ 0) THEN linestyle=0
   IF (n_elements(thick) EQ 0) THEN thick=1
   
   ;; if Clip-Ranges is not given, then we'll figure out the limits by
   ;; ourselves
   clip=!p.clip
   ranges=convert_coord([clip(0),clip(2)],[clip(1),clip(3)],/device,/to_data)

   IF (n_elements(xmin) EQ 0) THEN xmin=ranges(0,0)
   IF (n_elements(ymin) EQ 0) THEN ymin=ranges(1,0)
   IF (n_elements(xmax) EQ 0) THEN xmax=ranges(0,1)
   IF (n_elements(ymax) EQ 0) THEN ymax=ranges(1,1)
   
   ;; Plot the symbols
   IF (n_elements(x) EQ 1) THEN BEGIN 
       plots,x,y,psym=psym,symsize=symsize,color=color, $
         linestyle=linestyle,thick=thick
   END ELSE BEGIN 
       oplot,x,y,psym=psym,symsize=symsize,color=color, $
         linestyle=linestyle,thick=thick
   END
   
   ;; Plot the error-bars
   FOR i=0L,n_elements(x)-1 DO BEGIN 
       xx=x(i)
       yy=y(i)

       IF ( (size(sig))(0) EQ 1) THEN BEGIN 
           y1=y(i)-sig(i)
           y2=y(i)+sig(i)
       END ELSE BEGIN 
           y1=y(i)-sig(1,i)
           y2=y(i)+sig(0,i)
       END 
       
       IF (y1 GT y2) THEN BEGIN 
           message,'Error bars erroneous'
       ENDIF 
       
       ;;
       ;; Treatment of y-direction
       ;;
       IF ((y1 GE ymin) AND (y2 LE ymax))  THEN BEGIN 
           ;;
           ;; all is nice: we like this case
           ;;
           oplot,[xx,xx],[y1,y2],color=color,thick=thick
           ;;
           ;; plot dashes at the end 
           ;;
           IF (keyword_set(endmark)) THEN BEGIN 
               makedash,xx,y1,color=color,size=size,$
                 thick=thick,/horizontal
               makedash,xx,y2,color=color,size=size,$
                 thick=thick,/horizontal
           END 
       END ELSE BEGIN 
           ;;
           ;; lot's of possibilities in the case of limits
           ;; extending over the boundaries
           ;;
           IF (y1 LT ymin) THEN BEGIN 
               IF (y2 LT ymin) THEN BEGIN 
                    ;; Draw arrow 15% of height of window
                   temp=convert_coord([clip(0)], $
                                      [clip(1)+0.15*(clip(3)-clip(1))], $
                                      /device,/to_data)
                   yy=temp(1) ;; Override current data-value
                   oplot,[xx,xx],[yy,ymin],color=color,thick=thick
                   IF (NOT keyword_set(noarrow)) THEN BEGIN 
                       makearrow,xx,ymin,/down,color=color,size=size, $
                         thick=thick
                   ENDIF 
               END ELSE BEGIN 
                   IF (y2 LE ymax) THEN BEGIN 
                       oplot,[xx,xx],[ymin,y2],color=color,thick=thick
                       IF (keyword_set(endmark)) THEN BEGIN 
                           makedash,xx,y2,color=color,size=size, $
                             /horizontal,thick=thick
                       END 
                       IF (NOT keyword_set(noarrow)) THEN BEGIN 
                           makearrow,xx,ymin,/down,color=color,size=size, $
                             thick=thick
                       ENDIF 
                   END ELSE BEGIN 
                       oplot,[xx,xx],[ymin,ymax],color=color
                       IF (NOT keyword_set(noarrow)) THEN BEGIN 
                           makearrow,xx,ymin,/down,color=color,size=size, $
                             thick=thick
                           makearrow,xx,ymax,/up,color=color,size=size, $
                             thick=thick
                       ENDIF 
                   END
               END 
           END ELSE BEGIN 
               IF (y1 GT ymax) THEN BEGIN  
                   ;; Draw arrow 15% of height of window
                   temp=convert_coord([clip(0)], $
                                      [clip(3)-0.15*(clip(3)-clip(1))], $
                                      /device,/to_data)
                   yy=temp(1) ;; Override current data-value
                   oplot,[xx,xx],[yy,ymax],color=color,thick=thick
               END ELSE BEGIN 
                   oplot,[xx,xx],[y1,ymax],color=color,thick=thick
                   IF (keyword_set(endmark)) THEN BEGIN 
                       makedash,xx,y1,color=color,size=size, $
                         /horizontal,thick=thick
                   END 
               END
               IF (NOT keyword_set(noarrow)) THEN BEGIN 
                   makearrow,xx,ymax,/up,color=color,size=size,thick=thick
               ENDIF 
           END 
       END 
       ;;
       ;; Treatment of x-direction (not yet done)
       ;;
       IF (n_elements(dx) NE 0) THEN BEGIN 
           IF ( (size(dx))(0) EQ 1) THEN BEGIN 
               x1=x(i)-dx(i)
               x2=x(i)+dx(i)
           END ELSE BEGIN 
               x1=x(i)-dx(1,i)
               x2=x(i)+dx(0,i)
           END 

           IF ((x1 GE xmin) AND (x2 LE xmax)) THEN BEGIN 
               ;;
               ;; No extend over clipping rectangle: all is nice!
               ;;
               oplot,[x1,x2],[yy,yy],color=color,thick=thick
               ;;
               ;; plot dashes at the end 
               ;;
               IF (keyword_set(endmark)) THEN BEGIN 
                   makedash,x1,yy,color=color,size=size,$
                     thick=thick,/vertical
                   makedash,x2,yy,color=color,size=size,$
                     thick=thick,/vertical
               END 
           END 
           ;;
           ;; Here is where the trouble starts
           ;;
           IF ((x1 GT  xmin) AND (x1 LT xmax) AND  (x2 GT xmax)) THEN BEGIN 
               oplot,[x1,xmax],[yy,yy],color=color,thick=thick
               IF (NOT keyword_set(noarrow)) THEN BEGIN 
                   makearrow,xmax,yy,/right,color=color,size=size, $
                     thick=thick
               ENDIF 
           END 
           IF ((x1 LT  xmin) AND  (x2 GT xmax)) THEN BEGIN 
               oplot,[xmin,xmax],[yy,yy],color=color,thick=thick
               IF (NOT keyword_set(noarrow)) THEN BEGIN 
                   makearrow,xmax,yy,/right,color=color,size=size, $
                     thick=thick
                   makearrow,xmin,yy,/left,color=color,size=size, $
                     thick=thick
               ENDIF 
           END 
           IF ((x1 LT  xmin) AND  (x2 LT xmax) AND (x2 GT xmin)) THEN BEGIN 
               oplot,[xmin,x2],[yy,yy],color=color,thick=thick
               IF (NOT keyword_set(noarrow)) THEN BEGIN 
                   makearrow,xmin,yy,/left,color=color,size=size, $
                     thick=thick
               ENDIF 
           END 
           ;;
           ;; OTHER CASES STILL TO BE CODED
           ;;
       ENDIF 
   ENDFOR 
END 

