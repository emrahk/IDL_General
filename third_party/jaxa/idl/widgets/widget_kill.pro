;+
; Name: widget_kill
;
; Purpose: Widget interface to allow user to select which widgets to destroy.  Useful if
;	widgets are hung.
;
; Calling sequence:  widget_kill [,group=group]
;
; Input arguments:
;   group - widget id of parent widget (used only for positioning widget)
;
; Method:  Uses xmanager_com to determine the widgets that are currently being managed.  Calls
;	xsel_list_multi to present the list of widget names to the user.  User can select a single or
;	multiple widgets to destroy.  If user clicks cancel, nothing happens.
;
; Restrictions:  xmanager_com assumes the RSI xmanager common has certain variables.  RSI
;	can change this any time they say.
;
; Output:
;   Selected widgets are destroyed.
;
; Written:  Kim Tolbert, 1-Aug-2002
; Modifications:
;-
;===========================================================================

pro widget_kill, group = group

msg_none = 'There are no active widgets currently.'

xmanager_com, ids, names

num = n_elements(ids)
if num gt 0 then begin

	; find out which of currently active widgets are currently being managed
	managed = bytarr(num)
	for i = 0,num-1 do managed[i] = widget_info(ids[i], /managed)

	q = where (managed eq 1, count)
	if count gt 0 then begin
		ids = ids[q]
		names = names[q]

		; if no parent widget, then place this widget 1/3 of the way down and across screen
		if not exist(group) then begin
			device, get_screen_size=scr_size
			xoffset=scr_size[0]/3. & yoffset=scr_size[1]/3.
		endif

		items = ['None', names + '  (widget id: ' + strtrim(ids,2) + ')']
		destroy = xsel_list_multi (items, /index, title='Select widgets', $
			label='Select widgets to be destroyed.   BE CAREFUL!!!', $
			group=group, cancel=cancel, $
			xoffset=xoffset, yoffset=yoffset)
		if not cancel then begin
			destroy = destroy - 1 	; account for the None at the beginning of the list
			if destroy[0] ne -1 then begin
				for i = 0, n_elements(destroy)-1 do widget_control, ids[destroy[i]], /destroy
			endif
		endif
	endif else a = dialog_message (msg_none, /info)

endif else a = dialog_message (msg_none, /info)

end
