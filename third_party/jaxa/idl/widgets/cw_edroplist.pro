;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: cw_edroplist
;
; PURPOSE: Create a compound widget that is an editable droplist widget,
;	i.e. the contents of the text field can be changed by typing, or by selecting
;	from a droplist. After editing the text, the user can press enter, but doesn't
;	have to; since kbrd_focus_events is enabled, as soon as any other button is
;	clicked, an event is generated and the new value is saved.  Option to add user's
;	new value to droplist values, sorted or not.
;	Widget_control can be called with set_value and get_value, just as with simple
;	widgets.
;	Generates an event (described below) that the calling program can respond to.
;
;	Note: A current limitation is that if droplist is long, no scrollbars.  So entire
;		list needs to fit on screen.  This is because using buttons for droplist instead
;		of a real widget_droplist or widget_list for lots of reasons.
;
; CATEGORY: WIDGETS
;
; CALLING SEQUENCE:
;	widget_id = cw_edroplist (parent, $
;		value=value, $
;		format=format, $
;		xsize=xsize, $
;		label=label, $
;		_extra=_extra, $
;		drop_values=drop_values, $
;		uvalue=uvalue, $
;		append=append, $
;		sortdrop=sortdrop, $
;		help=help)
;
; INPUTS:
;	parent - widget id of widget calling cw_edroplist
;
; OPTIONAL INPUTS (KEYWORDS):
;	value - initial value of text
;	format - string containing format to display value in, .e.g. '(f10.2)'
;	xsize - xsize of editable text field
;	label - Text that will be placed to left of editable text field
;	_extra - any other keywords - will get passed to widget_base of compound widget
;	drop_values - values to put in droplist (will be display with same format).  If
;		drop_values is not present, then no droplist is attached to text widget.
;	uvalue - user value to assign to compound widget
;	append - if set, appends user-typed values to droplist
;	sortdrop - 1 means sort appended droplist in ascending order, 2 means descending order
;	help - if set, just lists this header documentation
;
; OUTPUTS:
;	Function value returned is widget id of compound widget.
;
; OPTIONAL OUTPUTS:  None
;
; Calls:
;
; COMMON BLOCKS: None
;
; PROCEDURE:
;
; RESTRICTIONS: None
;
; SIDE EFFECTS: Generates an event with the following structure:
;	{ id: 0L, top: 0L, handler: 0L, value:0. or 0}
;
; EXAMPLES:
;	widget_id = cw_edroplist ( base, $
;		value=2, $
;		format='(i5)', $
;		drop_values=[1,2,4,8,16,32,64,128], $
;		label='Enter value:', $
;		uvalue='max', $
;		xsize=6)
;
;	widget_control, widget_id, set_value=5
;	widget_control, widget_id, get_value=val
;
;
; HISTORY:
;	Kim Tolbert, Nov 1999
;       30-Mar-2001, Kim, In set_value, check if value is a STRING variable
;		30-Aug-2001, Kim, Use same_data function to decide whether to generate an event
;          (previously used total of diff ne 0, but didn't work for strings)
;   06-Aug-2009, Kim. w_but and drop_values in state didn't need to be pointers. Resulted in
;          memory leak.  
;
;-
;============================================================================
; SAMPLE PROGRAM:
;	 pro test_cw_event, event
;
;	 widget_control, event.id, get_uvalue=uvalue
;
;	 case uvalue of
;	     'low': print,'Low value = ', event.value
;	     'exit': widget_control, event.top, /destroy
;	 endcase
;	 end
;
;	 pro test_cw
;
;	 base = widget_base  (/column)
;
;	 w_low = cw_edroplist ( base, $
;	                     label='Low value: ', $
;	                     value=1., $
;	                     format='(f10.2)', $
;	                     drop_values=findgen(10), $
;	                     uvalue='low', $
;	                     xsize=10, $
;						 /append, $
;						 /sort )
;
;	 w_exit = widget_button (base, $
;	                     value='exit', $
;	                     uvalue='exit')
;
;	 widget_control, base, /realize
;	 xmanager, 'test_cw', base
;	 end
; END OF SAMPLE PROGRAM


;-- This procedure is called when widget_control, id, set_value=xxx is called

pro cw_edroplist_set_value, id, value

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

if size(value,/tname) eq 'STRING' then begin
	state.value = -99
	svalue = strtrim(value,2)
endif else begin
	state.value = value
	svalue=strtrim( string(value,format=state.format), 2 )
endelse
widget_control, state.w_text, set_val=svalue

widget_control, stash, set_uvalue=state, /no_copy

end


;-- This function is called when widget_control, id, get_value=xxx is called

function cw_edroplist_get_value, id

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

ret = state.value
widget_control, stash, set_uvalue=state, /no_copy

return, ret

end


;--- Event handler for compound widget

function cw_edroplist_event, event

base = event.handler
stash = widget_info (base, /child)

widget_control, stash, get_uvalue=state
old_value = state.value

widget_control, event.id, get_uvalue=uvalue

case uvalue of
	'text':  begin
		if tag_exist (event, 'ENTER') then if event.enter eq 1 then return, 0
		widget_control, event.id, get_value=value
		state.value=value

		if xalive(state.w_drop) and state.append then begin
			string_value = strtrim( string(value,format=state.format), 2 )
			drop_values = state.drop_values
			if (where (string_value eq drop_values))(0) eq -1 then begin
				drop_values = [drop_values, string_value]
				case state.sortdrop of
					0:
					1: drop_values = drop_values [sort (drop_values) ]
					2: drop_values = drop_values [reverse (sort (drop_values) ) ]
					else:
				endcase
				w_but = state.w_but
				for i = 0,n_elements(w_but)-1 do widget_control, w_but(i), /destroy
				w_but = lonarr( n_elements(drop_values) )
				for i = 0,n_elements(drop_values)-1 do begin
					w_but(i) = widget_button ( state.w_drop, $
						value=strtrim ( string (drop_values(i), format=state.format), 2), $
						uvalue='drop' )
				endfor

;				*state.w_but = w_but
;				*state.drop_values = drop_values
				state = rem_tag(state, ['w_but','drop_values'])
				state = add_tag(state, w_but, 'w_but')
				state = add_tag(state, drop_values, 'drop_values')

			endif
     endif
		end

	'drop': begin
		widget_control, event.id, get_value=value
		state.value = value
		widget_control, state.w_text, set_value=strtrim( string(state.value,format=state.format), 2 )
		end
endcase


;if total(state.value - old_value) ne 0. then ret = { id: base, top: event.top, handler: event.handler, value:state.value }
if not same_data(state.value, old_value) then ret = { id: base, top: event.top, handler: event.handler, value:state.value }
widget_control, stash, set_uvalue=state

return, ret
end

;-----

function cw_edroplist, parent, $
	value=value, $
	format=format, $
	xsize=xsize, $
	label=label, $
	_extra=_extra, $
	drop_values=drop_values, $
	uvalue=uvalue, $
	help=help, $
	append=append, $
	sortdrop=sortdrop

if keyword_set( help ) then begin
    doc_menu, 'cw_edroplist'
    return, 0
end

checkvar, append, 0
checkvar, sortdrop, 0
checkvar, xsize, 10
checkvar, value, '1'
checkvar, uvalue, 0
checkvar, label, ''
checkvar, format, '(i12)'

if keyword_set( drop_values ) then use_drop = 1 else use_drop = 0

base = widget_base( parent, $
                    event_func='cw_edroplist_event', $
                    func_get_value = 'cw_edroplist_get_value', $
					pro_set_value = 'cw_edroplist_set_value', $
                    uvalue=uvalue, $
                    /row, $
                    _extra=_extra )

label = widget_label ( base, $
					value=label)

w_text = widget_text ( base, $
					value=strtrim( string(value,format=format), 2 ), $
					uvalue='text', $
					/editable, $
					xsize=xsize, $
					/kbrd_focus_events )

if use_drop then begin
	if os_family() eq 'Windows' then begin
		if since_version('5.4') then xs = .15 else xs = .02
	endif else xs = .15
	w_drop = widget_button ( base, $
						/menu, $
						value='^', $
						;font='Webdings', $
						units=1, $
						xsize=xs )

	w_but = lonarr( n_elements(drop_values) )
	for i = 0,n_elements(drop_values)-1 $
		do w_but(i) = widget_button ( w_drop, $
						value=strtrim( string(drop_values[i],format=format), 2 ), $
						uvalue='drop' )
endif else begin
  w_drop = 0L
  w_but = 0L
  drop_values = 0
endelse

;widget_control, w_drop, set_value=bitmap_array, /bitmap, x_bitmap_extra=1

state = { base: base, $
		w_text: w_text, $
		w_drop: w_drop, $
		w_but: w_but, $
		drop_values: drop_values, $
		value: value, $
		format: format, $
		append: append, $
		sortdrop: sortdrop }

widget_control, widget_info( base, /child ), set_uvalue=state


return, base
end



