;+
; NAME:
;cs_display_parameter_list
;
;
; PURPOSE:
;displays parameterlist
;
;
; CATEGORY:
;xmm_logviewer subroutine
;widget
;
; CALLING SEQUENCE:
;cs_display_parameter_list, state
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
;includes: cs_display_parameter_list_event,
;needs: assocliste.dat
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_display_parameter_list_event, ev
WIDGET_CONTROL, ev.top, GET_UVALUE=text
WIDGET_CONTROL, ev.id, GET_UVALUE=uval
CASE uval OF
  'DISPLAYDONE': WIDGET_CONTROL, ev.top, /DESTROY
  'WY' : WIDGET_CONTROL, text.werte, SET_VALUE='To Y'         
  'WX' : WIDGET_CONTROL, text.werte, SET_VALUE='To X'
  'LIST' : BEGIN 
      selected_param=strarr(1)
      number=string(text.paramarray[ev.index])
      selected_param=str_sep(number,';') 
      parameter=STRTRIM(selected_param(0),2)
      parameter_name=STRTRIM(selected_param(1),2)
      WIDGET_CONTROL, text.werte, GET_VALUE=werte_var
      IF werte_var eq 'To X' then begin
      WIDGET_CONTROL, text.state.text_xparameter, SET_VALUE=parameter
      WIDGET_CONTROL, text.state.text_xpar_name, SET_VALUE=parameter_name
      ENDIF ELSE BEGIN
      WIDGET_CONTROL, text.state.text_parameter, SET_VALUE=parameter
      WIDGET_CONTROL, text.state.text_par_name, SET_VALUE=parameter_name
      ENDELSE
	    END
 
ENDCASE
END


PRO cs_display_parameter_list, state
           IF XREGISTERED('cs_display_parameter_list') GT 0 THEN RETURN
           displaybase = WIDGET_BASE(GROUP_LEADER=state.mainbase, TITLE='Parameter', ROW=3)
           paramarray=strarr(205)
           openr,unit_display,'assocliste.dat',/get_lun
           readf,unit_display,paramarray
           close,unit_display
           free_lun,unit_display
           werte=Widget_Button(displaybase, value='To Y', MENU=1) 
           werte_y=Widget_Button(werte, value='To Y', UVALUE='WY')
           werte_x=Widget_Button(werte, value='To X', UVALUE='WX')
           parameterlist = WIDGET_LIST(displaybase, ysize=15, UVALUE='LIST', VALUE=paramarray)
           done2button = WIDGET_BUTTON(displaybase, VALUE='Done', UVALUE='DISPLAYDONE')
          
           text = {state:state, paramarray:paramarray, werte:werte, parameterlist: parameterlist,$
           done2button: done2button}
           WIDGET_CONTROL, displaybase, SET_UVALUE=text
           WIDGET_CONTROL, displaybase, /REALIZE
           XMANAGER, 'cs_display_parameter_list', displaybase
END
