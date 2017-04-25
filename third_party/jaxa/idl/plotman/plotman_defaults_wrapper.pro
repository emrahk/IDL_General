;+
; Name: plotman_defaults_wrapper
;
; Purpose: A wrapper for calling widgets in plotman so that if we're setting default options,
;  we can draw a red or green box in front each widget that will allow users to control which
;  options will be applied.
;  If we're not setting defaults, then the widgets just get drawn normally.
;
;  An option is given a green button if it already has a default value (its'in the string
;  array defaults.def_names). All the red options are initially grayed out.  When the user
;  clicks a red box, it turns green and the widget becomes sensitive and the user can set a value.
;
;  For setting defaults:
;  1. The uname contains a string array of all the parameters that should be
;	set when the button is green.
;  2. The uvalue of the green/red button widget is a structure containing the widget id
;	of the plot option it is associated with, and the current state (red or green)
;  3. green_wid (in the defaults structure) is an array for accumulating the option
;	widgets that are active.
;  4. On exiting plotman::options, plotman_defaults_getvals is called to loop through
;	all the green options, and construct a structure of plotman option names and values.
;   The names were stored in the uname of the widget, and the values are retrieved from
;   the plotman object (since they've already been set at this point).


;-----

; This only does something when a red/green button was pressed (that's the only case
; we'll have a structure as a uvalue).
; If the button was red (uvalue.state eq 0), it is changed to green, and the widget id
; of the corresponding option widget is appended to the green_wid array.
; If the button was green, it is changed to red, and the widget id of the corresponding
; option is removed from the green_wid array.
; It passes back a uvalue of 'donothing' so the calling routine can just continue with
; that uvalue.

pro plotman_defaults_event, state, event, new_uvalue

widget_control, event.id, get_uvalue=uvalue

if is_struct(uvalue) then begin
	new_uvalue = 'donothing'
	if xalive(uvalue.wid) then begin
		green_wid = *state.defaults.green_wid
		if uvalue.state eq 0 then begin
			uvalue.state=1
			widget_control, event.id, set_value=state.defaults.green_bmp, set_uvalue=uvalue
			widget_control, uvalue.wid, /sensitive
			green_wid = append_arr(green_wid, uvalue.wid)
		endif else begin
			uvalue.state=0
			widget_control, event.id, set_value=state.defaults.red_bmp, set_uvalue=uvalue
			widget_control, uvalue.wid, sensitive=0
			ind = rem_elem(green_wid, uvalue.wid, count)
			green_wid = count gt 0 ? green_wid[ind] : -1
		endelse
		*state.defaults.green_wid = green_wid
	endif
endif

end

;-----

; make a structure from all of the green options.  The uname contains a string
; array of the tag names to include, and for each tag, get the current value
; out of plotman object.

function plotman_defaults_getvals, state, status=status

status = 1
struct = -1
green_wid = *state.defaults.green_wid
ind = rem_elem(green_wid, -1, count)
if count gt 0 then begin
	green_wid = green_wid[ind]
	; for each green widget, get the corresponding parameter name(s) that we want to
	; set.  If blank, that's a problem.  Otherwise loop through names to set,
	; getting current value from obj, and building a structure with the names and values.
	for i=0,count-1 do begin
		param = str2arr(widget_info(green_wid[i], /uname), ',')
		if param[0] eq '' then begin
			widget_control, green_wid[i], get_uvalue=uvalue
			message,'uname mising. Unable to set default for ' + uvalue, /cont
		endif else begin
			for j=0,n_elements(param)-1 do begin
				if param[j] ne 'none' then begin
					a = execute ('val = state.obj -> get(/' + param[j] + ')')
					struct = rep_tag_value (struct, val, param[j])
				endif
			endfor
		endelse
		status = is_struct(struct)
	endfor
endif

return, struct

end

;-----

; If not doing defaults, just create widgets as normal.
; Otherwise, draw green (if option already has a default value) or red button
; next to each widget. If red, de-sensitize the widget.
;
; Input Arguments:
;  defaults - structure from plotman::options
;  pro_name - widget function to call (e.g. 'widget_button' or widget_droplist')
;  base - base for widget
;  vals - some widget functions need an array of values (like cw_bgroup)
;  sensitive - some widgets need to control sensitivity regardless of green/red status
;  uname - uname to associate with widget
;
; Output - the widget id of the widget created (not the green/red button - we don't save
;  the ids for them)
;
; 10-oct-2007 - added vals, cw_bgroup call has a names array that's not a keyword

function plotman_defaults_wrapper, defaults, $
	pro_name, base,  vals, sensitive=sensitive, uname=uname, _extra=_extra

if defaults.do_def then begin
	uname_arr = str2arr(uname, ',')
	green = is_member(uname_arr[0], defaults.def_names) gt 0
	bmp = green ? defaults.green_bmp : defaults.red_bmp

	wsel = widget_button (base, $
		value=bmp, $
		/align_center, uname='redgreen')
endif

if exist(vals) then w = call_function(pro_name, base, vals, uname=uname, _extra=_extra) else $
	w = call_function(pro_name, base, uname=uname, _extra=_extra)
if exist(sensitive) then widget_control,w, sensitive=sensitive

if defaults.do_def then begin
	widget_control, wsel, set_uvalue={wid:w, state:green}
	widget_control, w, sensitive=green
	if green then *defaults.green_wid = append_arr(*defaults.green_wid, w)
endif

return,w
end
