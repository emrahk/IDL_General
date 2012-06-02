;+
; NAME:
;cs_preferences.pro
;
;
; PURPOSE:
;widget for saving preferences
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_preferences ,mainbase
;
;
; INPUTS:
;mainbase
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
;includes: cs_preferences_event
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
PRO cs_preferences_event, ev
WIDGET_CONTROL, ev.id, GET_UVALUE=uval
WIDGET_CONTROL, ev.top, GET_UVALUE=text
WIDGET_CONTROL, text.mainbase, GET_UVALUE=state

CASE uval OF
   'YES': WIDGET_CONTROL,text.button_autosave, SET_VALUE='YES'
     'NO': WIDGET_CONTROL,text.button_autosave, SET_VALUE='NO'
 'SAVE': BEGIN
        pref=strarr(15)
          Widget_Control, text.text_path, GET_VALUE=orig_path
		pref(0)=STRTRIM(orig_path(0),2)
           Widget_Control, text.text_path_save, GET_VALUE=save_path
		pref(1)=STRTRIM(save_path(0),2)
           Widget_Control, text.text_parameter , GET_VALUE=y_parameter
		 pref(2)=STRTRIM(y_parameter(0),2)
           Widget_Control, text.text_par_name , GET_VALUE=y_parameter_name
		 pref(3)=STRTRIM(y_parameter_name(0),2)
           Widget_Control, text.text_Xparameter , GET_VALUE=x_parameter
		 pref(4)=STRTRIM(x_parameter(0),2)
           Widget_Control, text.text_Xpar_name , GET_VALUE=x_parameter_name
		 pref(5)=STRTRIM(x_parameter_name(0),2)
           Widget_Control, text.text_rev, GET_VALUE =revolution_from
		pref(6)=STRTRIM(revolution_from(0),2)
           Widget_Control, text.text_rev_to, GET_VALUE =revolution_to
		pref(7)=STRTRIM(revolution_to(0),2)
           Widget_Control, text.text_time_interval, GET_VALUE =time_interval
		pref(8)=STRTRIM(time_interval(0),2)
           Widget_Control, text.smooth_edit, GET_VALUE =smooth_value
	      pref(13)=STRTRIM(smooth_value(0),2)
           Widget_Control, text.set_color_edit, GET_VALUE =color
		pref(9)=STRTRIM(color(0),2)
           Widget_Control, text.set_backgr_edit, GET_VALUE =bg_color
	      pref(10)=STRTRIM(bg_color(0),2)
           Widget_Control, text.set_sym_edit, GET_VALUE =sym
		pref(11)=STRTRIM(sym(0),2)
           Widget_Control, text.set_y_style_edit, GET_VALUE =y_style
		pref(12)=STRTRIM(y_style(0),2)
           Widget_Control, text.button_autosave, GET_VALUE =autosave
             pref(14)=STRTRIM(autosave(0),2)
           openw,unit_preferences,'preferences.dat',/get_lun
           FOR i=0,14 DO printf,unit_preferences, pref(i)        
           close,unit_preferences
           free_lun,unit_preferences 
           state.color=pref(9)
	    state.sym=pref(11)
	    state.background=pref(10)
	    state.y_style=pref(12)
	    state.smooth_value=pref(13)
          state.autosave=pref(14)
 WIDGET_CONTROL, text.mainbase, SET_UVALUE=state
 WIDGET_CONTROL, ev.top, /DESTROY
END
'CLOSE': BEGIN
            WIDGET_CONTROL, ev.top, /DESTROY
            RETURN
            END
ELSE:
ENDCASE
END


PRO cs_preferences ,mainbase
 IF XREGISTERED('cs_preferences') GT 0 THEN RETURN
;Laden der bisherigen Preferences
           pref=strarr(15)
           openr,unit_preferences,'preferences.dat',/get_lun
           readf,unit_preferences, pref
           close,unit_preferences
           free_lun,unit_preferences 
 
;Layout
       preferences_base = WIDGET_BASE(GROUP_LEADER=mainbase, TITLE='PREFERENCES', column=1)
      
       label_base=WIDGET_BASE(preferences_base, ROW=1, frame=1)
       label_path= WIDGET_Label(label_base, value='Original Data in:')
       text_path = WIDGET_TEXT(label_base, value = pref(0), editable=1, xsize=30, UVALUE='ORIG_PATH')
   
       path_save_base=WIDGET_BASE(preferences_base, ROW=1, frame=1)
       label_path_save= WIDGET_Label( path_save_base, value='Save Data to:')
       text_path_save = WIDGET_TEXT (path_save_base, value = pref(1), editable=1, xsize=30, UVALUE='SAVE_PATH')

       base_2= WIDGET_BASE(preferences_base, ROW=1, frame=1,xsize=380)
       
       parameter_base= WIDGET_BASE(base_2, ROW=2)
       label_parameter= WIDGET_Label(parameter_base, value='Y-Parameter :')
       text_parameter = WIDGET_TEXT(parameter_base, value=pref(2), UVALUE='PARAM' ,editable=1, xsize=5)
       label_par_name= WIDGET_Label(parameter_base, value='Y-Parameter Name :')
       text_par_name = WIDGET_TEXT(parameter_base, value = pref(3), UVALUE='NAME', editable=1,  xsize=16)
       label_Xparameter= WIDGET_Label(parameter_base, value='X-Parameter :')
       text_Xparameter = WIDGET_TEXT(parameter_base, value = pref(4), UVALUE='XPARAM' ,editable=1, xsize=5)
       label_Xpar_name= WIDGET_Label(parameter_base, value='X-Parameter Name :')
       text_Xpar_name = WIDGET_TEXT(parameter_base, value = pref(5), UVALUE='XNAME', editable=1,  xsize=16)

       rev_base=WIDGET_BASE(preferences_base, ROW=1, frame=1)
       label_rev= WIDGET_Label(rev_base, value='Revolution :')
       text_rev = WIDGET_TEXT(rev_base, value = pref(6), editable=1, UVALUE='REV', xsize=4)
       label_rev_to= WIDGET_Label(rev_base, value='to ')
       text_rev_to = WIDGET_TEXT(rev_base, value = pref(7), editable=1, UVALUE='REV_TO', xsize=4)
       time_interval_base=WIDGET_BASE(preferences_base, ROW=1, frame=1)
       label_time_interval=WIDGET_Label(time_interval_base, value='Corellation time interval:  ')
       text_time_interval=WIDGET_TEXT(time_interval_base, value = pref(8), editable=1, UVALUE='TIME_INTERVAL', xsize=4)
       label_millisec=WIDGET_Label(time_interval_base, value='ms')
       smooth_base= WIDGET_BASE(preferences_base, ROW=1, frame=1)
       smooth_label=WIDGET_LABEL (smooth_base, VALUE='Smooth value:' )
       smooth_edit = WIDGET_TEXT(smooth_base, VALUE=pref(13), xsize=5, editable=1, UVALUE='SMOOTHEDIT')
 
       sign_base= WIDGET_BASE(preferences_base, ROW=2, frame=1 )
       set_color_base= WIDGET_BASE(sign_base, ROW=1 )
       set_color_label = WIDGET_LABEL(set_color_base, xsize=130,VALUE='Set color 0..255')
       set_color_edit = WIDGET_TEXT(set_color_base, VALUE=pref(9), xsize=5, editable=1, UVALUE='COLOREDIT')
       set_backgr_base= WIDGET_BASE(sign_base, ROW=1 )
       set_backgr_label = WIDGET_LABEL(set_backgr_base, xsize=130,VALUE='Set bgcolor 0..255')
       set_backgr_edit = WIDGET_TEXT(set_backgr_base, VALUE=pref(10), xsize=5, editable=1, UVALUE='BACKGROUNDEDIT')       
       set_sym_base= WIDGET_BASE(sign_base, ROW=1 )
       set_sym_label = WIDGET_LABEL(set_sym_base,xsize=130, VALUE='Set symbol 0..7')
       set_sym_edit = WIDGET_TEXT(set_sym_base, VALUE=pref(11), xsize=5, editable=1, UVALUE='SYMEDIT')
       set_y_style_base= WIDGET_BASE(sign_base, ROW=1 )
       set_y_style_label = WIDGET_LABEL(set_y_style_base,xsize=130, VALUE='Set y_style 1..31')
       set_y_style_edit = WIDGET_TEXT(set_y_style_base, VALUE=pref(12), xsize=5, editable=1, UVALUE='Y_STYLEEDIT')
       autosave_base=WIDGET_BASE(preferences_base, ROW=1, frame=1)
       label_autosave=WIDGET_Label(autosave_base, value='Autosave Data to .asci - files:')
       button_autosave=WIDGET_BUTTON(autosave_base, value = pref(14), Menu=1)  
       button_autosave_yes=WIDGET_BUTTON(button_autosave, value = 'YES',uvalue = 'YES')  
       button_autosave_no=WIDGET_BUTTON(button_autosave, value = 'NO',uvalue = 'NO') 
       base_5= WIDGET_BASE(preferences_base,column=1,xsize=380 )
       save_button = WIDGET_BUTTON(base_5, xsize=130,VALUE='Save preferences', UVALUE='SAVE')
       exit_button = WIDGET_BUTTON(base_5, xsize=130,VALUE='Cancel', UVALUE='CLOSE')

      text = {	mainbase:mainbase,$
                   text_path:text_path,$
 		    	text_path_save:text_path_save,$
		  	text_parameter:text_parameter,$
			text_par_name:text_par_name,$
			text_Xparameter:text_Xparameter,$
			text_Xpar_name:text_Xpar_name,$
			text_rev:text_rev,$
			text_rev_to:text_rev_to,$
			text_time_interval:text_time_interval,$
			smooth_edit:smooth_edit,$
			set_color_edit:set_color_edit,$
			set_backgr_edit:set_backgr_edit,$
			set_sym_edit:set_sym_edit,$
			set_y_style_edit:set_y_style_edit,$
                   button_autosave:button_autosave}

        WIDGET_CONTROL, preferences_base, SET_UVALUE=text
        WIDGET_CONTROL, preferences_base, /REALIZE
        XMANAGER, 'cs_preferences', preferences_base
END
