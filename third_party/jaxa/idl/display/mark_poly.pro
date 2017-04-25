;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: mark_poly
;
; PURPOSE: draw polygon
;
; CATEGORY: display
;
; CALLING SEQUENCE:
;	xy = mark_poly (widget_id, color=color, $
;		device=device, data=data, normal=normal, event=event)
;
; INPUTS:
;	widget_id - widget id of draw widget
;
; OPTIONAL INPUTS (KEYWORDS):
;	color - color index to draw with
;	device - if set returns vertices in device coordinates
;	data - if set returns vertices in data coordinates
;	normal - if set returns vertices in normal coordinates
;	event - draw window left click event that has already occurred, e.g. user
;		has already left clicked in draw widget, and this position should
;		be used as starting position for polygon
;
; OUTPUTS:
;	Result of function is fltarr(2,n) where
;	xy(0,*) are x coordinates of vertices
;	xy(1,*) are y coordinates of vertices
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
;	Written, Kim Tolbert, April 22, 2001
;
;-
;============================================================================

function mark_poly_event, event

return,event

end

function mark_poly, widget_id, color=color, $
	device=device, data=data, normal=normal, event=event

device, get_graphics = old, set_graphics = 6  ;set xor

sav_draw_motion_events = widget_info(widget_id, /draw_motion_events)
sav_draw_button_events = widget_info(widget_id, /draw_button_events)
sav_event_pro = widget_info(widget_id,/event_pro)
sav_event_func = widget_info(widget_id,/event_func)

widget_control, widget_id, /draw_motion_events, /draw_button_events
widget_control, widget_id, event_pro=''
widget_control, widget_id, event_func='mark_poly_event'

checkvar, color, !d.n_colors-1

x1 = ''
y1 = ''

if keyword_set(event) then begin
	x1 = event.x
	y1 = event.y
	xarr = x1
	yarr = y1
endif

while 1 do begin

	ev = widget_event (widget_id)
	;print,'event in mark_poly
	;help,ev,/st


	if ev.press eq 1 then begin
		x2 = ev.x
		y2 = ev.y
		;print,'initializing x1,y1 = ', x1,y1, convert_coord(x1,y1,/dev,/to_data)
	endif

	if x1 ne '' then begin

		;erase the old line (works because device graphics operations set to xor)
		PLOTS, [x1,x2], [y1,y2], /dev, color=color, thick=1, lines=0, psym=0
		x2 = ev.x
		y2 = ev.y

		;draw new line
		PLOTS, [x1,x2], [y1,y2], /dev, color=color, thick=1, lines=0, psym=0
	endif

	if ev.release eq 1 then begin
		xarr = append_arr (xarr, x2)
		yarr = append_arr (yarr, y2)
		x1 = x2
		y1 = y2
	endif

	if ev.press eq 4 then begin

		if x1 ne '' then begin
			PLOTS, [x1,x2], [y1,y2], /dev, color=color, thick=1, lines=0, psym=0
			PLOTS, [x1, xarr[0]], [y1,yarr[0]], /dev, color=color, thick=1, lines=0, psym=0
			xarr = append_arr(xarr, xarr[0])
			yarr = append_arr(yarr, yarr[0])
		endif else begin
			xarr = ev.x
			yarr = ev.y
		endelse

		device,set_graphics = old
		if sav_event_pro ne '' then widget_control, widget_id, event_pro=sav_event_pro
		if sav_event_func ne '' then widget_control, widget_id, event_func=sav_event_func
		widget_control, widget_id, draw_button_events=sav_draw_button_events, $
			draw_motion_events=sav_draw_motion_events

		if keyword_set(data) then xy = convert_coord (xarr, yarr, /device, /to_data)
		if keyword_set(normal) then xy = convert_coord (xarr, yarr, /device, /to_normal)
		if keyword_set(device) then xy = convert_coord (xarr, yarr, /device, /to_device)

		return, xy(0:1,*)

	endif

	wait, .1

endwhile

end