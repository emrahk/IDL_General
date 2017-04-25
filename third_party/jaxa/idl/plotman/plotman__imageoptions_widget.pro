;+
; Name: plotman__imageoptions_widget
;
; Purpose: Widget to set options for displaying images
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
; Modifications:
;   21 Dec 2000, Kim,  added sliders for x and z angles for surfaces
;	17-Feb-2001, Kim.  Added overlay separate images option.
;		Also included plotman_imgopt_widget_update routine in this file.
;	8-Jul-2001, Kim.  Accounted for overlay_panel now being an array (multiple
;		is for xy and ut plots only, images will only allow one overlay)
;	30-Aug-2001, Kim.  Added mark limb option.
;	2-Sep-2001, Kim.  Added legend_color, translate_overlay options. Rearranged widgets.
;	22-Jan-2002, Kim.  Added mark_point option (for HESSI only)
;   20-Feb-2002, Kim.  Added user_label option
;	21-Jul-2002, Kim.  Added contour_percent, contour_color contour_thickness options.  Changed auto and define
; 		contour levels to regular buttons instead of exclusive (radio) buttons)
;	07-Oct-2002, Kim.  Allow setting of contour options for overlays
;   01-Nov-2002, Kim.  Add grid spacing and color options (right now color is same as contour)
;   05-Nov-2002, Kim.  Add grid_color, limb_color, and translate_image options (before translate
;     was just for overlays)
;	22-Nov-2002, Kim.  Changed mark_limb to limb_mark for compatibility with map objects
;	24-Nov-2002, KIm.  Changed log_image, square_image to log_scale, square_scale
;	24-Nov-2002, Kim.  Renamed limb_mark to limb_plot, and made Mark Pointing option unsensitive
;		since there's no pointing info yet.
;	5-Nov-2003. z axis was desensitized for images previously (was only for surface plots)
;	20-Feb-2004, Kim.  For contours, let overlay base be sensitive (previously was sens.
;	    only for image representation.
;	22-Feb-2004, Kim.  Added lots of options for overlay contours.  Took contour options out of
;	    main image options widget, and added 'Contour Options' button - calls plotman_contoptions.
;		Reorganized rest of main image options widget.  Added limb thickness.
;	5-Apr-2004, Kim.  Changed format for xyz limits to show more digits
;	30-Jun-2004, Kim.  Added no_timestamp option
;	6-Aug-2005, Kim.  Added grid_thickness option and commented out the mark_point stuff - not using
;	25-May-2006, Kim.  Modified string format for image translate
;	23-Mar-2007, Kim.  DMZ changed xinput to not use modal base (modal on xmanager) so
;		here we also have to move the /modal from widget_base call to xmanager (don't
;		call xinput from here, but do from a widget down, plotman_contoptions)
;	9-May-2007, Kim.  Previously had separate parameters controlling contours of
;	  primary image from those controlling overlaid contours.  Now all contour info
;	  is stored in overlay params, and the 0th overlay is always reserved for self.
;	  Added overlay_ulabel, overlay_ulabel_lev params - user label for each contour
;	  (which defaults to the panel description minus part before comma and current time) and
;	  option for whether to append user defined contour labels on label. Overlay label
;	  is constructed in plot method.
;	8-Jun-2007, Kim.  Added charthick option (controls xthick and ythick too) for better PS plots.
;	23-Aug-2007, Kim.  translate_overlay was being dimensioned wrong
;	30-Oct-2007, Kim. Major changes.
;	  1. Now plotman__options handles the stuff common to all plot types, and calls this for images
;	  2. This is now a method instead of a procedure.
;	  3. Call all widgets that can we can set defaults for by calling plotman_defaults_wrapper, so
;	   that a little red or green box will appear next to option, letting user control if it
;	   should be used.  All red box items are ignored.
;	  4. Added checkvals method
;	6-Dec-2007, Kim. Smooth=1 means no smoothing now.  So need to add widget for specifying boxcar
;	  width for smoothing.  In the meantime, when user selects smoothing, set it to 2.
;	7-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont (for move of plotman to ssw gen)
; 22-Aug-2008, Kim.
;   1. Added roll option
;   2. Moved things around in widget for better alignment and clarity
;   3. Don't show translate for main image in contour option widget
;   4. Changed what shows up in contour option text list, and changed cont_option_list name
;   5. Allow separate values for smooth in x and y directions, and for each overlay
;   6. Changed rescale_image to rescale_zoom
; 26-Apr-2009, Kim. Add widgets for nmax_overlay contours in scrollable base
; 16-Nov-2009, Kim. Add list button for overlay panel selection.  On some platforms the droplist becomes
;   scrollable (windows), but on some can't select any panels that don't show on screen (mac)
; 14-Jan-2011, Kim.  Changed keyword name in call to strip_panel_desc method.
; 20-Jan-2011, Kim. Added /scroll to tlb, and removed /column.  plotman__options will limit ysize.
; 29-Jan-2013, Kim. In checkvals, added check and set for zrange
; 27-Oct-2014, Kim. Added xtitle, ytitle, title, and moved things to keep widget shorter in y dimension 
;   so easier to use on laptops.
; 25-may-2015, Kim. Added xgrid,ygrid,zgrid to extend axis major tick marks across plot (really controls plot_control
;  xx. yy. and zz.ticklen, setting it to 0. or 1.)
; 12-Aug-2015, Kim. Added panel number in overlay dropdown list and separate widget list. (have to remove it
;  when setting overlay or comparing to existing overlays though)
; 
;-
;============================================================================


;----- construct string with contour options that are not default

function cont_option_list, ip, cn, color, thick, lev, perc, trans, rot, roll, smooth

acolor = (tag_names(cn))[color]
athick = (thick ne 0. and thick ne 1) ? ' Th=' + trim(thick, '(f4.1)') : ''
alev = (lev gt 0) ? ' UserLevels' : ''
aperc = (lev gt 0 and perc) ? ' %' : ''
atrans = (ip eq 0 or same_data(trans,[0.,0.])) ? '' : '  (' + arr2str(trim(trans,'(f10.2)'), ',') + ')'
arot = (ip eq 0 or rot eq 0) ? '' : ' Rot'
aroll = (ip eq 0 or roll eq 0) ? '' : ' Roll='+trim(roll,'(f6.2)')
asmooth = (ip eq 0 or smooth[0] le 1 or smooth[1] le 1) ? '' : ' Sm'

return, acolor + athick + alev + aperc + atrans + arot + aroll + asmooth
end

;----- update widget values

pro plotman::imageopt_widget_update, ostate

w = ostate

pc = self -> get (/plot_control)
pp = pc.pp
ncolors = self->get(/ncolors)
cn = self -> get(/color_names)

surf = pc.surface_image or pc.shade_surf_image or pc.show3_image
cont_overlay = (pc.overlay_panel[0] eq 'self') or pc.show3_image

rep_index = 0
case 1 of
	pc.contour_image: rep_index = 1
	pc.overlay_panel[0] eq 'self': rep_index = 2
	pc.shade_surf_image: rep_index = 3
	pc.surface_image: rep_index = 4
	pc.show3_image: rep_index = 5
	else:
endcase

widget_control, w.w_rep, set_droplist_select=rep_index

widget_control, w.w_translate, set_value=pc.translate_overlay[*,0]
widget_control, w.w_smooth, set_value = pc.smooth_image[*,0]
widget_control, w.w_roll, set_value=trim(pc.overlay_roll[0], '(f6.2)')

widget_control, w.w_overlay_base, sensitive = surf eq 0
;for ip = 0,3 do begin
;	if ip ne 0 then begin
;		q = where (pc.overlay_panel[ip] eq ostate.image_panel_descs, count)
;		if count eq 0 then q = 0
;		widget_control, w.w_overlay_panel[ip], set_droplist_select = q[0]
;	endif
;	widget_control, w.w_contour_options[ip], set_value = $
;		cont_option_list(ip, cn, pc.overlay_color[ip]-ncolors-1, pc.overlay_thickness[ip], $
;		pc.n_overlay_levels[ip], $
;		pc.overlay_percent[ip], pc.translate_overlay[*,ip], pc.drotate_image[ip], $
;		pc.overlay_roll[ip], pc.smooth_image[*,ip])
;		;pc.overlay_label[ip], pc.overlay_style[ip])
;endfor

q = where (pc.overlay_panel[1:*] ne '', n)
widget_control, w.w_noverlay, set_value='Currently ' + trim(n)+' overlay(s) set.'

; when checking if overlay selected matches one in list, remove panel number and one space from beginning of list item
image_panel_descs = stregex_replace(ostate.image_panel_descs,'^[0-9]+ ', '', /once)
for ip=0,pc.nmax_overlay-1 do begin
	if ip ne 0 then begin	  
		q = where (pc.overlay_panel[ip] eq image_panel_descs, count)
		q = count gt 0 ? q[0] : 0
		widget_control, w.w_overlay_panel[ip], set_droplist_select = q
	endif
	widget_control, w.w_contour_options[ip], set_value = $
		cont_option_list(ip, cn, pc.overlay_color[ip]-ncolors-1, pc.overlay_thickness[ip], $
		pc.n_overlay_levels[ip], $
		pc.overlay_percent[ip], pc.translate_overlay[*,ip], pc.drotate_image[ip], $
		pc.overlay_roll[ip], pc.smooth_image[*,ip])
		;pc.overlay_label[ip], pc.overlay_style[ip])
endfor

widget_control, w.w_surf_base, sensitive=surf

widget_control, w.w_ax, set_value=trim(pc.ax_surface,'(f5.0)')
widget_control, w.w_az, set_value=trim(pc.az_surface, '(f5.0)')

widget_control, w.w_sliderax, set_value=pc.ax_surface
widget_control, w.w_slideraz, set_value=pc.az_surface

widget_control, w.w_square, set_value = pc.square_scale
widget_control, w.w_keep, set_value = pc.rescale_zoom
widget_control, w.w_cbar, set_value = pc.cbar

widget_control, w.w_log_scale, set_value = pc.log_scale
widget_control, w.w_limb_plot, set_value = pc.limb_plot
;widget_control, w.w_mark_point, set_button = pc.mark_point
widget_control, w.w_timestamp, set_value = pc.no_timestamp eq 0

widget_control, w.w_grid_sp, set_value=trim(pc.grid_spacing, '(f6.2)')
widget_control, w.w_grid_color, set_droplist_select = pc.grid_color - ncolors - 1
gthick = pc.grid_thickness eq 0. ? 1. : pc.grid_thickness
widget_control, w.w_grid_thick, set_value=trim(gthick, '(f5.2)')

if pp.charsize eq 0. then charsize=1. else charsize = pp.charsize
widget_control, w.w_charsize, set_value=trim(charsize, '(f5.2)')

widget_control, w.w_legend_loc, set_droplist_select = pc.legend_loc
widget_control, w.w_legend_color, set_droplist_select = pc.legend_color - ncolors - 1

widget_control, w.w_limb_color, set_droplist_select = pc.limb_color - ncolors - 1

lmthick = pc.limb_thickness eq 0. ? 1. : pc.limb_thickness
widget_control, w.w_limb_thick, set_value=trim(lmthick, '(f5.2)')

charthick = pp.charthick eq 0. ? 1. : pp.charthick
widget_control, w.w_charthick, set_value=strtrim(string(charthick, format='(i2)'), 2)

widget_control, w.w_xtitle, set_value=pc.xx.title
widget_control, w.w_ytitle, set_value=pc.yy.title
widget_control, w.w_title,  set_value=pp.title
widget_control, w.w_user_label, set_value=pc.user_label

end

;--- Event handler for plotman_imageoptions (can't be a method, so this calls the method)

pro plotman_imageoptions_event, event
widget_control, event.top, get_uvalue=ostate
ostate.obj -> imageoptions_event, event
end

;--- The real event handler method

pro plotman::imageoptions_event, event, com, exit, redraw, found

found = 1

widget_control, event.top, get_uvalue=ostate

widget_control, event.id, get_uvalue=uvalue


if strpos(uvalue, 'contour_options') ne -1 then begin
	ov_number = ssw_strsplit(uvalue, '_', /tail, head=uvalue)
	uvalue=uvalue[0]
endif

sel_overlay = -1

case uvalue of

	'rep': begin
		overlay_panel = (self -> get(/overlay_panel))
		if event.index lt 2 and overlay_panel[0] eq 'self' then overlay_panel[0] = ''
		if event.index gt 2 then overlay_panel[*] = ''
		contour_image=event.index eq 1
		if event.index eq 2 then overlay_panel[0]='self'
		shade_surf_image=event.index eq 3
		surface_image=event.index eq 4
		show3_image=event.index eq 5
		com = 'self -> set, contour_image=contour_image, ' + $
			'overlay_panel=overlay_panel,' + $
			'shade_surf_image = shade_surf_image, ' + $
			'surface_image = surface_image, ' + $
			'show3_image = show3_image'
		;if contour or contour over image selected, and ulabel isn't defined, set it
		if event.index eq 2 or event.index eq 1 then begin
			overlay_ulabel = self -> get(/overlay_ulabel)
			if overlay_ulabel[0] eq '' then $
				overlay_ulabel[0] = self->strip_panel_desc(/current)
			com = com + ', overlay_ulabel=overlay_ulabel'
		endif
		end

;	'translate': begin
;		translate_overlay = self -> get(/translate_overlay)
;		translate_overlay[*,0] = event.value
;		com = 'self -> set, translate_overlay = translate_overlay'
;		end

  'color': begin
    ; don't redraw if doing defaults, unless changing existing plot
    replot = 1
    if ostate.defaults.do_def then replot=ostate.defaults.do_existing
    com = ''
    self -> colors, event, replot=replot, /modal
    end

  'translate': com = 'self -> set, c0_translate_overlay = event.value'

  'smooth_image': com = 'self -> set, c0_smooth_image = event.value'

  'roll': com = 'self -> set, c0_overlay_roll = event.value'

;	'contour_options_main': begin
;		_extra = plotman_contoptions (group=event.top, plotman_obj=self)
;		if size(_extra,/tname) eq 'STRUCT' then com = 'self -> set, _extra=_extra'
;		end

	'contour_options': begin
		green_save = *ostate.defaults.green_wid
		*ostate.defaults.green_wid = -1
		_extra = self -> contoptions (ostate.defaults, group=event.top, ov_number=ov_number)
		if size(_extra,/tname) eq 'STRUCT' then begin
			com = 'self -> set, _extra=_extra'
			widget_control, ostate.w_contour_buttons[ov_number], set_uname=arr2str(tag_names(_extra),',')
		endif
		*ostate.defaults.green_wid = green_save

		end
		
	; if sel_overlay is set by either of the next two	sections to other than -1, set overlay at end of case
  'list_panels': begin  ;added 16-nov-09 for Macs and Linux
    overlay_num = (where (event.id eq ostate.w_list_panels))[0]
    status = 0
    title = 'Select panel for contour #' + trim(overlay_num)
    overlay_panel = self -> get(/overlay_panel) 
    sel_overlay = xsel_list(ostate.image_panel_descs, title=title, initial=overlay_panel[overlay_num], ysize=30, $
      /index, /no_remove, /no_sort, status=status)
    if status eq 0 then sel_overlay = -1
    end
    
	'overlay_panel': begin
		overlay_num = (where (event.id eq ostate.w_overlay_panel))[0]
		sel_overlay = event.index
		end

	'unset_overlays':  begin
		overlay_panel = self->get(/overlay_panel)
		for ip = 1,n_elements(overlay_panel)-1 do overlay_panel[ip]=''  ; don't unset 0th (base)
		com = 'self -> set, overlay_panel=overlay_panel'
		end

	'log_scale': com = 'self -> set, log_scale = event.select'

	'limb_plot': com = 'self -> set, limb_plot = event.select'

	'mark_point': com = 'self -> set, mark_point = event.select'

	'timestamp': com = 'self -> set, no_timestamp = event.select eq 0'

	'square_scale': com = 'self -> set, square_scale = event.select'

	'rescale_zoom': com = 'self -> set, rescale_zoom = event.select'

	'cbar':  com = 'self -> set, cbar = event.select'

	'ax_surface': com = 'self -> set, ax_surface = event.value'

	'az_surface': com = 'self -> set, az_surface = event.value'

	'sliderax':  begin
		com = 'self -> set, ax_surface = event.value'
		widget_control, ostate.w_ax, set_value=event.value
		end

	'slideraz':  begin
		com = 'self -> set, az_surface = event.value'
		widget_control, ostate.w_az, set_value=event.value
		end

	'grid_spacing': com = 'self -> set, grid_spacing=event.value'

	'grid_color': begin
		cn = self -> get(/color_names)
		com = 'self -> set, grid_color = cn.(event.index)'
		end

	'grid_thickness': com = 'self -> set, grid_thickness = event.value'

	'charsize': com = 'self -> set, charsize = event.value'

	'charthick': com = 'self -> set,charthick=event.value, ' + $
		'xthick=event.value, ythick=event.value'

	'legend_loc': com = 'self -> set, legend_loc = event.index'

	'legend_color': begin
		cn = self -> get(/color_names)
		com = 'self -> set, legend_color = cn.(event.index)'
		end

	'limb_color': begin
		cn = self -> get(/color_names)
		com = 'self -> set, limb_color = cn.(event.index)'
		end

	'limb_thickness': com = 'self -> set, limb_thickness = event.value'

  'xtitle': com = 'self -> set, xtitle=event.value[0]'

  'ytitle': com = 'self -> set, ytitle=event.value[0]'
  
  'title': com = 'self -> set, title=event.value[0]'
  
	'user_label': com = 'self -> set, user_label=event.value[0]'

	else: found = 0

endcase

if sel_overlay ne -1 then begin
    overlay_panel = self -> get(/overlay_panel)
    overlay_ulabel = self -> get(/overlay_ulabel)
    overlay_ulabel_lev = self -> get(/overlay_ulabel_lev)

    if sel_overlay eq 0 then begin
      ; if setting overlay to None, then reset ulabel and ulabel_lev to defaults
      overlay_panel[overlay_num] = ''
      overlay_ulabel[overlay_num] = ''
      overlay_ulabel_lev[overlay_num] = 1

    endif else begin
      ; Otherwise, set overlay to panel selected (after removing panel number). Set user label to 
      ; the panel description after removing the 'Cube' and current time parts of the string. Leave
      ; ulabel_lev (option to append contour levels) alone.
      overlay_panel[overlay_num] = stregex_replace(ostate.image_panel_descs[sel_overlay],'^[0-9]+ ', '', /once)
      overlay_ulabel[overlay_num] = self->strip_panel_desc(panel_desc=overlay_panel[overlay_num])
    endelse

    com = 'self -> set, overlay_panel = overlay_panel,' + $
      'overlay_ulabel=overlay_ulabel, overlay_ulabel_lev=overlay_ulabel_lev'
endif

if com ne '' then result = execute(com)

end

;-----

; gather up all values that wouldn't cause an event unless user hit return
; note: cw_field does not cause an event, but cw_range and cw_edroplist do cause
; event when value has changed and focus is placed on another field in widget.
; If anything's changed, set ostate.any_change to 1, and set the all the values
; into plotman object (don't bother checking which ones changed, set all)

pro plotman::imageoptions_checkvals, ostate

pc = self -> get(/plot_control)

widget_control, ostate.w_roll, get_value=roll
widget_control, ostate.w_xrange, get_value=xrange
widget_control, ostate.w_yrange, get_value=yrange
widget_control, ostate.w_zrange, get_value=zrange
widget_control, ostate.w_xgrid, get_value=xgridline
widget_control, ostate.w_ygrid, get_value=ygridline
widget_control, ostate.w_zgrid, get_value=zgridline
widget_control, ostate.w_ax, get_value=ax_surface
widget_control, ostate.w_az, get_value=az_surface
widget_control, ostate.w_grid_sp, get_value=grid_spacing
widget_control, ostate.w_limb_thick, get_value=limb_thickness
widget_control, ostate.w_grid_thick, get_value=grid_thickness
widget_control, ostate.w_charsize, get_value=charsize
widget_control, ostate.w_charthick, get_value=charthick
widget_control, ostate.w_xtitle, get_value=xtitle
widget_control, ostate.w_ytitle, get_value=ytitle
widget_control, ostate.w_title,  get_value=title
widget_control, ostate.w_user_label, get_value=user_label

; If any of these values have changed, set any_change (which may have already been 1).
; If any_change is set, set them in object.
if (pc.overlay_roll[0] ne roll) or $
  (pc.ax_surface ne ax_surface[0]) or $
  (pc.az_surface ne az_surface[0]) or $
  (pc.pp.charsize ne charsize[0]) or $
  (pc.pp.charthick ne charthick[0]) or $
  (pc.xx.title ne xtitle[0]) or $
  (pc.yy.title ne ytitle[0]) or $
  (pc.pp.title ne title[0]) or $  
  (pc.user_label ne user_label[0]) or $
  (pc.grid_spacing ne grid_spacing) or $
  (pc.limb_thickness ne limb_thickness) or $
  (pc.grid_thickness ne grid_thickness) or $
  not same_data(pc.xx.range, xrange*1.d0) or $
  not same_data(pc.yy.range, yrange*1.d0) or $
  not same_data(pc.zz.range, zrange*1.d0) or $
  (pc.xx.ticklen ne xgridline) or $
  (pc.yy.ticklen ne ygridline) or $
  (pc.zz.ticklen ne zgridline) or $
  (self -> color_change()) then $
  	ostate.any_change = 1

;print,'redraw, any_change, any_change_atall = ', redraw,ostate.any_change, ostate.any_change_atall

if ostate.any_change then begin
	; note: use charthick for axes thickness too
	; if color changed, will already be set
	self -> set, c0_overlay_roll=roll, $
	  ax_surface=ax_surface, az_surface=az_surface, $
		charsize=charsize, charthick=charthick, xthick=charthick, ythick=charthick, $
		user_label=user_label[0], xrange=xrange, timerange=timerange, yrange=yrange, zrange=zrange, $
		xgridline=xgridline, ygridline=ygridline, zgridline=zgridline, $
		grid_spacing=grid_spacing, limb_thickness=limb_thickness, grid_thickness=grid_thickness, $
		xtitle=xtitle, ytitle=ytitle, title=title
endif

end

;-----  plotman_imageoptions main routine

pro plotman::imageoptions_widget, event, ostate, defaults

parent = event.top

rep_options = ['Image', 'Contour', 'Contour Overlaid on Image', 'Shaded Surface', $
	'Wire Surface', 'Image, Surface, and Contour']

panel_plot_types = self -> get(/all_panel_plot_type)
image_panel_numbers = where (panel_plot_types eq 'image', count)
panel_descs = self -> get(/all_panel_desc)
npanel = n_elements(panel_descs)
; prepend panel number in panel list
panel_descs = trim(indgen(npanel)) + ' ' + panel_descs
image_panel_descs = 'No Contour'
if count gt 0 then image_panel_descs = [image_panel_descs, panel_descs[image_panel_numbers]]

if defaults.do_def then $
	title = defaults.do_existing ? 'Plot Display Options for Selected Plots' : 'Plot Default Options for Future Plots' $
else title = 'Plot Display Options for Current Plot'
if not defaults.do_existing then title = 'Image ' + title

redgreen_text1 = 'Click red/green buttons to enable/disable default setting.'
redgreen_text2 = 'ONLY green items are used on exit. Red items are ignored.'

get_font, font, big_font=big_font
widget_control, default_font = font

; Add /scroll so if, once widget is populated, if we have to limit y size, it will scroll.
; For this to work on unix, child of this widget must contain full widget (to determine space needed)
tlb = widget_base (group_leader=parent, $
					title=title, $
					/base_align_center, $
					ypad=2, $
					space=3, /scroll)

w_box = widget_base (tlb, /column, /frame, space=3)
tmp = widget_label (w_box, value=title, /align_center, font=big_font)
if defaults.do_def then tmp = widget_label (w_box, value=redgreen_text1, /align_center, font=big_font)
if defaults.do_def then tmp = widget_label (w_box, value=redgreen_text2, /align_center, font=big_font)

w_image_base = widget_base (w_box, /column, space=0)
w_image_base0 = widget_base (w_image_base, /row, space=2)

tmp_base = widget_base (w_image_base0, /row, /align_center)
w_rep = plotman_defaults_wrapper(defaults, 'widget_droplist', tmp_base, $
;					title='Show:    ', $
					value=rep_options, $
					uvalue='rep', $
					uname='contour_image,shade_surf_image,surface_image,show3_image,c0_overlay_panel')

;tmp_base = widget_base (w_image_base1, /row)
temp = plotman_defaults_wrapper(defaults, 'widget_button', w_image_base0, $
  value='Color', uvalue='color', uname='rcolors,bcolors,gcolors', /align_center)

;tmp_base = widget_base (w_image_base0, /row)
w_translate = plotman_defaults_wrapper(defaults, 'cw_range', w_image_base0, $
            uvalue='translate', $
            value=[0.,0.], $
            format='(f8.2)', $
            xsize=6, $
            label1='Translate X: ', $
            label2=' Y:', space=0, xpad=0,$
            uname='translate_overlay' )

;tmp_base = widget_base (w_image_base0, /row, space=0)
w_smooth = plotman_defaults_wrapper(defaults, 'cw_range', w_image_base0, $
            uvalue='smooth_image', $
            value=[0,0], $
            format='(i3)', $
            xsize=3, $
            label1='Smoothing Width X: ', $
            label2=' Y:', space=0, xpad=0, $
            uname='smooth_image' )

tmp_base = widget_base (w_image_base0, /row, /align_bottom)
w_roll = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
          title='Roll: ', $
          value=0., $
          xsize=6, $
          /return_events, $
          uvalue='roll', $
          uname='c0_overlay_roll', /align_bottom)

nmax_overlay = self->get(/nmax_overlay)
w_contour_options = lonarr(nmax_overlay)
w_contour_buttons  = lonarr(nmax_overlay)

w_image_base1 = widget_base (w_image_base, /row, space=5)
tmp = widget_label(w_image_base1, value='Base Image Contours: ')
w_contour_options[0] = widget_label(w_image_base1, value='', /dynamic_resize)
w_contour_buttons[0] = plotman_defaults_wrapper(defaults, 'widget_button', w_image_base1, $
						value='Contour Options', uvalue='contour_options_0', uname='none')

colorstr = self -> get(/color_names)

w_overlay_base = widget_base (w_box, /column, /frame, space=0, /scroll, y_scroll_size=1.5, units=1)

w_overlay_row1 = widget_base(w_overlay_base, /row, space=10)
tmp = widget_label (w_overlay_row1, value='Base Image:  ' + self->get(/current_panel_desc), /align_left)
tmp = widget_button (w_overlay_row1, value='Unset all overlays', uvalue='unset_overlays')
w_noverlay = widget_label (w_overlay_row1, value='', /dynamic_resize)

w_overlay_panel = lonarr(nmax_overlay)  ; 0th won't be used (for base image)
w_list_panels = lonarr(nmax_overlay)

; 0th overlay is reserved for image itself, if contour over image is selected
for ip = 1,nmax_overlay-1 do begin
	w_overlay = widget_base (w_overlay_base, /row, space=10)

	w_overlay_panel[ip] = plotman_defaults_wrapper(defaults, 'widget_droplist', w_overlay, $
					title='Contour #' + trim(ip) + ': ', $
					value=image_panel_descs, $
					uvalue='overlay_panel', $
					sensitive=(defaults.do_def eq 0), $
					uname='c'+trim(ip)+'_'+'overlay_panel')

  w_list_panels[ip] = widget_button(w_overlay, value='List', uvalue='list_panels')
	w_contour_options[ip] = widget_label (w_overlay, value='', /dynamic_resize)
	w_contour_buttons[ip] = plotman_defaults_wrapper(defaults, 'widget_button', w_overlay, $
		value='Contour Options', uvalue='contour_options_'+trim(ip), uname='none')
endfor

w_axessurfleg = widget_base(w_box, /row, space=0)

w_axes_base = widget_base (w_axessurfleg, /row, /frame)

w_xyz_base = widget_base (w_axes_base, /column, space=0, ypad=0)

tmp_base = widget_base (w_xyz_base, /row, space=0, xpad=0, ypad=0)

w_xgrid = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
  'Grid', $
  label_left='X: ', $
  uvalue='axes_xgridline', $
  /nonexclusive, $
  uname='xgridline', space=0, ypad=0 )
  
w_xrange = plotman_defaults_wrapper(defaults, 'cw_range', tmp_base, $
					uvalue='axes_xrange', $
					value=[0.,0.], $
					format='(g12.4)', $
					label1='Limits: ', $
					label2=' - ', $
					uname='xrange', xpad=0, ypad=0, space=0 )

tmp_base = widget_base (w_xyz_base, /row, space=0, xpad=0, ypad=0)

w_ygrid = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
  'Grid', $
  label_left='Y: ', $
  uvalue='axes_ygridline', $
  /nonexclusive, $
  uname='ygridline', space=0, ypad=0 )

w_yrange = plotman_defaults_wrapper(defaults, 'cw_range', tmp_base, $
						uvalue='axes_yrange', $
						value=[0.,0.], $
						format='(g12.4)', $
						label1='Y Limits: ', $
						label2=' - ', $
						uname='yrange', xpad=0, ypad=0, space=0 )

tmp_base = widget_base (w_xyz_base, /row, space=0, xpad=0, ypad=0)

w_zgrid = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp_base, $
  'Grid', $
  label_left='Z: ', $
  uvalue='axes_zgridline', $
  /nonexclusive, $
  uname='zgridline', space=0, ypad=0 )

w_zrange = plotman_defaults_wrapper(defaults, 'cw_range', tmp_base, $
						uvalue='axes_zrange', $
						value=[0.,0.], $
						format='(g12.4)', $
						label1='Z Limits: ', $
						label2=' - ', $
						uname='zrange', xpad=0, ypad=0, space=0)

w_reset = widget_button (w_axes_base, $
					value='Reset', $
					/align_center, $
					/menu)

temp = widget_button (w_reset, $
						value='X only', $
						uvalue='axes_xreset' )

temp = widget_button (w_reset, $
					value='Y only', $
					uvalue='axes_yreset' )

temp = widget_button (w_reset, $
					value='Z only', $
					uvalue='axes_zreset' )

temp = widget_button (w_reset, $
					value='All', $
					uvalue='axes_xyzreset' )

w_surf_base = widget_base (w_axessurfleg, /column, /frame, /base_align_center)

temp = widget_label (w_surf_base, value='                    Surface Plot Rotation angle (degrees):                            ')

w_surf_base_row = widget_base (w_surf_base, /row, space=3)

w_surf_base1 = widget_base (w_surf_base_row, /column, /align_center)

tmp_base = widget_base (w_surf_base1, /row)
w_ax = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
					title='X axis:', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='ax_surface', $
					uname='ax_surface')

w_sliderax = widget_slider (w_surf_base1, minimum=-180, maximum=180, $
	value=30., uvalue='sliderax', /suppress, units=1, xsize=1.6, scroll=5.)

w_surf_base2 = widget_base (w_surf_base_row, /column, /align_center)

tmp_base = widget_base (w_surf_base2, /row)
w_az = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
					title='Z axis:', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='az_surface', $
					uname='az_surface')

w_slideraz = widget_slider (w_surf_base2, minimum=-180, maximum=180, $
	value=30., uvalue='slideraz', /suppress, units=1, xsize=1.6, scroll=5.)

w_legend_base = widget_base (w_axessurfleg, /column, /frame);, /base_align_center)

tmp = widget_label(w_legend_base, value='Legend:',/align_center)

tmp_base = widget_base (w_legend_base, /row)
w_legend_loc = plotman_defaults_wrapper(defaults, 'widget_droplist', tmp_base, $
;          title='Location: ', $
          value=[ 'No Legend', 'Upper Left', 'Upper Right', 'Lower Left', 'Lower Right'], $
          uvalue='legend_loc', $
          uname='legend_loc')

tmp_base = widget_base (w_legend_base, /row)
w_legend_color = plotman_defaults_wrapper(defaults, 'widget_droplist', tmp_base, $
;          title='Color: ', $
          value=tag_names(colorstr), $
          uvalue='legend_color', $
          uname='legend_color')
          
w_opt_base = widget_base (w_box, /row, /frame, space=0);, /align_center)

w_opt_base1 = widget_base (w_opt_base, /column, space=0, ypad=0 )

tmp = widget_base (w_opt_base1, /row, space=0)
w_square = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp, 'Equal x,y scale', $
	uvalue='square_scale', /nonexclusive, uname='square_scale', space=0, ypad=0)

tmp = widget_base (w_opt_base1, /row, space=0)
w_keep = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp, 'Rescale in zoom', $
	uvalue='rescale_zoom', /nonexclusive, uname='rescale_zoom', space=0, ypad=0)

tmp = widget_base (w_opt_base1, /row, space=0)
w_cbar = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp, 'Color Bar', $
	uvalue='cbar', /nonexclusive, uname='cbar', space=0, ypad=0)

tmp = widget_base (w_opt_base1, /row, space=0)
w_log_scale = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp, 'Scale by log base 10', $
	uvalue='log_scale', /nonexclusive, uname='log_scale', space=0, ypad=0)

;w_mark_point = widget_button (w_opt_base1, value='Mark Pointing', uvalue='mark_point', $
;					sensitive=0 )	; temporary until there's pointing!

tmp = widget_base (w_opt_base1, /row, space=0)
;w_limbbase = widget_base (w_opt_base2, /row, /nonexclusive, space=0)
w_limb_plot = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp, 'Mark limb', $
  uvalue='limb_plot', /nonexclusive, uname='limb_plot', space=0, ypad=0)

w_opt_base2= widget_base (w_opt_base, /column, space=1)

tmp_base = widget_base (w_opt_base2, /row)
w_limb_color = plotman_defaults_wrapper(defaults, 'widget_droplist', tmp_base, $
					title='Limb Color: ', $
					value=tag_names(colorstr), $
					uvalue='limb_color', $
					uname='limb_color')

tmp_base = widget_base (w_opt_base2, /row)
w_limb_thick = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
					title='Limb Thickness: ', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='limb_thickness', $
					uname='limb_thickness')

tmp_base = widget_base (w_opt_base2, /row)
w_charsize = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
          title='Character size: ', $
          value='', $
          xsize=5, $
          /return_events, $
          uvalue='charsize', $
          uname='charsize')

tmp_base = widget_base (w_opt_base2, /row)
w_charthick =  plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
          title='Char/Axes Thickness: ', $
          value='', $
          xsize=2, $
          /return_events, $
          uvalue='charthick', $
          uname='charthick,xthick,ythick')

w_opt_base3= widget_base (w_opt_base, /column, space=5)

tmp_base = widget_base (w_opt_base3, /row)
w_grid_sp = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
					title='Grid spacing (deg): ', $
					value='', $
					xsize=6, $
					/return_events, $
					uvalue='grid_spacing', $
					uname='grid_spacing')

tmp_base = widget_base (w_opt_base3, /row)
w_grid_color = plotman_defaults_wrapper(defaults, 'widget_droplist', tmp_base, $
					title='Grid Color: ', $
					value=tag_names(colorstr), $
					uvalue='grid_color', $
					uname='grid_color')

tmp_base = widget_base (w_opt_base3, /row, ypad=0)
w_grid_thick = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
					title='Grid Thickness: ', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='grid_thickness', $
					uname='grid_thickness', ypad=0)

tmp = widget_base (w_opt_base3, /row, space=0)
w_timestamp = plotman_defaults_wrapper(defaults, 'cw_bgroup', tmp, 'Timestamp', $
  uvalue='timestamp', /nonexclusive, uname='no_timestamp', space=0, ypad=0)

;w_opt_base4 = widget_base (w_opt_base, /column, space=0)

w_title_base = widget_base(w_opt_base, /column, space=0)

tmp_base = widget_base (w_title_base, /row)
w_xtitle = plotman_defaults_wrapper(defaults, 'cw_label' ,tmp_base, $
          /return_events, $
          title='X Title: ', $
          value='', $
          xsize=30,  $
          uvalue='xtitle', $
          uname='xtitle')
          
tmp_base = widget_base (w_title_base, /row)          
w_ytitle = plotman_defaults_wrapper(defaults, 'cw_label' ,tmp_base, $
          /return_events, $
          title='Y Title: ', $
          value='', $
          xsize=30,  $
          uvalue='ytitle', $
          uname='ytitle')          
          
tmp_base = widget_base (w_title_base, /row)
w_title = plotman_defaults_wrapper(defaults, 'cw_label' ,tmp_base, $
          /return_events, $
          title='Title:     ', $
          value='', $
          xsize=30,  $
          uvalue='title', $
          uname='title')
          
tmp_base = widget_base (w_title_base, /row)
w_user_label = plotman_defaults_wrapper(defaults, 'cw_field', tmp_base, $
          /string, $
          /return_events, $
          title='User Label: ', $
          value=' ', $
          xsize=30, $
          uvalue='user_label', $
          uname='user_label')

ostate = { $
	tlb: tlb, $
	parent: parent, $
	image_panel_descs: image_panel_descs, $
	w_rep: w_rep, $
	w_translate: w_translate, $
  w_smooth: w_smooth, $
	w_roll: w_roll, $
	w_overlay_base: w_overlay_base, $
	w_noverlay: w_noverlay, $
	w_overlay_panel: w_overlay_panel, $
	w_list_panels: w_list_panels, $
	w_contour_options: w_contour_options, $
	w_contour_buttons: w_contour_buttons, $

	w_surf_base: w_surf_base, $
	w_ax: w_ax, $
	w_az: w_az, $
	w_sliderax: w_sliderax, $
	w_slideraz: w_slideraz, $

	w_log_scale: w_log_scale, $
	w_limb_plot: w_limb_plot, $
	;w_mark_point: w_mark_point, $
	w_timestamp: w_timestamp, $
	w_keep: w_keep, $
	w_square: w_square, $
	w_cbar: w_cbar, $

	w_grid_sp: w_grid_sp, $
	w_grid_color: w_grid_color, $
	w_grid_thick: w_grid_thick, $
	w_charsize: w_charsize, $
	w_legend_loc: w_legend_loc, $
	w_legend_color: w_legend_color, $
	w_charthick: w_charthick, $
	w_limb_color: w_limb_color, $
	w_limb_thick: w_limb_thick, $
	w_xtitle: w_xtitle, $
  w_ytitle: w_ytitle, $
  w_title: w_title, $
	w_user_label: w_user_label, $
	w_timerange: 0L, $
	w_xrange: w_xrange, $
	w_yrange: w_yrange, $
	w_zrange: w_zrange, $
	w_xlog: 0L, $
	w_ylog: 0L, $
	w_xexact: 0L, $
	w_yexact: 0L, $
	w_xgrid: w_xgrid, $
	w_ygrid: w_ygrid, $
	w_zgrid: w_zgrid }

end
