;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: cw_energy_range
;
; PURPOSE: Create a compound widget that allows users to select an energy range.
;	User can enter low or high energy independently (either by choosing from a
;	droplist or by typing text, or can choose low and high from a standard set of
;	energy ranges.
;	Widget_control can be called with set_value and get_value, just as with simple
;	widgets.
;	Generates an event (described below) that the calling program can respond to.
;
; CATEGORY: HESSI WIDGETS
;
; CALLING SEQUENCE:
;	widget_id = cw_energy_range ( parent, $
;		value=energy_range, $
;		uvalue='energy_range', $
;		_extra=_extra, $
;		help=help )
;
; INPUTS:
;	parent - widget id of widget calling cw_energy_range
;
; OPTIONAL INPUTS (KEYWORDS):
;	value - initial energy range as fltarr(2)
;	uvalue - user value to assign to compound widget
;	_extra - any other keywords - will get passed to widget_base of compound widget
;	help - if set, just lists this header documentation
;
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
;	{ id: 0L, top: 0L, handler: 0L, value:fltarr(2) }
;
;
; EXAMPLES:
;
; HISTORY:
;	Kim Tolbert, rewrote hsi_cw_energy_range to make it general
;
;-
;============================================================================



;-- This procedure is called when widget_control, id, set_value=xxx is called

pro cw_energy_range_set_value, id, value

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

widget_control, state.w_energy_range, set_value=value
state.value = value

widget_control, stash, set_uvalue=state, /no_copy

end


;-- This function is called when widget_control, id, get_value=xxx is called

function cw_energy_range_get_value, id

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

widget_control, state.w_energy_range, get_value=value

state.value = value

widget_control, stash, set_uvalue=state, /no_copy

return, value

end

;--- Event handler for compound widget

function cw_energy_range_event, event

error = 0

;help,event,/st
;print,'error = ', error

base = event.handler
stash =  widget_info(base, /child)

widget_control, stash, get_uvalue=state
old_value = state.value

widget_control, event.id, get_uvalue=uvalue
;print,'uvalue=',uvalue

widget_control, state.base, get_value=value
state.value = value

if uvalue eq 'choices' then begin
	if event.index ne 0 then state.value = state.choices[*,event.index]
	widget_control, state.w_choices, set_droplist_select=0
endif

widget_control, state.base, set_value=state.value

if total(state.value - old_value) ne 0. then ret = {id: base, top: event.top, handler: 0L, value: state.value}

widget_control, stash, set_uvalue = state

;stop, 'end of event handler'
return,ret

end

;--------------


function cw_energy_range, parent, $
	ch_energy=ch_energy, $
	uvalue=uvalue, $
	value=value, $
	_extra=_extra, $
	help=help

if keyword_set( help ) then begin
    doc_menu, 'cw_energy_range'
    return, 0
end

checkvar, value, [6., 100.]
checkvar, uvalue, 0
checkvar, ch_energy, [1.,10.,100.,1000.]
format = '(f12.1)'

choices = [ [0.,0.], [get_edge_products(ch_energy, /edges_2)] ]
choices_str = 'Standard: '
for i = 1,n_elements(choices(0,*))-1 do $
	choices_str = [choices_str, $
		strtrim(string(choices[0,i], format='(f8.0)'), 2) + ' - ' + $
		strtrim(string(choices[1,i], format='(f8.0)'), 2) ]

; user value uval passed directly to the base
base = widget_base( parent, $
                    event_func='cw_energy_range_event', $
                    func_get_value = "cw_energy_range_get_value", $
					pro_set_value = "cw_energy_range_set_value", $
                    uvalue=uvalue, $
                    _extra=_extra, $
                    /column, $
                    /base_align_left, $
                    space=0, $
                    xpad=0, $
                    ypad=0, $
                    /frame )

;w_label = widget_label (base, /align_center, value='Note: Energy range of 0. - 0. means use full energy range available.')

;dummy = widget_base (base)

base1 = widget_base (base, /row)

w_energy_range = cw_range ( base1, $
					label1='Energy Range (keV)  Low: ', $
					label2='High: ', $
					value=value, $
					format=format, $
					dropvals1 = trim(choices[0,1:*]), $
					dropvals2 = trim(choices[1,1:*]), $
					uvalue='energy_range', $
					xsize=7 )

base2 = widget_base ( base1, /align_center, /column)

w_choices = widget_droplist ( base2, $
					value=choices_str, $
					uvalue='choices' )

state = { base: base, $
		w_energy_range: w_energy_range, $
		w_choices: w_choices, $
		choices: choices, $
		value: value }

widget_control, widget_info( base, /child ), set_uvalue=state

return, base

end
