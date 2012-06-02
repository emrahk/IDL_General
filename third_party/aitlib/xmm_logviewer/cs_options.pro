;+
; NAME:
;cs_options.pro
;
;
; PURPOSE:
;Graphical user interface for options 
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_options, info
;
;
; INPUTS:
; info
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
;includes: cs_options_event
;needs: cs_xmm_logviewer_load_subroutines.pro, cs_plot, cs_correlation_constructor, cs_zoomplot, 
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_options_event, ev
WIDGET_CONTROL, ev.top, GET_UVALUE=text
WIDGET_CONTROL, ev.id, GET_UVALUE=uval
IF WIDGET_INFO(text.operations_liste, /LIST_SELECT) EQ (-1) THEN  WIDGET_CONTROL, text.undo_button, SENSITIVE=0 ELSE WIDGET_CONTROL, text.undo_button, SENSITIVE=1

parent=WIDGET_INFO(text.info.drawID, /parent)
WIDGET_CONTROL, parent , GET_UVALUE=info

megaparent=WIDGET_INFO(text.info.base, /parent)
WIDGET_CONTROL, megaparent , GET_UVALUE=state
handlerliste=state.handlerliste

text.info=info
datatype=text.info.datatype
Widget_Control, text.info.drawID, Get_Value=drawIndex
WSet, drawIndex

zaehler=info.nummer

CASE uval OF
  'CORRELATE':BEGIN
 WIDGET_CONTROL, state.label_status_text,SET_VALUE='Correlating...'
      WIDGET_CONTROL, text.correlate_edit, GET_VALUE=graph_x
      WIDGET_CONTROL, text.time_interval_edit, GET_VALUE=time_interval
      graph_x=FIX(graph_x(0))
	time_interval=DOUBLE(FLOAT(time_interval(0))/(24*3600000))
      graph_x_parent=WIDGET_INFO(handlerliste(graph_x), /parent)
      WIDGET_CONTROL, graph_x_parent, GET_UVALUE=graph_x_parent_struc
      graph_x_datatype=graph_x_parent_struc.datatype   
                  get_current_ywerte, datatype, current_ywerte=ywerte1
		     get_current_xwerte, datatype, current_xwerte=xwerte1
                  get_current_ywerte, graph_x_datatype, current_ywerte=ywerte2
		     get_current_xwerte, graph_x_datatype, current_xwerte=xwerte2
		     cs_correlation_constructor, xwerte1, ywerte1, xwerte2, ywerte2,time_interval, xwerte=xwerte, ywerte=ywerte
                  
                  get_current_yparameter, datatype, current_yparameter=current_yparameter
                  get_current_yparameter, graph_x_datatype, current_yparameter=current_xparameter
                 
                  get_current_yunit, datatype, current_yunit=current_yunit
                  get_current_yunit, graph_x_datatype, current_yunit=current_xunit
                  get_revs, datatype, revs=revs
                  make_datatype, xwerte, ywerte, revs, current_xparameter, current_yparameter, current_xunit, current_yunit ,state.color, state.sym, state.background,state. y_style, datatype=datatype

           cs_zoomplot, datatype, state.base2, state.zaehler, state.handlerliste, handlerliste=handlerliste
           state.zaehler=state.zaehler+1   
           state.handlerliste=handlerliste
           WIDGET_CONTROL, megaparent , SET_UVALUE=state
           WIDGET_CONTROL, state.label_status_text,SET_VALUE='Done'
           WIDGET_CONTROL, ev.top, /DESTROY
           RETURN
	END
'ZOOM_Y':BEGIN 
             WIDGET_CONTROL, state.label_status_text,SET_VALUE='zooming...'
		WIDGET_CONTROL, text.y_range_from_edit, GET_VALUE=from
      		WIDGET_CONTROL, text.y_range_to_edit, GET_VALUE=to
           	perform_operation, datatype,'ZOOM_Y',from,to,datatype=datatype, nachricht=nachricht
		WIDGET_CONTROL, state.label_status_text,SET_VALUE=nachricht
		cs_plot, datatype
END
'ZOOM_X':BEGIN 
		WIDGET_CONTROL, state.label_status_text,SET_VALUE='zooming...'
		WIDGET_CONTROL, text.x_range_from_edit, GET_VALUE=from
      		WIDGET_CONTROL, text.x_range_to_edit, GET_VALUE=to
           	perform_operation, datatype,'ZOOM_X',from,to,datatype=datatype, nachricht=nachricht
		WIDGET_CONTROL, state.label_status_text,SET_VALUE=nachricht
		cs_plot, datatype
END
'DESTROY': BEGIN
              FOR i=zaehler, state.zaehler - 2 DO BEGIN 
              handlerliste(i)=handlerliste(i+1)
	       drawparent=WIDGET_INFO(handlerliste(i), /parent)
            	 WIDGET_CONTROL, drawparent , GET_UVALUE=struc
 		 struc.nummer=struc.nummer-1
              get_background, struc.datatype, background=background
		 axes_color=(255-background) mod 256
              WIDGET_CONTROL, handlerliste(i),GET_VALUE=drawindex
              WSET, drawindex
              XYOUTS, 5,5, 'Graph Nr.: '+STRTRIM(STRING(struc.nummer+1), 2), /DEVICE, color=background
              XYOUTS, 5,5, 'Graph Nr.: '+STRTRIM(STRING(struc.nummer), 2), /DEVICE, color=axes_color
              WIDGET_CONTROL, drawparent, SET_UVALUE=struc		  
              ENDFOR 
              state.handlerliste=handlerliste
              state.zaehler=state.zaehler-1
              WIDGET_CONTROL, megaparent , SET_UVALUE=state
              WIDGET_CONTROL, parent, /DESTROY
              RETURN
             END

'RESET':BEGIN
             perform_operation, datatype,'RESET',0,0,datatype=datatype, nachricht=nachricht
             cs_plot, datatype
             END
 'Y_STYLE':BEGIN
             WIDGET_CONTROL, text.set_y_style_edit, GET_VALUE=y_style
             perform_operation, datatype,'YSTYLE',y_style MOD 32,0,datatype=datatype, nachricht=nachricht
             cs_plot, datatype
                    END  
'UNZOOM': BEGIN 
             perform_operation, datatype,'UNZOOM',0,0,datatype=datatype, nachricht=nachricht
		cs_plot, datatype
                 END
  'UNDO': BEGIN 
       undo_operation=WIDGET_INFO(text.operations_liste, /LIST_SELECT)
       IF undo_operation GE 0 THEN BEGIN
       WIDGET_CONTROL, text.undo_button, SENSITIVE=0
       WIDGET_CONTROL, state.label_status_text,SET_VALUE='recalculating...'
       get_operations_length, datatype, length=length 
       IF undo_operation LE length-1 THEN BEGIN
        perform_operation,datatype,'UNDO',undo_operation,0,datatype=datatype, nachricht=nachricht   
        cs_plot, datatype 
        WIDGET_CONTROL, state.label_status_text,SET_VALUE=nachricht
       ENDIF
     WIDGET_CONTROL, text.undo_button, SENSITIVE=1
   ENDIF  
  END
 'FLIP': BEGIN
    perform_operation,datatype,'FLIPAXES',0,0,datatype=datatype, nachricht=nachricht   
    cs_plot, datatype
END
  'COLOR': BEGIN
  WIDGET_CONTROL, text.set_color_edit, GET_VALUE=colorvalue
  perform_operation,datatype,'COLOR',colorvalue MOD 256,0,datatype=datatype, nachricht=nachricht
  cs_plot, datatype
  END  
  'EXECUTEFORMULA': BEGIN
  WIDGET_CONTROL, text.execute_edit, GET_VALUE=execute_value
  perform_operation,datatype,'EXECUT',execute_value,0,datatype=datatype, nachricht=nachricht
  cs_plot, datatype
         END
  'SMOOTH': BEGIN
         WIDGET_CONTROL, text.smooth_edit, GET_VALUE=smoothvalue
         perform_operation,datatype,'SMOOTH',smoothvalue,0,datatype=datatype, nachricht=nachricht
         cs_plot, datatype
    END 
 'SYMBOL': BEGIN
  WIDGET_CONTROL, text.set_sym_edit, GET_VALUE=symvalue
  perform_operation,datatype,'SYMBOL',symvalue MOD 8,0,datatype=datatype, nachricht=nachricht
  cs_plot, datatype
  END
'BACKGROUND': BEGIN
  WIDGET_CONTROL, text.set_backgr_edit, GET_VALUE=backgroundvalue
  perform_operation,datatype,'BACKGROUND',backgroundvalue MOD 256,0,datatype=datatype, nachricht=nachricht
  cs_plot, datatype
  END
'LIST':RETURN
 'CLOSE': BEGIN
    WIDGET_CONTROL, ev.top, /DESTROY
    RETURN
    END
ELSE:
ENDCASE 
get_background, datatype, background=background
axes_color=(255-background) mod 256
XYOUTS, 5,5, 'Graph Nr.: '+STRTRIM(STRING(text.info.nummer), 2), /DEVICE, color=axes_color
get_operations, datatype, operations=operations
get_operations_length, datatype, length=length 
IF length EQ 0 THEN temp=strarr(1) ELSE temp=strarr(length)
FOR i=0, length-1 DO BEGIN
temp(i)=STRTRIM(STRING(operations(3*i+1)))+' '+STRTRIM(STRING(operations(3*i+2)))+' '+STRTRIM(STRING(operations(3*i+3)))
ENDFOR
WIDGET_CONTROL, text.operations_liste, SET_VALUE = temp  
text.info.datatype=datatype
text.info.handlerliste=handlerliste  
WIDGET_CONTROL,   parent  , SET_UVALUE=text.info
WIDGET_CONTROL, ev.top, SET_UVALUE=text
END


PRO cs_options, info
datatype=info.datatype
get_operations, datatype, operations=operations 
get_operations_length, datatype, length=length 
IF XRegistered('cs_options' +STRTRIM(STRING(info.nummer),2)) GT 0 THEN BEGIN
 IF length EQ 0 THEN temp=strarr(1) ELSE temp=strarr(length)
  FOR i=0, length-1 DO BEGIN
   temp(i)=STRTRIM(STRING(operations(3*i+1)))+' '+STRTRIM(STRING(operations(3*i+2)))+' '+STRTRIM(STRING(operations(3*i+3)))
  ENDFOR
WIDGET_CONTROL, info.operations_listenID, SET_VALUE = temp  
RETURN
ENDIF
IF info.zoomed GT 0 THEN BEGIN
info.zoomed=0
parent=WIDGET_INFO(info.drawID, /parent)
WIDGET_CONTROL, parent , SET_UVALUE=info
RETURN
ENDIF
stuff=strarr(8)
time_interval=strarr(1)

           openr,unit_options_pref,'preferences.dat',/get_lun
           readf,unit_options_pref, stuff
           readf,unit_options_pref, time_interval
           close,unit_options_pref 
           free_lun,unit_options_pref 

get_color, datatype , color=color          
get_sym, datatype , sym=sym
get_background, datatype, background=background 
get_y_style, datatype, y_style=y_style
IF length EQ 0 THEN temp=strarr(1) ELSE temp=strarr(length)
temp(0)=' '
FOR i=0, length-1 DO BEGIN
temp(i)=STRTRIM(STRING(operations(3*i+1)))+' '+STRTRIM(STRING(operations(3*i+2)))+' '+STRTRIM(STRING(operations(3*i+3)))
ENDFOR

  parent=WIDGET_INFO(info.drawID, /parent)
  megaparent=WIDGET_INFO(info.base, /parent)
  Widget_Control, megaparent, Get_UValue=state

        option_base = WIDGET_BASE(GROUP_LEADER=info.drawID, TITLE='OPTIONS for graph '+STRTRIM(STRING(info.nummer),2), column=1, /base_align_right)
        base_1= WIDGET_BASE(option_base, ROW=1, frame=1,xsize=380)
        base_1_1= WIDGET_BASE(base_1, ROW=10)
        destroy_base= WIDGET_BASE(base_1_1, column=1)
        destroy_button = WIDGET_BUTTON(destroy_base,xsize=130, VALUE='Destroy plot', UVALUE='DESTROY')
        reset_base= WIDGET_BASE(base_1_1, column=1)
        reset_button = WIDGET_BUTTON(reset_base,xsize=130, VALUE='Reset', UVALUE='RESET')
        unzoom_base= WIDGET_BASE(base_1_1, column=1)
        unzoom_button = WIDGET_BUTTON(unzoom_base,xsize=130, VALUE='Unzoom', UVALUE='UNZOOM')
        flip_axes_base= WIDGET_BASE(base_1_1, column=2 )
        flip_axes_button = WIDGET_BUTTON(flip_axes_base, xsize=130,VALUE='Flip axes', UVALUE='FLIP', SENSITIVE=1)
        smooth_base= WIDGET_BASE(base_1_1, column=2 )
        smooth_button = WIDGET_BUTTON(smooth_base,xsize=130, VALUE='Smooth', UVALUE='SMOOTH')
        smooth_edit = WIDGET_TEXT(smooth_base, VALUE='10', xsize=5, editable=1, UVALUE='SMOOTHEDIT') 
        base_1_2= WIDGET_BASE(base_1,ROW=10 )
        operations_label=WIDGET_LABEL (base_1_2, VALUE='Operations:' )
        operations_liste=WIDGET_LIST(base_1_2, ysize=9, xsize=24, UVALUE='LIST', VALUE=temp) 
        undo_button = WIDGET_BUTTON(base_1_2, xsize=130, VALUE='Undo', UVALUE='UNDO', SENSITIVE=0)
        base_2= WIDGET_BASE(option_base,ROW=1, frame=1,xsize=380 )
        execute_base= WIDGET_BASE(base_2, row=1 )
        execute_button = WIDGET_BUTTON(base_2, xsize=130,VALUE='Calculate', UVALUE='EXECUTEFORMULA')
        execute_label=WIDGET_LABEL (base_2, VALUE=' y=' )
        execute_edit=WIDGET_TEXT(base_2, VALUE='y' , xsize=32, editable=1, UVALUE='EXECUTEFORMULAEDIT')
        base_3= WIDGET_BASE(option_base,ROW=2 , frame=1,xsize=380 )
        correlate_base= WIDGET_BASE(base_3, row=1 )
        correlate_button=WIDGET_BUTTON(correlate_base, xsize=130,VALUE='Correlate', UVALUE='CORRELATE')
        correlate_label=WIDGET_LABEL (correlate_base, VALUE='Graph '+STRTRIM(STRING(info.nummer),2)+ ' with graph No.: ' )
        correlate_edit=WIDGET_TEXT(correlate_base, VALUE='' , xsize=2, editable=1, UVALUE='CORRELATEEDIT')
        correlate_base2=WIDGET_BASE(base_3, row=1 )
        time_interval_label=WIDGET_LABEL (correlate_base2, VALUE='      Time interval: ')
        time_interval_edit=WIDGET_TEXT(correlate_base2, VALUE=time_interval , xsize=4, editable=1, UVALUE='TIME_INTERVALEDIT') 
        time_interval_label2=WIDGET_LABEL (correlate_base2, VALUE='ms')
        y_range_base= WIDGET_BASE(option_base, row=1, frame=1,xsize=380)
        y_range_button=WIDGET_BUTTON(y_range_base, xsize=130,VALUE='Zoom y', UVALUE='ZOOM_Y')
        y_range_from_label=WIDGET_LABEL (y_range_base, VALUE='from ')
        y_range_from_edit=WIDGET_TEXT(y_range_base, VALUE='' , xsize=10, editable=1, UVALUE='ZOOM_Y_FROM_EDIT')
        y_range_to_label=WIDGET_LABEL (y_range_base, VALUE='to ')
        y_range_to_edit=WIDGET_TEXT(y_range_base, VALUE='' , xsize=10, editable=1, UVALUE='ZOOM_Y_TO_EDIT')
        x_range_base= WIDGET_BASE(option_base, row=1, frame=1,xsize=380 )
        x_range_button=WIDGET_BUTTON(x_range_base, xsize=130,VALUE='Zoom x', UVALUE='ZOOM_X')
        x_range_from_label=WIDGET_LABEL (x_range_base, VALUE='from ')
        x_range_from_edit=WIDGET_TEXT(x_range_base, VALUE='' , xsize=10, editable=1, UVALUE='ZOOM_X_FROM_EDIT')
        x_range_to_label=WIDGET_LABEL (x_range_base, VALUE='to ')
        x_range_to_edit=WIDGET_TEXT(x_range_base, VALUE='' , xsize=10, editable=1, UVALUE='ZOOM_X_TO_EDIT')
        base_4= WIDGET_BASE(option_base,ROW=2, frame=1,xsize=380 )
        set_color_base= WIDGET_BASE(base_4, column=2 )
        set_color_button = WIDGET_BUTTON(set_color_base, xsize=130,VALUE='Set color 0..255', UVALUE='COLOR')
        set_color_edit = WIDGET_TEXT(set_color_base, VALUE=STRTRIM(STRING(color),2), xsize=5, editable=1, UVALUE='COLOREDIT')
        set_backgr_base= WIDGET_BASE(base_4, column=2 )
        set_backgr_button = WIDGET_BUTTON(set_backgr_base, xsize=130,VALUE='Set bgcolor 0..255', UVALUE='BACKGROUND')
        set_backgr_edit = WIDGET_TEXT(set_backgr_base, VALUE=STRTRIM(STRING(background),2), xsize=5, editable=1, UVALUE='BACKGROUNDEDIT')
        set_sym_base= WIDGET_BASE(base_4, column=2 )
        set_sym_button = WIDGET_BUTTON(set_sym_base,xsize=130, VALUE='Set symbol 0..7', UVALUE='SYMBOL')
        set_sym_edit = WIDGET_TEXT(set_sym_base, VALUE=STRTRIM(STRING(sym),2), xsize=5, editable=1, UVALUE='SYMEDIT')
        set_y_style_base= WIDGET_BASE(base_4, column=2 )
        set_y_style_button = WIDGET_BUTTON(set_y_style_base,xsize=130, VALUE='Set y_style 1..31', UVALUE='Y_STYLE')
        set_y_style_edit = WIDGET_TEXT(set_y_style_base, VALUE=STRTRIM(STRING(y_style),2), xsize=5, editable=1, UVALUE='Y_STYLEEDIT')
        base_5= WIDGET_BASE(option_base,column=1,xsize=380 )
        exit_button = WIDGET_BUTTON(base_5, xsize=130,VALUE='Exit menu', UVALUE='CLOSE')

;state:state,$ 
   text = {info:info,$
           	set_sym_edit:set_sym_edit,$
           	set_color_edit:set_color_edit,$
           	operations_liste:operations_liste,$
           	unzoom_button: unzoom_button,$
           	undo_button: undo_button,$
           	smooth_edit:smooth_edit, $
           	set_y_style_edit: set_y_style_edit,$
           	correlate_edit:correlate_edit,$
           	execute_edit:execute_edit, $
           	set_backgr_edit:set_backgr_edit, $
	    	time_interval_edit:time_interval_edit, $
  		x_range_from_edit:x_range_from_edit, $
		y_range_from_edit:y_range_from_edit, $
		x_range_to_edit:x_range_to_edit, $
		y_range_to_edit:y_range_to_edit}
           WIDGET_CONTROL, option_base, SET_UVALUE=text
           WIDGET_CONTROL, option_base, /REALIZE
           info.operations_listenID=operations_liste
     
          WIDGET_CONTROL, parent , SET_UVALUE=info
          XMANAGER, 'cs_options'+STRTRIM(STRING(info.nummer),2), option_base,Event_Handler='cs_options_event'
END
