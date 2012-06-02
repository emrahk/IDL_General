;; =============================================================================
;+
; NAME:
;       MZOOM_PLOT_BUTTONS
;
; PURPOSE:
;
;       Event handler for 'mzoom_plot.pro'.
;       This event handler responds to EXIT and PRINT buttons.
;
; AUTHOR:
;
;   Jochen L. Deetjen
;   Institut fuer Astronomie und Astrophysik Tuebingen
;   Waldhaeuser Str. 64
;   D-72076 Tuebingen
;   Germany
;
; MODIFICATION HISTORY:
;
;        Written by: Jochen L. Deetjen, 7 May 2001
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
; Copyright © 2001 Jochen L. Deetjen
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
; PURPOSE: This event handler responds to EXIT and PRINT buttons.
;  
;
PRO MZOOM_PLOT_BUTTONS, event
   
   parent = widget_info(event.handler,/parent)
   
   ;; Which button is this?
   ;;
   Widget_Control, event.id, Get_Value=buttonValue
   
   ;; Branch on button value.
   ;;
   CASE buttonValue OF
       
       'Exit': BEGIN
           
           ;; Simply destroy the widget. The pointer info is already
           ;; set up for a CANCEL event.
           ;;
           Widget_Control, parent, /Destroy
           
       ENDCASE
       
       
       ;; ----------------------------------------
       'Print': BEGIN
           
           Widget_Control, event.top, Get_UValue=main_info, /No_Copy
           
           ;; Create the PostScript configuration object.
           ;;
           ;object = Obj_New('FSC_PSConfig', /European, /Landscape)

           ;; We want hardware fonts.
           ;;
           ;thisFontType = !P.Font
           ;!P.Font = 1

           ;; Get user input to PostScript configuration.
           ;;
           ;object->GUI

           ;; Configure the PostScript Device.
           ;;
           thisDevice = !D.Name
           Set_Plot, 'PS'
           ;keywords = object->GetKeywords(FontType=fonttype)
           ;Device, _Extra=keywords, /color
           
           open_print, STRCOMPRESS(main_info.maintitle,/REMOVE_ALL) + '.ps',/A4,/COLOR,/POSTSCRIPT
           
           ;; Draw the example plots.
           ;;
           backColor  = GetColor('white', !D.Table_Size-2)
           dataColor  = GetColor('black', !D.Table_Size-3)
           dataColor2 = GetColor('red', !D.Table_Size-4)
           dataColor3 = GetColor('blue', !D.Table_Size-5)
           axisColor  = GetColor('black', !D.Table_Size-6)
           
           CASE 1 OF
               
               (main_info.nr_fig GT 0) AND (main_info.nr_fig LE 3): BEGIN
                   !P.MULTI = [0,3,1]
               ENDCASE
               
               (main_info.nr_fig EQ 4): BEGIN
                   !P.MULTI = [0,2,2]
               ENDCASE
               
               (main_info.nr_fig GT 4) AND (main_info.nr_fig LE 6): BEGIN
                   !P.MULTI = [0,3,2]
               ENDCASE
               
               (main_info.nr_fig GT 6) AND (main_info.nr_fig LE 9): BEGIN
                   !P.MULTI = [0,3,3]
               ENDCASE
               
               (main_info.nr_fig GT 9) AND (main_info.nr_fig LE 12): BEGIN
                   !P.MULTI = [0,3,4]
               ENDCASE
               
               (main_info.nr_fig GT 12) AND (main_info.nr_fig LE 16): BEGIN
                   !P.MULTI = [0,4,4]
               ENDCASE
               
           ENDCASE

           FOR i=1,main_info.nr_fig DO BEGIN

               plot_base = widget_info(event.top, FIND_BY_UNAME=i)
               Widget_Control, plot_base, Get_UValue=info, /No_Copy
               
               Plot, info.indep, info.dep, $
                 XRange=info.xrange, XStyle=info.xstyle, $
                 YRange=info.yrange, YStyle=info.ystyle, $
                 Background=backColor, Color=axisColor,  $
                 /NoData, PSYM=info.psym, $
                 _Extra=*info.extraKeywords
       
               OPlot, info.indep, info.dep, Color=dataColor, PSYM=info.psym, _Extra=extra
               IF (info.y2_set EQ 1) THEN BEGIN
                   IF (info.x2_set EQ 1) THEN BEGIN
                       OPlot, info.x2, info.y2, Color=dataColor2, PSYM=info.psym, _Extra=extra
                   END ELSE BEGIN
                       OPlot, info.indep, info.y2, Color=dataColor2, PSYM=info.psym, _Extra=extra
                   END
               END
               IF (info.y3_set EQ 1) THEN BEGIN
                   IF (info.x3_set EQ 1) THEN BEGIN
                       OPlot, info.x3, info.y3, Color=dataColor3, PSYM=info.psym, _Extra=extra
                   END ELSE BEGIN
                       OPlot, info.indep, info.y3, Color=dataColor3, PSYM=info.psym, _Extra=extra
                   END
               END
               
               ;; Put the info structure back into its storage location.
               ;;
               Widget_Control, plot_base, Set_UValue=info, /No_Copy
           END
           
           ;; Clean up.
           ;;
           !P.Multi = 0
           XYOUTS, 0.25, 1.00, main_info.maintitle, /NORMAL
           
           
           close_print
           ;Device, /Close_File
           Set_Plot, thisDevice
           ;!P.Font = thisfontType
           

           ;; Return the PS_Configuration object or destroy it.
           ;;
           ;IF Arg_Present(object) EQ 0 THEN Obj_Destroy, object
           
           Widget_Control, event.top, Set_UValue=main_info, /No_Copy
           
           backColor  = GetColor('black', !D.Table_Size-2)
           dataColor  = GetColor('white', !D.Table_Size-3)
           dataColor2 = GetColor('yellow', !D.Table_Size-4)
           dataColor3 = GetColor('red', !D.Table_Size-5)
           axisColor  = GetColor('green', !D.Table_Size-6)

       ENDCASE
       
       ;; ----------------------------------------
       ELSE: BEGIN
           
       END
       
   ENDCASE
       
END
;; of MZOOM_PLOT_BUTTONS -------------------------------------------------------

;
;-------------------------------------------------------------------------------


