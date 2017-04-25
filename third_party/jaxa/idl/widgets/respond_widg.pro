;+
; Project     :	SOHO - CDS
;
; Name        :	RESPOND_WIDG
;
; Purpose     :	Widget to prompt user for (e.g.) a "YES" or "NO" response.
;
; Explanation :	
;	Creates a widget to prompt user for a "YES" or "NO" response as a
;	default.  But you may pass your own button names with the BUTTONS
;	keyword.
;
; Use         :	
;   var = respond_widg, [message=message, buttons=buttons, /column,
;			/row, group_leader=group]
;
; Inputs      :	
;	MESSAGE : 	String or string vector with message to be 
;		    	displayed in widget
;			The default message is 'Respond YES or NO '	
;	BUTTONS :	String vector where each element will be a button
;			You may have as many elements as will fit.
;	TITLE   :	string to appear as widget's banner
;	COLUMN  :	if set then the buttons will be verically placed
;	ROW	:	if set then the buttons will be horizontally placed
;				(/ROW is the default and it overrides /COLUMN)
;	GROUP_LEADER : 	Causes the widgets destruction if parent is killed
;	XOFFSET :       X-POSITION OF BASE IN PIXEL UNITS
;	YOFFSET :       Y-POSITION OF BASE IN PIXEL UNITS
;
; Opt. Inputs :	None.
;
; Outputs     :	
;	Returns a -1 if program fails else it returns the index number of 
;	the button that was selected, as determined by the array BUTTONS.
;       Indexes start at 0.  
;	If you passed this array then you already know your values.
;	If you use the default BUTTONS array then 
;		   0 if "YES" was selected
;	           1 if "NO" was selected
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	None.
;
; Common      :	RESPOND_WIDGET
;
; Restrictions:	
;	Must have X windows device.
;
; Side effects:	None.
;
; Category    :	Utilities, User_interaction
;
; Prev. Hist. :	
;	FEB 1993 - Elaine Einfalt (HSTX)
;
; Written     :	Elaine Einfalt, GSFC (HSTX), February 1993
;
; Modified    :	Version 1, Elaine Einfalt, GSFC (HSTX), February 1993
;
; Version     :	Version 1, February 1993
;
; Version     : Version 2, July 1996 - Richard Schwartz (added xoffset and yoffset keywords)
;	      : June 2004 - einfalt - moved the /modal from xmanager to base
;				      via the routine WIDGET_MBASE 
;-


pro respond_event, event             	; the event handler for RESPOND_WIDG
common respond_widget, result

;
; Only two things could have happen : 
;    1) the user click on one of the default buttons (YES or NO)
;    2) the user click on one of the user determined buttons
;
 widget_control, event.id, get_uvalue=input     ; which was clicked

 result = long(input)				; this button was clicked

 widget_control, event.top, /destroy            ; get rid of widget

return
end



function respond_widg, message=message, buttons=buttons, title=title, $
		       xoffset=xoffset, yoffset=yoffset, $
		       column=column, row=row, group_leader=group

common respond_widget, result

result = -1
if n_elements(title) eq 0 then title='Use mouse to choose'	

if keyword_set(column) then rows = 0 else rows=1
if keyword_set(row) then rows = 1
if keyword_set(xoffset) then xoffset=xoffset(0) else xoffset=0
if keyword_set(yoffset) then yoffset=yoffset(0) else yoffset=0

mess_loop = n_elements(message)-1   &  if mess_loop eq -1 then begin
					  message = 'Respond YES or NO '	
					  mess_loop = 0
				       endif

if not keyword_set(buttons) then but_names = [' YES ', '  NO '] $ ; defaults
			    else but_names = buttons	          ; user's

but_loop = n_elements(but_names)   &  but_junk = lonarr(but_loop)

;
; Create widget with a message and as many buttons as in the array BUTTONS,
; the only action possible will be to press one of these BUTTONS.
;

  if rows then base = widget_mbase(title=title, /row, /modal,     $
		    			xoffset=xoffset, $
					yoffset=yoffset, $
					xpad=25, ypad=25, space=20) $
	  else base = widget_mbase(title=title, /column, /modal, $
		    			xoffset=xoffset, $
					yoffset=yoffset, $
					xpad=25, ypad=25, space=20)


	label = widget_base(base, /column)	; the message is written
						; in a column, regardless.
	for i = 0, mess_loop do lab = widget_label(label, value=message(i))

	for i = 0, but_loop-1 do  $
		but_junk(i) = widget_button(base, value=but_names(i), $
						  uvalue=strtrim(i))

	widget_control, base, /realize
	xmanager, 'respond', base, group_leader=group 

return, result
end
