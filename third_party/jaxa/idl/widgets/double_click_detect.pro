;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: double_click_detect.pro
;
; PURPOSE:  Detect a double click in a draw widget
;
; CATEGORY: HESSI WIDGETS
;
; CALLING SEQUENCE:  double_click_detect, event, continue [, /press, delay=delay]]
;
; INPUTS:
;	event - event structure passed to an event handling routine
;
; OPTIONAL KEYWORDS:
;	press - only handle events where button was pressed.  Default is to handle release events.
;	delay - if second click is more than 'delay' seconds after first click, then it's not a double click (default=.4)
;
; OUTPUTS:
;	continue - if =0, then calling program should just return (waiting for timer event or next button event)
;
; OPTIONAL OUTPUTS:  None
;
; Calls:
;
; COMMON BLOCKS: None
;
; PROCEDURE:  Call double_click_detect from within draw widget's event handling routine.  On first call,
;	first_click will be 0.  Save the event structure in info.save_event (see restrictions below), set first_click to 1,
;	set the timer, and set continue to 0 so calling program won't do anything with this event. If a timer event
;	occurs before another button event, then it was a single click, so restore the saved event and set continue
;	to 1 so calling program will handle the event.  If two draw events happen in succession, then it's a double
;	click so set event.clicks to 1 and continue to 1.
;
; 	Note:  This routine will get the draw widget's uvalue and rewrite it, so if the calling routine has already
;	gotten the uvalue, it should get it again after calling this routine.
;
; RESTRICTIONS: For draw widgets only.  The draw_widget must have an information structure
;	saved in its uvalue which includes the tags first_click (init to 0) and save_event (init to {widget_draw})
;
; SIDE EFFECTS:  When double click detected, sets event.clicks to 2
;
; EXAMPLES:
;	pro event_handler, event
;	double_click_detect, event, continue
;	if not continue then return
;	w_draw = event.id
;	widget_control, w_draw, get_uvalue=info
;	if event.clicks eq 2 then print,'double click event detected.'
;
; HISTORY:
;	Kim Tolbert, 12-Sep-2000
;
;
;-
;============================================================================

pro double_click_detect, event, continue, press=press, delay=delay

checkvar, delay, .4

continue = 1

w_draw = event.id

widget_control, w_draw, get_uvalue=info

this_event = tag_names (event, /structure)

; if event was from the timer, then if we have saved an event that needs to be processed, set continue to 1
if (this_event eq 'WIDGET_TIMER')  then begin
	if info.save_event.top ne 0 then continue = 1 else continue = 0
	info.first_click = 0
	event = info.save_event
endif

; if event is not a timer event, then it was from a user click.  Set first_click to one and set the
; timer.  If get another user event when first_click is one, then it's a double click.

if (this_event ne 'WIDGET_TIMER') then begin

	if keyword_set(press) then begin
		if event.press eq 0 then return			; only handle events when button pressed
	endif else begin
		if event.release eq 0 then return		; only handle events when button released
	endelse

	if (info.first_click eq 0) then begin		; first click
		info.save_event = event					; save event structure for later handling
		info.first_click = 1
		widget_control, event.id, timer=delay
		continue = 0										; in caller, don't do anything with this event

	endif else begin									; second click
		info.save_event.top = 0L 				 ; put 0 in saved event, so we know not to use it when timer event happens
		info.first_click = 0
		event.clicks = 2
		continue = 1										; tell caller to process this event
	endelse
endif

widget_control, w_draw, set_uvalue=info		; store changed first_click and save_event back in widget uvalue

end