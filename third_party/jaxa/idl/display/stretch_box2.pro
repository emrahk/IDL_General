;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: stretch_box2
;
; PURPOSE: Draw a resizeable, movable rectangle in a draw widget. User supplies 
;   initial size, and uses the cursor to resize or move it.  This is different
;   from the stretch_box routine, which simply allows users to draw a rectangle
;   with the cursor.
;
; METHOD: User can move center of rectangle by moving mouse, change size
;	  of rectangle by holding down left button and dragging. Right click
;   to finish.  5 x,y points defining rectangle are returned to user
;   in device(default), data, or normalized coordinates.
;
; CATEGORY: display
;
; CALLING SEQUENCE:
;	xy = stretch_box2 (widget_id, color=color, xsize=xsize, ysize=ysize, $
;		device=device, data=data, normal=normal, event=event)
;
; INPUTS:
;	widget_id - widget id of draw widget
;
; OPTIONAL INPUTS (KEYWORDS):
;	color - color index to draw rectangle with
;	device - if set returns rectangle in device coordinates (default)
;	data - if set returns rectangle in data coordinates
;	normal - if set returns rectangle in normal coordinates
;	event - draw window left click event that has already occurred, e.g. user
;		has already left clicked in draw widget, and this position should
;		be used as starting position for stretch rectangle
;	xsize - initial x size of rectangle in data coordinates
;	ysize - initial y size of rectangle in data coordinates
;	message_id - widget id of a widget to display message in
;
; OUTPUTS:
;	Result of function is fltarr(2,5) where
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
;	Written, Kim Tolbert, 06-Aug-2014  (used stretch_circle as base and modified for rectangles)
; Modifications:
;
;-
;============================================================================

function stretch_box2_event, event

return,event

end

function stretch_box2, widget_id, color=color, xsize=xsize, ysize=ysize, $
	device=device, data=data, normal=normal, event=event, npts=npts, message_id=message_id

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
widget_control, widget_id, event_func='stretch_box2_event'

checkvar, color, !d.n_colors-1

checkvar, xsize, 10.
checkvar, ysize, 10.

; x1,y1 are center of rectangle in device coords, xs,ys are size of rectangle in device coords

xy = convert_coord ([0,xsize], [0,ysize], /data, /to_device)
xs = xy[0,1]-xy[0,0]
ys = xy[1,1]-xy[1,0]

x1 = 0.
y1 = 0.

if keyword_set(event) then begin
	x1 = event.x
	y1 = event.y
endif

pressing = 0

draw_boxcensiz, x1, y1, xs, ys, /device, color=color

while 1 do begin

	ev = widget_event (widget_id)

	if ev.press eq 1 then begin
	 ; if left-click and dragging to resize, position cursor at bottom, left of rectangle
		pressing = 1
		tvcrs, x1-xs/2., y1-ys/2., /dev
	endif

	if ev.release eq 1 then begin
	  ; when left-click is released, reposition to center of rectangle
		pressing = 0
		tvcrs, x1, y1, /dev
	endif

	if ev.type eq 2 then begin	;motion event

		;print,'old values = ', x1,y1,radius
		;erase the old rectangle (works because device graphics operations set to xor)
		draw_boxcensiz, x1, y1, xs, ys, /device, color=color
		wait,.01
		
		if pressing then begin
		  ; if left-clicking and dragging, get new size (old right/top edge minus new position), and new center
			xs = x1 + xs/2. - ev.x
			ys = y1 + ys/2. - ev.y
			x1 = ev.x + xs/2.
			y1 = ev.y + ys/2.
		endif else begin
			x1 = ev.x
			y1 = ev.y
		endelse

		draw_boxcensiz, x1, y1, xs, ys, /device, color=color

		if do_message then begin
			xy = convert_coord(x1, y1, /device, /to_data)
			xys = convert_coord(x1+xs, y1+ys, /device, /to_data)
			mess = 'X Center = ' + trim(xy[0], '(g12.6)') + $
				'  Y Center = ' + trim(xy[1], '(g12.6)') + $
				'  X Size = ' + trim(xys[0] - xy[0], '(g12.6)') + $
				'  Y Size = ' + trim(xys[1] - xy[1], '(g12.6)') 
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

		draw_boxcensiz, x1, y1, xs, ys, /device, color=color

		xarr = [x1-xs/2., x1+xs/2., x1+xs/2., x1-xs/2., x1-xs/2.]
		yarr = [y1-ys/2., y1-ys/2., y1+ys/2., y1+ys/2., y1-ys/2.]
		
		if keyword_set(data) then xy = convert_coord (xarr, yarr, /device, /to_data)
		if keyword_set(normal) then xy = convert_coord (xarr, yarr, /device, /to_normal)
		if not exist(xy) then xy = convert_coord (xarr, yarr, /device, /to_device)

		return, xy(0:1,*)

	endif

	wait, .1

endwhile

end