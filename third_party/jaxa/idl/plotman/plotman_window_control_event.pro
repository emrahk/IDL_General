;+
; Name: plotman_window_control_event
; Purpose: Procedure to handle events from the plotman window_control pulldown menu.
; If called with saved_uvalue and state keywords (both must be passed), then this is not
;	a real event, use uvalue passed. (In this case event is a dummy argument, just set to 1
;	or something.)
;
; Written: Kim Tolbert, 2001
; Modifications:
;	30-Jun-2002, Kim.  Added currdel, currmax, currnew, currsumm to uvalues to handle
;	15-Nov-2006, Kim.  uvalue is now panel description (previously had 'panel x' in name),so
;	  in else: use uvalue to get panel number to use as arg to show_panel.  Also
;	  for 'new plotman window' option, call with wxpos=300 to offset from original.
;	  Also, don't set last_window_choice unless uvalue is one we'd want to repeat after resize.
;-

pro plotman_window_control_event, event, saved_uvalue=uvalue, state=state

; if we're using a saved uvalue (like the window was resized and want to redraw), then
; 'configure' is the only invalid one.
if keyword_set(uvalue) then if uvalue eq 'configure' then return

if not exist(uvalue) or not exist(state) then begin

	; if didn't pass in uvalue or state, then event better be a structure from a real event.
	if size(event, /tname) ne 'STRUCT' then return
	widget_control, event.top, get_uvalue=state
	widget_control, event.id, get_uvalue=uvalue

	;state.plotman_obj -> set, last_window_choice = uvalue
	;help,event,/st
	;print,'uvalue=',uvalue

endif

widget_control, state.widgets.w_message, set_value=' '

case uvalue of

	'separator':

	'currdel': if state.plotman_obj -> valid_window(/message) then $
		state.plotman_obj -> delete_panel, /current

	'currmax': begin
		panel_number = state.plotman_obj->get(/current_panel_number)
		if panel_number ne -1 then state.plotman_obj -> show_panel, /maximize, $
			panel_number=panel_number
		state.plotman_obj -> set, last_window_choice = uvalue
		end

	'currnew': begin
		if state.plotman_obj -> valid_window(/message) then begin
			panel = state.plotman_obj -> get(/current_panel_struct)
			;set x offset to 300 just to offset from default position
			new_obj = obj_new ('plotman', plot_type = panel.plot_control.plot_type, wxpos=300)

			if panel.saved_data.save_mode eq 'obj_extract' then begin
				new_obj -> set, saved_data=stc_clone(panel.saved_data), /use_extracted
			endif else begin
				new_obj -> set, input=*panel.saved_data.data, class_name=panel.saved_data.class_name
			endelse

			new_obj -> set, plot_control = stc_clone(panel.plot_control)
			new_obj -> new_panel, '', /using_saved
		endif
		end

	'currsumm': if state.plotman_obj ->valid_window(/message) then state.plotman_obj -> summ_params

	'showall': begin
		state.plotman_obj -> show_panel, /showall
		state.plotman_obj -> set, last_window_choice = uvalue
		end

	'2x2': begin
		state.plotman_obj -> show_panel, /p2x2
		state.plotman_obj -> set, last_window_choice = uvalue
		end

	'deleteall': begin
		answer = xanswer ('     Do you really want to delete all the panels?     ', /str, default=0)
		if answer eq 'y' then state.plotman_obj -> delete_panel, /all
		end

	'configure': begin
		state.plotman_obj -> multi_panel, state=state
		state.plotman_obj -> set, last_window_choice = uvalue
		end

	else: begin
		panel_number = state.plotman_obj -> desc2panel (uvalue, /number)
		if panel_number ne -1 then $
			state.plotman_obj -> show_panel, panel_number=panel_number[0], /maximize
		state.plotman_obj -> set, last_window_choice = uvalue
;		if strpos(uvalue, 'panel') eq 0 then begin
;			panel_number = fix (ssw_strsplit (uvalue, 'panel', /tail) )
;			state.plotman_obj -> show_panel, panel_number=panel_number(0), /maximize
;		endif
	end
endcase

end
