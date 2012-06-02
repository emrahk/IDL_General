;+
; NAME:
;cs_xmm_logviewer.pro
;
;
; PURPOSE:  
;creates main widget and event handler
;
;
; CATEGORY:
;XMM
;
;
; CALLING SEQUENCE:
;cs_xmm_logviewer
;
;
; INPUTS: 
;none
;
;
; OPTIONAL INPUTS:
;none
;
;
; KEYWORD PARAMETERS:
;none
;
;
; OUTPUTS:
;none
;
;
; OPTIONAL OUTPUTS:
;none
;
;
; COMMON BLOCKS:
;none
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
; none
;
;
; PROCEDURE:
;includes: cs_xmm_logviewer_event
;needs: cs_xmm_logviewer_load_subroutines, cs_plot, cs_options, cs_find_parameter_name, cs_find_parameter_number, assocliste.dat, cs_find_file_number, cs_array_constructor, 
;           cs_find_parameter_position_in_file, cs_correlation_constructor, cs_display_parameter_list, cs_multiple_file_reader, cs_load, cs_save, cs_read
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

PRO cs_xmm_logviewer_event, ev
   WIDGET_CONTROL, ev.id, GET_UVALUE=uval
   WIDGET_CONTROL, ev.top, GET_UVALUE=state
   handlerliste=state.handlerliste

CASE uval OF
'PREFERENCES': BEGIN
cs_preferences, state.mainbase
RETURN
END
'DISPLAY' : BEGIN
cs_display_parameter_list, state
RETURN
END
'MANUAL': BEGIN
cs_display_info, state
RETURN
END
'ABOUT': BEGIN
cs_display_about, state
RETURN
END        
'PRINTALL':BEGIN
   IF state.zaehler GT 1 THEN BEGIN
     !P.MULTI=[0,1,3]
     psObject = Obj_New("FSC_PSCONFIG")
     psObject->GUI
     psKeywords = psObject->GetKeywords()
     thisDevice = !D.Name
     Set_Plot, 'PS'
     Device, _Extra=psKeywords
     printed=1
     plotted=1
     FOR i=1, state.zaehler -1 DO BEGIN 
           IF ((i MOD 3) EQ 0) OR ( i EQ state.zaehler-1) THEN BEGIN 
           ERASE
           FOR k=printed, i DO BEGIN
		drawparent=WIDGET_INFO(handlerliste(k), /parent)
             Widget_CONTROL ,drawparent, get_UValue=struct
             get_revs, struct.datatype, revs=revs
		XYOUTS,((k-1) mod 3)*0.33 ,.98 ,'OPERATIONEN',/NORMAL, color=0
             XYOUTS,((k-1) mod 3)*0.33 ,.96 ,'REV: '+revs,/NORMAL, color=0
             get_operations, struct.datatype, operations=operations 
             get_operations_length, struct.datatype, length=length 
             IF length EQ 0 THEN temp=strarr(1) ELSE temp=strarr(length)
             FOR a=0, length-1 DO BEGIN
             text=STRTRIM(STRING(operations(3*a+1)))+' '+STRTRIM(STRING(operations(3*a+2)))+' '+STRTRIM(STRING(operations(3*a+3)))
              XYOUTS,((k-1) mod 3)*0.33,.93-.02*a ,text,/NORMAL, color=0
            ENDFOR
            printed=i+1
          ENDFOR 
          FOR k=plotted, i DO BEGIN
		drawparent=WIDGET_INFO(handlerliste(k), /parent)
             Widget_CONTROL ,drawparent, get_UValue=struct
            plotted=i+1
            cs_plot,struct.datatype
          ENDFOR 
          ENDIF
                 
     ENDFOR
     Device, /Close_File
     Set_Plot, thisDevice
     Obj_Destroy, psObject
     !P.MULTI=0
RETURN
   ENDIF
	           END 
 'PARAM' : BEGIN
          WIDGET_CONTROL, state.text_parameter,GET_VALUE=number 
          cs_find_parameter_name,number(0), name=name
          WIDGET_CONTROL, state.text_par_name, SET_VALUE=name    
                 END 
       
 'NAME' : BEGIN
          WIDGET_CONTROL, state.text_par_name,GET_VALUE=name 
          cs_find_parameter_number, name(0), number=number
          WIDGET_CONTROL, state.text_parameter, SET_VALUE=number    
                END 

 'XPARAM' : BEGIN
          WIDGET_CONTROL, state.text_Xparameter,GET_VALUE=number 
          cs_find_parameter_name,number(0), name=name
          WIDGET_CONTROL, state.text_Xpar_name, SET_VALUE=name    
                 END 
     
 'XNAME' : BEGIN
          WIDGET_CONTROL, state.text_Xpar_name,GET_VALUE=name 
          cs_find_parameter_number, name(0), number=number
          WIDGET_CONTROL, state.text_Xparameter, SET_VALUE=number    
                END       

'PLOT' : BEGIN 
          WIDGET_CONTROL, state.label_status_text,SET_VALUE='Constructing array(s)...'
          WIDGET_CONTROL, state.text_parameter,GET_VALUE=number 
          cs_find_parameter_name,number(0), name=name
          WIDGET_CONTROL, state.text_par_name, SET_VALUE=name    
          WIDGET_CONTROL, state.text_Xparameter,GET_VALUE=number 
           IF name EQ 'NOT FOUND' THEN BEGIN
          WIDGET_CONTROL, state.label_status_text,SET_VALUE='ERROR: No valid parameter!'
          RETURN
          END
          cs_find_parameter_name,number(0), name=name
          WIDGET_CONTROL, state.text_Xpar_name, SET_VALUE=name    
           IF name EQ 'NOT FOUND' THEN BEGIN
          WIDGET_CONTROL, state.label_status_text,SET_VALUE='ERROR: No valid parameter!'
          RETURN
          END
          WIDGET_CONTROL, state.text_path,GET_VALUE=orig_path 
		orig_path=STRTRIM(STRING(orig_path(0)), 2)
          WIDGET_CONTROL, state.text_path_save,GET_VALUE=user_path
		user_path=STRTRIM(STRING(user_path(0)), 2)
          WIDGET_CONTROL, state.text_rev,GET_VALUE=rev_from
		rev_from=FIX(rev_from(0))
          WIDGET_CONTROL, state.text_rev_to,GET_VALUE=rev_to 
		rev_to=FIX(rev_to(0))
          IF (rev_from GT rev_to) THEN BEGIN
 		rev_to=rev_from
	      WIDGET_CONTROL, state.text_rev_to, SET_VALUE=STRTRIM(String(rev_from), 2)
	    ENDIF
          WIDGET_CONTROL, state.text_Xparameter,GET_VALUE=x_parameter
		x_parameter=STRTRIM(STRING(x_parameter(0)), 2)
          WIDGET_CONTROL, state.text_parameter,GET_VALUE=y_parameter
		y_parameter=STRTRIM(STRING(y_parameter(0)), 2)
          WIDGET_CONTROL, state.text_Xpar_name,GET_VALUE=x_parameter_name
		x_parameter_name=STRTRIM(STRING(x_parameter_name(0)), 2)
          WIDGET_CONTROL, state.text_par_name,GET_VALUE=y_parameter_name
             y_parameter_name=STRTRIM(STRING(y_parameter_name(0)), 2)
          WIDGET_CONTROL, state.text_time_interval,GET_VALUE=time_interval
		time_interval=DOUBLE(FLOAT(time_interval(0))/(24*3600000))

          cs_multiple_file_reader,rev_from, rev_to, orig_path, user_path, x_parameter, x_parameter_name,  y_parameter, y_parameter_name, time_interval, state.color, state.sym, state.background, state.y_style, state.autosave, datatype=datatype, nachricht=nachricht
          WIDGET_CONTROL, state.label_status_text,SET_VALUE='Plotting...'
          IF nachricht EQ 'Done' THEN BEGIN
          cs_zoomplot, datatype, state.base2, state.zaehler, state.handlerliste, handlerliste=handlerliste
          state.zaehler=state.zaehler+1             
          WIDGET_CONTROL, state.base2, map=1
          ENDIF
        WIDGET_CONTROL, state.label_status_text,SET_VALUE=nachricht
END        
                
'DONE': BEGIN
WIDGET_CONTROL, ev.top, /DESTROY
RETURN
END

'CLEARALL' : BEGIN
            IF state.zaehler GT 1 THEN BEGIN
	      FOR i=1, state.zaehler -1 DO BEGIN 
	       	drawparent=WIDGET_INFO(handlerliste(i), /parent)
            	 	WIDGET_CONTROL, drawparent ,/DESTROY  
            ENDFOR 
           state.zaehler=1
           WIDGET_CONTROL, ev.top , SET_UVALUE=state  
          ENDIF 
         END
ELSE:             
ENDCASE

 state.handlerliste=handlerliste
 WIDGET_CONTROL, ev.top, SET_UVALUE=state

END


PRO cs_xmm_logviewer
; Setzen der Umgebungsvariablen
  DEVICE, RETAIN=2
  LOADCT, 2
  DEVICE, DECOMPOSE=0
  cs_xmm_logviewer_load_subroutines 
 ;Lesen der Preferences
 	orig_path=strarr(1)
	save_path=strarr(1)
 	y_parameter=strarr(1)
	y_parameter_name=strarr(1)
	x_parameter=strarr(1)
	x_parameter_name=strarr(1)
 	revolution_from=strarr(1)
	revolution_to=strarr(1)
	time_interval=strarr(1)
	color=strarr(1)
	bg_color=strarr(1)
	sym=strarr(1)
	y_style=strarr(1)
	smooth_value=strarr(1)
      autosave=strarr(1)
           openr,unit_xmm_logviewer_pref,'preferences.dat',/get_lun
           readf,unit_xmm_logviewer_pref, orig_path
           readf,unit_xmm_logviewer_pref, save_path
           readf,unit_xmm_logviewer_pref, y_parameter
           readf,unit_xmm_logviewer_pref, y_parameter_name
           readf,unit_xmm_logviewer_pref, x_parameter
           readf,unit_xmm_logviewer_pref, x_parameter_name
           readf,unit_xmm_logviewer_pref, revolution_from
           readf,unit_xmm_logviewer_pref, revolution_to
           readf,unit_xmm_logviewer_pref, time_interval
           readf,unit_xmm_logviewer_pref, color
           readf,unit_xmm_logviewer_pref, background
           readf,unit_xmm_logviewer_pref, sym
           readf,unit_xmm_logviewer_pref, y_style
           readf,unit_xmm_logviewer_pref, smooth_value
           readf,unit_xmm_logviewer_pref, autosave
           close,unit_xmm_logviewer_pref 
           free_lun,unit_xmm_logviewer_pref 
; HauptLayout  
  mainbase = WIDGET_BASE(TITLE='XMM LOGFILE VIEWER',MBAR=bar,ROW=2, XSIZE=800)
  base = WIDGET_BASE(mainbase, ROW=3)
  base2 = WIDGET_BASE(mainbase, SCROLL=1 ,X_SCROLL_SIZE=800, Y_SCROLL_SIZE=670, ROW=15, MAP=0)
 ; Menüleiste  
  menu1 = WIDGET_BUTTON(bar, VALUE='Main', /MENU)
  menu2 = WIDGET_BUTTON(bar, VALUE='Info', /MENU)
  button1 = WIDGET_BUTTON(menu1, VALUE='Clear all', UVALUE='CLEARALL', ysize=10)
  button3 = WIDGET_BUTTON(menu1, VALUE='Display parameter list...', UVALUE='DISPLAY')
  button4 = WIDGET_BUTTON(menu1, VALUE='Print all graphs', SENSITIVE=1, UVALUE='PRINTALL')
  button5 = WIDGET_BUTTON(menu1, VALUE='Preferences...', SENSITIVE=1, UVALUE='PREFERENCES')
  button6 = WIDGET_BUTTON(menu1, VALUE='Exit', /SEPARATOR, UVALUE='DONE')
  button7 = WIDGET_BUTTON(menu2, VALUE='Manual', SENSITIVE=1, UVALUE='MANUAL')
  button8 = WIDGET_BUTTON(menu2, VALUE='About', UVALUE='ABOUT', SENSITIVE=1)
 ; Eingabefenster
   oberes_base=WIDGET_BASE(base, ROW=1, frame=0)
   label_base=WIDGET_BASE(oberes_base, ROW=1, frame=1)
   label_path= WIDGET_Label(label_base, value='Original Data in:')
   text_path = WIDGET_TEXT(label_base, value = orig_path, editable=1, UVALUE='PATH')
   
   path_save_base=WIDGET_BASE(oberes_base, ROW=1, frame=1)
   label_path_save= WIDGET_Label( path_save_base, value='Save Data to:')
   text_path_save = WIDGET_TEXT (path_save_base, value = save_path, editable=1, UVALUE='SAVE_PATH')

   unteres_base=WIDGET_BASE(base, ROW=1, frame=0)
   parameter_base= WIDGET_BASE(unteres_base, ROW=2, frame=1)
   label_parameter= WIDGET_Label(parameter_base, value='Y-Parameter :')
   text_parameter = WIDGET_TEXT(parameter_base, value = y_parameter, UVALUE='PARAM' ,editable=1, xsize=5)
   label_par_name= WIDGET_Label(parameter_base, value='Y-Parameter Name :')
   text_par_name = WIDGET_TEXT(parameter_base, value = y_parameter_name, UVALUE='NAME', editable=1,  xsize=16)
   label_Xparameter= WIDGET_Label(parameter_base, value='X-Parameter :')
   text_Xparameter = WIDGET_TEXT(parameter_base, value =x_parameter, UVALUE='XPARAM' ,editable=1, xsize=5)
   label_Xpar_name= WIDGET_Label(parameter_base, value='X-Parameter Name :')
   text_Xpar_name = WIDGET_TEXT(parameter_base, value =x_parameter_name, UVALUE='XNAME', editable=1,  xsize=16)

   rev_base=WIDGET_BASE(unteres_base, ROW=2, frame=1)
   label_rev= WIDGET_Label(rev_base, value='Revolution :')
   text_rev = WIDGET_TEXT(rev_base, value = revolution_from, editable=1, UVALUE='REV', xsize=4)
   label_rev_to= WIDGET_Label(rev_base, value='to ')
   text_rev_to = WIDGET_TEXT(rev_base, value = revolution_to, editable=1, UVALUE='REV_TO', xsize=4)
   label_time_interval=WIDGET_Label(rev_base, value='Corellation time interval:  ')
   text_time_interval=WIDGET_TEXT(rev_base, value = time_interval, editable=1, UVALUE='TIME_INTERVAL', xsize=4)
   label_millisec=WIDGET_Label(rev_base, value='ms')

   plotbase = WIDGET_BASE(unteres_base, column=2 ,frame=2)
   button_plot1 = WIDGET_BUTTON(plotbase, value='plot', UVALUE='PLOT')
   letztes_base=WIDGET_BASE(base, ROW=1, frame=0)
   status_base=WIDGET_BASE(letztes_base, ROW=1, frame=1, xsize=663)
   label_status=WIDGET_Label(status_base, value='Status: ')
   label_status_text=WIDGET_Label(status_base, value=' ',/DYNAMIC_RESIZE, /Align_left)
   state = {base2: base2,$   ;;base in das alle graphen erstellt werden
          mainbase:mainbase,$
          text_par_name: text_par_name,$
          text_parameter: text_parameter, $
          text_Xpar_name: text_Xpar_name,$
          text_Xparameter: text_Xparameter, $
          text_rev: text_rev, $
          text_rev_to: text_rev_to, $
          text_path: text_path,$
          text_path_save: text_path_save,$ 
          text_time_interval:text_time_interval,$
	    color:color, $
	    sym:sym, $
	    background:background, $
	    y_style:y_style, $
	    smooth_value:smooth_value, $
	    zaehler:1, $
          handlerliste:lonarr(1000),$
          label_status_text:label_status_text,$
          autosave:autosave(0)}
   WIDGET_CONTROL, mainbase, SET_UVALUE=state
   WIDGET_CONTROL, mainbase, /REALIZE
   XMANAGER, 'cs_xmm_logviewer', mainbase
  END
