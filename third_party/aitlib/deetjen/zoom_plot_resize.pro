;; =============================================================================
;+
; NAME:
;       ZOOM_PLOT_RESIZE
;
; PURPOSE:
;
;       Event handler for 'zoom_plot.pro'.
;       This event handler reponds to TLB re-size events.
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
; PURPOSE: This event handler reponds to TLB re-size events.
;  
;
PRO ZOOM_PLOT_RESIZE, event
   
   Widget_Control, event.top, Get_UValue=info, /No_Copy

   ;; Update window sizes.
   ;;
   info.zxsize = event.x
   info.zysize = event.y
   
   ;; Destroy old pixmap and create a new one.
   ;;
   WDelete, info.pixIndex
   Window, XSize=event.x, YSize=event.y, /Free, /Pixmap
   info.pixIndex = !D. Window

   ;; Resize draw widget.
   ;;
   Widget_Control, info.drawID, Draw_XSize=(event.x > 200), Draw_YSize=(event.y > 150)

   ;;  Set up colors for line plot.
   ;;
   backColor  = GetColor('black', !D.Table_Size-2)
   dataColor  = GetColor('white', !D.Table_Size-3)
   dataColor2 = GetColor('yellow', !D.Table_Size-4)
   dataColor3 = GetColor('red', !D.Table_Size-5)
   axisColor  = GetColor('green', !D.Table_Size-6)

   ;; Draw the plot in both windows.
   ;;
   Plot, info.indep, info.dep, $
     XRange=info.xrange, XStyle=info.xstyle, $
     YRange=info.yrange, $
     Background=backColor, Color=axisColor, $
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

   WSet, info.drawIndex
   Plot, info.indep, info.dep, $
     XRange=info.xrange, XStyle=1, $
     YRange=info.yrange, $
     Background=backColor, Color=axisColor, $
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

   ;; Update system parameters.
   ;;
   info.x = !X
   info.y = !Y
   info.p = !P
   
   
   ;; Put the info structure back into its storage location.
   ;;
   Widget_Control, event.top, Set_UValue=info, /No_Copy

END 
;; of ZOOM_PLOT_RESIZE ---------------------------------------------------------

;
;-------------------------------------------------------------------------------




