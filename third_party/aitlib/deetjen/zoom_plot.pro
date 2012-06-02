;; =============================================================================
;+
; NAME:
;       ZOOM_PLOT
;
; PURPOSE:
;
;       The purpose of this program is to display a line plot in a resizeable
;       graphics window which can be zoomed in x (left-) and y (middle
;       mouse button) direction by drawing an "arrow box" on top of
;       it. To return to the un-zoomed plot, click and release the
;       right mouse button anywhere in the window.
;       The current plot in the window can be printed into a
;       Postscript file.
;
; AUTHOR:
;
;   Jochen L. Deetjen
;   Institut fuer Astronomie und Astrophysik Tuebingen
;   Waldhaeuser Str. 64
;   D-72076 Tuebingen
;   Germany
;
;   based on 'zplot.pro' by
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;
;      Widgets.
;
; CALLING SEQUENCE:
;
;      Zoom_Plot, x, y
;
; OPTIONAL INPUTS:
;
;      x: If only one positional parameter, this is assumed to be the
;         independent data. If there are two positional parameters, this
;         is assumed to be the independent data in accordance with the
;         PLOT command.
;
;      y: The dependent data, if the X parameter is present.
;
; KEYWORD PARAMETERS:
;
;       Any valid PLOT keyword can be used with this program. In additon,
;       the following keywords are defined specifically.
;
;       X2: Second set of independent data which will be plotted additionally.
;
;       Y2: Second set of dependent data which will be plotted
;       additionally. If x2 is not given x will be used as independent
;       data.
;
;       X3: Third set of independent data which will be plotted additionally.
;
;       Y3: Third set of dependent data which will be plotted
;       additionally. If x2 is not given x will be used as independent
;       data.
;
;       GROUP_LEADER: This keyword is used to assign a group leader to this
;                 program. This program will be destroyed when the group
;                 leader is destroyed. Use this keyword if you are calling
;                 ZOOM_IMAGE from another widget program.
;
;       ZOOM_XSIZE: The initial X size of the plot window. Default is 400 pixels.
;
;       ZOOM_YSIZE: The initial Y size of the plot window. Default is 400 pixels.
;
;       XRANGE: Maximal x-range.
;
;       YRANGE: Maximal y-range.
;
; COMMON BLOCKS:
;
;       None.
;
; SIDE EFFECTS:
;
;       Drawing colors are loaded into the color table.
;
; RESTRICTIONS:
;
;       None.
;
; PROCEDURE:
;
;       Click (left/middle) and drag the cursor to create an "arrow
;       box". The plot is zoomed into the X/Y coordinates of the box,
;       when released. To restore unzoomed plot, click and release
;       the right mouse button anywhere in the window.
;
; EXAMPLE:
;
;        To display an plot you can zoom into, type:
;
;        ZOOM_PLOT
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
;###########################################################################
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
;###########################################################################



;-------------------------------------------------------------------------------
;
; PURPOSE: The purpose of this module is to delete the pixmap window
;          and perform other cleanup chores when the program ZOOM_PLOT is
;          destroyed.
;
PRO ZOOM_PLOT_CLEANUP, plot_base
   
   Widget_Control, plot_base, Get_UValue=info
   
   IF N_Elements(info) NE 0 THEN BEGIN
       WDelete, info.pixIndex
       Ptr_Free, info.extraKeywords
   ENDIF
   
END
;; of ZOOM_PLOT_CLEANUP --------------------------------------------------------




;-------------------------------------------------------------------------------
;
; PURPOSE: This procedure allows the user to "zoom" into the data plot
;          by drawing an arrow box around the part of the data to zoom into.
;          The arrow box will be drawn and erased by using a pixmap and
;          the "Device Copy" technique.
;
PRO ZOOM_PLOT, x, y, x2=x2, y2=y2, x3=x3, y3=y3,     $
               Zoom_XSize=zxsize, Zoom_YSize=zysize, $
               Group_Leader=group, top_base=top_base, $
               xrange=xrange, yrange=yrange,         $
               ynorm=ynorm, psym=psym, _Extra=extra

   ;; On an error condition, return to the main level of IDL.
   ;;
   On_Error, 1

   ;; Was data passed into the procedure? If not, create some.
   
   CASE N_Params() OF
       
       0: BEGIN
           dep = Findgen(101)
           dep = Sin(dep/5) / Exp(dep/50)
           indep = Findgen(101)
       ENDCASE
       
       1: BEGIN
           dep = x
           indep = Findgen(N_Elements(dep))
       ENDCASE
       
       2: BEGIN
           dep = y
           indep = x
       ENDCASE
   ENDCASE

   IF (NOT KEYWORD_SET(psym)) THEN psym=0

   ;;  Set up colors for line plot.
   ;;
   backColor  = GetColor('black', !D.Table_Size-2)
   dataColor  = GetColor('white', !D.Table_Size-3)
   dataColor2 = GetColor('yellow', !D.Table_Size-4)
   dataColor3 = GetColor('red', !D.Table_Size-5)
   axisColor  = GetColor('green', !D.Table_Size-6)

   ;; Check for keywords. Set defaults if necessary.
   ;;
   IF N_Elements(zxsize) EQ 0 THEN zxsize = 400
   IF N_Elements(zysize) EQ 0 THEN zysize = 400
   
   x2_set = 1
   y2_set = 1
   x3_set = 1
   y3_set = 1
   
   IF (NOT keyword_set(x2)) THEN BEGIN
       x2_set = 0
       IF (keyword_set(y2)) THEN BEGIN
           x2 = dep
       END ELSE BEGIN
           y2_set = 0
           y2     = dep[0:1]
           x2     = indep[0:1]
       END
   END
   IF (NOT keyword_set(x3)) THEN BEGIN
       x3_set = 0
       IF (keyword_set(y3)) THEN BEGIN
           x3 = dep
       END ELSE BEGIN
           y3_set = 0
           y3     = dep[0:1]
           x3     = indep[0:1]
       END
   END
   
   ;; y2(ynorm)/y3(ynorm) == y1(ynorm)
   ;;
   IF (keyword_set(ynorm)) THEN BEGIN
     idx  = WHERE(indep EQ YNORM)
     IDXX = IDX[0]    
     IF (Y2_SET EQ 1) THEN BEGIN
       idx   = WHERE(x2 EQ YNORM)
       idxx2 = idx[0]  
       Y2 = Y2 * dep[IDXX]/Y2[IDXX2]
     ENDIF
     IF (Y3_SET EQ 1) THEN BEGIN
       idx   = WHERE(x3 EQ YNORM)
       idxx3 = idx[0]    
       Y3 = Y3 * dep[IDXX]/Y3[IDXX3]
     ENDIF
   END   

   ;; Clip data according to x/y-range -
   ;; don't pass keyword to plot command
   ;;
   IF (keyword_set(xrange)) THEN BEGIN
       idx   = WHERE((indep GE xrange[0]) AND (indep LE xrange[1]), count)
       IF (count GE 0) THEN BEGIN
           dep   = dep[idx]
           indep = indep[idx]
       END
       IF (y2_set EQ 1) THEN BEGIN
           idx   = WHERE((x2 GE xrange[0]) AND (x2 LE xrange[1]), count)
           IF (count GT 0) THEN BEGIN
               x2    = x2[idx]
               y2    = y2[idx]
           END
       END
       IF (y3_set EQ 1) THEN BEGIN
           idx   = WHERE((x3 GE xrange[0]) AND (x3 LE xrange[1]), count)
           IF (count GT 0) THEN BEGIN
               x3    = x3[idx]
               y3    = y3[idx]
           END
       END
   END
   
   
   IF (keyword_set(yrange)) THEN BEGIN
       idx   = WHERE((dep GE yrange[0]) AND (dep LE yrange[1]), count)
       IF (count GT 0) THEN BEGIN
           dep   = dep[idx]
           indep = indep[idx]
       END
       IF (y2_set EQ 1) THEN BEGIN
           idx   = WHERE((y2 GE yrange[0]) AND (y2 LE yrange[1]), count)
           IF (count GT 0) THEN BEGIN
               x2    = x2[idx]
               y2    = y2[idx]
           END    
       END
       IF (y3_set EQ 1) THEN BEGIN
           idx   = WHERE((y3 GE yrange[0]) AND (y3 LE yrange[1]), count)
           IF (count GT 0) THEN BEGIN
               x3    = x3[idx]
               y3    = y3[idx]
           END
       END
   END

   ;; Create a top-level base for this program. No resizing of this base.
   ;;
   IF (NOT keyword_set(top_base)) THEN BEGIN
       plot_base = Widget_Base(Title='Zoom Plot Window', TLB_Size_Events=1, $
                         Base_Align_Center=1, Column=1)
   END ELSE BEGIN
       plot_base = top_base
   END
   
   drawID = Widget_Draw(plot_base, XSize=zxsize, YSize=zysize, $
                        Button_Events=1, Event_Pro='ZOOM_PLOT_EVENTS')

   IF (NOT keyword_set(top_base)) THEN BEGIN
       ;; Add Widget Label
       ;;
       labelID = Widget_Label(plot_base, $
                              Value='Left Button: x-zoom  Middle Button: y-zoom  Right Button: reset')
       
       ;; Add Exit and Print buttons.
       ;;
       buttonbase  = Widget_Base(plot_base, ROW=1, Align_Center=1, Event_Pro='ZOOM_PLOT_BUTTONS')
       cancelID    = Widget_Button(buttonbase, VALUE='Exit')
       acceptID    = Widget_Button(buttonbase, VALUE='Print')
       newwindowID = Widget_Button(buttonbase, VALUE='New Window')
   END ELSE BEGIN
       buttonbase  = Widget_Base(plot_base, ROW=1, Align_Center=1, Event_Pro='ZOOM_PLOT_BUTTONS')
       acceptID    = Widget_Button(buttonbase,  VALUE='Print')
       newwindowID = Widget_Button(buttonbase, VALUE='New Window')
   END
       
   Widget_Control, plot_base, /Realize
   
   
   ;; Get the window index number of the draw widget.
   ;; Make the draw widget the current graphics window
   ;; and draw the plot of the data in it. Make the
   ;; X data range exactly fit the data.
   ;;
   Widget_Control, drawID, Get_Value=drawIndex
   WSet, drawIndex
   xrange = [Min(indep), Max(indep)]
   IF (y2_set EQ 1) THEN BEGIN
       IF (y3_set EQ 1) THEN BEGIN
           yrange = [Min([dep,y2,y3]),Max([dep,y2,y3])]
       END ELSE BEGIN
           yrange = [Min([dep,y2]),Max([dep,y2])]
       END 
   END ELSE BEGIN
       yrange = [Min(dep),Max(dep)]
   END
       
   Plot, indep, dep, $
     XRange=xrange, YRange=yrange, $
     Background=backColor, Color=axisColor, $
     /NoData, PSYM=psym, $
     _Extra=extra
   
   OPlot, indep, dep, Color=dataColor, PSYM=psym, _Extra=extra
   IF (y2_set EQ 1) THEN BEGIN
       IF (x2_set EQ 1) THEN BEGIN
           OPlot, x2, y2, Color=dataColor2, PSYM=psym, _Extra=extra
       END ELSE BEGIN
           OPlot, indep, y2, Color=dataColor2, PSYM=psym, _Extra=extra
       END
   END
   IF (y3_set EQ 1) THEN BEGIN
       IF (x3_set EQ 1) THEN BEGIN
           OPlot, x3, y3, Color=dataColor3, PSYM=psym, _Extra=extra
       END ELSE BEGIN
           OPlot, indep, y3, Color=dataColor3, PSYM=psym, _Extra=extra
       END
   END


   ;; Create a pixmap window the same size as the draw widget window.
   ;; Store its window index number in a local variable. Draw the same
   ;; plot you just put in the draw widget in the pixmap window.
   ;;
   Window, /Free, XSize=zxsize, YSize=zysize, /Pixmap
   pixIndex = !D.Window
   Plot, indep, dep, $
     XRange=xrange, YRange=yrange, $
     Background=backColor, Color=axisColor, $
     /NoData, PSYM=psym, $
     _Extra=extra
   
   OPlot, indep, dep, Color=dataColor, PSYM=psym, _Extra=extra
   IF (y2_set EQ 1) THEN BEGIN
       IF (x2_set EQ 1) THEN BEGIN
           OPlot, x2, y2, Color=dataColor2, PSYM=psym, _Extra=extra
       END ELSE BEGIN
           OPlot, indep, y2, Color=dataColor2, PSYM=psym, _Extra=extra
       END
   END
   IF (y3_set EQ 1) THEN BEGIN
       IF (x3_set EQ 1) THEN BEGIN
           OPlot, x3, y3, Color=dataColor3, PSYM=psym, _Extra=extra
       END ELSE BEGIN
           OPlot, indep, y3, Color=dataColor3, PSYM=psym, _Extra=extra
       END
   END

   IF N_Elements(extra) EQ 0 THEN extraKeywords = Ptr_New(/Allocate_Heap) ELSE extraKeywords = Ptr_New(extra)

   ;; Initialize MouseButton
   ;;
   mouseButton = 'EMPTY'


   ;; Create an info structure to hold information required by the program.
   ;;
   info = { $
            dep:dep, $          ; The dependent data to be plotted.
            indep:indep, $      ; The independent data to be plotted.
            x2_set:x2_set, $    ; Optional second data set given?
            y2_set:y2_set, $    ; Optional second data set given?
            x3_set:x3_set, $    ; Optional third data set given?
            y3_set:y3_set, $    ; Optional third data set given?
            x2:x2, $            ; Optional second data set?
            y2:y2, $            ; Optional second data set?
            x3:x3, $            ; Optional third data set?
            y3:y3, $            ; Optional third data set?
            zxsize:zxsize, $    ; The X size of the draw widget.
            zysize:zysize, $    ; The Y size of the draw widget.
            drawID:drawID, $    ; The widget identifier of the draw widget.
            drawIndex:drawIndex, $     ; The draw window index number.
            pixIndex:pixIndex, $       ; The pixmap window index number.
            mouseButton:mouseButton, $ ; The mouse button beeing pressed      
            xrange:xrange, $    ; The current X range of the plot.
            yrange:yrange, $    ; The current Y range of the plot.
            xstyle:0, $         ; The setting for the XStyle keyword.
            ystyle:0, $         ; The setting for the XStyle keyword.
            ynorm:0, $          ; The setting for the XStyle keyword.	
            xs:0, $             ; X static corner of the zoom box.
            ys:0, $             ; Y static corner of the zoom box.
            xd:0, $             ; X dynamic corner of the zoom box.
            yd:0, $             ; Y dynamic corner of the zoom box.
            x:!X, $             ; The !X system variable after plot.
            y:!Y, $             ; The !Y system variable after plot.
            p:!P, $             ; The !P system variable after plot.
            psym:psym, $
            extraKeywords:extraKeywords } ; Extra plot keywords pointer.
   
   ;; Store the info structure in the user value of the top-level base.
   ;;
   Widget_Control, plot_base, Set_UValue=info, /No_Copy

   XManager, 'ZOOM_PLOT', plot_base, Cleanup='ZOOM_PLOT_Cleanup', Group_Leader=group, /No_Block, $
     Event_Handler='ZOOM_PLOT_Resize'
   
END 
;; of ZOOM_PLOT ----------------------------------------------------------------

;
;-------------------------------------------------------------------------------
