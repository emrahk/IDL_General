;+
; Name: plotman_setaxes
;
; Kim Tolbert
; Modifications:
;   14-May-2002, Kim.  Fixed error in xyzreset line
;	5-Nov-2003, Kim.  xyzreset wasn't resetting z axis
; 25-may-2015, Kim. Added xgrid,ygrid,zgrid to extend axis major tick marks across plot (really controls plot_control
;  xx. yy. and zz.ticklen, setting it to 0. or 1.)
;-

pro plotman::setaxes, event, com

widget_control, event.id, get_uvalue=uvalue

widget_control, event.top, get_uvalue=state_opt

option = strmid (uvalue, 5, 99)
;print,'option = ', option

case option of

	'xlog': com = 'self -> set, xlog=event.select'

	'ylog': com = 'self -> set, ylog=event.select'

	'xrange': com = 'self -> set, xrange=event.value'

	'yrange': com = 'self -> set, yrange=event.value'

	'zrange': com = 'self -> set, zrange=event.value'

	'xexact': com = 'self -> set, xexact=event.select'

	'yexact': com = 'self -> set, yexact=event.select'
	
	'xgridline': com = 'self -> set, xticklen=event.select'
	
	'ygridline': com = 'self -> set, yticklen=event.select'
	
	'zgridline': com = 'self -> set, zticklen=event.select'

	'xreset': begin
		com = 'self -> set, xrange=[0.,0.], timerange=[0.d0, 0.d0]'
		if xalive(state_opt.w_xrange) then widget_control, state_opt.w_xrange, set_value=[0.,0.]
		if xalive(state_opt.w_timerange) then widget_control, state_opt.w_timerange, set_value=[0.d0, 0.d0]
		end

	'yreset': begin
		com = 'self -> set, yrange=[0.,0.]'
		widget_control, state_opt.w_yrange, set_value=[0.,0.]
		end

	'zreset': begin
		com = 'self -> set, zrange=[0.,0.]'
		widget_control, state_opt.w_zrange, set_value=[0.,0.]
		end


	'xyzreset': begin
		com = 'self -> set, xrange=[0.,0.], yrange=[0.,0.], timerange=[0.d0, 0.d0], zrange=[0.,0.]'
		if xalive(state_opt.w_xrange) then widget_control, state_opt.w_xrange, set_value=[0.,0.]
		if xalive(state_opt.w_yrange) then widget_control, state_opt.w_yrange, set_value=[0.,0.]
		if xalive(state_opt.w_zrange) then widget_control, state_opt.w_zrange, set_value=[0.,0.]
		if xalive(state_opt.w_timerange) then widget_control, state_opt.w_timerange, set_value=[0.d0, 0.d0]
		end

	'timerange': begin
		times = anytim(event.value, /vms)
		com = 'self -> set, timerange=' + "['" + times[0] + "','" + times[1] + "']"
		widget_control, state_opt.w_timerange, set_value=anytim(times)
		end

	else: print,'Unknown command in plotman_setaxes.'

endcase

if com ne '' then result = execute(com)

;print,'command in plotman_setaxes = ', com

end
