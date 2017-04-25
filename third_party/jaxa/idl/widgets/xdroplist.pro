;+
; Name: xdroplist
;
; Purpose: Function to select an item from a droplist widget.
;
; Calling sequence:  list = xdroplist (items)
;
; Input arguments:
;   items - string array of items for droplist selection
;
; Keywords:
;   initial - index into items of initial selection
;   index - if set, return index of selection, otherwise return string
;   title - title of widget
;   label - label in front of droplist widget
;   group - widget id of calling widget
;   cancel - set to 1 if user pressed cancel button
;
; Output:
;   Function returns item selected (as index if index keyword set).
;
; Written:  Kim Tolbert, 12/3/00
; Modifications: 
;   22-Apr-2001, Kim. Added cancel keyword
;-
;===========================================================================


pro xdroplist_event, event

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

exit = 0
case uvalue of
	'select': begin
		*state.ptr = event.index
		end

	'cancel': begin
		*state.ptr = state.initial
		*state.ptr_cancel = 1
		exit = 1
		end

	'accept': exit = 1

endcase


if exit then widget_control, event.top, /destroy else $
	widget_control, event.top, set_uvalue=state

end

;------------

function xdroplist, items, $
	initial=initial, $
	index=index, $
	title=title, $
	label=label, $
	group=group, $
	cancel=cancel

if n_elements(items) eq 0 then begin
	message,'Syntax:  list = xdroplist(items)', /cont
	return, -1
endif

if size(items,/tname) ne 'STRING' then begin
	message, 'Items must be of type STRING.', /cont
	return, -1
endif

if exist(initial) then if initial gt n_elements(items)-1 then begin
	message,'Initial selection must be within array indices of items.', /cont
	return, -1
endif

checkvar, initial, 0
checkvar, index, 0
checkvar, title, 'Selection Widget'
checkvar, label, 'Select from List: '

w_base = widget_base (group=group, $
					/column, $
					title=title, $
					/frame, space=10, modal = exist(group))

tmp = widget_droplist ( w_base, $
					value=items, $
					title=label, $
					uvalue='select' )
widget_control, tmp, set_droplist_select=initial

w_buttons = widget_base (w_base, /row, space=30, /align_center)
tmp = widget_button (w_buttons, value='Cancel', uvalue='cancel')
tmp = widget_button (w_buttons, value='Accept', uvalue='accept')

; pointer to store output value in so we can get it after widget is destroyed

state = {w_base: w_base, $
	items: items, $
	initial: initial, $
	ptr: ptr_new(initial), $
	ptr_cancel: ptr_new(0) }

if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=w_base
	widget_control, w_base, xoffset=xoffset, yoffset=yoffset
endif

widget_control, w_base, /realize

widget_control, w_base, set_uvalue=state

xmanager, 'xdroplist', w_base;, /no_block

item_sel = *state.ptr
cancel = *state.ptr_cancel
ptr_free, state.ptr, state.ptr_cancel

if index then return, item_sel else return, items[item_sel]

end
