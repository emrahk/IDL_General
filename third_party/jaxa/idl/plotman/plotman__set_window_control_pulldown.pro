;+
; Name: plotman::set_window_control_pulldown
;
; Purpose: Set up the plotman Window_Control pulldown menu.  Every time we add or delete
;	a panel to this menu, have to delete the whole thing, and refill it again (don't know
;	why).  So first remove all buttons, then add the basic, generic buttons, then add a
;	description for each panel.
;
; Written: Kim Tolbert, 2001
; Modifications:
;	30-Jun-2002, Kim.  Use xwidump to find widget id's
;	5-Jan-2005, Kim.  Changed from subroutine to object method.
;-

pro plotman::set_window_control_pulldown

widget_control, self.plot_base, get_uvalue=state

;print,'old w_window_control = ', state.widgets.w_window_control
;print,'valid = ', xalive(state.widgets.w_window_control)

w_window_control = state.widgets.w_window_control

; if have single panel plotman, then don't have window_control widget
if xalive (w_window_control) then begin
	widget_control, w_window_control, update=0
	xwidump, w_window_control, text, id
	;remove backwards, and don't remove 0'th one (that's w_window_control)
	for i=n_elements(id)-1,1, -1 do widget_control, id[i], /destroy

	plotman_set_window_control_pulldown_basic, state.widgets.plot_base, w_window_control

	panel_descs = state.plotman_obj -> get(/all_panel_desc)

	if panel_descs(0) ne '' then begin
		for ip = 0, n_elements(panel_descs)-1 do begin

			; can't use /separator keyword to widget_button because it screws things up
			; when we need to delete this list of buttons and recreate it, so use a button of '-----'
			; to separate list of windows from list of controls.
			if ip eq 0 then temp = widget_button (w_window_control, $
													value='--------------------------', $
													uvalue='separator')
			w_panels = widget_button(w_window_control, $
				value=panel_descs(ip), $
				uvalue = 'panel' + strtrim(ip,2), $
				event_pro='plotman_window_control_event' )
		endfor
	endif

	widget_control, w_window_control, /update

endif

end
