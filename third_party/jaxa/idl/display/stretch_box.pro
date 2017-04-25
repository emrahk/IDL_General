;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: stretch_box
;
; PURPOSE: Draw a rectangle in a draw widget.  (see stretch_box2 for drawing a moveable,
;  resizeable rectangle in a draw widget)
;
; CATEGORY: display
;
; CALLING SEQUENCE:
;	xy = stretch_box (widget_id, color=color, $
;		device=device, data=data, normal=normal, event=event)
;
; INPUTS:
;	widget_id - widget id of draw widget
;
; OPTIONAL INPUTS (KEYWORDS):
;	color - color index to draw box with
;	device - if set returns corners of box in device coordinates
;	data - if set returns corners of box in data coordinates
;	normal - if set returns corners of box in normal coordinates
;	event - draw window left click event that has already occurred, e.g. user
;		has already left clicked in draw widget, and this position should
;		be used as starting position for stretch box
;	no_sort - if set, order of x and y coords is first/last corner, not min/max
;
; OUTPUTS:
;	Result of function is fltarr(2,2) where
;	xy(0,*) are x min and max of box (see no_sort keyword)
;	xy(1,*) are y min and max of box (see no_sort keyword)
;
; OPTIONAL OUTPUTS:  None
;
; Calls:
;
; COMMON BLOCKS: None
;
; PROCEDURE:
;
; RESTRICTIONS: Requires that window be a draw widget
;
; SIDE EFFECTS: None.
;
; EXAMPLES:
;
; HISTORY:
;	Written, Kim Tolbert, Dec 99
;	Kim, Mar 22, 00 - Added event keyword
;	Kim. Jul 9, 2005 - Added no_sort option
;	Kim, Aug 6, 2014 - Modified comments to point out existence of stretch_box2 with different capabilities
;
;-
;============================================================================
function stretch_box_event, event

return,event

end

function stretch_box, widget_id, color=color, $
	device=device, data=data, normal=normal, event=event, no_sort=no_sort

device, get_graphics = old, set_graphics = 6  ;set xor

sav_draw_motion_events = widget_info(widget_id, /draw_motion_events)
sav_draw_button_events = widget_info(widget_id, /draw_button_events)
sav_event_pro = widget_info(widget_id,/event_pro)
sav_event_func = widget_info(widget_id,/event_func)

widget_control, widget_id, /draw_motion_events, /draw_button_events
widget_control, widget_id, event_pro=''
widget_control, widget_id, event_func='stretch_box_event'

checkvar, color, !d.n_colors-1

if keyword_set(event) then begin
	x1 = event.x
	y1 = event.y
	x2 = x1
	y2 = y1
endif else x1 = ''

while 1 do begin

	ev = widget_event (widget_id)
;	print,'event in stretch_box
;	help,ev,/st

	if ev.press eq 1 then begin
		x1 = ev.x
		y1 = ev.y
		x2 = x1
		y2 = y1
		;print,'initializing x1,y1 = ', x1,y1, convert_coord(x1,y1,/dev,/to_data)
	endif

	if x1 ne '' then begin

		;erase the old box (works because device graphics operations set to xor)
		PLOTS, [x1,x2,x2,x1,x1], [y1,y1,y2,y2,y1], /dev, color=color, thick=1, lines=0, psym=0
		x2 = ev.x
		y2 = ev.y

		;draw new box
		PLOTS, [x1,x2,x2,x1,x1], [y1,y1,y2,y2,y1], /dev, color=color, thick=1, lines=0, psym=0

		if ev.release eq 1 then begin

			device,set_graphics = old
			if sav_event_pro ne '' then widget_control, widget_id, event_pro=sav_event_pro
			if sav_event_func ne '' then widget_control, widget_id, event_func=sav_event_func
			widget_control, widget_id, draw_button_events=sav_draw_button_events, $
				draw_motion_events=sav_draw_motion_events

			xarr = [x1,x2]
			if not keyword_set(no_sort) then xarr = minmax(xarr)
			yarr = [y1,y2]
			if not keyword_set(no_sort) then yarr = minmax(yarr)
			if keyword_set(data) then xy = convert_coord (xarr, yarr, /device, /to_data)
			if keyword_set(normal) then xy = convert_coord (xarr, yarr, /device, /to_normal)
			if keyword_set(device) then xy = convert_coord (xarr, yarr, /device, /to_device)

			return, xy(0:1,*)

		endif
	endif

	wait, .1

endwhile

end