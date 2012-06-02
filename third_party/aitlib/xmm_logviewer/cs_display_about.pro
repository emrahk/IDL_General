;+
; NAME:
;cs_display_about
;
;
; PURPOSE:
;displays about-information
;
;
; CATEGORY:
;xmm_logviewer subroutine
;widget
;
; CALLING SEQUENCE:
;cs_display_about, state
;
;
; INPUTS:
;state
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
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
;includes: cs_display_about_event,
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

PRO cs_display_about_event, ev
WIDGET_CONTROL, ev.top, GET_UVALUE=text
WIDGET_CONTROL, ev.id, GET_UVALUE=uval
CASE uval OF
  'DISPLAYDONE': WIDGET_CONTROL, ev.top, /DESTROY
ELSE:
ENDCASE
END


PRO cs_display_about, state
      IF XRegistered('cs_display_about') GT 0 THEN RETURN
           mainbase=WIDGET_BASE(GROUP_LEADER=state.mainbase, TITLE='ABOUT THIS PROGRAMM', ROW=3)
           displaybase = WIDGET_BASE(mainbase, SCROLL=1 , X_SCROLL_SIZE=350,Y_SCROLL_SIZE=300) 
        
          helptext = [ $
"                                                       ", $
"   Dieses Programm wurde erstellt von :", $
"                 Christoph Tenzer", $
"  	         Stefan Schwarzburg ", $
" ", $
"                 tenzer@astro.uni-tuebingen.de", $
"                 schwarz@astro.uni-tuebingen.de", $
" ", $
" ", $
"Benötigt werden folgende Unterprogramme / Dateien:", $
"cs_xmm_logviewer.pro", $
"cs_xmm_logviewer_load_subroutines.pro", $
"cs_load.pro", $
"cs_multiple_file_reader.pro ",  $
"cs_options.pro", $
"cs_plot.pro",$
"cs_preferences.pro",$
"cs_read.pro",$
"cs_save.pro",$
"cs_zoomplot.pro",$
"cs_array_constructor.pro ",  $
"cs_correlation_constructor.pro ",  $ 
"cs_display_parameter_list.pro", $ 
"cs_display_about.pro",   $ 
"cs_display_info.pro ",$
"cs_find_file_number.pro ", $
"cs_find_parameter_name.pro",$
"cs_find_parameter_number.pro" ,$
"cs_find_parameter_position_in_file.pro" , $
"preferences.dat"  ,    $
"assocliste.dat  ",  $         
"error_message.pro",$
"fsc_droplist.pro",$
"fsc_field.pro",$                  
"fsc_fileselect.pro",$         
"fsc_plotwindow.pro",$  
"fsc_psconfig.pro",$               
"fsc_psconfig__define.pro"  ,  $         
"ps_plotter.pro"  ,  $         
"psconfig.pro"   ,   $ 
"showprogress__define.pro",$
"tvimage.pro",$
"                          " ]
textsize = 43
textID = Widget_Text(displaybase, Value=helptext, YSize=textsize)    
donebutton = WIDGET_BUTTON(mainbase, VALUE='Done', UVALUE='DISPLAYDONE')
           text = { state:state, donebutton: donebutton}
           WIDGET_CONTROL, mainbase, SET_UVALUE=text
           WIDGET_CONTROL, mainbase, /REALIZE
           XMANAGER, 'cs_display_about', mainbase
END
