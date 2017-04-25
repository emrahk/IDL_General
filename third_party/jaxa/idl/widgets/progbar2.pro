;============================================================================
;+
; PROJECT:  HESSI
;
; NAME:  progbar2
;
; PURPOSE:  interface to progressbar object to create and update a progress bar, and check if
;       cancel button on progress bar has been clicked. (This is very similar to progbar, except
;       progbar uses the showprogress object, which doesn't seem to work as well.)
;
; CATEGORY: HESSI, Widgets
;
; CALLING SEQUENCE:
;   1.  progbar, progobj, /init [, xloc=xloc, yloc=yloc] - initializes object and returns object reference in progobj variable
;   2.  progbar, progobj, /update[, percent, message_text = message_text]	- updates progress bar and message
;   3.  progbar,  progobj, cancel=cancelled	- check if cancel button clicked
;   4.  progbar, /destroy
;
; ARGUMENTS:
;   progobj - Instance of showprogress object.  If init is set, progobj is returned.  Otherwise it is an input argument.
;
; KEYWORDS:
;   init - If set, then initializes new show showprogress object.
;   update - If set, updates display of progress bar and message if any
;   percent - Percentage of task completed.  Used only if  /update is set to show progress on bar.  Progress
;      bar will change color according to this percentage.  If not set, then progress bar stays black.
;   message_text - Used only if /update is set.  Message to show above progress bar. Can be a string array with
;      a maximum of three elements.  Default is 'Operation in Progress...'
;   cancel - Returns a 0 or 1 if cancel button has not / has been pushed.
;   can_text - text to add to cancel question:  'Are you sure you want to cancel ...?' default='this operation'
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
;   .r progbar2
;   test_progbar2
;
; HISTORY:
;	Written Kim,  18-Mar-2001.  Converted to progbar2 8-Feb-2005
;
; MODIFICATIONS:
;	8-Feb-2005, Kim.  Rewrote progbar to call progressbar obj instead of showprogress obj, and
;		renamed to progbar2.  Also, added _extra keyword to pass on the xloc,yloc keywords.
;
;============================================================================


pro progbar2, progobj, $
	init=init, $
	update=update, $
	percent=percent, $
	message_text=message_text, $
	can_text=can_text, $
	cancel=cancel, $
	destroy=destroy, $
	_extra=_extra

case 1 of
	keyword_set(init): begin
		progobj = Obj_New("Progressbar", title='Progress Bar', _extra=_extra)
		progobj -> start
		end

	keyword_set(update):  begin
		ok = is_class(progobj, 'Progressbar', /quiet)
		if ok then begin
			if n_elements(percent) eq 0 then begin
				progobj -> update, text=message_text
			endif else begin
				progobj -> update, percent, text=message_text
			endelse
		endif
		end

	arg_present(cancel): begin
		cancel = 0
		if is_class(progobj, 'Progressbar', /quiet) then begin
			cancel = progobj -> checkcancel()
		endif
		if cancel then begin
			text = 'Are you sure you want to cancel '
			text =  text + (keyword_set(can_text) ? can_text : 'this operation') + '?'
			yesno = Dialog_Message(text, /question, /default_no)
			if strlowcase(yesno) eq 'yes' then begin
				progobj -> destroy
				obj_destroy, progobj
			endif else begin
				cancel = 0
				progobj -> setproperty,cancel=0
			endelse
		endif
		end

	keyword_set(destroy): begin
		if is_class(progobj, 'Progressbar', /quiet) then begin
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

pro test_progbar2

progbar2, progobj, /init, xloc=-1, yloc=-1

FOR j=0, 1000 DO BEGIN
  if j mod 100 EQ 0 THEN BEGIN
  	message_text = $
    	['Spare line for extra text', 'Working..., count = ' + strtrim(j,2),  $
    	'Another long spare line for more extra text']
    progbar2,  progobj, /update, percent=(j/10.), message_text = message_text
    progbar2,  progobj, cancel=cancelled
    IF cancelled THEN goto, getout
  endif
  Wait, 0.01 ; This is where you would do something useful.
ENDFOR
progbar2,  progobj, /destroy

getout:
print,'final count = ', j
end
