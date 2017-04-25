;+
; Name: plotman__specoptions_widget
;
; Purpose: Widget to set options for displaying spectrograms
;
; CATEGORY:  HESSI WIDGETS
;
; Calling sequence:  Called from plotman::options. Not called directly.
;
; Input arguments:
;   event - event structure
;	defaults - defaults structure (see plotman::options)
; Output arguments:
;	ostate - structure with all of widget settings
;
; Output: changes display of image in plot window
;
; Output Keyword:  None
;
; Written: Kim Tolbert
;
; Modifications:
; Copied from plotman_xyoptions and modified for spectrogram plots
; 02-Mar-2003 - Call cw_ut_range instead of hsi_cw_ut_range
; 17-Jun-2005, Kim.  Changed smooth_spec to interpolate to match specplot__define
; 21-Aug-2006, Kim.  Added user_label option
; 11-Jun-2007, Kim. Use overlay_panel [1,2,3] instead of [0,1,2].  Oth is now reserved for
;    overlaying self (for images only) (forgot about spec plots when made this chg a month ago)
; 11-Jun-2007, Kim.  Added charthick option (controls xthick and ythick too) for better PS plots.
; 30-Oct-2007, Kim. Major changes.
;	  1. Now plotman__options handles the stuff common to all plot types, and calls this for spectrograms
;	  2. This is now a method instead of a procedure.
;	  3. Call all widgets that can we can set defaults for by calling plotman_defaults_wrapper, so
;	   that a little red or green box will appear next to option, letting user control if it
;	   should be used.  All red box items are ignored.
;	  4. Added checkvals method
; 16-May-2008, Kim.  Added overlay_squish option (don't leave space between stacked overlays)
; 07-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont (for move of plotman to ssw gen)
; 26-Apr-2009, Kim. Add widgets for nmax_overlay overlays in scrollable base
; 29-Apr-2009, Kim. Added control for x axis exact option
; 20-Jan-2011, Kim. Added /scroll to tlb, and removed /column.  plotman__options will limit ysize.
; 18-Nov-2013, Kim. cw_ut_range now returns a string, so convert timerange string to sec
; 25-may-2015, Kim. Added xgrid,ygrid,zgrid to extend axis major tick marks across plot (really controls plot_control
;  xx. yy. and zz.ticklen, setting it to 0. or 1.)
; 12-Aug-2015, Kim. Added panel number in overlay dropdown list and separate widget list. (have to remove it
;  when setting overlay or comparing to existing overlays though).
;  Also, added list button (like in xyoptions_widget) for overlay panel selection. On some platforms the droplist
;  becomes scrollable (Windows), but on some can't select any panels that don't show on screen (mac,unix)
;  Also, set value=self->get(/utrange) in cw_ut_range call (previously was 0.,0. so reset button failed)
;
;-

pro plotman::specopt_widget_update, ostate
w = ostate

;widget_control, w.parent, get_uvalue=state
pc = self -> get (/plot_control)
pp = pc.pp

if xalive(w.w_noverlay) then begin
  q = where (pc.overlay_panel ne '', n)
  widget_control, w.w_noverlay, set_value='Currently ' + trim(n)+' overlay(s) set.'
endif

; when checking if overlay selected matches one in list, remove panel number and one space from beginning of list item
ov_panel_descs = stregex_replace(ostate.ov_panel_descs,'^[0-9]+ ', '', /once)
; no overlays in defaults widget
if xalive (w.w_overlay_panel[1]) then begin  ; skipped 0th, just checking if any overlay widgets are there
  for i=1,pc.nmax_overlay-1 do begin
	  q = where (pc.overlay_panel[i] eq ov_panel_descs, count)
	  q = count gt 0 ? q[0] : 0
	  widget_control, w.w_overlay_panel[i], set_droplist_select = q
	endfor
endif

;if xalive (w.w_overlay_panel1) then begin
;	q = where (pc.overlay_panel[1] eq ostate.ov_panel_descs, count)
;	q = count gt 0 ? q[0] : 0
;	widget_control, w.w_overlay_panel1, set_droplist_select = q
;
;	q = where (pc.overlay_panel[2] eq ostate.ov_panel_descs, count)
;	q = count gt 0 ? q[0] : 0
;	widget_control, w.w_overlay_panel2, set_droplist_select = q
;
;	q = where (pc.overlay_panel[3] eq ostate.ov_panel_descs, count)
;	q = count gt 0 ? q[0] : 0
;	widget_control, w.w_overlay_panel3, set_droplist_select = q
;endif

widget_control, w.w_squish, set_value = pc.overlay_squish eq 1
widget_control, w.w_cbar, set_value = pc.cbar
widget_control, w.w_interpolate, set_value = pc.interpolate
widget_control, w.w_log_scale, set_value = pc.log_scale
widget_control, w.w_exp_scale, set_value = pc.exp_scale

if pp.charsize eq 0. then charsize=1. else charsize = pp.charsize
charthick = pp.charthick eq 0. ? 1. : pp.charthick
widget_control, w.w_charsize, set_value=strtrim( string(charsize, format='(f5.2)'), 2)
widget_control, w.w_charthick, set_value=strtrim(string(charthick, format='(i2)'), 2)
widget_control, w.w_legend_loc, set_droplist_select = pc.legend_loc
widget_control, w.w_user_label, set_value=pc.user_label


end

;----------  The real event handler method

pro plotman::specoptions_event, event, com, exit, redraw, found

found = 1

widget_control, event.top, get_uvalue=ostate

widget_control, event.id, get_uvalue=uvalue

sel_overlay = -1

case uvalue of

  'list_panels': begin  ;added 13-aug-2015 for Macs and Linux
    overlay_num = (where (event.id eq ostate.w_list_panels))[0]
    status = 0
    title = 'Select panel for overlay #' + trim(overlay_num)
    overlay_panel = self -> get(/overlay_panel)
    sel_overlay = xsel_list(ostate.ov_panel_descs, title=title, initial=overlay_panel[overlay_num], ysize=15, $
      /index, /no_remove, /no_sort, status=status)
    if status eq 0 then sel_overlay = -1
    end
  
  'overlay_panel': begin
    overlay_num = (where (event.id eq ostate.w_overlay_panel))[0]
    sel_overlay = event.index
    end

;	'overlay_panel': begin
;	  q = where (event.id eq ostate.w_overlay_panel)
;	  q = q[0]
;		overlay_panel = self -> get(/overlay_panel)
;		if event.index eq 0 then overlay_panel[q] = '' else $
;			overlay_panel[q] = ostate.ov_panel_descs[event.index]
;		com = 'self -> set, overlay_panel = overlay_panel'
;		end

;	'overlay_panel1': begin
;		overlay_panel = self -> get(/overlay_panel)
;		if event.index eq 0 then overlay_panel[1] = '' else $
;			overlay_panel[1] = ostate.ov_panel_descs[event.index]
;		com = 'self -> set, overlay_panel = overlay_panel, cbar=0'
;		end
;
;	'overlay_panel2': begin
;		overlay_panel = self -> get(/overlay_panel)
;		if event.index eq 0 then overlay_panel[2] = '' else $
;			overlay_panel[2] = ostate.ov_panel_descs[event.index]
;		com = 'self -> set, overlay_panel = overlay_panel, cbar=0'
;		end
;
;	'overlay_panel3': begin
;		overlay_panel = self -> get(/overlay_panel)
;		if event.index eq 0 then overlay_panel[3] = '' else $
;			overlay_panel[3] = ostate.ov_panel_descs[event.index]
;		com = 'self -> set, overlay_panel = overlay_panel, cbar=0'
;		end

	'squish': com = 'self -> set, overlay_squish=event.select'

	'unset_overlays': com = 'self -> set, overlay_panel=strarr(n_elements(ostate.w_overlay_panel))'

	'cbar':  com = 'self -> set, cbar = event.select'

	'interpolate': com = 'self -> set, interpolate = event.select'

	'log_scale': begin
		com = 'self -> set, log_scale = event.select'
		if event.select then com=com + ', exp_scale = 0'
		end

	'exp_scale': begin
		com = 'self -> set, exp_scale = event.select'
		if event.select then com=com + ', log_scale = 0'
		end

	'color': begin
		; don't redraw if doing defaults, unless changing existing plot
		replot = 1
		if ostate.defaults.do_def then replot=ostate.defaults.do_existing
		com = ''
		self -> colors, event, replot=replot, /modal
		end

	'charsize': com = 'self -> set, charsize = event.value'

	'charthick': com = 'self -> set,charthick=event.value, ' + $
		'xthick=event.value, ythick=event.value'

	'legend_loc': com = 'self -> set, legend_loc = event.index'

	'user_label': com = 'self -> set, user_label=event.value[0]'

	else: found = 0

endcase

if sel_overlay ne -1 then begin
  overlay_panel = self -> get(/overlay_panel)
  ind = where (overlay_panel ne '', count)
  if sel_overlay eq 0 then overlay_panel[overlay_num] = '' else $
    ; remove panel number from beginning of panel names in list
    overlay_panel[overlay_num] = stregex_replace(ostate.ov_panel_descs[sel_overlay],'^[0-9]+ ', '', /once)
  ind_new = where (overlay_panel ne '', count)
  com = 'self -> set, overlay_panel = overlay_panel'
endif

if com ne '' then result = execute(com)

end

;-----

; gather up all values that wouldn't cause an event unless user hit return
; note: cw_field does not cause an event, but cw_range and cw_edroplist do cause
; event when value has changed and focus is placed on another field in widget.
; If anything's changed, set ostate.any_change to 1, and set the all the values
; into plotman object (don't bother checking which ones changed, set all)

pro plotman::specoptions_checkvals, ostate

pc = self -> get(/plot_control)

widget_control, ostate.w_timerange, get_value=timerange
timerange = anytim(timerange)
widget_control, ostate.w_yrange, get_value=yrange
widget_control, ostate.w_charsize, get_value=charsize
widget_control, ostate.w_charthick, get_value=charthick
widget_control, ostate.w_user_label, get_value=user_label

; If any of these values have changed, set any_change (which may have already been 1).
; If any_change is set, set them in object.
if (pc.pp.charsize ne charsize[0]) or $
	(pc.pp.charthick ne charthick[0]) or $
	(pc.user_label ne user_label[0]) or $
	not same_data(pc.timerange, timerange) or $
	not same_data(pc.yy.range, yrange*1.d0) or $
	(self -> color_change()) then $
		ostate.any_change = 1

if ostate.any_change then begin
	; note: use charthick for axes thickness too
	; if color changed, will already be set
	self -> set, charsize=charsize, $
		charthick=charthick, xthick=charthick, ythick=charthick, $
		user_label=user_label[0], timerange=timerange, yrange=yrange
endif

end

;-----

pro plotman::specoptions_widget, event, ostate, defaults

parent = event.top

panel_plot_types = self -> get(/all_panel_plot_type)
ov_panel_numbers = where (panel_plot_types eq 'utplot' or panel_plot_types eq 'specplot', count)
panel_descs = self -> get(/all_panel_desc)
npanel = n_elements(panel_descs)
; prepend panel number in panel list
panel_descs = trim(indgen(npanel)) + ' ' + panel_descs
ov_panel_descs = 'No Overlay'
if count gt 0 then ov_panel_descs = [ov_panel_descs, panel_descs[ov_panel_numbers]]

if defaults.do_def then $
	title = defaults.do_existing ? 'Plot Display Options for Selected Plots' : 'Plot Default Options for Future Plots' $
else title = 'Plot Display Options for Current Plot'
if not defaults.do_existing then title = 'Spectrogram ' + title

redgreen_text1 = 'Click red/green buttons to enable/disable default setting.'
redgreen_text2 = 'ONLY green items are used on exit. Red items are ignored.'

get_font, font, big_font=big_font
widget_control, default_font = font

; Add /scroll so if, once widget is populated, if we have to limit y size, it will scroll.
; For this to work on unix, child of this widget must contain full widget (to determine space needed)
tlb = widget_base (group_leader=parent, $
					title=title, $
					/base_align_center, $
;					/column, $
					ypad=0, $
					space=1,/scroll);, $
;					/modal )

w_box = widget_base (tlb, /column, /frame, space=1)
tmp = widget_label (w_box, value=title, /align_center, font=big_font)
if defaults.do_def then tmp = widget_label (w_box, value=redgreen_text1, /align_center, font=big_font)
if defaults.do_def then tmp = widget_label (w_box, value=redgreen_text2, /align_center, font=big_font)

if not defaults.do_def then begin
  scroll = 1
  y_scroll_size = 1.5
  units = 1
endif
w_overlay_base = widget_base (w_box, /column, /frame, scroll=scroll, y_scroll_size=y_scroll_size, units=units)

tmp = widget_label (w_overlay_base, value='Current Plot:  ' + self->get(/current_panel_desc), /align_left)

w_overlay_row1 = widget_base(w_overlay_base, /row, space=10)
w_squish =  plotman_defaults_wrapper(defaults, 'cw_bgroup', w_overlay_row1, $
            'Remove extra labels between overlays', $
            uvalue='squish', $
            /nonexclusive, $
            uname='overlay_squish', space=0, ypad=0 )

if not defaults.do_def then tmp = widget_button (w_overlay_row1, value='Unset all overlays', uvalue='unset_overlays')

if not defaults.do_def then w_noverlay = widget_label (w_overlay_row1, value='', /dynamic_resize) else w_noverlay=0L

; 0th overlay always reserved for self for images, so not used for xyplots.
;  w_overlay_panel indexed from 0 to n-1, but we won't use 0th.
nmax_overlay = self->get(/nmax_overlay)
w_overlay_panel = lonarr(nmax_overlay) 
w_list_panels = lonarr(nmax_overlay)

;if not defaults.do_def then begin
  for ip=1,nmax_overlay-1 do begin
    
    w_overlay = widget_base (w_overlay_base, /row, space=10)

	  w_overlay_panel[ip] = plotman_defaults_wrapper(defaults, 'widget_droplist', w_overlay, $
						title='Overlay #' + trim(ip) + ': ', $
						value=ov_panel_descs, $
						uvalue='overlay_panel', $
						sensitive=(defaults.do_def eq 0), $
						uname='c'+trim(ip)+'_'+'overlay_panel')
					
		w_list_panels[ip] = widget_button(w_overlay, value='List', uvalue='list_panels')
						
  endfor
;endif

;w_overlay_base = widget_base (w_box, /column, /frame, space=1)
;
;tmp = widget_label (w_overlay_base, value='Current Plot:  ' + self->get(/current_panel_desc), /align_left)
;
;if not defaults.do_def then begin
;	w_overlay_panel1 = widget_droplist (w_overlay_base, $
;						title='Overlay #1: ', $
;						value=ov_panel_descs, $
;						uvalue='overlay_panel1')
;
;	w_overlay_panel2 = widget_droplist (w_overlay_base, $
;						title='Overlay #2: ', $
;						value=ov_panel_descs, $
;						uvalue='overlay_panel2')
;
;	w_overlay_panel3= widget_droplist (w_overlay_base, $
;						title='Overlay #3: ', $
;						value=ov_panel_descs, $
;						uvalue='overlay_panel3')
;endif else begin
;	w_overlay_panel1 = 0L
;	w_overlay_panel2 = 0L
;	w_overlay_panel3 = 0L
;endelse
;
;w_squish =  plotman_defaults_wrapper(defaults, 'cw_bgroup', w_overlay_base, $
;						'Remove extra labels', $
;						uvalue='squish', $
;						/nonexclusive, $
;						uname='overlay_squish', space=0, ypad=0 )

w_timerange = 0L & w_xrange = 0L
w_s_base = widget_base (w_box, /column, space=0, /frame)

w_time_base = widget_base (w_s_base, $
					/row )

w_timerange = plotman_defaults_wrapper(defaults, 'cw_ut_range', w_time_base, $
				value=self->get(/utrange), $
				uvalue='axes_timerange', $
				label='', $
				space=1, ypad=1, /align_left, frame=0, $
				uname='timerange')

w_yrange_base = w_s_base

w_ybase = widget_base (w_yrange_base, $
						/row, $
						space=5 )

w_yrange = plotman_defaults_wrapper(defaults, 'cw_range', w_ybase, $
						value = [0.,0.], $
						uvalue='axes_yrange', $
						format='(g12.4)', $
						label1='Y Limits: ', $
						label2=' - ', $
						uname='yrange' )

w_reset = widget_button (w_ybase, $
					value='Reset limits', $
					/align_center, $
					/menu)

temp = widget_button (w_reset, $
						value='X only', $
						uvalue='axes_xreset' )

temp = widget_button (w_reset, $
					value='Y only', $
					uvalue='axes_yreset' )

temp = widget_button (w_reset, $
					value='X and Y', $
					uvalue='axes_xyzreset' )

w_xybase = widget_base (w_box, $
					/row, $
					space=10, /frame)

w_opt_base1 = widget_base (w_xybase, $
					/column, $
					space=0 )

tmp_base = widget_base (w_opt_base1, /row, space=0)
w_cbar = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
						'Color Bar', $
						uvalue='cbar', $
						/nonexclusive, $
						uname='cbar', space=0, ypad=0)

tmp_base = widget_base (w_opt_base1, /row, space=0)
w_interpolate = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
						'Smooth', $
						uvalue='interpolate', $
						/nonexclusive, $
						uname='interpolate', space=0, ypad=0 )

tmp_base = widget_base (w_opt_base1, /row, space=0)
w_log_scale = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
						'Scale by natural log', $
						uvalue='log_scale', $
						/nonexclusive, $
						uname='log_scale,exp_scale', space=0, ypad=0 )

tmp_base = widget_base (w_opt_base1, /row, space=0)
w_exp_scale = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
						'Scale by exponential', $
						uvalue='exp_scale', $
						/nonexclusive, $
						uname='log_scale,exp_scale', space=0, ypad=0 )

w_x = widget_base (w_xybase, /column)

temp = widget_label (w_x, value='X axis:  ')

w_xopt = widget_base (w_x, $
          /column, $
          frame=0, sensitive=1 )
; need row base so defaults red/green button will be in line with option
tmp_base = widget_base (w_xopt, /row, space=0)
w_xexact = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
          'Exact', $
          uvalue='axes_xexact', $
          /nonexclusive, $
          uname='xexact', space=0, ypad=0 )         

tmp_base = widget_base (w_xopt, /row, space=0)
w_xgrid = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
          'Grid', $
          uvalue='axes_xgridline', $
          /nonexclusive, $
          uname='xgridline', space=0, ypad=0 )
          
w_y = widget_base (w_xybase, /column)

temp = widget_label (w_y, value='Y axis:  ')

w_yopt = widget_base (w_y, $
					/column, $
					frame=0, sensitive=1 )

tmp_base = widget_base (w_yopt, /row, space=0)
w_ylog = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
					'Log', $
					uvalue='axes_ylog', $
					/nonexclusive, $
					sensitive=1, $
					uname='ylog', space=0, ypad=0 )

tmp_base = widget_base (w_yopt, /row, space=0)
w_yexact = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
					'Exact', $
					uvalue='axes_yexact', $
					/nonexclusive, $
					uname='yexact', space=0, ypad=0 )				

tmp_base = widget_base (w_yopt, /row, space=0)
w_ygrid = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
        'Grid', $
        uvalue='axes_ygridline', $
        /nonexclusive, $
        uname='ygridline', space=0, ypad=0 )

tmp_base = widget_base (w_xybase, /row)
temp = plotman_defaults_wrapper(defaults, 'widget_button', tmp_base, $
	value='Color', uvalue='color', uname='rcolors,bcolors,gcolors')

w_char_base0 = widget_base (w_box, /column, /frame)
w_char_base = widget_base (w_char_base0, /row)

w_charsize = plotman_defaults_wrapper(defaults, 'cw_field', w_char_base, $
					title='Character size: ', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='charsize', $
					uname='charsize')

w_charthick =  plotman_defaults_wrapper(defaults, 'cw_field', w_char_base, $
					title='Char/Axes Thickness: ', $
					value='', $
					xsize=2, $
					/return_events, $
					uvalue='charthick', $
					uname='charthick,xthick,ythick')

w_legend_loc = plotman_defaults_wrapper(defaults, 'widget_droplist', w_char_base, $
					title='Legend location: ', $
					value=['None', 'Upper Left', 'Upper Right', 'Lower Left', 'Lower Right', $
						'Outside Plot, Left', 'Outside Plot, Right'], $
					uvalue='legend_loc', $
					uname='legend_loc')

w_label_base = widget_base (w_char_base0, /row)

w_user_label = plotman_defaults_wrapper(defaults, 'cw_field', w_label_base, $
					/string, $
					/return_events, $
					title='User Label: ', $
					value=' ', $
					xsize=50,  $
					uvalue='user_label', $
					uname='user_label')

ostate = { $
	tlb: tlb, $
	parent: parent, $
	ov_panel_descs: ov_panel_descs, $
	w_noverlay: w_noverlay, $
	w_overlay_panel: w_overlay_panel, $
	w_list_panels: w_list_panels, $
;	w_overlay_panel1: w_overlay_panel1, $
;	w_overlay_panel2: w_overlay_panel2, $
;	w_overlay_panel3: w_overlay_panel3, $
	w_squish: w_squish, $
	w_timerange: w_timerange, $
	w_xrange: w_xrange, $
	w_yrange: w_yrange, $
	w_zrange: 0L, $
	w_xlog: 0L, $  ; need w_xlog, x_exact so general axis routines won't crash
	w_ylog: w_ylog, $
	w_xexact: w_xexact, $
	w_yexact: w_yexact, $
	w_xgrid: w_xgrid, $
	w_ygrid: w_ygrid, $
	w_zgrid: 0L, $
	w_cbar: w_cbar, $
	w_interpolate: w_interpolate, $
	w_log_scale: w_log_scale, $
	w_exp_scale: w_exp_scale, $
	w_charsize: w_charsize, $
	w_charthick: w_charthick, $
	w_legend_loc: w_legend_loc, $
	w_user_label: w_user_label }

end
