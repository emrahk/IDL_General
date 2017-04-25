;+
; Name: plotman_set_window_control_pulldown_basic
; Purpose: Set up the basic generic part of the Window_Control pulldown menu on plotman
;
; Written: Kim Tolbert, 2001
; Modifications:
;	30-Jun-2002, Kim.  Added Current Panel pulldown to items in basic windows pulldown
;	16-Nov-2006, Kim.  Added separator button.
;-


pro plotman_set_window_control_pulldown_basic, base, w_window_control

widget_control, base, update=0

w_curr = widget_button (w_window_control, $
					value='Current Panel', $
					/menu, $
					event_pro='plotman_window_control_event')

temp = widget_button (w_curr, value='Delete', uvalue='currdel')
temp = widget_button (w_curr, value='Maximize', uvalue='currmax')
temp = widget_button (w_curr, value='New PLOTMAN Window', uvalue='currnew')
temp = widget_button (w_curr, value='Summarize', uvalue='currsumm')

temp = widget_button (w_window_control, $
					value='Show All Panels', $
					uvalue='showall', $
					event_pro='plotman_window_control_event')

temp = widget_button (w_window_control, $
					value='2x2 Panels', $
					uvalue='2x2', $
					event_pro='plotman_window_control_event')

temp = widget_button (w_window_control, $
					value = 'Delete All Panels', $
					uvalue = 'deleteall', $
					event_pro = 'plotman_window_control_event')

temp = widget_button (w_window_control, $
					value = 'Multi-Panel Options...', $
					uvalue = 'configure', $
					event_pro = 'plotman_window_control_event')

temp = widget_button (w_window_control, $
					value = '-------------------------', $
					uvalue = 'separator', $
					event_pro = 'plotman_window_control_event')
;widget_control, temp, sensitive=0

widget_control, base, / update

end
