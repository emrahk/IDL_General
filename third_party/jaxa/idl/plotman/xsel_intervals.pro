; Modifications:
; 8-Nov-2001, Kim.  Changed max # intervals to 2000 from 20.
; 17-Oct-2002, Kim. Changed wording and options for creating multiple bands manually
;  to make it clearer, and add log spaced bins, and dividing range into intervals of
;  a certain length.
; 28-Jan-2003, Kim.  calculations are in double to accomodate times, but causes problem
;  for energy mode when checking if selected edges are within valid_range, so call float
; 02-Mar-2003, Kim.  Added ch_energy and hessi keywords.  If hessi is set, call hsi_cw_ut_range
;  instead of cw_ut_range.  Always call cw_energy_range (it was generalized from
;  hsi_cw_energy_range) and pass it ch_energy as energy choices for widgets.
; 11-Mar-2003, Kim. Added title, show_start, and type keywords, and 'Draw Current' button.
; 16-Mar-2003, Kim. In graphic selection option, previously tried to accumulate and plot
;  the appropriate kind of HESSI data if the right kind of plot isn't already showing.  Now
;  draw a blank plot of the type needed (utplot or xyplot) using the default limits in
;  x and [0,1] in y.  Plotman desc is 'Blank plot' - check if there, and delete when done.
; 19-Mar-2003, Kim.  Renamed to xsel_intervals.  Returns a -1 when cancelled instead of
;  original intervals.
; 2-Jun-2003, Kim.  Changed max # intervals to 10000 from 2000.
; 6-Jun-2003, Kim.  In graphics option, if use blank plot, set force to data boundaries option off.
; 16-Mar-2004, Kim. Return -99 when user presses 'cancel'
; 27-Apr-2006, Kim. Error in delta widget - wouldn't let you set to < 1.
; 7-Jul-2008, Kim. To remove hessi dependencies:
;   Call get_font instead of hsi_ui_getfont.
;   Call hsi_cw_ut_range via call_function.
;	  Call restore_intervals (renamed from hsi_restore_intervals)
;	  Call store_intervals (renamed from hsi_save_intervals)
; 25-Aug-2008, Kim. hsi_store_intervals now called store_intervals
; 04-Aug-2009, Kim. Include stored_intervals_obj in free_var, except if
;   it's in calling arguments (was a memory leak)
; 24-Feb-2010, Kim.  If ch_energy not passed in, make defaults the HESSI ql bands.
; 28-Oct-2013, Kim. Added widget_control/show in several places to make selection widget come to front
; 18-Nov-2013, Kim. cw_ut_range now returns a string, so if what='Time', convert range string to sec

;-----

pro xsel_intervals_event, event

widget_control, event.top, get_uvalue=int_info

widget_control, event.id, get_uvalue=uvalue

exit = 0
reset_uvalue = 1

if stregex(uvalue, '^restore', /boolean) then begin
	restoren = (ssw_strsplit(uvalue,'restore', /tail))[0]
	uvalue='restore'
endif

relist = 0

case uvalue of

	'deletesel': begin
		index = widget_info (int_info.w_list, /droplist_select)
		plotman_modify_int, 'delete', int_info, int_index=index
		relist = 1
		end

	'editsel': begin
		index = widget_info (int_info.w_list, /droplist_select)
		plotman_edit_int, int_index=index, int_info, err_msg=err_msg
		relist = 1
		if err_msg ne '' then reset_uvalue = 0
		end

	'editlist': begin
		plotman_edit_int, int_info, err_msg=err_msg
		relist = 1
		if err_msg ne '' then reset_uvalue = 0
		end

	'deleteall': begin
		plotman_modify_int, 'delete', int_info
		relist = 1
		end

	'multi': int_info.add_mode_index = event.index

	'numint': if event.value lt 1 or event.value gt int_info.max_intervals then $
			widget_control, int_info.w_numint, set_value=1

	'delta': ; if event.value lt 1 then widget_control, int_info.w_delta, set_value=1. ; commented out 27-apr-2006

	'add_man': begin
		widget_control, int_info.w_numint, get_value=numint
		widget_control, int_info.w_range, get_value=range
		range = int_info.what eq 'Time' ? anytim(range) : range
		widget_control, int_info.w_delta, get_value=delta
		;print,'numint = ', numint, '  range=',range[0],range[1], '  delta=',delta
		case int_info.add_mode_index of
			0: begin
				int_info.new_se = range
				plotman_modify_int, 'add', int_info, /nosort
				plotman_modify_int, 'nbreak', int_info, int_index=int_info.nint-1, $
					nbreak=numint[0]
				end
			1: begin
				int_info.new_se = range
				plotman_modify_int, 'add', int_info, /nosort
				plotman_modify_int, 'nbreak_log', int_info, int_index=int_info.nint-1, $
					nbreak=numint[0]
				end
			2: begin
				int_info.new_se = range
				plotman_modify_int, 'add', int_info, /nosort
				plotman_modify_int, 'lbreak', int_info, int_index=int_info.nint-1, $
					lbreak=float(delta[0])
				end
			3: begin
				plotman_modify_int, 'ntotalbreak', int_info, lbreak=float(delta[0]), $
					ntotalbreak=fix(numint[0]), startint=range[0], error=error
				end
			else:

		endcase
		relist = 1
		end

	'all_energy': begin
		*int_info.list_intervals = int_info.ch_energy
		widget_control, int_info.w_intlist, $
			set_value=format_intervals(*int_info.list_intervals,ut=(int_info.what eq 'Time'), /prefix)
		;ind = indgen(n_elements((*int_info.list_intervals)[0,*]))
		;*int_info.list_intervals_selected = ind
		;widget_control, int_info.w_intlist, set_list_select=ind
		widget_control, int_info.w_select_all, $
			send_event={id:int_info.w_select_all, top:event.top, handler:0L}
		end

	'rep_man': begin
		plotman_modify_int, 'delete', int_info
		widget_control, event.top, set_uvalue=int_info
		event.id = int_info.w_add_man
		widget_control, int_info.w_add_man, send_event=event
		end

	'graph': begin
		; check if the current plot is the right kind (utplot, xyplot).  If not draw a blank plot.
		if int_info.plotman_obj -> any_plot(range=int_info.valid_range, $
		  what=int_info.what, blank_plot=blank_plot) then begin
		  	; can't force to data boundaries if no data
		  	force = blank_plot ? 0 : int_info.force
			int_info.plotman_obj -> intervals, type=int_info.type, intervals=*int_info.se, /show_start, $
				title=int_info.title, force=force, send_widget = int_info.w_list_row
			widget_control, event.top, sensitive=0
		endif
		end

	'get_graph_int': begin
		; event was sent by plotman__intervals when user finished defining intervals
		int = int_info.plotman_obj -> get(/intervals)
		if int[0] gt -1 then begin
			*int_info.list_intervals = int
			widget_control, int_info.w_intlist, $
				set_value=format_intervals (*int_info.list_intervals, ut=(int_info.what eq 'Time'), /prefix)
			;*int_info.list_intervals_selected = -1
			widget_control, int_info.w_select_all, $
				send_event={id:int_info.w_select_all, top:event.top, handler:0L}
		endif
		widget_control, event.top, sensitive=1
		xshow, event.top
		end

	'intlist': if (*int_info.list_intervals)[0] ne -1 then $
		*int_info.list_intervals_selected = widget_selected(event.id, /index)

	'select_all': begin
		if (*int_info.list_intervals)[0] ne -1 then begin
			ind = indgen(n_elements((*int_info.list_intervals)[0,*]))
			*int_info.list_intervals_selected = ind
			widget_control, int_info.w_intlist, set_list_select=ind
		endif
		end

	'add_list': begin
		ind = *int_info.list_intervals_selected
		if ind[0] ne  -1 then begin
			for i=0,n_elements(ind)-1 do begin
				int_info.new_se = (*int_info.list_intervals)[*,ind[i]]
				plotman_modify_int, 'add', int_info, error=error
				if error then return
			endfor
		endif else begin
			reset_uvalue = 0
			a = dialog_message ('No intervals were selected from list.', /info)
		endelse
		relist = 1
		end

	'rep_list': begin
		plotman_modify_int, 'delete', int_info
		widget_control, event.top, set_uvalue=int_info
		event.id = int_info.w_add_list
		widget_control, int_info.w_add_list, send_event=event
		end

	'readfile': begin
		int = restore_intervals (ut=(int_info.what eq 'Time') )
	;	if int[0] ne -1 then begin
	;		*int_info.an_intervals_str.se = int
	;		int_info.an_intervals_str.nint = n_elements(int[0,*])
	;	endif
	;	*int_info.an_intervals_descs = plotman_format_int (int_info.an_intervals_str)
		if int[0] ne -1 then begin
			*int_info.list_intervals = int
			widget_control, int_info.w_intlist, $
				set_value=format_intervals(*int_info.list_intervals,ut=(int_info.what eq 'Time'), /prefix)
			;*int_info.list_intervals_selected = -1
			widget_control, int_info.w_select_all, $
				send_event={id:int_info.w_select_all, top:event.top, handler:0L}
		endif
		end

	'restore': begin
		desc = int_info.stored_intervals_obj -> getdata(/desc)
		if stregex(desc[restoren], int_info.what, /fold_case, /boolean) then begin
			*int_info.list_intervals = int_info.stored_intervals_obj -> getdata(index=restoren)
			widget_control, int_info.w_intlist, $
				set_value=format_intervals(*int_info.list_intervals,ut=(int_info.what eq 'Time'), /prefix)
			;*int_info.list_intervals_selected = -1
			widget_control, int_info.w_select_all, $
				send_event={id:int_info.w_select_all, top:event.top, handler:0L}
		endif else begin
			a = dialog_message('Error - you did not select a set of ' + int_info.what + ' intervals.')
			return
		endelse
		end

	'display': begin
		if int_info.plotman_obj->valid_window(/message, $
				utplot=(int_info.what eq 'Time'), $
				xyplot=(int_info.what eq 'Energy')) then begin
			int_info.plotman_obj -> select
			int_info.plotman_obj -> plot
			plotman_draw_int, 'all', int_info, intervals=*int_info.se, type=int_info.type
		endif
		end

	'savefile': store_intervals, *int_info.se, ut=(int_info.what eq 'Time')

	'cancel': begin
		;*int_info.se = int_info.orig_se
		;int_info.nint = n_elements(int_info.orig_se[0,*])
		*int_info.se = -99
		int_info.nint = 0
		exit=1
		end

	'accept': begin
		reset_uvalue = 0
		if int_info.nint eq 0 then $
			a = dialog_message ('ERROR - Cannot exit without setting at least one interval.', /error) $
		else begin
			int_info.stored_intervals_obj -> add, *int_info.se, $
				ut=(int_info.what eq 'Time'), $
				ident = int_info.program + anytim(!stime,/vms, /time,/trunc)
			exit=1
		endelse
		end

	else:

	endcase

if reset_uvalue then begin
	widget_control, event.top, set_uvalue=int_info
	if relist then plotman_list_int, int_info
endif

if widget_info(event.top,/sensitive) then widget_control, event.top, /show

if exit then begin
	widget_control, event.top, /destroy
	if strpos (int_info.plotman_obj ->get(/current_panel_desc), 'Blank plot') ne -1 then $
		int_info.plotman_obj -> delete_panel, /current
endif

end

;-----

function xsel_intervals, group=group, $
	input_intervals=input_intervals, $
	title=title, show_start=show_start, type=type, $
	energy=energy, time=time,  $
	hessi=hessi, ch_energy=ch_energy_in, force=force, $
	msg_label=msg_label, valid_range=valid_range, $
	obs_time_interval=obs_time_interval, $
	chg_msg=chg_msg, $
	plotman_obj=plotman_obj, $
	stored_intervals_obj=stored_intervals_obj, $
	_extra=_extra

if not keyword_set(input_intervals) then input_intervals = [0.,0.]

if xregistered ('xsel_intervals') then begin
	xshow,'xsel_intervals', /name
	a = dialog_message (['You can not run more than one copy of the Select Intervals Widget.', $
		'Aborting second copy.'], /error)
	return, input_intervals
endif

max_intervals=10000
checkvar, type, 'Analysis'
checkvar, force, 0

what = keyword_set(energy) ? 'Energy' : 'Time'
checkvar, valid_range, [0.,0.]
checkvar, obs_time_interval, [0.,0.]
checkvar, ch_energy_in, [3.,6.,12.,25.,50.,100.,300.,800.,7000.,20000.]
ch_energy = get_edge_products(ch_energy_in, /edges_2)
if not is_class(plotman_obj, 'plotman', /quiet) then plotman_obj = obj_new()
if not is_class(stored_intervals_obj, 'store_intervals', /quiet) then $
	stored_intervals_obj=obj_new('store_intervals')

case what of
	'Time': begin
		length_unit = 's'
		plot_type='utplot'
		s_name = 'intervals'
		s_both = 'time range'
		s_start = 'start time'
		s_delta = 'length'
		end
	'Energy': begin
		length_unit='keV'
		plot_type='xyplot'
		s_name = 'bands'
		s_both = 'energy range'
		s_start = 'low energy'
		s_delta = 'width'
		end
endcase

; determine type of data intervals are for from name of handler.  This is for labelling
; the set of intervals when we save them.
program = xalive(group) ? get_handler_name(group) : ''
if stregex(program,'spec',/fold,/bool) then program='Spectrum '
if stregex(program,'img',/fold,/bool) then program='Image '
if stregex(program,'lc',/fold,/bool) then program='Lightcurve '

; Construct list of intervals for list widget of previously-defined intervals
;checkvar, an_intervals, -1
;if an_intervals[0] ne -1 then begin
;	an_intervals_str = {nint: n_elements(an_intervals(0,*)), $
;				se: ptr_new(an_intervals), $
;				plot_type: plot_type, $
;				utbase: 0.d0}
;	an_intervals_descs = plotman_format_int (an_intervals_str)
;endif else begin
;	an_intervals_str = {nint: 0, $
;				se: ptr_new(/alloc), $
;				plot_type: plot_type, $
;				utbase: 0.d0}
;	an_intervals_descs = 'None'
;endelse

get_font, font, big_font=big_font

checkvar, title, 'Select ' + what + ' Interval(s)'

w_base = widget_base (group=group, $
					/column, $
					title=title[0], $
					/frame, space=5)

w_temp = widget_label (w_base, value=title[0],  font=big_font, /align_center)
if n_elements(title) gt 1 then w_temp = widget_label (w_base, value=title[1],  font=big_font, /align_center)

if keyword_set(msg_label) then $
	for i = 0,n_elements(msg_label)-1 do  tmp = widget_label(w_base, value=msg_label[i], /align_center)

w_listbase = widget_base (w_base, $
					/column, $
					/frame, $
					space=5)

w_current = widget_base (w_listbase, /row, space=30, /align_center)

tmp = widget_label (w_current, value='List of current intervals:')
w_total = widget_label (w_current, value = '# Intervals =    ', /dynamic_resize)

; on Windows, size of window is wrong unless dynamic_resize is set. But on unix, makes
; it really slow, so set xsize by giving dummy string.
if !version.os_family eq 'Windows' then resize=1 else resize=0
w_list = widget_droplist (w_listbase, $
					value='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', $
					uvalue='list', $
					;dynamic_resize=resize, $
					/align_center)

w_listbuttons = widget_base (w_listbase, $
					/align_center, $
					/row, $
					space=5 )

w_tmp = widget_button (w_listbuttons, $
					value='Delete selected interval', $
					uvalue='deletesel' )

w_tmp = widget_button (w_listbuttons, $
					value='Delete all', $
					uvalue='deleteall')

w_tmp = widget_button (w_listbuttons, $
					value='Edit selected interval...', $
					uvalue='editsel' )

w_tmp = widget_button (w_listbuttons, $
					value='Edit intervals...', $
					uvalue='editlist', $
					/align_center)

w_tmp = widget_label (w_base, value='Select from pre-defined list of intervals:   or Define intervals to add below.')

w_list_base = widget_base (w_base, /column, /frame,  space=3)

; set a uvalue for this base.  When defining intervals graphically, we'll send an event to this widget when user
; is done, so we can extract intervals from plotman object.
w_list_row = widget_base (w_list_base, /row, /align_center, space=15, uvalue='get_graph_int')

tmp = widget_button (w_list_row, value='Define intervals graphically...', uvalue='graph')

tmp = widget_button (w_list_row, value='Read Intervals from File', uvalue='readfile')

restore_button = widget_button (w_list_row, value='Restore Previous Intervals', uvalue='restore', /menu)
desc = stored_intervals_obj -> getdata(/desc)
ni = stored_intervals_obj -> getdata(/num_stored) > 1
tmp = -1
for i = 0,ni-1 do if stregex(desc[i],what,/fold,/bool) then $
	tmp = widget_button (restore_button, value=desc[i], uvalue='restore'+strtrim(i,2))
if tmp eq -1 then tmp = widget_button (restore_button, value='None', uvalue='nothing')


tmp = widget_label (w_list_base, value='Highlight one or more interval(s) to add or replace to current list:')

w_list_base2 = widget_base (w_list_base, /row)

if !version.os_family eq 'Windows' then xsize=55 else xsize=30
w_intlist = widget_list (w_list_base2, $
					/multiple, $
					value='None', $
					uvalue='intlist', $
					ysize=9, $
					xsize=xsize)

w_list_but = widget_base (w_list_base2, /column, space=10, /align_center)

w_select_all = widget_button (w_list_but, value='Select All', uvalue='select_all')
w_add_list = widget_button (w_list_but, value='Add to List', uvalue='add_list')
w_rep_list = widget_button (w_list_but, value='Replace List', uvalue='rep_list')

tmp = widget_label (w_base, value='Or Define intervals manually below:', /align_center)
w_manual_base = widget_base (w_base, /column, /frame, space=2)

case what of
	'Time': begin
		if keyword_set(hessi) then begin
			w_range = call_function('hsi_cw_ut_range', w_manual_base, $
					value=minmax(input_intervals), $
					label='', $
					uvalue='range', $
					frame=0)
		endif else begin
			w_range = cw_ut_range ( w_manual_base, $
					value=minmax(input_intervals), $
					label='', $
					uvalue='range', $
					frame=0)
		endelse
		end

	'Energy': w_range = cw_energy_range ( w_manual_base, $
					value=minmax(input_intervals), $
					ch_energy=ch_energy, $
					label='', $
					uvalue='range', $
					frame=0.)

endcase

w_opt_base = widget_base (w_manual_base, /row, space=20)

w_opt_base1 = widget_base (w_opt_base, /column, space=0)

max = strtrim(max_intervals,2)

tmp = widget_label (w_opt_base1, value='Create multiple (max=' + max + ') ' + s_name + ':')
multi_vals = ['Divide this ' + s_both + ' into N equal ' + s_name, $
	'Divide this ' + s_both + ' into N logarithmically spaced ' + s_name, $
	'Divide this ' + s_both + ' into ' + s_name + ' of ' + s_delta + ' D', $
	'Make N ' + s_name + ' of ' + s_delta + ' D starting at this ' + s_start]
w_multi = widget_droplist(w_opt_base1, value=multi_vals, uvalue='multi')

w_opt_nums = widget_base (w_opt_base1, /row, /align_center, space=15)
w_numint = cw_field (w_opt_nums, /row, /string, /return_event, $
	title='N: ', value='1', uvalue='numint', xsize=7)
w_delta = cw_field (w_opt_nums, /row, /string, /return_event, $
	title='D (' + length_unit + '): ', value='1.', uvalue='delta', xsize=12)

w_opt_base2 = widget_base (w_opt_base, /column, space=10, /align_center)

if what eq 'Energy' then w_all_energy = widget_button(w_opt_base2, value='All Standard', uvalue='all_energy')
w_add_man = widget_button (w_opt_base2, value='Add to List', uvalue='add_man')
w_rep_man = widget_button (w_opt_base2, value='Replace List', uvalue='rep_man')

w_buttons = widget_base (w_base, /row, space=30, /align_center)
tmp = widget_button (w_buttons, value='Draw Current', uvalue='display' )
tmp = widget_button (w_buttons, value='Save Current Intervals to File', uvalue='savefile')
tmp = widget_button (w_buttons, value='Cancel', uvalue='cancel')
tmp = widget_button (w_buttons, value='Accept', uvalue='accept')

int_info = {w_list: w_list, $
	w_list_row: w_list_row, $
	w_total: w_total, $
	w_select_all: w_select_all, $
	w_range: w_range, $
	w_delta: w_delta, $
	w_add_man: w_add_man, $
	w_rep_man: w_rep_man, $
	w_numint: w_numint, $
	w_intlist: w_intlist, $
	w_add_list: w_add_list, $
	w_rep_list: w_rep_list, $

	program: program, $
	plotman_obj: plotman_obj, $
	ch_energy: ch_energy, $
	stored_intervals_obj: stored_intervals_obj, $
	what: what, $
	type: type, $
	title: title, $
	force: force, $
	valid_range: valid_range, $
	obs_time_interval: obs_time_interval, $

	add_mode_index: 0, $
	new_se: [0.d0, 0.d0], $
	nint: n_elements(input_intervals[0,*]), $
	se: ptr_new(input_intervals), $
	max_intervals: max_intervals, $
	plot_type: plot_type, $

	orig_se: input_intervals, $
	utbase: 0.d0, $
	list_intervals: ptr_new(-1), $
	list_intervals_selected: ptr_new(-1) $
	 }


if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=w_base
	widget_control, w_base, xoffset=xoffset, yoffset=yoffset
endif

widget_control, w_base, /realize

widget_control, w_base, set_uvalue=int_info

list = format_intervals (*int_info.se, ut=(what eq 'Time'), /prefix)
widget_control, w_list, set_value=list
widget_control, w_total, set_value='# intervals = ' + strtrim(int_info.nint,2)

if keyword_set(show_start) then begin
	if plotman_obj->valid_window(utplot=(what eq 'Time'), xyplot=(what eq 'Energy')) then begin
		plotman_obj -> select
		plotman_obj -> plot
		plotman_draw_int, 'all', int_info, intervals=input_intervals, type=int_info.type
	endif
endif

widget_control, w_base, /show
xmanager, 'xsel_intervals', w_base;, /no_block

retval = *int_info.se

if retval[0] gt -1 and not same_data(valid_range, [0.,0.]) then begin
	; for times use double for comparison, for energies, use float
	if what eq 'Time' then $
		good = where_within (retval, valid_range, bad_count=bad_count, bad_ind=bad_ind) $
	else $
		good = where_within (float(retval), valid_range, bad_count=bad_count, bad_ind=bad_ind)
	if bad_count gt 0 then begin
		if good[0] eq -1 then begin
			retval = input_intervals
			a = dialog_message (['All elements of returned array had to be removed because  ', $
				'they were outside of allowed range.', $
				'', 'Resetting intervals to original interval'], /error)
		endif else begin
			retval = retval[*,good]
			a = dialog_message (['Some elements of returned array had to be removed because  ', $
				'they were outside of allowed range.'], /info)
		endelse
	endif
endif

; don't free plotman obj, or stored interval obj if we're passing it back out.
exclude = ['plotman_obj', arg_present(stored_intervals_obj) ? stored_intervals_obj : '']
free_var, int_info, exclude=exclude

;print,'Values returned by xsel_intervals are:
;ptim,retval
return,  retval
end
