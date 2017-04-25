; widget interface to set plotman contour options
; Written: Kim Tolbert, 21-Feb-2004
; Modifications:
;	24-Mar-2004, Kim.  Image range was from base image, not image being overlaid. Fixed.
;	   Also, changed format so small numbers don't display as 0.0
;	16-Nov-2005, Kim. For some types of data, the image isn't in *(*panel).saved_data.data -
;	   but it might contain the object.  In that case, do a getdata to get the image.
;	25-May-2006, Kim.  Modified string format for image translate
;	23-Mar-2007, Kim.  DMZ changed xinput to not use modal base (modal on xmanager) so
;		don't call xinput with /modal, and here we also have to move the /modal
;		from widget_base call to xmanager.
;	9-May-2007, Kim.  Added ulabel and ulabel_lev controls.
;		Got rid of overlay keyword since now all contours are handled as overlays
;		in the 0th overlay...parameters (previously separate params for primary image)
;		Also added a button to copy user-defined contour levels
;		and percent choice to all overlays.
;	20-Oct-2007, Kim.  Made into a method, and made work with new defaults stuff (use
;		plotman_defaults_wrapper to call widgets instead of calling directly to get red/green boxes)
;	18-Mar-2008, Kim. When retrieving image, if it's a structure, get struct.data
; 5-Sep-2008, Kim.  Added overlay_roll and smooth. Include widgets for translate, roll,
;   and smooth only on contours other than the 0th (since those widgets are on main image widget).
; 03-Feb-2009, Kim. Now have 12 max overlays, not 4, so use nmax_overlay prop in copy to all levels.
; 08-Apr-2013, Kim. In contoptions, make sure panel is a pointer before getting image out of it.
; 08-Mar-2015, Kim. Added nolabel option, and selections for which options to copy to all contours

function plotman_contoptions_getlevels, state
if *state.n_levels gt 0 then begin
	levels = trim (string ((*state.levels)[0:*state.n_levels-1], format='(g15.4)'))
	return, arr2str(levels,', ')
endif else return,''
end

;-----

pro plotman_contoptions_widget_update, state

widget_control, state.w_color, set_droplist_select = *state.color - state.ncolors - 1
thick = *state.thickness eq 0. ? 1. : *state.thickness
widget_control, state.w_thickness, set_value=trim(thick, '(f5.1)')
widget_control, state.w_style, set_droplist_select = *state.style
widget_control, state.w_label, set_value=*state.label
if xalive(state.w_translate) then widget_control, state.w_translate, set_value=*state.translate
if xalive(state.w_rotate) then widget_control, state.w_rotate, set_value=*state.rotate
if xalive(state.w_roll) then widget_control, state.w_roll, set_value=trim(*state.roll, '(f6.2)')
if xalive(state.w_smooth) then widget_control, state.w_smooth, set_value=*state.smooth

widget_control, state.w_ulabel, set_value=*state.ulabel, sensitive=(*state.nolabel eq 0)
widget_control, state.w_ulabel_lev, set_value=*state.ulabel_lev, sensitive=(*state.nolabel eq 0)

widget_control, state.w_nolabel, set_value=*state.nolabel

widget_control, state.w_percent, set_value=*state.percent

levs = plotman_contoptions_getlevels(state)
val = levs eq '' ? 'Levels are autodefined' : 'Levels: ' + levs
widget_control, state.w_level_text, set_value=val


end

;-----

pro plotman_contoptions_event, event

widget_control, event.top, get_uvalue=state
widget_control, event.id, get_uvalue=uvalue

if state.defaults.do_def then plotman_defaults_event, state, event, uvalue

exit = 0
case uvalue of

	'color': *state.color = event.index + state.ncolors + 1

	'style': *state.style = event.index

	'contour_auto': begin
		if event.select then begin
			*state.n_levels = 0
			*state. levels = *state.levels * 0
		endif
		end

	'contour_define': begin

		if event.select then begin
			image = state.image
			dtype = size(image, /type)
			if image[0] eq -1 or (dtype gt  0 and dtype lt 6 and size(image,/n_dim) eq 2) then begin
				range = image[0] ne -1 ? strtrim (string (minmax (image), format='(g15.4)'), 2) : ['?','?']
				levs = plotman_contoptions_getlevels(state)
				widget_offset, event.top, xoffset, yoffset
				if *state.percent then $
					instruct =['Enter contour level as percent of maximum separated by commas', $
						'  e.g. 10,20,50,80'] $
				else $
					instruct = ['Enter contour levels separated by commas', $
						'  e.g. 200,400,600']
				xinput, levs, $
					[' ', $
					'Range of image data = ' + range[0] + ' - ' + range[1], $
					' ', $
					instruct[0], $
					instruct[1], $
					' '], $
					group=event.top, xoff=xoffset,yoff=yoffset, ysize=1, max_len=50, status=status;, /modal

				; if clicked Accept, and text in box changed, then get new contour levels
				if status and levs ne '' then begin
					arr = str2arr (levs, ',')
					*state.n_levels = n_elements (arr)
					(*state.levels)[0:*state.n_levels-1] = float(arr)
				endif
			endif else begin
				err_msg =  "Can't compute range of data"
				print,err_msg
				a = dialog_message(err_msg)
			endelse

		endif
		end

	'cancel': begin
		*state.cancel = 1
		exit = 1
		end

	'accept': exit = 1

	'donothing':

	else:

	endcase

widget_control, state.w_thickness, get_value = thickness & *state.thickness = thickness[0]
widget_control, state.w_label, get_value = label & *state.label = label

if xalive(state.w_translate) then begin
  widget_control, state.w_translate, get_value = translate & *state.translate = translate
endif

if xalive(state.w_smooth) then begin
  widget_control, state.w_smooth, get_value = smooth & *state.smooth = smooth
endif

widget_control, state.w_copy_thick, get_value = copy_thick & *state.copy_thick = copy_thick
widget_control, state.w_copy_style, get_value = copy_style & *state.copy_style = copy_style
widget_control, state.w_copy_nolabel, get_value = copy_nolabel & *state.copy_nolabel = copy_nolabel
widget_control, state.w_copy_levs, get_value = copy_levs & *state.copy_levs = copy_levs
widget_control, state.w_copy_ulabel_lev, get_value = copy_ulabel_lev & *state.copy_ulabel_lev = copy_ulabel_lev

widget_control, state.w_ulabel, get_value=ulabel & *state.ulabel = ulabel
widget_control, state.w_ulabel_lev, get_value=ulabel_lev & *state.ulabel_lev = ulabel_lev
widget_control, state.w_nolabel, get_value=nolabel & *state.nolabel = nolabel


if xalive(state.w_rotate) then begin
	widget_control, state.w_rotate, get_value = rotate & *state.rotate = rotate
endif

if xalive(state.w_roll) then begin
  widget_control, state.w_roll, get_value = roll & *state.roll = roll
endif

widget_control, state.w_percent, get_value = percent & *state.percent = percent

widget_control, state.w_base, set_uvalue=state

if exit then begin
	if state.defaults.do_def then begin
		*state.def_struct = plotman_defaults_getvals(state, status=status)
	endif
	widget_control, event.top, /destroy
	return
endif

plotman_contoptions_widget_update, state

end

;-----

function plotman::contoptions, defaults, group=group, ov_number=ov_number

checkvar, ov_number, 0

; if setting general defaults, may not have an image yet, set image to -1
if defaults.do_def and not defaults.do_existing then begin
	image = -1
endif else begin
	if ov_number eq 0 then begin
		image = self -> get(/saved_data_data)
	endif else begin
		desc = (self -> get(/overlay_panel)) [ov_number]
		panel = self -> desc2panel(desc)
		image = ptr_valid(panel) ? *(*panel).saved_data.data : -1
		if is_struct(image) then image = image.data
		if obj_valid(image[0]) then image = image->getdata()
	endelse
endelse

pc = self.plot_control
struct = str_subset(pc, $
	['drotate_image', 'overlay_roll', 'smooth_image', $
	 'translate_overlay', 'overlay_color', $
	 'overlay_thickness', 'overlay_label', 'overlay_style', $
	 'n_overlay_levels', 'overlay_levels', 'overlay_percent', $
	 'overlay_nolabel', 'overlay_ulabel', 'overlay_ulabel_lev'] )

color = struct.overlay_color[ov_number]
thickness =  struct.overlay_thickness[ov_number]
style =  struct.overlay_style[ov_number]
label =  struct.overlay_label[ov_number]
translate =  struct.translate_overlay[*,ov_number]
smooth = struct.smooth_image[*,ov_number]
rotate =  struct.drotate_image[ov_number]
roll = struct.overlay_roll[ov_number]
n_levels =  struct.n_overlay_levels[ov_number]
levels =  struct.overlay_levels[*,ov_number]
percent =  struct.overlay_percent[ov_number]
nolabel = struct.overlay_nolabel[ov_number]
ulabel = struct.overlay_ulabel[ov_number]
ulabel_lev = struct.overlay_ulabel_lev[ov_number]

colorstr = self -> get(/color_names)
ncolors = self -> get(/ncolors)
linestyles = ['Solid', 'Dotted', 'Dashed', 'Dash Dot', 'Dash Dot Dot', 'Long Dashes']

copy_thick = 0
copy_style = 0
copy_nolabel = 0
copy_levs = 0
copy_ulabel_lev = 0

ovs = 'c'+trim(ov_number)+'_'
what = ov_number eq 0 ? ' for Primary Contour' :' for Contour ' + trim(ov_number)
w_base = widget_base ( group_leader=group, $
					/column, $
					xpad=5, $
					ypad=0, $
					space=10, $
					title='Contour Options' + what, $
					/frame);, $
					;/modal )

temp = widget_label (w_base, value='Contour Options' + what, /align_center)

w_base1 = widget_base (w_base, /row, space=5)

w_color = plotman_defaults_wrapper(defaults, 'widget_droplist', w_base1, $
					title='Color: ', $
					value=tag_names(colorstr), $
					uvalue='color', $
					uname=ovs+'overlay_color')

w_thickness = plotman_defaults_wrapper(defaults, 'cw_field', w_base1, $
					title='Thickness: ', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='thickness', $
					uname=ovs+'overlay_thickness')

w_style = plotman_defaults_wrapper(defaults, 'widget_droplist', w_base1, $
					title='Line Style: ', $
					value=linestyles, $
					uvalue='style', $
					uname=ovs+'overlay_style')

w_label = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_base1, $
					'Label', uvalue='label', /nonexclusive, uname=ovs+'overlay_label')


w_base2 = widget_base (w_base, /row, space=10, /frame)
w_base2a = widget_base (w_base2, /column, /align_left)

w_translate = 0L
if ov_number gt 0 then w_translate = plotman_defaults_wrapper(defaults, 'cw_range', w_base2a, $
						uvalue='translate', $
						value=[0.,0.], $
						format='(f10.3)', $
						xsize=8, $
						label1='Translate X: ', $
						label2='  Y:', space=0, $
						uname=ovs+'translate_overlay' )

w_smooth = 0L
if ov_number gt 0 then w_smooth = plotman_defaults_wrapper(defaults, 'cw_range', w_base2a, $
            uvalue='smooth', $
            value=[0,0], $
            format='(i3)', $
            xsize=3, $
            label1='Smoothing Width X: ', $
            label2='  Y:', space=0, xpad=0, $
            uname=ovs+'smooth_image' )

w_base2b = widget_base (w_base2, /column, /align_left)

w_roll = 0L
if ov_number gt 0 then w_roll = plotman_defaults_wrapper(defaults, 'cw_field', w_base2b, $
          title='Roll (deg cw): ', $
          value=0., $
          xsize=6, $
          /return_events, $
          uvalue='roll', $
          uname=ovs+'overlay_roll')

w_rotate = 0L
if ov_number gt 0 then w_rotate = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_base2b, $
            'Solar Rotate', uvalue='rotate', /nonexclusive, uname=ovs+'drotate_image')

w_labelbase = widget_base (w_base, /row, /frame)

w_ulabel = plotman_defaults_wrapper(defaults, 'cw_field', w_labelbase, $
					/string, $
					/return_events, $
					title='User Label: ', $
					value=string('',format='(a40)'), $
					uvalue='ulabel', $
					uname=ovs+'overlay_ulabel')

w_ulabel_lev = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_labelbase, $
					'Append user levels', uvalue='ulabel_lev', $
					/nonexclusive, uname=ovs+'overlay_ulabel_lev')
					
w_nolabel = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_labelbase, $
			  'No label', uvalue='nolabel', $
			  /nonexclusive, uname=ovs+'overlay_nolabel')					

w_base3 = widget_base (w_base, /column, /frame)
w_base3a = widget_base (w_base3, /row, space=5)

tmp = plotman_defaults_wrapper(defaults, 'widget_button', w_base3a, $
					value='Autoselect levels', $
					uvalue='contour_auto', $
					uname=ovs+'overlay_levels,' + ovs+'n_overlay_levels' )

tmp = plotman_defaults_wrapper(defaults, 'widget_button', w_base3a, $
					value='Define levels', $
					uvalue='contour_define', $
					uname=ovs+'overlay_levels,' + ovs+'n_overlay_levels' )

w_percent = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_base3a, $
					'As % of max', uvalue='contour_percent', /nonexclusive, $
					uname=ovs+'overlay_percent')

w_base3b = widget_base (w_base3, /row, space=10)

w_level_text = widget_label (w_base3b, $
						value='   ', $
						/align_left, $
						xsize=250 )

w_base4 = widget_base(w_base, /row)
w_base4a = widget_base(w_base4, /column)
tmp = widget_label(w_base4a, value='Copy selection above to all contours for: ')
w_base4b = widget_base(w_base4a, /row)
w_copy_thick = cw_bgroup (w_base4b, 'Thickness', uvalue='copy_thick', /nonexclusive)
w_copy_style = cw_bgroup (w_base4b, 'Line styles', uvalue='copy_style', /nonexclusive)
w_copy_nolabel = cw_bgroup (w_base4b, 'No label', uvalue='copy_nolabel', /nonexclusive)
w_copy_levs = cw_bgroup (w_base4b, 'Levels', uvalue='copy_levs', /nonexclusive)
w_copy_ulabel_lev = cw_bgroup (w_base4b, 'Append user levels to label', uvalue='copy_ulabel_lev', /nonexclusive)

w_base5 = widget_base (w_base, /row, space=30, /align_center)

tmp = widget_button (w_base5, value='Accept', uvalue='accept')
tmp = widget_button (w_base5, value='Cancel', uvalue='cancel')

widget_offset, group, newbase=w_base, xoffset, yoffset

widget_control, w_base, xoffset=xoffset, yoffset=yoffset

widget_control, w_base, /realize

state = {w_base: w_base, $
	w_color: w_color, $
	w_thickness: w_thickness, $
	w_style: w_style, $
	w_label: w_label, $
	w_translate: w_translate, $
	w_smooth: w_smooth, $
	w_rotate: w_rotate, $
	w_roll: w_roll, $
	w_ulabel: w_ulabel, $
	w_ulabel_lev: w_ulabel_lev, $
	w_nolabel: w_nolabel, $
	w_percent: w_percent, $
	w_copy_thick: w_copy_thick, $
	w_copy_style: w_copy_style, $
	w_copy_nolabel: w_copy_nolabel, $
	w_copy_levs: w_copy_levs, $
	w_copy_ulabel_lev: w_copy_ulabel_lev, $
	w_level_text: w_level_text, $
	obj: self, $
	colorstr: colorstr, $
	ncolors: ncolors, $
	linestyles: linestyles, $

	color: ptr_new(color), $
	thickness: ptr_new(thickness), $
	style: ptr_new(style), $
	label: ptr_new(label), $
	translate: ptr_new(translate), $
	smooth: ptr_new(smooth), $
	rotate: ptr_new(rotate), $
	roll: ptr_new(roll), $
	n_levels: ptr_new(n_levels), $
	levels: ptr_new(levels), $
	percent: ptr_new(percent), $
	nolabel: ptr_new(nolabel), $
	ulabel: ptr_new(ulabel), $
	ulabel_lev: ptr_new(ulabel_lev), $

	image: image, $
	copy_thick: ptr_new(copy_thick), $
	copy_style: ptr_new(copy_style), $
	copy_nolabel: ptr_new(copy_nolabel), $
	copy_levs: ptr_new(copy_levs), $
	copy_ulabel_lev: ptr_new(copy_ulabel_lev), $
	cancel: ptr_new(0), $
	defaults: defaults, $
	def_struct: ptr_new(-1) }

widget_control, w_base, set_uvalue=state

plotman_contoptions_widget_update, state

xmanager, 'plotman_contoptions', w_base, group=group, /modal

if *state.cancel then return, -1

struct = create_struct (ovs+'overlay_color', *state.color, $	
	ovs+'overlay_label', *state.label, $
	ovs+'translate_overlay', *state.translate, $
	ovs+'smooth_image', *state.smooth, $
	ovs+'drotate_image', *state.rotate, $
	ovs+'overlay_roll', *state.roll, $
	ovs+'overlay_ulabel', *state.ulabel)

if *state.copy_thick then begin
  struct = create_struct(struct, $
    'overlay_thickness', reproduce(*state.thickness, pc.nmax_overlay) )
endif else begin
  struct = create_struct(struct, $
    ovs+'overlay_thickness', *state.thickness)
endelse

if *state.copy_style then begin
  struct = create_struct(struct, $
    'overlay_style', reproduce(*state.style, pc.nmax_overlay) )
endif else begin
  struct = create_struct(struct, $
    ovs+'overlay_style', *state.style)
endelse

if *state.copy_nolabel then begin
  struct = create_struct(struct, $
    'overlay_nolabel', reproduce(*state.nolabel, pc.nmax_overlay) )
endif else begin
  struct = create_struct(struct, $
    ovs+'overlay_nolabel', *state.nolabel)
endelse

; if selected, copy # levels, level values, and % choice to all overlays
if *state.copy_levs then begin
	struct = create_struct(struct, $
		'n_overlay_levels', reproduce(*state.n_levels, pc.nmax_overlay), $
		'overlay_levels', rebin(*state.levels, n_elements(*state.levels), pc.nmax_overlay), $
		'overlay_percent', reproduce(*state.percent, pc.nmax_overlay) )
endif else begin
	struct = create_struct(struct, $
		ovs+'n_overlay_levels', *state.n_levels, $
		ovs+'overlay_levels', *state.levels, $
		ovs+'overlay_percent', *state.percent )
endelse

if *state.copy_ulabel_lev then begin
  struct = create_struct(struct, $
    'overlay_ulabel_lev', reproduce(*state.ulabel_lev, pc.nmax_overlay) )
endif else begin
  struct = create_struct(struct, $
    ovs+'overlay_ulabel_lev', *state.ulabel_lev)
endelse

;print,struct

if state.defaults.do_def then begin
	if is_struct(*state.def_struct) then begin
		tags = strlowcase(tag_names(*state.def_struct))
		; if 'copy levels to all contours' option was selected, then remove ovs part of tag name
		if *state.copy_levs then begin
			q = where (strpos(tags,'overlay_levels') ne -1 or strpos(tags,'overlay_percent') ne -1, count)
			if count gt 0 then for i=0,count-1 do tags[q[i]] = repstr(tags[q[i]], ovs) ; replace ovs with ''
		endif
		struct = str_subset(struct, tags, /quiet, status=status)
		return, status eq 1 ? struct : {dummy:1}
	endif else return, {dummy:1}
endif

return, struct

end
