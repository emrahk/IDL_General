;; =============================================================================
;+
; NAME:
;       MZOOM_PLOT
;
; PURPOSE:
;
;       Create multiple zoom_plot windows within one main widget.
;       Plot the contents of a complete table.
;
; AUTHOR:
;
;   Jochen L. Deetjen
;   Institut fuer Astronomie und Astrophysik Tuebingen
;   Waldhaeuser Str. 64
;   D-72076 Tuebingen
;   Germany
;
; CATEGORY:
;
;      Widgets.
;
; CALLING SEQUENCE:
;
;      MZoom_Plot, data
;
; OPTIONAL INPUTS:
;
;      data: Two dimensional array. The data in the first column
;            assumed to be the independent data (x-values).
;            The data in the each remaining column is assumed to be
;            the dependent data sets (y1-, y2- ... values).
;
; KEYWORD PARAMETERS:
;
;      Any valid PLOT keyword can be used with this program. In additon,
;      the following keywords are defined specifically.
;
;      XRANGE: Maximal x-range.
;
;      YRANGE: Maximal y-range.
;
;      TITLE:  Onedimensional array containing the title of the individual plots.
; 
;      YTITLE: Onedimensional array containing the ytitle of the individual plots.
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
;        To display an multiple plot you can zoom into, type:
;
;        MZOOM_PLOT, data
;
; MODIFICATION HISTORY:
;
;        Written by: Jochen L. Deetjen, 9 May 2001.
;        Version 1.0: intitial version under cvs control, 16 May 2001    
;-
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Jochen L. Deetjen
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
; PURPOSE: Create multiple zoom_plot windows within one main widget.
;          Plot the contents of a complete table.
;
PRO mzoom_plot, data, data2=data2, data3=data3, title=title, xtitle=xtitle, ytitle=ytitle, maintitle=maintitle, PSYM=psym, _Extra=extra
   
    
   ;; Determine the number of figures to be created
   ;;
   data_size = SIZE(data)
   nr_fig    = data_size[1] - 1
   
   ;; Create a top-level base for this program. No resizing of this base.
   ;;
   IF (NOT KEYWORD_SET(maintitle)) THEN maintitle='Zoom Plot Window'
   tlb = Widget_Base(Title=maintitle, TLB_Size_Events=1, $
                     Base_Align_Center=1, Column=1)
   
   ;; Add Exit buttons
   ;;
   buttonbase = Widget_Base(tlb, ROW=1, Event_Pro='MZOOM_PLOT_BUTTONS')
   exitID  = Widget_Button(buttonbase, VALUE='Exit' )
   printID = Widget_Button(buttonbase, VALUE='Print')
   
       
   ;; Set empty titles as default
   ;;
   IF (NOT keyword_set(title))  THEN  title=STRARR(nr_fig)
   IF (NOT keyword_set(ytitle)) THEN ytitle=STRARR(nr_fig)
   IF (NOT keyword_set(xtitle)) THEN xtitle=''
   
   ;;  Get the screen size.
   ;;
   Device, GET_SCREEN_SIZE = screenSize

   CASE 1 OF
       
       ;;  Set up dimensions of the drawing (viewing) area of a
       ;;  single plot.
       ;;  
       (nr_fig GT 0) AND (nr_fig LE 3): BEGIN
           base  = Widget_Base(tlb, Base_Align_Center=1, ROW=1)
           xsize = screenSize[0] *0.95 /3
           ysize = screenSize[1] *0.80
           IF ysize GT xsize THEN ysize = xsize
       ENDCASE
       
       (nr_fig EQ 4): BEGIN
           base  = Widget_Base(tlb, Base_Align_Center=1, ROW=2)
           xsize = screenSize[0] *0.95 /2
           ysize = screenSize[1] *0.80 /2
           IF ysize GT xsize THEN ysize = xsize
       ENDCASE
       
       (nr_fig GT 4) AND (nr_fig LE 6): BEGIN
           base  = Widget_Base(tlb, Base_Align_Center=1, ROW=2)
           xsize = screenSize[0] *0.95 /3
           ysize = screenSize[1] *0.80 /2
           IF ysize GT xsize THEN ysize = xsize
       ENDCASE
       
       (nr_fig GT 6) AND (nr_fig LE 9): BEGIN
           base  = Widget_Base(tlb, Base_Align_Center=1, ROW=3)
           xsize = screenSize[0] *0.95 /3
           ysize = screenSize[1] *0.80 /3
           IF ysize GT xsize THEN ysize = xsize
      ENDCASE
       
       (nr_fig GT 9) AND (nr_fig LE 12): BEGIN
           base  = Widget_Base(tlb, Base_Align_Center=1, ROW=4)
           xsize = screenSize[0] *0.95 /3
           ysize = screenSize[1] *0.80 /4
           IF ysize GT xsize THEN ysize = xsize
      ENDCASE
       
       (nr_fig GT 6) AND (nr_fig LE 16): BEGIN
           base  = Widget_Base(tlb, Base_Align_Center=1, ROW=4)
           xsize = screenSize[0] *0.95 /4
           ysize = screenSize[1] *0.80 /4
           IF ysize GT xsize THEN ysize = xsize
      ENDCASE
       
   ENDCASE
   
   
   ;; Create the individual plot subwidgets
   ;;
   FOR i=1,nr_fig DO BEGIN
       
       IF (keyword_set(data2)) THEN BEGIN
           IF (keyword_set(data3)) THEN BEGIN
               
               plot_base = Widget_Base(base, Base_Align_Center=1, Uname=i, Column=1)
               zoom_plot, REFORM(data[0,*]), REFORM(data[i,*]), $
                 x2=REFORM(data2[0,*]), y2=REFORM(data2[i,*]),  $
                 x3=REFORM(data3[0,*]), y3=REFORM(data3[i,*]),  $
                 top_base=plot_base, group_leader=tlb,          $
                 zoom_xsize = xsize, zoom_ysize = ysize,        $
                 title=title(i-1), xtitle=xtitle, ytitle=ytitle(i-1), $
                 PSYM=psym, _Extra=extra
               
           END ELSE BEGIN
               
               plot_base = Widget_Base(base, Base_Align_Center=1, Uname=i, Column=1)
               zoom_plot, REFORM(data[0,*]), REFORM(data[i,*]), $
                 x2=REFORM(data2[0,*]), y2=REFORM(data2[i,*]),  $
                 top_base=plot_base, group_leader=tlb,          $
                 zoom_xsize = xsize, zoom_ysize = ysize,        $
                 title=title(i-1), xtitle=xtitle, ytitle=ytitle(i-1), $
                 PSYM=psym, _Extra=extra
               
           END 
       END ELSE BEGIN
           
               plot_base = Widget_Base(base, Base_Align_Center=1, Uname=i, Column=1)
               zoom_plot, REFORM(data[0,*]), REFORM(data[i,*]), $
                 top_base=plot_base, group_leader=tlb,          $
                 zoom_xsize = xsize, zoom_ysize = ysize,        $
                 title=title(i-1), xtitle=xtitle, ytitle=ytitle(i-1), $
                 PSYM=psym, _Extra=extra
               
           END
   END
   
   main_info = {nr_fig:nr_fig, $
                maintitle:maintitle}
   
   Widget_Control, tlb, Set_UValue=main_info, /No_Copy
   
END
;; of MZOOM_PLOT ---------------------------------------------------------------

;
;-------------------------------------------------------------------------------

