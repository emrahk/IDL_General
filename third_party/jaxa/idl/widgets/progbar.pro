;============================================================================
;+
; PROJECT:  HESSI
;
; NAME:  progbar
;
; PURPOSE:  interface to showprogress object to create and update a progress bar, and check if
;       cancel button on progress bar has been clicked.
;
; CATEGORY: HESSI, Widgets
;
; CALLING SEQUENCE:
;   1.  progbar, progobj, /init [, position=position] - initializes object and returns object reference in progobj variable
;   2.  progbar, progobj, /update[, percent, message_text = message_text]	- updates progress bar and message
;   3.  progbar,  progobj, cancel=cancelled	- check if cancel button clicked
;   4.  progbar, /destroy
;
; ARGUMENTS:
;   progobj - Instance of showprogress object.  If init is set, progobj is returned.  Otherwise it is an input argument.
;
; KEYWORDS:
;   position - x,y location to place widget in device coords, 0,0 is top left corner of screen.
;      Only used on init call.  Default is center of screen
;   init - If set, then initializes new show showprogress object.
;   update - If set, updates display of progress bar and message if any
;   percent - Percentage of task completed.  Used only if  /update is set to show progress on bar.  Progress
;      bar will change color according to this percentage.  If not set, then progress bar flips back and forth.
;   message_text - Used only if /update is set.  Message to show above progress bar. Can be a string array with
;      a maximum of three elements.  Default is 'Operation in Progress...'
;   cancel - Returns a 0 or 1 if cancel button has not / has been pushed.
;   destroy - Kills progress widget and destroys showprogress object.
;
; Calls:
;
; COMMON BLOCKS: None
;
; PROCEDURE:  Call progbar with /init at beginning of a loop that will take some time.
;   During loop, call with /update.  If percent is passed in, then progress bar will steadily change
;   color showing progress increasing.  Otherwise, progress bar will flip back and forth, white - black,
;   black - white, to show the work is in progress.  If message_text is passed in on /update call, then
;   text above progress bar is updated.
;   Also during loop, call with cancel=cancel to see if cancel button has been pushed.  If it has, take
;   action to exit loop.  (Widget and object are automatically destroyed by progbar.)
;   If loop finishes without being cancelled, destroy widget and object by calling with /destroy.
;
; RESTRICTIONS: None
;
; SIDE EFFECTS: None.
;
; EXAMPLES:
;   See end of this file for example program.  To use, type:
;   .r progbar
;   test_progbar
;
; HISTORY:
;	Written Kim,  18-Mar-2001
;
; MODIFICATIONS:
;   3-22-2001, Kim.  Added position keyword for init call.  Enabled multi-line message above progress
;      bar (maximum of three lines).
;   3-24-2001, Kim.  Added confirmation question for cancel.
;	3-24-2004, Kim.  Added wait,.5 in destroy option.  On linux, entire IDL
;	   session crashes if destroy too soon (maybe while still updating?)
;	6-21-2004, Kim.  In cancel check, first check whether showprogress object already
;		has cancel flag set.  If not get cancel button widget id, and get any event waiting,
;		and check if it's a cancel click.  Needed because showprogress does not use xmanager
;		when not in autoupdate mode (which we're not), and the only time it checks for the 'cancel'
;		button event is during the update process. But sometimes want to check button before
;		doing the update.
;
;============================================================================


pro progbar, progobj, $
	init=init, $
	position=position, $
	update=update, $
	percent=percent, $
	message_text=message_text, $
	cancel=cancel, $
	destroy=destroy

case 1 of
	keyword_set(init): begin
		progobj = Obj_New("ShowProgress", /CancelButton, title='Progress Bar', position=position)
		progobj -> start
		end

	keyword_set(update):  begin
		ok = is_class(progobj, 'ShowProgress', /quiet)
		if ok then begin
			if n_elements(percent) eq 0 then begin
				progobj -> update, message_text=message_text
			endif else begin
				progobj -> update, percent, message_text=message_text
			endelse
		endif
		end

	arg_present(cancel): begin
		cancel = 0
		if is_class(progobj, 'ShowProgress', /quiet) then begin
			cancel = progobj -> checkcancel()
			if not cancel then begin
				progobj -> getproperty, cancelid=cancelid
				event = widget_event(cancelid, /nowait)
				if Tag_Names(event, /Structure_Name) eq 'WIDGET_BUTTON'	 then cancel = 1
			endif
		endif
		if cancel then begin
			yesno = Dialog_Message('Are you sure you want to cancel this operation?', $
				/question, /default_no)
			if strlowcase(yesno) eq 'yes' then begin
				progobj -> destroy
				obj_destroy, progobj
			endif else begin
				cancel = 0
				progobj -> setcancel, 0
			endelse
		endif
		end

	keyword_set(destroy): begin
		if is_class(progobj, 'ShowProgress', /quiet) then begin
			;on some linux boxes, if destroyed too fast, crashes IDL session
			wait,1.
			progobj -> destroy
			obj_destroy, progobj
		endif
		end

endcase

end

; Sample program to show use of probar.  To use, type:
;   .r progbar
;   test_progbar

pro test_progbar

progbar, progobj, /init

FOR j=0, 1000 DO BEGIN
  if j mod 100 EQ 0 THEN BEGIN
  	message_text = $
    	['Spare line for extra text', 'Working..., count = ' + strtrim(j,2),  $
    	'Another long spare line for more extra text']
    ;progbar,  progobj, /update, percent=(j/10.), message_text = message_text
    progbar,  progobj, /update, percent=(j/10.), message_text = message_text
    progbar,  progobj, cancel=cancelled
    IF cancelled THEN goto, getout
  endif
  Wait, 0.01 ; This is where you would do something useful.
ENDFOR
progbar,  progobj, /destroy

getout:
print,'final count = ', j
end
