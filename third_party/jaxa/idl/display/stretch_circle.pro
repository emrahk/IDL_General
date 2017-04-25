;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: stretch_circle
;
; PURPOSE: draw rubberband circle
;
; METHOD: User can move center of circle by moving mouse, change size
;	of circle by holding down left button and dragging. Right click
;   to finish.  20 (or npts) points defining circle are returned to user
;   in device(default), data, or normalized coordinates.
;
; CATEGORY: display
;
; CALLING SEQUENCE:
;	xy = stretch_circle (widget_id, color=color, $
;		device=device, data=data, normal=normal, event=event)
;
; INPUTS:
;	widget_id - widget id of draw widget
;
; OPTIONAL INPUTS (KEYWORDS):
;	color - color index to draw circle with
;	device - if set returns circle in device coordinates (default)
;	data - if set returns circle in data coordinates
;	normal - if set returns circle in normal coordinates
;	event - draw window left click event that has already occurred, e.g. user
;		has already left clicked in draw widget, and this position should
;		be used as starting position for stretch circle
;   npts - number of points used to define circle (default=20)
;	radius_start - initial radius of circle in data coordinates
;	message_id - widget id of a widget to display message in
;
; OUTPUTS:
;	Result of function is fltarr(2,npts) where
;	xy(0,*) are x values
;	xy(1,*) are y values
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
;	Written, Kim Tolbert, 24-Apr-2001
; Modifications:
;	4-June-2001, Kim.  Added radius_start and message_id keywords
;
;-
;============================================================================

function stretch_circle_event, event

return,event

end

function stretch_circle, widget_id, color=color, radius_start=radius, $
	device=device, data=data, normal=normal, event=event, npts=npts, message_id=message_id

checkvar, npts, 20
if keyword_set(message_id) then do_message=1 else do_message=0

device, get_graphics = old, set_graphics = 6  ;set xor

sav_draw_motion_events = widget_info(widget_id, /draw_motion_events)
sav_draw_button_events = widget_info(widget_id, /draw_button_events)
sav_event_pro = widget_info(widget_id,/event_pro)
sav_event_func = widget_info(widget_id,/event_func)
psym = !p.psym
!p.psym = 0

catch, error
if error ne 0 then begin

	print,!err_string
	device,set_graphics = old
	if sav_event_pro ne '' then widget_control, widget_id, event_pro=sav_event_pro
	if sav_event_func ne '' then widget_control, widget_id, event_func=sav_event_func
	widget_control, widget_id, draw_button_events=sav_draw_button_events, $
		draw_motion_events=sav_draw_motion_events
	!p.psym = psym
	return, -1
endif

widget_control, widget_id, /draw_motion_events, /draw_button_events
widget_control, widget_id, event_pro=''
widget_control, widget_id, event_func='stretch_circle_event'

checkvar, color, !d.n_colors-1

if keyword_set(radius) then begin
	xy = convert_coord ([0,radius], [0,0], /data, /to_device)
	radius = abs(xy[0,1] - xy[0,0])
endif else radius = 0.

x1 = 0.
y1 = 0.

if keyword_set(event) then begin
	x1 = event.x
	y1 = event.y
endif

pressing = 0

draw_circle, x1,y1,radius, /dev, npts=npts, color=color, thick=1.2, lines=0

while 1 do begin

	ev = widget_event (widget_id)
	;print,'event in stretch_circle
	;help,ev,/st

	if ev.press eq 1 then begin
		pressing = 1
		tvcrs, x1, y1 + radius, /dev
	endif

	if ev.release eq 1 then begin
		pressing = 0
		tvcrs, x1,y1, /dev
	endif

	if ev.type eq 2 then begin	;motion event

		;print,'old values = ', x1,y1,radius
		;erase the old circle (works because device graphics operations set to xor)
		draw_circle, x1,y1,radius, /dev, npts=npts, color=color, thick=1.2, lines=0
		wait,.01
		if pressing then begin
			; make float because otherwise 2-byte integers overflow in math
			radius = sqrt ( (float(ev.x)-x1)^2 + (float(ev.y)-y1)^2 )
		endif else begin
			x1 = ev.x
			y1 = ev.y
		endelse
		;print,'new values = ', x1,y1,radius
		;draw new circle
		draw_circle, x1,y1,radius, /dev, npts=npts, color=color, thick=1.2, lines=0
		if do_message then begin
			xy = convert_coord (x1, y1, /device, /to_data)
			xyrad = convert_coord ([0,radius], [0,0], /device, /to_data)
			radius_data = abs (xyrad[0,1] - xyrad[0,0])
			mess = 'X Center = ' + strtrim(string(xy[0], format='(g12.6)'),2) + $
				'  Y Center = ' +  strtrim(string(xy[1], format='(g12.6)'),2) + $
				'  Radius = ' + strtrim(string(radius_data, format='(g12.6)'),2)
			widget_control, message_id, set_value=mess
		endif
		wait,.01
	endif

	if ev.press eq 4 then begin

		device,set_graphics = old
		if sav_event_pro ne '' then widget_control, widget_id, event_pro=sav_event_pro
		if sav_event_func ne '' then widget_control, widget_id, event_func=sav_event_func
		widget_control, widget_id, draw_button_events=sav_draw_button_events, $
			draw_motion_events=sav_draw_motion_events
		!p.psym = psym

		draw_circle, x1,y1,radius, /dev, npts=npts, color=color, thick=1.8, lines=0

		theta = indgen(npts)*2*!pi / (npts-1)

		xarr = radius * sin(theta) + x1
		yarr = radius * cos(theta) + y1

		if keyword_set(data) then xy = convert_coord (xarr, yarr, /device, /to_data)
		if keyword_set(normal) then xy = convert_coord (xarr, yarr, /device, /to_normal)
		if not exist(xy) then xy = convert_coord (xarr, yarr, /device, /to_device)

		return, xy(0:1,*)

	endif

	wait, .1

endwhile

end