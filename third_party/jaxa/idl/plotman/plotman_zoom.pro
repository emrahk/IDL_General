;+
; Name: plotman_zoom
; Purpose: allow user to define borders of zoom area and zoom in plotman window
;
; Input:
;	state - state structure containing plotman object
;	event -  - draw window left click event that has already occurred, e.g. user
;		has already left clicked in draw widget, and this position should
;		be used as starting position for stretch box
;	orig_panel_num - if set, reset focus to this panel before replotting (we zoomed on
;		one of the plots in an overlay that wasn't the main plot
;
; Written: Kim Tolbert
; Modifications:
;	1-Sep-2001, Added use_previous option.  Remember previous zoom limits for xy, ut,
;	  and image plots separately in common, and restore thoseif use_previous is set.
;   11-Oct-2002, Kim.  Call new plotman method dev2data to convert coords
;	28-Mar-2003, Kim.  Added orig_panel_num keyword, and if it exists, reset focus to
;	  that panel before replotting.
;
;-
pro plotman_zoom, state, use_previous=use_previous, event=event, orig_panel_num=orig_panel_num

common plotman_prev_zoom_common, prev_xy_zoom, prev_ut_zoom, prev_image_zoom, prev_spec_zoom

;print,'event in plotman_zoom
;help,event,/st

use_previous = keyword_set(use_previous)
plot_type = state.plotman_obj -> get(/plot_type)

state.plotman_obj -> select  ; to restore !x,!y from plot
oldxrange = !x.range & oldyrange = !y.range & oldtrange = state.plotman_obj->get(/timerange)
;oldxrange = state.plotman_obj->get(xrange) & oldyrange = state.plotman_obj->get(/yrange) & oldtrange = state.plotman_obj->get(/timerange)

if use_previous then begin
	case plot_type of
		'utplot': begin
			if size(prev_ut_zoom, /tname) ne 'STRUCT' then begin
				a = dialog_message('No previous utplot zoom limits to use.', /error)
				return
			endif
			xy = prev_ut_zoom.xy
			utbase = prev_ut_zoom.utbase
			end
		'xyplot': begin
			if size(prev_xy_zoom, /tname) ne 'STRUCT' then begin
				a = dialog_message('No previous xy plot zoom limits to use.', /error)
				return
			endif
			xy = prev_xy_zoom.xy
			end
		'image': begin
			if size(prev_image_zoom, /tname) ne 'STRUCT' then begin
				a = dialog_message('No previous image plot zoom limits to use.', /error)
				return
			endif
			xy = prev_image_zoom.xy
			end
		'specplot': begin
			if size(prev_spec_zoom, /tname) ne 'STRUCT' then begin
				a = dialog_message('No previous spectrogram plot zoom limits to use.', /error)
				return
			endif
			xy = prev_spec_zoom.xy
			utbase = prev_spec_zoom.utbase
			end
	endcase
endif else begin

	if not keyword_set(event) then begin

		state.plotman_obj -> select

		flash_msg, state.widgets.w_message,  num=3, rate=.1, $
			'Click and drag left mouse button to define zoom area.'

	endif

	color_names = state.plotman_obj -> get(/color_names)
	xydev = stretch_box (state.widgets.w_draw, /dev, color=color_names.red, event=event)
	xy = fltarr(2,2)
	xy[*,0] = state.plotman_obj -> dev2data (xydev[0,0], xydev[1,0])
	xy[*,1] = state.plotman_obj -> dev2data (xydev[0,1], xydev[1,1])

	utbase = anytim (state.plotman_obj -> get(/utbase))

endelse


xdiff = abs(xy[0,0] - xy[0,1])
ydiff = abs(xy[1,0] - xy[1,1])
xratio = f_div (xdiff, abs(!x.crange[1] - !x.crange[0]) )
yratio = f_div (ydiff, abs(!y.crange[1] - !y.crange[0]) )

if xratio lt .01 and yratio lt .01 then begin

	comx = 'state.plotman_obj -> set, xrange=[0,0], timerange=[0.,0.]'
	comy = ', yrange=[0,0]'

endif else begin

	if plot_type eq 'utplot' or plot_type eq 'specplot' then begin

		times = utbase + xy[0,*]
		;print, 'setting times to ', anytim(times, /vms)
		;print, 'setting yrange to ', xy[1,*]
		comx = 'state.plotman_obj -> set, timerange=[times[0], times[1]]'
		comy = ', yrange=xy[1,*]'
		if plot_type eq 'utplot' then prev_ut_zoom = {xy: xy, utbase: utbase} else $
			prev_spec_zoom = {xy: xy, utbase: utbase}

	endif else begin

		comx = 'state.plotman_obj -> set, xrange=xy[0,*]'
		comy = ', yrange=xy[1,*]'
		if plot_type eq 'xyplot' then prev_xy_zoom = {xy: xy} else prev_image_zoom = {xy:xy}
	endelse

endelse

result = execute(comx+comy)
pc = state.plotman_obj -> get(/plot_control)
newxrange = pc.xx.range  & newyrange = pc.yy.range & newtrange = state.plotman_obj->get(/timerange)

; if x, time, or y range changed then replot.  If orig_panel_num was passed in, that
; means we zoomed on a panel that's not the original panel, so so set focus back
; to the original panel first, set the new x limits in that panel, then replot
if not (same_data(newxrange, oldxrange) and $
		same_data(newyrange, oldyrange) and $
		same_data(newtrange, oldtrange) ) then begin
	if exist(orig_panel_num) then begin
		;want any new limits we just saved to get stored in panel structure
		state.plotman_obj -> update_panel
		;print,'in plotman_zoom, setting focus to panel ', orig_panel_num
		state.plotman_obj -> focus_panel, dummy, orig_panel_num, /minimal
		result = execute(comx)
	endif
	state.plotman_obj -> select
	state.plotman_obj -> plot
endif

state.plotman_obj -> unselect

widget_control, state.widgets.w_message, set_value=' '

end