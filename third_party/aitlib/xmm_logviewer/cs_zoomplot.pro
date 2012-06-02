;+
; NAME:
; cs_zoomplot.pro
;
;
; PURPOSE:
;template for drawwidgets + plot
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_zoomplot, datatype, base, nummer, handlerlist, handlerliste=handlerliste
;
;
; INPUTS:
; datatype, base, nummer, handlerlist
;
;
; OPTIONAL INPUTS:
;none
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;handlerliste
;
;
; OPTIONAL OUTPUTS:
;none
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;includes: cs_zoomplot_cleanup.pro, cs_zoomplot_process_events.pro, cs_zoomplot_drawbox.pro
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

PRO cs_zoomplot_cleanup, tlb                                           ;;gibt die pixmap frei
Widget_Control, tlb, Get_UValue=info
IF N_Elements(info) NE 0 THEN BEGIN
   WDelete, info.pixIndex
ENDIF
END 


PRO cs_zoomplot_process_events, event                            ;;down eventhandler
 parent=WIDGET_INFO(event.handler, /parent)
 Widget_Control, parent, Get_UValue=info                           ;;holen sich info

IF event.press GT 1 THEN BEGIN                                       ;;rechte mouse-taste
cs_options, info
RETURN
ENDIF

possibleEventTypes = [ 'DOWN', 'UP', 'MOTION', 'SCROLL' ]
thisEvent = possibleEventTypes(event.type)
IF thisEvent NE 'DOWN' THEN RETURN
 info.xs = event.x
 info.ys = event.y

 megaparent=WIDGET_INFO(info.base, /parent)                    ;;hauptwidget
 Widget_Control, megaparent, Get_UValue=state
 WIDGET_CONTROL, state.label_status_text,SET_VALUE='select area for zooming!'
 WIDGET_CONTROL, info.drawID, GET_VALUE=drawIndex   
 WSet, info.pixIndex
 Device, Copy = [0, 0, info.zxsize, info.zysize, 0, 0, drawIndex]
 WSet, drawIndex
 Widget_Control, parent, Set_UValue=info, /No_Copy
 Widget_Control, event.id, Event_Pro='cs_zoomplot_drawbox', Draw_Motion_Events=1
END



PRO cs_zoomplot_drawbox, event

parent=WIDGET_INFO(event.handler, /parent)
Widget_Control, parent, Get_UValue=info,/no_copy
megaparent=WIDGET_INFO(info.base, /parent)
Widget_Control, megaparent, Get_UValue=state



boxColor=50                                                                            ;;Farbe der zoombox (rot)

possibleEventTypes = [ 'DOWN', 'UP', 'MOTION', 'SCROLL' ]
thisEvent = possibleEventTypes(event.type)

IF thisEvent EQ 'UP' THEN BEGIN  
WIDGET_CONTROL, state.label_status_text,SET_VALUE='zooming...'
get_background, info.datatype, background=background
axes_color=(255-background) mod 256
   WIDGET_CONTROL, info.drawID, GET_VALUE=drawIndex   
   WSet, drawIndex
   Device, Copy = [0, 0, info.zxsize, info.zysize, 0, 0, info.pixIndex]
   cs_plot, info.datatype
   XYOUTS,5,5,'Graph Nr.: '+STRTRIM(STRING(info.nummer),2),/DEVICE, color=axes_color
   Widget_Control, event.id, Draw_Motion_Events=0, Event_Pro='cs_zoomplot_process_events'


   x = [info.xs, event.x]                                                            ;;intervallgrenzen von x
   y = [info.ys, event.y]                                                            ;;intervallgrenzen von y  

   IF info.xs GT event.x THEN x = [event.x, info.xs]                   ;;anordnen nach min, max

   IF info.xs EQ event.x THEN xstyle = 0 ELSE xstyle = 1
   info.xstyle = xstyle

   coords = Convert_Coord(x, y, /Device, /To_Data)                  ;;Koordinatenkonversion zu Daten

   x1 = !X.CRange(0) > coords(0,0) < !X.CRange(1)
   x2 = !X.CRange(0) > coords(0,1) < !X.CRange(1)

  perform_operation, info.datatype, 'ZOOM_X', x1, x2, datatype=datatype, nachricht=nachricht
  cs_plot, datatype
  XYOUTS,5,5,'Graph Nr.: '+STRTRIM(STRING(info.nummer),2),/DEVICE, color=axes_color
  WSet, info.pixIndex
  cs_plot, datatype
  XYOUTS,5,5,'Graph Nr.: '+STRTRIM(STRING(info.nummer),2),/DEVICE, color=axes_color
  WIDGET_CONTROL, state.label_status_text,SET_VALUE=nachricht
  
  info.datatype=datatype
  info.zoomed=1  
  cs_options, info 
   Widget_Control, parent, Set_UValue=info, /No_Copy
   RETURN
ENDIF 
  
WIDGET_CONTROL, info.drawID, GET_VALUE=drawindex
WSet, drawIndex
Device, Copy = [0, 0, info.zxsize, info.zysize, 0, 0, info.pixIndex]

 info.xd = event.x
 info.yd = event.y

x = [info.xs, event.x]
y = [info.ys, event.y]

coords = Convert_Coord(x, y, /Device, /To_Data)

x1 = !X.CRange(0) > coords(0,0) < !X.CRange(1)
x2 = !X.CRange(0) > coords(0,1) < !X.CRange(1)
y1 = !Y.CRange(0) > coords(1,0) < !Y.CRange(1)
y2 = !Y.CRange(0) > coords(1,1) < !Y.CRange(1)

PlotS, [x1, x1], [!Y.CRange[0], !Y.CRange[1]], Color=boxColor
PlotS, [x2, x2], [!Y.CRange[0], !Y.CRange[1]], Color=boxColor

Widget_Control, parent, Set_UValue=info, /No_Copy
END 


PRO cs_zoomplot, datatype, base, nummer, handlerlist, handlerliste=handlerliste
handlerliste=handlerlist

zxsize = 750                                                                             ;;größe der Plots
zysize = 350

tlb = Widget_Base(base)
drawID = Widget_Draw(tlb, XSize=zxsize, YSize=zysize, Button_Events=1, Event_Pro='cs_zoomplot_process_events')
get_background, datatype, background=background
axes_color=(255-background) mod 256
Widget_Control, tlb, /Realize
Widget_Control, drawID, Get_Value=drawIndex
WSet, drawIndex
cs_plot,datatype
XYOUTS,5,5,'Graph Nr.: '+STRTRIM(STRING(nummer),2),/DEVICE, color=axes_color
Window, /Free, XSize=zxsize, YSize=zysize, /Pixmap
pixIndex = !D.Window
cs_plot,datatype
XYOUTS,5,5,'Graph Nr.: '+STRTRIM(STRING(nummer),2),/DEVICE, color=axes_color

handlerliste(nummer)=drawID
info = {base:base, $
           datatype:datatype,$
          zxsize:zxsize, $               
          zysize:zysize, $                 
          drawID:drawID, $                
          pixIndex:pixIndex, $            
          xstyle:0,$
   	   xs:0, $                         
   	   ys:0, $                          
   	   xd:0, $                         
   	   yd:0, $                          
        nummer:nummer,$
        handlerliste:handlerliste,$
        operations_listenID:0,$
        zoomed:0}           

Widget_Control, tlb, Set_UValue=info, /No_Copy
XManager, 'cs_zoomplot', tlb, Cleanup='cs_zoomplot_cleanup',  /No_Block
END 
