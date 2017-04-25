;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: cw_ut_range
;
; PURPOSE: Create a compound widget that allows users to set a start and end time.
;	Widget consists of buttons for entering a date/time selection widget, text fields
;	for entering start/end times directly, and a duration text field.  Changing the
;	duration will change the end time
;	only.
;	Widget_control can be called with set_value and get_value, just as with simple
;	widgets.
;	Generates an event (described below) that the calling program can respond to.
;
; CATEGORY: HESSI WIDGETS
;
; CALLING SEQUENCE:
;	widget_id = cw_ut_range ( parent, $
;		value=time_range, $
;		uvalue='time_range', $
;		label='Time Range: ', $
;		_extra=_extra, $
;		help=help )
;
; INPUTS:
;	parent - widget id of widget calling cw_ut_range
;
; OPTIONAL INPUTS (KEYWORDS):
;	value - initial start/end times as 2-element array of r*8 seconds since 79/1/1
;	uvalue - user value to assign to compound widget
;	label - Label that is displayed to left of buttons and text widgets
;	oneline - if set, put start and end across in one line instead in a column
;	narrow - if set, make widget narrower (put duration under times instead of beside)
;	nodur - if set, don't show duration widget
;	noreset - if set, don't show reset buttons for start and end times
;	nomsec - if set, show times without the msec part
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
;	{ id: 0L, top: 0L, handler: 0L, value:dblarr(2) }
;
;
; EXAMPLES:
;
; HISTORY:
;	Kim Tolbert, 2-Mar-03 (extracted from hsi_cw_ut_range and made general
;		by removing the rotation stuff specific to hessi)
;	Kim, 28-May-2004.  Protected against input value being -1 (no original
;		intervals).  If so, or value not passed, set to [0.,1.]
;   Kim, 14-Apr-2005, Don't use format for dur string, just use trim.
;	Kim, 6-May-2005, In twidget (dial-a-date) allow years 1980-2020 instead of 1990-2020
;	Kim, 9-Jan-2006, Added nextprev keyword, and if set, then add Next and Previous
;	    buttons to jump to next or previous duration period.
; Kim. 10-Aug-2008, Removed test for relative values (always interpret as time
;     instead of printing blanks).  Needed for using old goes data < 1979 (negative times!)
; Kim, 20-Jan-2010, If end time < start time, make start=end-dur. Previously got negative dur.
; Kim, 21-Mar-2010, Tried to make widget more compact - removed frame on start,end buttons, 
;  changed from Start... to Start, shortened Duration (s) to Dur(s)
; Kim, 15-Jun-2013, In get_value return string time instead of sec (so will work for environments
;  that use utc/tai like show_synop. Must pass in times as string or structure too). If error
;  converting string time, print error msg and don't set times to anything. Don't 
;  make label base if label is ''.
;-
;============================================================================



;-- This procedure is called when widget_control, id, set_value=xxx is called

pro cw_ut_range_set_value, id, value

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

state.value = anytim( value, /sec)
dur = state.value[1] - state.value[0]

; if time < 3.e7 (~1980/1/1), then probably is a relative time, not absolute, so print blanks
;if value[0] gt 3.e7 then $
;	stime = anytim( value[0], /vms, truncate=state.nomsec ) else $
;	stime = string(bytarr(23) + 32b)
stime = anytim( value[0], /vms, truncate=state.nomsec )
widget_control, state.w_start_text, set_val=stime

; if time < 3.e7 (~1980/1/1), then probably is a relative time, not absolute, so print blanks
;if value[1] gt 3.e7 then $
;	etime = anytim( value[1], /vms, truncate=state.nomsec ) else $
;	etime = string(bytarr(23) + 32b)
etime = anytim( value[1], /vms, truncate=state.nomsec )	
widget_control, state.w_end_text, set_val=etime

if xalive(state.w_dur) then $
	;widget_control, state.w_dur, set_val=string( dur, format=state.format )
	widget_control, state.w_dur, set_val=trim(dur)

widget_control, stash, set_uvalue=state, /no_copy

end


;-- This function is called when widget_control, id, get_value=xxx is called

function cw_ut_range_get_value, id

stash = widget_info ( id, /child )
widget_control, stash, get_uvalue=state, /no_copy

widget_control, state.w_start_text, get_value=time1
widget_control, state.w_end_text, get_value=time2
times = anytim( [time1, time2], /sec, error=error )
ret = state.value
if error eq 0 then begin
  state.value = times
  ret = times
endif else message, 'Invalid time format. Valid format example: 01-jan-2013 01:20:30', /cont
widget_control, stash, set_uvalue=state, /no_copy

return, anytim(ret,/vms)

end


;--- Event handler for compound widget

function cw_ut_range_event, event


; when user changes text in tstarttime, tendtime, or duration text fields, only
; generates an event when user presses return, or when user clicks on a different widget,
; so if event.enter is 1, just return.  Only do something if event.enter=0.

struct_name = tag_names (event, /struct)
if struct_name eq 'WIDGET_KBRD_FOCUS' then if event.enter eq 1 then return, 0


;help,event,/st

base = event.handler
stash =  widget_info(base, /child)

widget_control, stash, get_uvalue=state
old_value = state.value
dur = old_value[1] - old_value[0]

widget_control, event.id, get_uvalue=uvalue
;print,'uvalue=',uvalue

; retrieve current value of start and end time in 'value'
widget_control, state.base, get_value=value
value = anytim(value)  ; value is returned as string now (6/15/2013) so convert to sec

state.value = value
err_msg = ''

case uvalue of

	'tstarttime': begin
		state.value[1] = state.value[0] + dur
		end

	'duration': begin
		widget_control, event.id, get_value=dur
		if dur(0) le 0. then err_msg = 'Invalid duration.  Must be > 0.'
		if err_msg eq '' then state.value[1] = value[0] + dur
		end

	'wstarttime': begin
		twidget, time_init=value[0], /init
		twidget, rdate, outsec=outsec, /all, year=[1980,2020], error=error, $
			message='Select Start Time', /nowild, group_leader=event.top
		if not error then begin
			state.value[0] = outsec
			state.value[1] = state.value[0] + dur
		endif
		end

	'wendtime': begin
		twidget, time_init=value[1], /init
		twidget, rdate, outsec=outsec, /all, year=[1980,2020], error=error, $
			message='Select End Time', /nowild, group_leader=event.top
		if not error then state.value[1] = outsec
		end
    
	'sreset': begin
		state.value[0] = state.orig_value[0]
		state.value[1] = state.value[0] + dur
		end

	'ereset': begin
		state.value[1] = state.orig_value[1]
		end

	'next': state.value = state.value + (state.value[1]-state.value[0])

	'previous': state.value = state.value - (state.value[1]-state.value[0])

	else: ; handles tendtime
endcase

if state.value[1] lt state.value[0] then state.value[0] = state.value[1] - dur

if err_msg ne '' then begin
	xmessage,['Error in times selected.', $
		' ', $
		err_msg], $
		/register, group=event.top, xoff=50, yoff=50
endif

widget_control, state.base, set_value=state.value

; only generate an event if time range has changed.
if total(abs(state.value - old_value)) ne 0. then ret = {id: base, top: event.top, handler: 0L, value: state.value}

widget_control, stash, set_uvalue = state

;stop, 'end of event handler'
return,ret

end

;--------------


function cw_ut_range, parent, $
	uvalue=uvalue, $
	label=label, $
	value=value, $
	oneline=oneline, $
	narrow=narrow, $
	nodur=nodur, $
	noreset=noreset, $
	nomsec=nomsec, $
	nextprev=nextprev, $
	_extra=_extra, $
	help=help


if keyword_set( help ) then begin
    doc_menu, 'cw_ut_range'
    return, 0
end

checkvar, label, 'Time Range: '
checkvar, value, -1
if value[0] eq -1 then value = [0.,1.]	; if no intervals set to anything
value = anytim(value) ; make sure it's seconds
checkvar, nomsec, 0
checkvar, uvalue, 0
;format = '(f9.3)'

; user value uval passed directly to the base
base = widget_base( parent, $
                    event_func='cw_ut_range_event', $
                    func_get_value = "cw_ut_range_get_value", $
                    pro_set_value = "cw_ut_range_set_value", $
                    uvalue=uvalue, $
                    _extra=_extra, $
                    /column, $
                    /base_align_left, $
                    space=0, $
                    xpad=0, $
                    ypad=0, $
                    /frame )

base0 = widget_base (base, /column)

base1 = widget_base ( base0, /row)

if label ne '' then begin
  base_label = widget_base ( base1, $
					  /column, $
					  /align_center )

  w_label = widget_label ( base_label, $
	  				value=label )
endif

base_vals = widget_base ( base1, $
					/column )

base_stimes = widget_base( base_vals, $
					/row, $
					space=3, ypad=0 )

w_start_button = widget_button ( base_stimes, $
					value='Start', $
					uvalue='wstarttime')

stime_st = anytim (value[0], /vms, truncate=nomsec )
w_start_text = widget_text ( base_stimes, $
					value = stime_st, $
					xsize = strlen ( stime_st ), $
					uvalue = 'tstarttime', $
					/editable, $
					/kbrd_focus_events )

if not keyword_set(noreset) then $
	w_start_reset = widget_button ( base_stimes, $
					value = 'Reset', $
					uvalue = 'sreset')

if keyword_set(oneline) then base_etimes = base_stimes else $
	base_etimes = widget_base( base_vals, $
					/row, $
					space=3, ypad=0 )

w_end_button = widget_button ( base_etimes, $
					value='End', $
					uvalue='wendtime')

etime_st = anytim (value[1], /vms, truncate=nomsec )
w_end_text = widget_text ( base_etimes, $
					value = etime_st, $
					xsize=strlen ( etime_st ), $
					uvalue = 'tendtime', $
					/editable, $
					/kbrd_focus_events )

if not keyword_set(noreset) then $
	w_end_reset = widget_button ( base_etimes, $
					value = 'Reset', $
					uvalue = 'ereset')

if not keyword_set(nodur) then begin

	if keyword_set(narrow) then base_durrot = widget_base (base, /row ) else $
		base_durrot = widget_base (base1, /column )

	dur_base = widget_base (base_durrot, /row)

	label = widget_label (dur_base, $
						value='Dur(s):')

	dur = value[1] - value[0]
	w_dur = widget_text ( dur_base, $
						;value=string (dur, format=format), $
						value=trim(dur), $
						xsize=10, $
						uvalue='duration', $
						/editable, $
						/kbrd_focus_events )
endif else w_dur = 0L

if keyword_set(nextprev) then begin
	if not exist(base_durrot) then base_durrot = widget_base(base, /row)
	tmp = widget_button (base_durrot, value='Next', uvalue='next', /align_left)
	tmp = widget_button (base_durrot, value='Previous', uvalue='previous', /align_left)
endif

state = { base: base, $
		w_start_text: w_start_text, $
		w_end_text: w_end_text, $
		w_dur: w_dur, $
		;format: format, $
		nomsec: nomsec, $
		orig_value: value, $
		value: value }

widget_control, widget_info( base, /child ), set_uvalue=state

return, base

end



