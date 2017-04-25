pro plotman_axes_event, event

widget_control, event.top, get_uvalue=axes_state

widget_control, axes_state.parent, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

;help,event,/st

com = ''
if axes_state.applynow then redraw = 1 else redraw = 0
exit = 0

case uvalue of

	'applyoption': begin
		axes_state.applynow = event.select
		if not axes_state.applynow then redraw = 0
		end

	'xlinlog': com = 'state.plotman_obj -> set, xlog=' + strtrim(event.value)

	'ylinlog': com = 'state.plotman_obj -> set, ylog=' + strtrim(event.value)

	'xrange': com = 'state.plotman_obj -> set, xrange=' + string(event.value,form="('[',e, ',', e, ']')")

	'yrange': com = 'state.plotman_obj -> set, yrange=' + string(event.value,form="('[',e, ',', e, ']')")

	'xexact': com = 'state.plotman_obj -> set, xexact=' + strtrim(event.select)

	'yexact': com = 'state.plotman_obj -> set, yexact=' + strtrim(event.select)

	'xreset': com = 'state.plotman_obj -> set, xrange=[0.,0.], timerange=[0.d0, 0.d0]'

	'yreset': com = 'state.plotman_obj -> set, yrange=[0.,0.]'

	'xyreset': com = 'state.plotman_obj -> set, xrange=[0.,0.], yrange=[0.,0.], timerange=[0.d0, 0.d0]'

	'timerange': begin
		times = anytim(event.value, /hxrbs)
		com = 'state.plotman_obj -> set, timerange=' + "['" + times[0] + "','" + times[1] + "']"
		end

	'apply': redraw = 1

	'exit': begin
		redraw = 1
		exit = 1
		end

	'cancel': begin
		redraw = 1
;		*axes_state.original_plot_control.plot_args = *axes_state.original_plot_args
		state.plotman_obj -> set, plot_control=axes_state.original_plot_control
		exit = 1
		end

	else: print,'Unknown command in plotman_axes_event.'

endcase

if com ne '' then result = execute(com)

if redraw then begin
	state.plotman_obj -> select
	state.plotman_obj -> plot
	;plot_control = state.plotman_obj -> get(/plot_control)
	;axes_state.original_plot_control = plot_control
	;*axes_state.original_plot_args = *plot_control.plot_args
endif

if exit then begin
	widget_control, event.top, /destroy
;	ptr_free, axes_state.original_plot_args
endif else begin
	plotman_update_axes_widgets, axes_state
	widget_control, event.top, set_uvalue=axes_state
endelse

end

;-----

pro plotman_axes, event

widget_control, event.top, get_uvalue=state

widget_control, state.widgets.w_message, set_value=' '

parent = event.top

plot_control = state.plotman_obj -> get (/plot_control)
plot_type = plot_control.plot_type

xx = plot_control.xx
yy = plot_control.yy
data = state.plotman_obj -> get (/data)

;geom = widget_info (event.top, /geometry)
;xoffset = geom.xoffset
;yoffset = geom.yoffset

tlb = widget_base (group_leader=parent, $
					title='Configure Axes', $
					;xoffset=50 + xoffset, $
					;yoffset=50 + yoffset, $
					/base_align_center, $
					/column, $
					ypad=5, $
					space=5, $
					/modal )

w_box = widget_base (tlb, /column, /frame)

w_timerange = 0L & w_xrange = 0L & w_xlinlog = 0L & w_xexact = 0L
if plot_type eq 'utplot' then begin

	w_time_base = widget_base (w_box, $
						/row )

	w_timerange = hsi_cw_ut_range (w_time_base, $
					value=plot_control.utrange, $
					uvalue='timerange', $
					label='Times: ', $
					frame=0, space=1, ypad=1, /align_left )

	w_xexact_base = widget_base (w_time_base, $
						/row, $
						/nonexclusive, /align_center)

	w_xexact = widget_button (w_xexact_base, $
						value='Exact', $
						uvalue='xexact' )

endif else begin

	w_xbase = widget_base (w_box, $
						/row, $
						space=5, $
						ypad=0, $
						/frame )

	w_xlinlog = cw_bgroup (w_xbase, $
						['Linear', 'Log'], $
						set_value=0, $
						/exclusive, $
						label_left='X AXIS   ', $
						/row, $
						uvalue='xlinlog', $
						/return_index, $
						/no_release )

	w_xrange = cw_range (w_xbase, $
						uvalue='xrange', $
						value=xx.range, $
						format='(g12.2)', $
						label1='Limits: ', $
						label2=' - ' )


	w_xexact_base = widget_base (w_xbase, $
						/row, $
						/nonexclusive )

	w_xexact = widget_button (w_xexact_base, $
						value='Exact', $
						uvalue='xexact' )

	if plot_type eq 'image' then begin
		widget_control, w_xlinlog, sensitive=0
		widget_control, w_xexact, sensitive=0
	endif

endelse

w_ybase = widget_base (w_box, $
					/row, $
					space=5, $
					ypad=0, $
					/frame )

w_ylinlog = cw_bgroup (w_ybase, $
					['Linear', 'Log'], $
					set_value=0, $
					/exclusive, $
					label_left='Y AXIS   ', $
					/row, $
					uvalue='ylinlog', $
					/return_index, $
					/no_release , ysize=20)

w_yrange = cw_range (w_ybase, $
					uvalue='yrange', $
					value=yy.range, $
					format='(g12.2)', $
					label1='Limits: ', $
					label2=' - ', ypad=0 )

w_yexact_base = widget_base (w_ybase, $
					/row, $
					/nonexclusive )

w_yexact = widget_button (w_yexact_base, $
					value='Exact', $
					uvalue='yexact' )

if plot_type eq 'image' then begin
	widget_control, w_ylinlog, sensitive=0
	widget_control, w_yexact, sensitive=0
endif


w_buttons = widget_base (tlb, $
					/row, $
					space=5)

w_applynow_base = widget_base (w_buttons, $
					/row, $
					/nonexclusive, /align_center)

w_applynow = widget_button (w_applynow_base, $
						value='Auto Apply', $
						uvalue='applyoption' )

w_reset = widget_button (w_buttons, $
					value='Reset limits', $
					/menu)

temp = widget_button (w_reset, $
						value='X only', $
						uvalue='xreset' )

temp = widget_button (w_reset, $
					value='Y only', $
					uvalue='yreset' )

temp = widget_button (w_reset, $
					value='X and Y', $
					uvalue='xyreset' )

temp = widget_button (w_buttons, $
					value=' Cancel ', uvalue='cancel' )

temp = widget_button (w_buttons, $
					value=' Apply ', uvalue='apply' )

temp = widget_button (w_buttons, $
					value=' Accept ', uvalue='exit' )

widget_offset, parent, newbase=tlb, xoffset, yoffset, /vertical

widget_control, tlb, xoffset=xoffset, yoffset=yoffset

widget_control, tlb, /realize

axes_state = { $
	tlb: tlb, $
	parent: parent, $
	applynow: 0, $
	w_xlinlog: w_xlinlog, $
	w_ylinlog: w_ylinlog, $
	w_xrange: w_xrange, $
	w_yrange: w_yrange, $
	w_xexact: w_xexact, $
	w_yexact: w_yexact, $
	w_timerange: w_timerange, $
	original_plot_control: plot_control }
;	original_plot_args: ptr_new(*plot_control.plot_args) }

plotman_update_axes_widgets, axes_state

widget_control, tlb, set_uvalue=axes_state

xmanager, 'plotman_axes', tlb

return

end
