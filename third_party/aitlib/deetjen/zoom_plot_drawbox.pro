;; =============================================================================
;+
; NAME:
;       ZOOM_PLOT_DRAWBOX
;
; PURPOSE:
;
;       Event handler for 'zoom_plot.pro'.
;       This event handler continuously draws and erases the arrow box until it
;       receives an UP event from the draw widget. Then it turns draw widget motion
;       events OFF and changes the event handler for the draw widget back to
;       ZOOM_PLOT_EVENTS.
;
; AUTHOR:
;
;   Jochen L. Deetjen
;   Institut fuer Astronomie und Astrophysik Tuebingen
;   Waldhaeuser Str. 64
;   D-72076 Tuebingen
;   Germany
;
;
;   'zoom_plot.pro' is based on 'zplot.pro' by
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; MODIFICATION HISTORY:
;
;        Written by: David Fanning, 15 February 2000.
;        Modified the original rubberband box to be an "arrow box". 1 April 2000. DWF.
;
;        Modification by: Jochen L. Deetjen, 7 May 2001.
;        Added the optional 'OPlot' routines and changed colors. 
;        Added zooming in y direction.
;-
;; =============================================================================
;
;###############################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Fanning Software Consulting
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###############################################################################



;-------------------------------------------------------------------------------
;
; PURPOSE: This event handler continuously draws and erases the arrow box until it
;      receives an UP event from the draw widget. Then it turns draw widget motion
;      events OFF and changes the event handler for the draw widget back to
;      ZOOM_PLOT_EVENTS.
;  
;
PRO ZOOM_PLOT_DRAWBOX, event
   
   parent = widget_info(event.handler,/parent)
   
   ;; Get the info structure out of the top-level base.
   ;;
   Widget_Control, parent, Get_UValue=info, /No_Copy

   ;;  Set up colors for line plot.
   ;;
   backColor  = GetColor('black', !D.Table_Size-2)
   dataColor  = GetColor('white', !D.Table_Size-3)
   dataColor2 = GetColor('yellow', !D.Table_Size-4)
   dataColor3 = GetColor('red', !D.Table_Size-5)
   axisColor  = GetColor('green', !D.Table_Size-6)
   boxColor   = GetColor('beige', !D.Table_Size-7)
   
   ;; What type of an event is this?
   ;;
   possibleEventTypes = [ 'DOWN', 'UP', 'MOTION', 'SCROLL' ]
   thisEvent = possibleEventTypes(event.type)
   
   IF thisEvent EQ 'UP' THEN BEGIN
       
       ;; If this is an UP event, you need to erase the zoombox, restore
       ;; the user's color table, turn motion events OFF, set the
       ;; draw widget's event handler back to ZOOM_PLOT_EVENTS, and
       ;; draw the "zoomed" plot in both the draw widget and the pixmap.
       
       ;; Erase the arrow box one final time by copying the plot from the pixmap.
       ;;
       WSet, info.drawIndex
       Device, Copy = [0, 0, info.zxsize, info.zysize, 0, 0, info.pixIndex]
       
       ;; Turn motion events off and redirect the events to ZOOM_PLOT_EVENTS.
       ;;
       Widget_Control, event.id, Draw_Motion_Events=0, $
         Event_Pro='ZOOM_PLOT_EVENTS'

       ;; Draw the "zoomed" plot. Start by getting the new limits to the plot
       ;; (i.e., the LAST zoom box outline).
       ;;
       x = [info.xs, event.x]
       y = [info.ys, event.y]
       
       IF (info.mouseButton EQ 'LEFT') THEN BEGIN
           
           ;; Make sure the x values are ordered as [min, max].
           ;;
           IF info.xs GT event.x THEN x = [event.x, info.xs]
           
           ;; Don't want exact style if we are drawing entire plot.
           ;;
           IF info.xs EQ event.x THEN xstyle = 0 ELSE xstyle = 1
           info.xstyle = xstyle
           
       END
       
       
       IF (info.mouseButton EQ 'MIDDLE') THEN BEGIN
           
           ;; Make sure the y values are ordered as [min, max].
           ;;
           IF info.ys GT event.y THEN y = [event.y, info.ys]

           ;; Don't want exact style if we are drawing entire plot.
           ;;
           IF info.ys EQ event.y THEN ystyle = 0 ELSE ystyle = 1
           info.ystyle = ystyle
           
       END
       
       ;; Restore plot system variables.
       ;;
       !X = info.x
       !Y = info.y
       !P = info.p
       
       ;; Convert the x device coordinates to data coordinates.
       ;;
       coords = Convert_Coord(x, y, /Device, /To_Data)
   
       IF (info.mouseButton EQ 'LEFT') THEN BEGIN
           
           ;; Make sure the x coordinates are within the data boundaries of the plot.
           ;;
           x1 = MIN(info.indep) > coords(0,0) < MAX(info.indep)
           x2 = MIN(info.indep) > coords(0,1) < MAX(info.indep)
           info.xrange = [x1,x2]
       END
       
       IF (info.mouseButton EQ 'MIDDLE') THEN BEGIN
   
           ;; Make sure the y coordinates are within the data boundaries of the plot.
           ;;
           ;;y1 = MIN(info.dep) > coords(1,0) < MAX(info.dep)
           ;;y2 = MIN(info.dep) > coords(1,1) < MAX(info.dep)
           y1 = coords(1,0)
           y2 = coords(1,1) 
           info.yrange = [y1,y2]           
       END
       
       IF (info.mouseButton EQ 'RIGHT') THEN BEGIN
           
           ;; Reset coordinates
           ;;
           info.xrange = [Min(info.indep), Max(info.indep)]
           info.xstyle = 1
           IF (info.y2_set EQ 1) THEN BEGIN
               IF (info.y3_set EQ 1) THEN BEGIN
                   info.yrange = [Min([info.dep,info.y2,info.y3]),Max([info.dep,info.y2,info.y3])]
               END ELSE BEGIN
                   info.yrange = [Min([info.dep,info.y2]),Max([info.dep,info.y2])]
               END 
           END ELSE BEGIN 
               info.yrange = [Min(info.dep),Max(info.dep)]
           END    
           info.ystyle = 1
           
       END
       
       ;; Draw the "zoomed" plot in both the draw widget and the pixmap.
       ;;
       yDataRange = [Min(info.dep),Max(info.dep)]
       Plot, info.indep, info.dep, $
         XRange=info.xrange, XStyle=info.xstyle, $
         YRange=info.yrange, YStyle=info.ystyle, $
         Background=backColor, Color=axisColor,  $
         /NoData, PSYM=info.psym, $
         _Extra=*info.extraKeywords
       
       OPlot, info.indep, info.dep, Color=dataColor, PSYM=info.psym, _Extra=*info.extraKeywords
       IF (info.y2_set EQ 1) THEN BEGIN
           IF (info.x2_set EQ 1) THEN BEGIN
               OPlot, info.x2, info.y2, Color=dataColor2, PSYM=info.psym, _Extra=*info.extraKeywords
           END ELSE BEGIN
               OPlot, info.indep, info.y2, Color=dataColor2, PSYM=info.psym,_Extra=*info.extraKeywords 
           END
       END
       IF (info.y3_set EQ 1) THEN BEGIN
           IF (info.x3_set EQ 1) THEN BEGIN
               OPlot, info.x3, info.y3, Color=dataColor3, PSYM=info.psym, _Extra=*info.extraKeywords
           END ELSE BEGIN
               OPlot, info.indep, info.y3, Color=dataColor3, PSYM=info.psym, _Extra=*info.extraKeywords
           END
       END
       
       WSet, info.pixIndex
       Plot, info.indep, info.dep, $
         XRange=info.xrange, XStyle=info.xstyle, $
         YRange=info.yrange, YStyle=info.ystyle, $
         Background=backColor, Color=axisColor,  $
         /NoData, PSYM=info.psym, $
         _Extra=*info.extraKeywords
       
       OPlot, info.indep, info.dep, Color=dataColor, PSYM=info.psym,  _Extra=*info.extraKeywords
       IF (info.y2_set EQ 1) THEN BEGIN
           IF (info.x2_set EQ 1) THEN BEGIN
               OPlot, info.x2, info.y2, Color=dataColor2, PSYM=info.psym,  _Extra=*info.extraKeywords
           END ELSE BEGIN
               OPlot, info.indep, info.y2, Color=dataColor2, PSYM=info.psym,  _Extra=*info.extraKeywords
           END
       END
       IF (info.y3_set EQ 1) THEN BEGIN
           IF (info.x3_set EQ 1) THEN BEGIN
               OPlot, info.x3, info.y3, Color=dataColor3, PSYM=info.psym,  _Extra=*info.extraKeywords
           END ELSE BEGIN
               OPlot, info.indep, info.y3, Color=dataColor3, PSYM=info.psym,  _Extra=*info.extraKeywords
           END
       END
       
       ;; Update the plot system variables.
       ;;
       info.x = !X
       info.y = !Y
       info.p = !P
       
       ;; Put the info structure back into its storage location and then, out of here!
       ;;
       Widget_Control, parent, Set_UValue=info, /No_Copy
       RETURN
       
   ENDIF ;; thisEvent = UP


   ;; Most of the action in this event handler occurs here while we are waiting
   ;; for an UP event to occur. As long as we don't get it, keep erasing the
   ;; old zoom box and drawing a new one.

   ;; Erase the old zoom box.
   ;;
   WSet, info.drawIndex
   Device, Copy = [0, 0, info.zxsize, info.zysize, 0, 0, info.pixIndex]
   
   ;; Update the dynamic corner of the zoom box to the current cursor location.
   ;;
   info.xd = event.x
   info.yd = event.y
   
   ;; Restore plot system variables.
   ;;
   !X = info.x
   !Y = info.y
   !P = info.p
   
   ;; Convert the x device coordinates to data coordinates.
   ;;
   x = [info.xs, event.x]
   y = [info.ys, event.y]
   coords = Convert_Coord(x, y, /Device, /To_Data)

   ;; Make sure the x coordinates are within the data boundaries of the plot.
   ;;
   x1 = !X.CRange(0) > coords(0,0) < !X.CRange(1)
   x2 = !X.CRange(0) > coords(0,1) < !X.CRange(1)
   y1 = !Y.CRange(0) > coords(1,0) < !Y.CRange(1)
   y2 = !Y.CRange(0) > coords(1,1) < !Y.CRange(1)
    
   IF (info.mouseButton EQ 'LEFT') THEN BEGIN
       
       ;; Draw the arrow box.
       ;;
       Arrow, x1, y1, x2, y1, /Data, Color=boxColor, /Solid, HSize=12
       PlotS, [x1, x1], [!Y.CRange[0], !Y.CRange[1]], Color=boxColor
       PlotS, [x2, x2], [!Y.CRange[0], !Y.CRange[1]], Color=boxColor
   END

   IF (info.mouseButton EQ 'MIDDLE') THEN BEGIN
    
       ;; Draw the arrow box.
       ;;
       Arrow, x1, y1, x1, y2, /Data, Color=boxColor, /Solid, HSize=12
       PlotS, [!X.CRange[0], !X.CRange[1]], [y1, y1], Color=boxColor
       PlotS, [!X.CRange[0], !X.CRange[1]], [y2, y2], Color=boxColor
   END
   
   ;; Put the info structure back into its storage location.
   ;;
   Widget_Control, parent, Set_UValue=info, /No_Copy

END 
;; of ZOOM_PLOT_DRAWBOX --------------------------------------------------------

;
;-------------------------------------------------------------------------------




