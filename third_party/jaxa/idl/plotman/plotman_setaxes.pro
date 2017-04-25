;+
; Name: plotman_setaxes
;
; Kim Tolbert
; Modifications:
;   14-May-2002, Kim.  Fixed error in xyzreset line
;	5-Nov-2003, Kim.  xyzreset wasn't resetting z axis
;-

pro plotman_setaxes, state, uvalue, event, com

option = strmid (uvalue, 5, 99)
;print,'option = ', option

case option of

	'xlog': com = 'state.plotman_obj -> set, xlog=event.select'

	'ylog': com = 'state.plotman_obj -> set, ylog=event.select'

	'xrange': com = 'state.plotman_obj -> set, xrange=event.value'

	'yrange': com = 'state.plotman_obj -> set, yrange=event.value'

	'zrange': com = 'state.plotman_obj -> set, zrange=event.value'

	'xexact': com = 'state.plotman_obj -> set, xexact=event.select'

	'yexact': com = 'state.plotman_obj -> set, yexact=event.select'

	'xreset': com = 'state.plotman_obj -> set, xrange=[0.,0.], timerange=[0.d0, 0.d0]'

	'yreset': com = 'state.plotman_obj -> set, yrange=[0.,0.]'

	'zreset': com = 'state.plotman_obj -> set, zrange=[0.,0.]'

	'xyzreset': com = $
		'state.plotman_obj -> set, xrange=[0.,0.], yrange=[0.,0.], timerange=[0.d0, 0.d0], zrange=[0.,0.]'

	'timerange': begin
		times = anytim(event.value, /vms)
		com = 'state.plotman_obj -> set, timerange=' + "['" + times[0] + "','" + times[1] + "']"
		end

	else: print,'Unknown command in plotman_setaxes.'

endcase

;print,'command in plotman_setaxes = ', com

end
