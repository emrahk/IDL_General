;; =============================================================================
;+
; NAME:
;       ZOOM_PLOT_BUTTONS
;
; PURPOSE:
;
;       Event handler for 'zoom_plot.pro'.
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
; PURPOSE: This event handler responds to EXIT and PRINT buttons.
;  
;
PRO ZOOM_PLOT_BUTTONS, event
   
   parent = widget_info(event.handler,/parent)
   
   Widget_Control, parent, Get_UValue=info, /No_Copy
   
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
       
           ;; Create the PostScript configuration object.
           ;;
           object = Obj_New('FSC_PSConfig', /European)

           ;; We want hardware fonts.
           ;;
           thisFontType = !P.Font
           !P.Font = 1

           ;; Get user input to PostScript configuration.
           ;;
           object->GUI

           backColor  = GetColor('white', !D.Table_Size-2)
           dataColor  = GetColor('black', !D.Table_Size-3)
           dataColor2 = GetColor('red', !D.Table_Size-4)
           dataColor3 = GetColor('blue', !D.Table_Size-5)
           axisColor  = GetColor('black', !D.Table_Size-6)

           ;; Configure the PostScript Device.
           ;;
           thisDevice = !D.Name
           Set_Plot, 'PS'
           keywords = object->GetKeywords(FontType=fonttype)
           Device, _Extra=keywords
           Device, /color

           ;; Draw the example plots.
           ;;
           Plot, info.indep, info.dep,               $
             XRange=info.xrange, XStyle=info.xstyle, $
             YRange=info.yrange, YStyle=info.ystyle, $
             Background=backColor, Color=axisColor,  $
             /NoData, PSYM=info.psym,                                $
             _Extra=*info.extraKeywords
           
           OPlot, info.indep, info.dep, PSYM=info.psym, Color=dataColor
           IF (info.y2_set EQ 1) THEN BEGIN
               IF (info.x2_set EQ 1) THEN BEGIN
                   OPlot, info.x2, info.y2, PSYM=info.psym, Color=dataColor2
               END ELSE BEGIN
                   OPlot, info.indep, info.y2, PSYM=info.psym, Color=dataColor2
               END
           END
           IF (info.y3_set EQ 1) THEN BEGIN
               IF (info.x3_set EQ 1) THEN BEGIN
                   OPlot, info.x3, info.y3, PSYM=info.psym, Color=dataColor3
               END ELSE BEGIN
                   OPlot, info.indep, info.y3, PSYM=info.psym, Color=dataColor3
               END
           END

           ;; Clean up.
           ;;
           !P.Multi = 0
           Device, /Close_File
           Set_Plot, thisDevice
           !P.Font = thisfontType
           
           ;; Return the PS_Configuration object or destroy it.
           ;;
           IF Arg_Present(object) EQ 0 THEN Obj_Destroy, object
           
           ;; Put the info structure back into its storage location.
           ;;
           Widget_Control, parent, Set_UValue=info, /No_Copy
           
           backColor  = GetColor('black', !D.Table_Size-2)
           dataColor  = GetColor('white', !D.Table_Size-3)
           dataColor2 = GetColor('yellow', !D.Table_Size-4)
           dataColor3 = GetColor('red', !D.Table_Size-5)
           axisColor  = GetColor('green', !D.Table_Size-6)

       ENDCASE
       
       ;; ----------------------------------------
       'New Window': BEGIN
           
           ;; Open a new Window
           ;;
           zoom_plot, info.indep, info.dep,          $
             x2=info.x2, y2=info.y2,                 $
             x3=info.x3, y3=info.y3,                 $
             XRange=info.xrange, XStyle=info.xstyle, $
             YRange=info.yrange, YStyle=info.ystyle, $
             Background=backColor, Color=axisColor, PSYM=info.psym,  $
             _Extra=*info.extraKeywords
           
           ;; Put the info structure back into its storage location.
           ;;
           Widget_Control, parent, Set_UValue=info, /No_Copy
           
       ENDCASE
       
       
       ;; ----------------------------------------
       ELSE: BEGIN
           
           ;; Put the info structure back into its storage location.
           ;;
           Widget_Control, parent, Set_UValue=info, /No_Copy
           
       END
       
   ENDCASE
       
END
;; of ZOOM_PLOT_BUTTONS --------------------------------------------------------

;
;-------------------------------------------------------------------------------


