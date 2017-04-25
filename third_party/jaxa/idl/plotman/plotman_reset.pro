;+
; Name: plotman_reset
;
; Purpose: Tries to restore plotman settings in case of a crash.  Also lets user kill hung widgets.
;
; Calling sequence:  plotman_reset, plotman_obj
;
; Input arguments:
;   plotman_obj - plotman object to clean up
;
; Method:
;	1. Restores normal setting of 3 for device graphics setting
;	2. Resets the event handler for the draw widget
;	3. Clears pending events
;	4. Lets user destroy any hung widgets (user can choose from list)
;
; Output:
;   Selected widgets are destroyed.
;
; Written:  Kim Tolbert, 1-Aug-2002
; Modifications:
;-
;===========================================================================

pro plotman_reset, plotman_obj

widgets = plotman_obj -> get(/widgets)

; plotman leaves !d.window eq 0, not the window last plotted to.  On unix this call to device
; opens a blank window, so first do wset to current window, call device, then set window
; back to what it was.  If there's no current window, will open a blank window on unix - oh well...
curr = !d.window
if is_wopen(widgets.window_id) then wset, widgets.window_id
device, set_graphics=3
wset, curr

if xalive(widgets.w_draw) then widget_control, widgets.w_draw, event_pro='plotman_draw_event', event_func=''

widget_control, /clear_events

widget_kill, group = widgets.plot_base


end