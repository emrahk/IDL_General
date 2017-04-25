;+
; Name: xsel_list_multi
;
; Purpose: Function to select one or more item(s) from one or two list widget(s).  User can use
;   shift and control keys to select multiple items from the list.
;
; Calling sequence:  list = xsel_list_multi (items)
;
; Input arguments:
;   items - string array of items for selection
;
; Keywords (NOTE: n2_... parameters are for a second list widget with a second set of
;   options for user to choose):
;   initial - index into items of initial selection
;   index - if set, return index of selection(s), otherwise return string
;   title - title of widget
;   label - label above list widget
;   n2_items - string array of items for selection from second list
;   n2_initial - index into items of initial selection for second list
;   n2_index - if set, return index of selection(s), otherwise return string from second list
;   n2_label - label above list widget for second list
;   n2_item_sel - item selected in second list widget (as index if n2_index keyword set)
;   group - widget id of calling widget
;   cancel - set to 1 if user pressed cancel button
;
; Output:
;   Function returns item selected in first list widget (as index if index keyword set).
;
; Example:
;  This example makes two lists, returns the choice from the first list as an index into the list1 array
;  in the output value ind, and returns the choice from the second list as a string 
;  in the variable n2_item_sel.
;  list1 = 'choice '+['1','2','3']
;  list2 = 'second ' + ['1','2','3','4']
;  ind = xsel_list_multi(list1, label='First list:', /index, $
;    n2_items=list2, n2_label='Second list:', n2_initial=[2,3], n2_item_sel=n2_item_sel, $
;    title='Two list widget example')
;   
; Written:  Kim Tolbert, 18-Jul-2002
; Modifications:
;   1-Aug-2002, Kim.  Added xoffset, yoffset keywords
;   14-Feb-2010, Zarro (ADNET), initialized cancel to 0
;   28-Feb-2013, Kim.  Added n2 parameters to allow for a second list of user options
;   11-Mar-2013, Kim.  Added initialization for n2_initial and check to set n2_item_sel only if 
;     n2_items is defined.
;-
;===========================================================================


pro xsel_list_multi_event, event

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

exit = 0
case uvalue of
	'select': begin
		ind = widget_selected(event.id, /index)
		*state.ptr = ind
		end

  'n2_select': begin
    ind = widget_selected(event.id, /index)
    *state.n2_ptr = ind
    end
    
	'cancel': begin
		*state.ptr = state.initial
		*state.n2_ptr = state.n2_initial
		*state.ptr_cancel = 1
		exit = 1
		end

	'accept': exit = 1

endcase


if exit then widget_control, event.top, /destroy else $
	widget_control, event.top, set_uvalue=state

end

;------------
pro xsel_list_multi_listwidget, w_baserow=w_baserow, items=items, label=label, initial=initial, uvalue=uvalue

checkvar, initial, 0
checkvar, label, 'Select from List: '
checkvar, uvalue, 'select'

nitems = n_elements(items)
initial = initial > 0 < (nitems-1)

w_base = widget_base(w_baserow, /column)

tmp = widget_label (w_base, value=label, /align_center)

; On windows, need to define x size of widgets
if os_family() eq 'Windows' then xsize=10+max(strlen(trim(items)))
w_list = widget_list (w_base,  $
          /multiple, $
          /align_center, $
          ysize=nitems < 20, $
          xsize=xsize, $
          value='  ' + trim(items) + '  ', $
          uvalue=uvalue)
widget_control, w_list, set_list_select=initial
end

;------------

function xsel_list_multi, items, $
	initial=initial, $
	index=index, $
	title=title, $
	label=label, $
	n2_items=n2_items, $
	n2_initial=n2_initial, $
	n2_index=n2_index, $
	n2_label=n2_label,$
	n2_item_sel=n2_item_sel, $
	group=group, $
	xoffset=xoffset, $
	yoffset=yoffset, $
	cancel=cancel

cancel=0

if n_elements(items) eq 0 then begin
	message,'Syntax:  list = xsel_list_multi(items)', /cont
	return, -1
endif

if size(items,/tname) ne 'STRING' then begin
	message, 'Items must be of type STRING.', /cont
	return, -1
endif

checkvar, index, 0
checkvar, n2_index, 0
checkvar, n2_initial, 0
checkvar, title, 'Selection Widget'

w_basemain = widget_base (group=group, $
					/column, $
					title=title, $
					/frame, space=10, modal = exist(group), xoffset=xoffset, yoffset=yoffset)
					
tmp = widget_label (w_basemain, value='(Use shift and control keys to select multiple items.)')

w_baserow = widget_base(w_basemain, /row, space=10)

xsel_list_multi_listwidget, w_baserow=w_baserow, items=items, $
  label=label, initial=initial, uvalue='select'

if keyword_set(n2_items) then xsel_list_multi_listwidget, w_baserow=w_baserow, $
  items=n2_items, label=n2_label, initial=n2_initial, uvalue='n2_select'
  
w_buttons = widget_base (w_basemain, /row, space=30, /align_center)
tmp = widget_button (w_buttons, value='Cancel', uvalue='cancel')
tmp = widget_button (w_buttons, value='Accept', uvalue='accept')

; pointer to store output value in so we can get it after widget is destroyed

state = {w_basemain: w_basemain, $
	items: items, $
	initial: initial, $
	n2_initial: n2_initial, $
	ptr: ptr_new(initial), $
	n2_ptr: ptr_new(n2_initial), $
	ptr_cancel: ptr_new(0) }

if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=w_basemain
	widget_control, w_basemain, xoffset=xoffset, yoffset=yoffset
endif

widget_control, w_basemain, /realize

widget_control, w_basemain, set_uvalue=state

xmanager, 'xsel_list_multi', w_basemain;, /no_block

item_sel = *state.ptr
n2_item_sel = *state.n2_ptr
if keyword_set(n2_items) and ~n2_index then n2_item_sel = n2_items[n2_item_sel]

cancel = *state.ptr_cancel
ptr_free, state.ptr, state.n2_ptr, state.ptr_cancel

if index then return, item_sel else return, items[item_sel]

end
