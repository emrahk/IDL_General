; 25-may-2015, Kim. Added xgrid,ygrid,zgrid to extend axis major tick marks across plot (really controls plot_control
;  xx. yy. and zz.ticklen, setting it to 0. or 1.)

pro plotman_update_axes_widgets, opt_state

w = opt_state

widget_control, w.parent, get_uvalue=state
pc = state.plotman_obj -> get (/plot_control)

;data = state

if xalive (w.w_xlog) and pc.plot_type eq 'utplot' then widget_control, w.w_xlog, sensitive=0
if xalive (w.w_xlog) then widget_control, w.w_xlog, set_value = pc.xlog
if xalive (w.w_ylog) then widget_control, w.w_ylog, set_value = pc.ylog

if xalive (w.w_xrange) then widget_control, w.w_xrange, set_value = pc.xx.range
if xalive (w.w_yrange) then widget_control, w.w_yrange, set_value = pc.yy.range
if xalive (w.w_zrange) then widget_control, w.w_zrange, set_value = pc.zz.range

maskon = '1'X  ; mask with 2^0 bit on
if (pc.xx.style and maskon) eq 0 then xexact = 0 else xexact = 1
if (pc.yy.style and maskon) eq 0 then yexact = 0 else yexact = 1
if xalive (w.w_xexact) then widget_control, w.w_xexact, set_value = xexact
if xalive (w.w_yexact) then widget_control, w.w_yexact, set_value = yexact
if xalive (w.w_xgrid) then widget_control, w.w_xgrid, set_value=(pc.xx.ticklen ne 0.)
if xalive (w.w_ygrid) then widget_control, w.w_ygrid, set_value=(pc.yy.ticklen ne 0.)
if xalive (w.w_zgrid) then widget_control, w.w_zgrid, set_value=(pc.zz.ticklen ne 0.)

if xalive (w.w_timerange) then begin
	timerange = pc.timerange
	if total(pc.timerange) eq 0. then timerange = pc.utrange
	widget_control, w.w_timerange, set_value = timerange
endif

end
