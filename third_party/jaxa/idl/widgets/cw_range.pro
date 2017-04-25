;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: cw_range
;
; PURPOSE: Create a compound widget consisting of two editable droplist
;	widgets.  Useful for inputting a range or x,y values or any pair of
;	values.  The widgets are laid out in a row with a label followed by a
;	editable droplist widget followed by another label followed by another
;	editable droplist.  For example:
;		Energy range  Low: xxxxxx^     High: xxxxxx^
;	Widget_control can be called with set_value and get_value, just as with simple
;	widgets.
;	Generates an event (described below) that the calling program can respond to.
;
; CATEGORY: WIDGETS
;
; CALLING SEQUENCE:
;	widget_id = cw_range ( parent, $
;		uvalue=uvalue, $
;		label1=label1, $
;		label2=label2, $
;		value=value, $
;		dropvals1=dropvals1, $
;		dropvals2=dropvals2, $
;		xsize=xsize, $
;		frame=frame, $
;		_extra=_extra, $
;		help=help )
;
; INPUTS:
;	parent - widget id of widget calling cw_range
;
; OPTIONAL INPUTS (KEYWORDS):
;	uvalue - user value to assign to compound widget
;	label1 - Text that will be placed to left of first editable text field
;	label2 - Text that will be placed to left of second editable text field
;	value - 2-element array of initial values
;	dropvals1 - values to put in first droplist
;	dropvals2 - values to put in second droplist
;	Note:  if dropvals1 or dropvals2 is not present, then that widget won't have
;		a droplist, will be just a text widget.
;	xsize - xsize of editable text field
;	frame - if set, draw frame around compound widget
;	_extra - any other keywords - will get passed to widget_base of compound widget
;		and to cw_edroplist
;	help - if set, just lists this header documentation
;
;
; OUTPUTS:
;	Function value returned is widget id of compound widget.
;
; OPTIONAL OUTPUTS:  None
;
; Calls: cw_edroplist
;
; COMMON BLOCKS: None
;
; PROCEDURE:
;
; RESTRICTIONS: None
;
; SIDE EFFECTS: Generates an event with the following structure:
;	{ id: 0L, top: 0L, handler: 0L, value:fltarr(2) or intarr(2) }
;
; EXAMPLES:
;
; HISTORY:
;	Kim Tolbert, Nov 1999
;   26-Aug-2007, Kim.  Added uname keyword to pass to widget_base
;
;-
;============================================================================

; SAMPLE PROGRAM
;	pro test_cw_event, event
;
;	widget_control, event.id, get_uvalue=uvalue
;
;	case uvalue of
;		'energy_band': print,'Energy range = ', event.value
;		'exit': widget_control, event.top, /destroy
;	endcase
;	end
;
;	pro test_cw
;
;	base = widget_base  (/column)
;
;	w_energy = cw_range (base, $
;						label1='Energy Range (keV)  Low: ', $
;						label2='High: ', $
;						value=[6.,20.], $
;						format='(f12.1)', $
;						dropvals1=[6.,10.,20.,40.,60.,80.,100.], $
;						dropvals2=[6.,10.,20.,40.,60.,80.,100.], $
;						uvalue='energy_band', $
;						xsize=7, $
;						/frame)
;
;	w_exit = widget_button (base, $
;						value='exit', $
;						uvalue='exit')
;
;	widget_control, base, /realize
;	xmanager, 'test_cw', base
;	end
; END OF SAMPLE PROGRAM


;-- This procedure is called when widget_control, id, set_value=xxx is called

pro cw_range_set_value, id, value

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

state.value = value
widget_control, state.w_low, set_value=value[0]
widget_control, state.w_high, set_value=value[1]
widget_control, stash, set_uvalue=state, /no_copy

end


;-- This function is called when widget_control, id, get_value=xxx is called

function cw_range_get_value, id

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

ret = state.value
widget_control, stash, set_uvalue=state, /no_copy

return, ret

end


;--- Event handler for compound widget


function cw_range_event, event

base = event.handler
stash =  widget_info(base, /child)

widget_control, stash, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

case uvalue of

	'low': begin
		;print,'low = ', event.value
		end

	'high': begin
		;print,'high = ', event.value
		end

endcase

widget_control, state.w_low, get_value = val1
widget_control, state.w_high, get_value = val2
state.value = [val1, val2]

ret = {id: base, top: event.top, handler: event.handler, value: state.value}
widget_control, stash, set_uvalue = state

return, ret

end

;--------------


function cw_range, parent, $
	uvalue=uvalue, $
	label1=label1, $
	label2=label2, $
	value=value, $
	dropvals1=dropvals1, $
	dropvals2=dropvals2, $
	xsize=xsize, $
	frame=frame, $
	uname=uname, $
	_extra=_extra, $
	help=help


if keyword_set( help ) then begin
    doc_menu, 'cw_range'
    return, 0
end

checkvar, xsize, 10
checkvar, label1, 'Low: '
checkvar, label2, 'High: '
checkvar, value, [1, 10]
checkvar, uvalue, 0

; user value uval passed directly to the base
base = widget_base( parent, $
                    event_func='cw_range_event', $
                    func_get_value = "cw_range_get_value", $
					pro_set_value = "cw_range_set_value", $
                    uvalue=uvalue, $
                    /row, $
                    /base_align_left, $
                    frame=frame, $
                    uname=uname, $
                    _extra=extra )

dummy = widget_base (base, /row, /base_align_left, _extra=extra)

w_low = cw_edroplist ( base, $
					label=label1, $
					value=value[0], $
					drop_values=dropvals1, $
					uvalue='low', $
					xsize=xsize, $
					_extra=_extra )

w_high = cw_edroplist (base, $
					label=label2, $
					value=value[1], $
					drop_values=dropvals2, $
					uvalue='high', $
					xsize=xsize, $
					_extra=_extra )


state = { $
		base: base, $
		w_low: w_low, $
		w_high: w_high, $
		value: value}

widget_control, widget_info( base, /child ), set_uvalue=state

return, base

end



