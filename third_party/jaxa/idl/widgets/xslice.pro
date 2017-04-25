;+
; NAME:
;       XSLICE
;
; PURPOSE:
;       Displays slices through a data cube.
;                                                                  
; CALLING SEQUENCE:
;       XSLICE, DATA, START_IM=start_im, IMIN=imin, IMAX=imax,
;			XTSLICE=xtslice, YTSLICE=ytslice, PHITSLICE=phitslice
;			MAGNIFICATION=magnification, TITLE=title ROOT=root
;			INPLACE=inplace, BINDKEYS=bindkeys
;
; DESCRIPTION:
;
;		XSLICE allows a user to interactively investigate slices through
;		a 3D data cube.  XSLICE displays X-Y, X-t, and Y-t slices by
;		default, and optionally also a slice at an arbitrary angle.
;
; INPUTS:
;
;		DATA - 3D data cube.  Can be any data type except COMPLEX, STRING,
;			STRUCT, DCOMPLEX, POINTER, or OBJREF.
;
; KEYWORD PARAMETERS:
;
;		START_IM - initial image to display in the X-Y slice.  Defaults to
;			the middle image.
;
;		IMIN - lower cut-off intensity.  Defaults to the minimum value in
;			the cube.
;
;		IMAX - upper cut-off intensity.  Defaults to the maximum value in
;			the cube.
;
;		XTSLICE - show X-t slice.  Defaults to on.  Ignored in slave mode.
;
;		YTSLICE - show Y-t slice.  Defaults to on.  Ignored in slave mode.
;
;		PHITSLICE - show phi-t slice.  Defaults to off.  Ignored in slave
;			mode.
;
;		MAGNIFICATION - scaling factors.  If given as a scalar value, scale
;			all dimensions equally.  If given as a 3-element array, scale
;			dimensions according to each element.  Defaults to 1, i.e., no
;			scaling.
;
;		TITLE - title string.
;
;		ROOT - named variable that identifies the master widget.  If an
;			undefined variable or a variable that identifies a
;			non-existing widget is passed, a new master XSlice instance
;			is created.  If an identifier of an existing XSlice instance
;			is passed, a slave XSlice is started.
;
;		INPLACE - don't copy data.  DATA will become undefined as a result.
;			Use this in case of low memory.
;
;		BINDKEYS - bind keys to functions.  Should be a structure (or an
;			array of structures) containing the with the following tags:
;				key: a single ASCII character
;				funct: the name of the function to call
;				expert: boolean to set "expert" mode
;
; MODIFICATION HISTORY:
;       27 Jun 2008 AdW: initial version
;       09 Jul 2008 AdW: master-slave mode added
;       10 Jul 2008 AdW: split off X-Y window, handle cursor, catch mouse
;		                 catch mouse in slave X-Y windows
;		22 Jul 2008 AdW: add custom keybindings
;
; AUTHOR:
;		Alfred de Wijn <dwijn@ucar.edu>
;
; $Id: xslice.pro 343 2008-08-14 21:17:17Z dwijn $
;-

pro xslice_colors, event
	widget_control, event.top, get_uvalue = info
	thisevent = tag_names(event, /structure_name)
	case thisevent of
	'WIDGET_BUTTON': begin
		xcolors, ncolors = (*info).ncolors, bottom = 0, $
			title = 'xwhisker colors', $
			group_leader = event.top, notifyid = [event.id, event.top]
	end
	'XCOLORS_LOAD': begin
		if !d.n_colors gt 256 then xslice_draw, event
	end
	endcase
end

pro xslice_hooks, event
	widget_control, event.top, get_uvalue = info
	tlb = widget_base(title = 'Keyboard Hooks', group_leader = event.top, $
		/column)
	txt = widget_text(tlb, xsize = 80, ysize = 10, /wrap, $
		value = ['Functions can be bound to keys.  A function should have the following form:', '', $
'FUNCTION  MY_FUNCTION, X, Y, T', $
'	...', $
'	RETURN, 0', $
'END', '', $
"where X, Y, and T are the current X position, Y position, and T position, respectively.  The 'expert' option is reserved for people who know what they're doing."])
	fctnbase = widget_base(tlb, /row, /align_left, /base_align_center)
	keycombo = widget_combobox(fctnbase, value = *(*info).b_keys, $
		/editable, xsize = 70, event_pro = 'xslice_hooks_key')
	fctnname = widget_text(fctnbase, xsize = 30, /editable)
	efb = widget_base(fctnbase, /nonexclusive)
	eflag = widget_button(efb, value = 'Expert')
	editbtn = widget_button(fctnbase, value = 'Add/Edit', $
		event_pro = 'xslice_hooks_addedit')
	removebtn = widget_button(fctnbase, value = 'Remove', $
		event_pro = 'xslice_hooks_remove')
	info_hook = { keycombo:keycombo, fctnname:fctnname, eflag:eflag }
	info_hook = ptr_new(info_hook, /no_copy)
	closefield = widget_base(tlb, /column)
	closebtn = widget_button(closefield, value = 'Close', $
		event_pro = 'xslice_hook_destroy')
	widget_control, keycombo, set_uvalue = info_hook
	widget_control, editbtn, set_uvalue = info_hook
	widget_control, removebtn, set_uvalue = info_hook
	widget_control, closebtn, set_uvalue = info_hook
	widget_control, tlb, set_uvalue = info
	widget_control, tlb, /realize
	xmanager, 'xslice', tlb, /no_block
end

pro xslice_hooks_key, event
	if event.index eq -1 then return
	widget_control, event.top, get_uvalue = info
	widget_control, event.id, get_uvalue = info_hook
	widget_control, (*info_hook).fctnname, $
		set_value = (*(*info).b_functs)[event.index]
	widget_control, (*info_hook).eflag, $
		set_button = (*(*info).b_expert)[event.index]
end

pro xslice_hooks_addedit, event
	widget_control, event.top, get_uvalue = info
	widget_control, event.id, get_uvalue = info_hook
	; get key, function name, expert flag
	key = widget_info((*info_hook).keycombo, /combobox_gettext)
	widget_control, (*info_hook).fctnname, get_value = fctnname
	eflag = widget_info((*info_hook).eflag, /button_set)
	; get first char from key
	key = strmid(key, 0, 1)
	; look for key in b_keys
	wkey = where(*(*info).b_keys eq key, numwkey, complement=nwkey)
	; if found: replace function name, expert flag
	; if not found: add key, function name, expert flag
	if numwkey gt 0 then begin
		*(*info).b_keys = (*(*info).b_keys)[nwkey]
		*(*info).b_functs = (*(*info).b_functs)[nwkey]
		*(*info).b_expert = (*(*info).b_expert)[nwkey]
	endif
	*(*info).b_keys = [*(*info).b_keys, key]
	*(*info).b_functs = [*(*info).b_functs, fctnname]
	*(*info).b_expert = [*(*info).b_expert, eflag]
	; update keycombo, fctnname, eflag
	widget_control, (*info_hook).keycombo, set_value = *(*info).b_keys
	widget_control, (*info_hook).fctnname, set_value = ''
	widget_control, (*info_hook).eflag, set_button = 0
end

pro xslice_hooks_remove, event
	widget_control, event.top, get_uvalue = info
	widget_control, event.id, get_uvalue = info_hook
	; get key, function name, expert flag
	key = widget_info((*info_hook).keycombo, /combobox_gettext)
	widget_control, (*info_hook).fctnname, get_value = fctnname
	eflag = widget_info((*info_hook).eflag, /button_set)
	; return if key = 'key'
	if key eq 'key' then return
	; look for key in b_keys
	wkey = where(*(*info).b_keys eq key, numwkey, complement=nwkey)
	; if found: remove key, function name, expert flag
	if numwkey gt 0 then begin
		*(*info).b_keys = (*(*info).b_keys)[nwkey]
		*(*info).b_functs = (*(*info).b_functs)[nwkey]
		*(*info).b_expert = (*(*info).b_expert)[nwkey]
	endif
	; update keycombo, fctnname, eflag
	widget_control, (*info_hook).keycombo, set_value = *(*info).b_keys
	widget_control, (*info_hook).fctnname, set_value = ''
	widget_control, (*info_hook).eflag, set_button = 0
end

pro xslice_hook_destroy, event
	widget_control, event.id, get_uvalue = info_hook
	ptr_free, info_hook
	xslice_destroy, event
end

pro xslice_t_slider, event
	widget_control, event.top, get_uvalue = info
	(*info).t = event.value
	(*info).st = (*info).st_lookup[event.value]
	xslice_t_update, event
	xslice_draw, event
end

pro xslice_speed_slider, event
	widget_control, event.top, get_uvalue = info
	(*info).t_speed = event.value
end

pro xslice_step_slider, event
	widget_control, event.top, get_uvalue = info
	(*info).t_step = event.value
end

pro xslice_window, xsize, ysize, leader, title, tlb, wid, drawid=drawid
	tlb = widget_base(title = strtrim(title), group_leader = leader, $
		tlb_frame_attr = 1, /tlb_kill_request_events)
	displaybase = widget_base(tlb, /column)
	drawid = widget_draw(displaybase, retain = 2, xsize = xsize, ysize = ysize)
	widget_control, tlb, /realize
	widget_control, drawid, get_value = wid
end

pro xslice_xt_toggle, event
	widget_control, event.top, get_uvalue = info
	(*info).showxt = event.select
	if event.select then begin
		for li=1, n_elements((*(*info).xytlbs))-1 do begin
			widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
			xslice_window, (*info).d_xsz, (*info).d_tsz, (*info_local).xytlb, $
				'xslice: X-t slice' + (*info_local).title, tlb, wid
			(*info_local).xttlb = tlb
			(*info_local).xtwid = wid
		endfor
		xslice_y_update, event
	endif else begin
		for li=1, n_elements((*(*info).xytlbs))-1 do begin
			widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
			widget_control, (*info_local).xttlb, /destroy
		endfor
	endelse
	xslice_draw, event
end

pro xslice_x_slider, event
	widget_control, event.top, get_uvalue = info
	(*info).x = event.value
	(*info).sx = (*info).sx_lookup[event.value]
	xslice_x_update, event
	xslice_phi_update, event
	xslice_draw, event
end

pro xslice_yt_toggle, event
	widget_control, event.top, get_uvalue = info
	(*info).showyt = event.select
	if event.select then begin
		for li=1, n_elements((*(*info).xytlbs))-1 do begin
			widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
			xslice_window, (*info).d_ysz, (*info).d_tsz, (*info_local).xytlb, $
				'xslice: Y-t slice' + (*info_local).title, tlb, wid
			(*info_local).yttlb = tlb
			(*info_local).ytwid = wid
		endfor
		xslice_x_update, event
	endif else begin
		for li=1, n_elements((*(*info).xytlbs))-1 do begin
			widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
			widget_control, (*info_local).yttlb, /destroy
		endfor
	endelse
	xslice_draw, event
end

pro xslice_y_slider, event
	widget_control, event.top, get_uvalue = info
	(*info).y = event.value
	(*info).sy = (*info).sy_lookup[event.value]
	xslice_y_update, event
	xslice_phi_update, event
	xslice_draw, event
end

pro xslice_phit_toggle, event
	widget_control, event.top, get_uvalue = info
	(*info).showphit = event.select
	if event.select then begin
		for li=1, n_elements((*(*info).xytlbs))-1 do begin
			widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
			xslice_window, (*info).d_phisz, (*info).d_tsz, (*info_local).xytlb, $
				'xslice: phi-t slice' + (*info_local).title, tlb, wid
			(*info_local).phittlb = tlb
			(*info_local).phitwid = wid
		endfor
		xslice_phi_update, event
	endif else begin
		for li=1, n_elements((*(*info).xytlbs))-1 do begin
			widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
			widget_control, (*info_local).phittlb, /destroy
		endfor
	endelse
	xslice_draw, event
end

pro xslice_phi_slider, event
	widget_control, event.top, get_uvalue = info
	(*info).angle = event.value
	xslice_phi_update, event
	xslice_draw, event
end

pro xslice_mouse, event
	widget_control, event.top, get_uvalue = info

	if tag_names(event, /structure_name) eq 'WIDGET_TRACKING' then begin
		if event.enter then begin
			widget_control, event.handler, get_value = wid
			wset, wid
			ci = uintarr(16) & cim = ci & cim[8] = 1
			device, cursor_image = ci, cursor_mask = cim, cursor_xy=[8,8]
	   endif else device, /cursor_crosshair
	endif else if tag_names(event, /structure_name) eq 'WIDGET_DRAW' then begin
		pseudoevent = {widget_button, id:event.id, $
			top:event.top, handler:0l, select:1}

		case event.type of
		0: begin ; up
			case event.press of
			1: if (*info).play_mode eq 'play' and (*info).play_direction eq -1 then $
				xslice_pause, pseudoevent else xslice_backward, pseudoevent
			2: xslice_pause, pseudoevent
			4: if (*info).play_mode eq 'play' and (*info).play_direction eq 1 then $
				xslice_pause, pseudoevent else xslice_forward, pseudoevent
			else: break
			endcase
			end
			2: begin ; motion
				(*info).sx = event.x > 0 < (*info).d_xsz
				(*info).x = (*info).x_lookup[(*info).sx]
				widget_control, (*info).x_slider, set_value = (*info).x
				(*info).sy = event.y > 0 < (*info).d_ysz
				(*info).y = (*info).y_lookup[(*info).sy]
				widget_control, (*info).y_slider, set_value = (*info).y
				xslice_x_update, event
				xslice_y_update, event
				xslice_phi_update, event
				if (*info).play_mode eq 'pause' then xslice_draw, event
				end
				7: begin ; wheel scroll
					if (*info).play_mode eq 'pause' then begin
						if event.clicks gt 0 then $
							for clicks=0, abs(event.clicks)-1 do xslice_incr, pseudoevent $
							else $
							for clicks=0, abs(event.clicks)-1 do xslice_decr, pseudoevent
					endif
		end
		5: if event.press then begin
			wkey = where(*(*info).b_keys eq string(event.ch), numwkey)
			if numwkey eq 0 then return
			if (*(*info).b_expert)[wkey[0]] then begin
				result = call_function((*(*info).b_functs)[wkey[0]], info)
			endif else begin
				result = call_function((*(*info).b_functs)[wkey[0]], $
					(*info).x, (*info).y, (*info).t)
			endelse
		endif
		else: return
		endcase
	endif
end

pro xslice_t_update, event
	widget_control, event.top, get_uvalue = info
	for li=1, n_elements((*(*info).xytlbs))-1 do begin
		widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
		*(*info_local).image = reform((*(*info_local).data)[*,*,(*info).st])
	endfor
end

pro xslice_x_update, event
	widget_control, event.top, get_uvalue = info
	if (*info).showyt then for li=1, n_elements((*(*info).xytlbs))-1 do begin
		widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
		*(*info_local).ytslice = reform((*(*info_local).data)[(*info).sx,*,*])
	endfor
end

pro xslice_y_update, event
	widget_control, event.top, get_uvalue = info
	if (*info).showxt then for li=1, n_elements((*(*info).xytlbs))-1 do begin
		widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
   		*(*info_local).xtslice = reform((*(*info_local).data)[*,(*info).sy,*])
	endfor
end

pro xslice_extract_phi, info, info_local
	sz = size(data)
	szs = size(slice)
	xpts = cos(!dtor*(*info).angle)*(findgen(2*(*info).d_phisz+1)-(*info).d_phisz) + (*info).sx
	ypts = sin(!dtor*(*info).angle)*(findgen(2*(*info).d_phisz+1)-(*info).d_phisz) + (*info).sy
	w = where(xpts ge 0 and xpts le (*info).d_xsz-1 and $
		ypts ge 0 and ypts le (*info).d_ysz-1, nw)
	(*info).d_phiszcur = nw
	xpts = rebin(xpts[w], nw, (*info).d_tsz)
	ypts = rebin(ypts[w], nw, (*info).d_tsz)
	tpts = rebin(findgen(1,(*info).d_tsz), nw, (*info).d_tsz)
	tmp = interpolate(*(*info_local).data, xpts, ypts, tpts)
	(*info).sphi = where(w eq (*info).d_phisz) + ((*info).d_phisz-nw)/2
	(*(*info_local).phitslice)[*,*] = 0
	(*(*info_local).phitslice)[((*info).d_phisz-nw)/2,0] = tmp
end

pro xslice_phi_update, event
	widget_control, event.top, get_uvalue = info
	if (*info).showphit then for li=1, n_elements((*(*info).xytlbs))-1 do begin
		widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local
		xslice_extract_phi, info, info_local
	endfor
end

pro xslice_pause, event
	widget_control, event.top, get_uvalue = info

	if (*info).play_mode eq 'pause' then return

	(*info).play_mode = 'pause'

	widget_control, (*info).forward_button, set_value = (*info).buttons.forward
	widget_control, (*info).backward_button, set_value = (*info).buttons.backward
	widget_control, (*info).pause_button, set_value = (*info).buttons_black.pause
	widget_control, (*info).fastforward_button, set_value = (*info).buttons.fastforward
	widget_control, (*info).fastbackward_button, set_value = (*info).buttons.fastbackward
end

pro xslice_forward, event
	widget_control, event.top, get_uvalue = info

	if (*info).play_mode eq 'play' and (*info).play_direction eq 1 then return

	(*info).play_direction = 1

	widget_control, (*info).root, update=0
	widget_control, (*info).forward_button, set_value = (*info).buttons_black.forward
	widget_control, (*info).backward_button, set_value = (*info).buttons.backward
	widget_control, (*info).pause_button, set_value = (*info).buttons.pause
	if (*info).loop_mode ne 'blink' then begin
		widget_control, (*info).fastforward_button, set_value = (*info).buttons_gray.fastforward
		widget_control, (*info).fastbackward_button, set_value = (*info).buttons_gray.fastbackward
	endif
	widget_control, (*info).root, update=1

	(*info).play_mode = 'play'
	widget_control, (*info).bg, timer = 0.0
end

pro xslice_backward, event
	widget_control, event.top, get_uvalue = info

	if (*info).play_mode eq 'play' and (*info).play_direction eq -1 then return

	(*info).play_direction = -1

	widget_control, (*info).root, update=0
	widget_control, (*info).forward_button, set_value = (*info).buttons.forward
	widget_control, (*info).backward_button, set_value = (*info).buttons_black.backward
	widget_control, (*info).pause_button, set_value = (*info).buttons.pause
	if (*info).loop_mode ne 'blink' then begin
		widget_control, (*info).fastforward_button, set_value = (*info).buttons_gray.fastforward
		widget_control, (*info).fastbackward_button, set_value = (*info).buttons_gray.fastbackward
	endif
	widget_control, (*info).root, update=1

	(*info).play_mode = 'play'
	widget_control, (*info).bg, timer = 0.0
end

pro xslice_incr, event
	widget_control, event.top, get_uvalue = info

	if (*info).play_mode eq 'pause' or (*info).loop_mode eq 'blink' then begin
		(*info).t = ((*info).t + (*info).t_step) < (*info).last
		(*info).st = (*info).st_lookup[(*info).t]
		xslice_t_update, event
		widget_control, (*info).t_slider, set_value = (*info).t
		xslice_draw, event
	endif
end

pro xslice_decr, event
	widget_control, event.top, get_uvalue = info

	if (*info).play_mode eq 'pause' or (*info).loop_mode eq 'blink' then begin
		(*info).t = ((*info).t - (*info).t_step) > (*info).first
		(*info).st = (*info).st_lookup[(*info).t]
		xslice_t_update, event
		widget_control, (*info).t_slider, set_value = (*info).t
		xslice_draw, event
	endif
end

pro xslice_loop, event
	widget_control, event.top, get_uvalue = info

	widget_control, (*info).root, update=0

	if (*info).loop_mode eq 'blink' then begin
		if (*info).play_direction eq -1 then begin
			widget_control, (*info).backward_button, $
				set_value = (*info).buttons_black.backward
			widget_control, (*info).forward_button, $
				set_value = (*info).buttons.forward
		endif else if (*info).play_direction eq 1 then begin
			widget_control, (*info).backward_button, $
				set_value = (*info).buttons.backward
			widget_control, (*info).forward_button, $
				set_value = (*info).buttons_black.forward
		endif
	endif

	(*info).loop_mode = 'loop'

	widget_control, (*info).loop_button, set_value = (*info).buttons_black.loop
	widget_control, (*info).cycle_button, set_value = (*info).buttons.cycle
	widget_control, (*info).blink_button, set_value = (*info).buttons.blink
	widget_control, (*info).fastforward_button, set_value = (*info).buttons_gray.fastforward
	widget_control, (*info).fastbackward_button, set_value = (*info).buttons_gray.fastbackward

	widget_control, (*info).root, update=1
end

pro xslice_cycle, event
	widget_control, event.top, get_uvalue = info

	widget_control, (*info).root, update=0

	if (*info).loop_mode eq 'blink' then begin
		if (*info).play_direction eq -1 then begin
			widget_control, (*info).backward_button, $
				set_value = (*info).buttons_black.backward
			widget_control, (*info).forward_button, $
				set_value = (*info).buttons.forward
		endif else if (*info).play_direction eq 1 then begin
			widget_control, (*info).backward_button, $
				set_value = (*info).buttons.backward
			widget_control, (*info).forward_button, $
				set_value = (*info).buttons_black.forward
		endif
	endif

	(*info).loop_mode = 'cycle'

	widget_control, (*info).loop_button, set_value = (*info).buttons.loop
	widget_control, (*info).cycle_button, set_value = (*info).buttons_black.cycle
	widget_control, (*info).blink_button, set_value = (*info).buttons.blink
	widget_control, (*info).fastforward_button, set_value = (*info).buttons_gray.fastforward
	widget_control, (*info).fastbackward_button, set_value = (*info).buttons_gray.fastbackward

	widget_control, (*info).root, update=1
end

pro xslice_blink, event
	widget_control, event.top, get_uvalue = info

	(*info).loop_mode = 'blink'

	widget_control, (*info).root, update=0
	widget_control, (*info).loop_button, set_value = (*info).buttons.loop
	widget_control, (*info).cycle_button, set_value = (*info).buttons.cycle
	widget_control, (*info).blink_button, set_value = (*info).buttons_black.blink
	widget_control, (*info).fastforward_button, set_value = (*info).buttons.fastforward
	widget_control, (*info).fastbackward_button, set_value = (*info).buttons.fastbackward
	widget_control, (*info).root, update=1
end

pro xslice_bck, event
	widget_control, event.top, get_uvalue = info

	widget_control, (*info).root, update=0

	; set frame number
	case (*info).play_mode of
	'pause': if (*info).loop_mode ne 'blink' then return else $
		if (*info).play_direction eq 1 then return
	'play': (*info).t += (*info).play_direction * (*info).t_step
	endcase

	case (*info).loop_mode of
	'loop': begin
		if (*info).t gt (*info).last then $
			(*info).t = (*info).t - (*info).last - 1
		if (*info).t lt (*info).first then $
			(*info).t = (*info).t + (*info).last + 1
	end
	'cycle': begin
		if (*info).t gt (*info).last then begin
			(*info).play_direction = -1
			(*info).t = (*info).last - ((*info).t mod (*info).last)
			widget_control, (*info).forward_button, set_value = (*info).buttons.forward
			widget_control, (*info).backward_button, set_value = (*info).buttons_black.backward
		endif else if (*info).t lt (*info).first then begin
			(*info).play_direction = 1
			(*info).t = -1 * (*info).t
			widget_control, (*info).forward_button, set_value = (*info).buttons_black.forward
			widget_control, (*info).backward_button, set_value = (*info).buttons.backward
		endif
	end
	'blink': begin
		(*info).play_direction *= -1
		if (*info).t gt (*info).last then (*info).t = (*info).t - (*info).nframes $
		else if (*info).t lt (*info).first then (*info).t = (*info).t + (*info).nframes
	end
	endcase

	(*info).st = (*info).st_lookup[(*info).t]

	if (*info).loop_mode eq 'blink' then begin
		if (*info).play_direction eq -1 then begin
			widget_control, (*info).backward_button, $
				set_value = (*info).buttons_black.backward
			widget_control, (*info).forward_button, $
				set_value = (*info).buttons.forward
		endif else if (*info).play_direction eq 1 then begin
			widget_control, (*info).backward_button, $
				set_value = (*info).buttons.backward
			widget_control, (*info).forward_button, $
				set_value = (*info).buttons_black.forward
		endif
	endif

	widget_control, (*info).t_slider, set_value = (*info).t

	widget_control, (*info).root, update=1

	;  generate timer event
	widget_control, (*info).bg, timer = 1./(*info).t_speed

	xslice_t_update, event
	xslice_draw, event
end

pro xslice_draw, event
	widget_control, event.top, get_uvalue = info

	for li=1, n_elements((*(*info).xytlbs))-1 do begin
		widget_control, (*(*info).xytlbs)[li], get_uvalue = info_local

		wset, (*info_local).xywid
		tv, *(*info_local).image
		plots, (*info).sx, (*info).sy, /device, color = !p.color, psym=1
		if (*info).showxt then $
			plots, [0,(*info).d_xsz], [1,1]*(*info).sy, /device, color = !p.color
		if (*info).showyt then $
			plots, [1,1]*(*info).sx, [0,(*info).d_ysz], /device, color = !p.color
		if (*info).showphit then $
			plots, ([-1,1]*(*info).d_phisz)*cos((*info).angle*!dtor)+(*info).sx, $
			([-1,1]*(*info).d_phisz)*sin((*info).angle*!dtor)+(*info).sy, $
			/device, color = !p.color

		if (*info).showxt then begin
			wset, (*info_local).xtwid
			tv, *(*info_local).xtslice
			plots, (*info).sx, (*info).st, /device, color = !p.color, psym=1
			plots, [0,(*info).d_xsz], [1,1]*(*info).st, /device, color = !p.color
			if (*info).showyt then $
				plots, [1,1]*(*info).sx, [0,(*info).d_tsz], /device, $
				color = !p.color
		endif

		if (*info).showyt then begin
			wset, (*info_local).ytwid
			tv, *(*info_local).ytslice
			plots, (*info).sy, (*info).st, /device, color = !p.color, psym=1
			plots, [0,(*info).d_ysz], [1,1]*(*info).st, /device, color = !p.color
			if (*info).showxt then $
				plots, [1,1]*(*info).sy, [0,(*info).d_tsz], /device, $
				color = !p.color
		endif

		if (*info).showphit then begin
			wset, (*info_local).phitwid
			tv, *(*info_local).phitslice
			plots, (*info).sphi, (*info).st, /device, color = !p.color, psym=1
			plots, [0,(*info).d_phisz], [1,1]*(*info).st, /device, color = !p.color
			if (*info).showxt or (*info).showyt then $
				plots, [1,1]*(*info).sphi, [0,(*info).d_tsz], /device, $
				color = !p.color
		endif
	endfor
end

pro xslice_cleanup, tlb
	widget_control, tlb, get_uvalue = info
	while n_elements((*(*info).xytlbs)) gt 1 do $
		widget_control, (*(*info).xytlbs)[1], /destroy
	tvlct, (*info).r, (*info).g, (*info).b
	ptr_free, info
end

pro xslice_cleanup_local, local
	widget_control, local, get_uvalue = info
	widget_control, (*info).root, get_uvalue = info_root
	if ptr_valid((*info).data) then ptr_free, (*info).data
	ptr_free, info
	xytlbs = *(*info_root).xytlbs
	w = where(xytlbs ne local, nw)
	xytlbs = xytlbs[w]
	*(*info_root).xytlbs = xytlbs
	if nw eq 1 then widget_control, (*info_root).root, /destroy
end

pro xslice_destroy, event
	widget_control, event.top, /destroy
end

pro xslice_event, event
	if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
		widget_control, event.top, get_uvalue = info
		w = where(widget_info((*(*info).xytlbs)[1:*], /parent) eq event.top, nw)
		if nw eq 1 then widget_control, event.top, /destroy
	endif
end

pro xslice, data, $
	start_im = start_im, imin = imin, imax = imax, $
	xtslice = xtshow, ytslice = ytshow, phitslice = phitshow, $
	magnification = magnification, title = title, root = root, $
	inplace = inplace, bindkeys = bindkeys

	if n_params() lt 1 then begin
		print, 'xslice, data, $'
		print, 'start_im = start_im, imin = imin, imax = imax, $'
		print, 'xtslice = xtshow, ytslice = ytshow, phitslice = phitshow, $'
		print, 'magnification = magnification, title = title, root = root, $'
		print, 'inplace = inplace, bindkeys = bindkeys'
		return
	endif

	dsize = size(data)
	if dsize[0] ne 3 then begin
		print, 'input data is not a 3D array'
		return
	endif

	if dsize[4] eq 1 then begin
		if keyword_set(inplace) then bd = temporary(data) else bd = data
	endif else if dsize[4] gt 5 and dsize[4] lt 12 then begin
		print, 'unrecognized data type'
		return
	endif else begin
		if keyword_set(imin) then imin = imin else imin = min(data)
		if keyword_set(imax) then imax = imax else imax = max(data)
		if keyword_set(inplace) then $
			bd = bytscl(temporary(data), min = imin, max = imax) else $
			bd = bytscl(data, min = imin, max = imax)
	endelse

	master = 1
	if keyword_set(root) then if widget_info(root, /managed) then $
		if widget_info(root, /uname) eq 'xslice_master' then master = 0

	if master then begin
		if not keyword_set(title) then title = '' else title = ' - ' + title

		if n_elements(magnification) eq 1 then mag = [1.,1.,1.]*magnification else $
			if n_elements(magnification) eq 3 then mag = 1.*magnification else $
			mag = [1.,1.,1.]
		ncolors = !d.table_size

		xsize = dsize[1]
		ysize = dsize[2]
		nframes = dsize[3]

		first = 0
		last = nframes-1

		; check if desired x, y, and t size is integer number of original size. 
		; If that's the case, use rebin in stead of congrid where possible
		d_xsz = fix(round(xsize*mag[0]))
		d_ysz = fix(round(ysize*mag[1]))
		d_tsz = fix(round(nframes*mag[2]))
		d_phisz = fix(ceil(sqrt(float(d_xsz)^2+float(d_ysz)^2)))

		sx = 0
		sy = 0
		angle = 45
		sphi = 0
		d_phiszcur = 0

		sx_lookup = fix(round(findgen(xsize) / (xsize - 1) * (d_xsz - 1)))
		x_lookup = fix(round(findgen(d_xsz) / (d_xsz - 1) * (xsize - 1)))
		sy_lookup = fix(round(findgen(ysize) / (ysize - 1) * (d_ysz - 1)))
		y_lookup = fix(round(findgen(d_ysz) / (d_ysz - 1) * (ysize - 1)))
		st_lookup = fix(round(findgen(nframes) / (nframes - 1) * (d_tsz - 1)))
		t_lookup = fix(round(findgen(d_tsz) / (d_tsz - 1) * (nframes - 1)))
		if n_elements(start_im) eq 0 then start_im = nframes/2

		st = st_lookup[start_im]
		x = x_lookup[sx]
		y = y_lookup[sy]

		; set parameters controlling the direction and speed of the movie
		play_direction = 1
		t_step = 1
		t_speed = 100

		; get bitmap buttons for play/pause buttons:
		forward_function xslice_buttons
		buttons = xslice_buttons()
		buttons_gray = xslice_buttons(/gray)
		buttons_black = xslice_buttons(/black)

		root = widget_base(title = 'xslice: cube slicing tool', $
			mbar = menubar, tlb_frame_attr = 1, /column, $
			kill_notify = 'xslice_cleanup', uname = 'xslice_master')

		xslice_window, d_xsz, d_ysz, root, 'xslice: X-Y slice' + title, $
			xytlb, xywid, drawid=xydrawid
		widget_control, xydrawid, event_pro = 'xslice_mouse', /sensitive, $
			/draw_motion_events, /draw_button_events, /draw_wheel_events, $
			/tracking_events, /draw_keyboard_events

		filemenu = widget_button(menubar, value = 'File', /menu, uvalue = 'file')
		exitmenu = widget_button(filemenu, value = 'Close', $
			event_pro = 'xslice_destroy')
		optmenu = widget_button(menubar, value = 'Options', /menu)
		colmenu = widget_button(optmenu, value = 'Colour Table', $
			event_pro = 'xslice_colors')
		hookmenu = widget_button(optmenu, value = 'Keyboard Hooks', $
			event_pro = 'xslice_hooks')

		control_field = widget_base(root, /column)
		buttons_field = widget_base(control_field, /row)
		buttons_area1 = widget_base(buttons_field, /row, /frame)
		buttons_area2 = widget_base(buttons_field, /row, /frame)
		fastbackward_button = widget_button(buttons_area1, value = buttons.fastbackward, $
			event_pro = 'xslice_decr')
		backward_button = widget_button(buttons_area1, value = buttons.backward, $
			event_pro = 'xslice_backward')
		pause_button = widget_button(buttons_area1, value = buttons_black.pause, $
			event_pro = 'xslice_pause')
		forward_button = widget_button(buttons_area1, value = buttons.forward, $
			event_pro = 'xslice_forward')
		fastforward_button = widget_button(buttons_area1, value = buttons.fastforward, $
			event_pro = 'xslice_incr')
		loop_button = widget_button(buttons_area2, value = buttons_black.loop, $
			event_pro = 'xslice_loop')
		cycle_button = widget_button(buttons_area2, value = buttons.cycle, $
			event_pro = 'xslice_cycle')
		blink_button = widget_button(buttons_area2, value = buttons.blink, $
			event_pro = 'xslice_blink')

		t_slider = widget_slider(control_field, $
			minimum = first, maximum = last, title = 'Frame number', $
			value = start_im, event_pro = 'xslice_t_slider', /drag)
		t_speed_slider = widget_slider(control_field, $
			minimum = 1, maximum = 100, title = 'Animation speed [frames/s]', $
			value = t_speed, event_pro = 'xslice_speed_slider', /drag)
		t_step_slider = widget_slider(control_field, minimum = 1, $
			maximum = last, title = 'Frame increment', $
			value = t_step, event_pro = 'xslice_step_slider')

		slice_area = widget_base(control_field, /row)
		slice_label = widget_label(slice_area, value='Display:')
		slice_buttons_area = widget_base(slice_area, /row, /nonexclusive)
		xt_button = widget_button(slice_buttons_area, $
			event_pro = 'xslice_xt_toggle', value = 'X-t')
		widget_control, xt_button, set_button = 0
		yt_button = widget_button(slice_buttons_area, $
			event_pro = 'xslice_yt_toggle', value = 'Y-t')
		widget_control, yt_button, set_button = 0
		phit_button = widget_button(slice_buttons_area, $
			event_pro = 'xslice_phit_toggle', value = 'phi-t')
		widget_control, phit_button, set_button = 0

		x_slider = widget_slider(control_field, minimum = 0, $
			title = 'X position', $
			maximum = xsize-1, value = x, event_pro = 'xslice_x_slider', /drag)
		y_slider = widget_slider(control_field, minimum = 0, $
			title = 'Y position', $
			maximum = ysize-1, value = y, event_pro = 'xslice_y_slider', /drag)
		phi_slider = widget_slider(control_field, minimum = 0, $
			title = 'angle', $
			maximum = 179, value = angle, event_pro = 'xslice_phi_slider', /drag)

		; Close xslice button:
		closefield = widget_base(root, /column)
		closebutton = widget_button(closefield, value = 'Close', $
			event_pro = 'xslice_destroy')

		; realize main window:
		widget_control, root, /realize

		; set up background
		bg = widget_base(root, event_pro = 'xslice_bck')

		;get and save color table
		tvlct, r, g, b, /get

		xytlbs = ptr_new([0])
		b_keys = ptr_new(['key'])
		b_functs = ptr_new([''])
		b_expert = ptr_new([0])

		info_root = { buttons:buttons, $
			buttons_gray:buttons_gray, $
			buttons_black:buttons_black, $
			r:r, g:g, b:b, ncolors:ncolors, $
			xsize:xsize, ysize:ysize, nframes:nframes, first:first, last:last, mag:mag, $
			d_xsz:d_xsz, d_ysz:d_ysz, d_tsz:d_tsz, d_phisz:d_phisz, d_phiszcur:d_phiszcur, $
			sx_lookup:sx_lookup, x_lookup:x_lookup, $
			sy_lookup:sy_lookup, y_lookup:y_lookup, $
			st_lookup:st_lookup, t_lookup:t_lookup, $
			t:start_im, st:st, x:x, sx:sx, y:y, sy:sy, angle:angle, sphi:sphi, $
			t_step:t_step, t_speed:t_speed, play_direction:play_direction, $
			showxt:0, showyt:0, showphit: 0, $
			t_slider:t_slider, $
			t_speed_slider:t_speed_slider, $
			t_step_slider:t_step_slider, $
			x_slider:x_slider, y_slider:y_slider, phi_slider:phi_slider, $
			forward_button:forward_button, $
			backward_button:backward_button, $
			fastforward_button:fastforward_button, $
			fastbackward_button:fastbackward_button, $
			pause_button:pause_button, $
			loop_button:loop_button, $
			cycle_button:cycle_button, $
			blink_button:blink_button, $
			play_mode:'pause', loop_mode:'loop', $
			bg:bg, root:root, xytlbs:xytlbs, $
			b_keys:b_keys, b_functs:b_functs, b_expert:b_expert }
		info_root = ptr_new(info_root, /no_copy)

		; set user value of root widget to be the info ptr
		widget_control, root, set_uvalue = info_root
	endif else begin
		if not keyword_set(title) then title = '' else title = ' - ' + title

		widget_control, root, get_uvalue = info_root
		d_xsz = (*info_root).d_xsz
		d_ysz = (*info_root).d_ysz
		d_tsz = (*info_root).d_tsz
		d_phisz = (*info_root).d_phisz
		xsize = (*info_root).xsize
		ysize = (*info_root).ysize
		nframes = (*info_root).nframes

		if dsize[1] ne xsize or dsize[2] ne ysize or $
			dsize[3] ne nframes then begin
			print, 'input data mismatch'
			return
		endif

		xslice_window, d_xsz, d_ysz, root, 'xslice: X-Y slice' + title, $
			xytlb, xywid, drawid=xydrawid
		widget_control, xydrawid, event_pro = 'xslice_mouse', /sensitive, $
			/draw_motion_events, /draw_button_events, /draw_wheel_events, $
			/tracking_events, /draw_keyboard_events
	endelse

	; attach uvalue to xy display
	widget_control, xytlb, set_uvalue = info_root

	; set up placeholder for uvalue
	local = widget_base(xytlb, kill_notify = 'xslice_cleanup_local')
	*(*info_root).xytlbs = [*(*info_root).xytlbs,local]

	if not array_equal((*info_root).mag,[1,1,1]) then $
		bd = interpolate(bd, $
			findgen(d_xsz)/(d_xsz-1)*(xsize-1), $
			findgen(d_ysz)/(d_ysz-1)*(ysize-1), $
			findgen(d_tsz)/(d_tsz-1)*(nframes-1), /grid)
	pbd = ptr_new(bd, /no_copy)

	image = ptr_new(bytarr(d_xsz,d_ysz))
	xtslice = ptr_new(bytarr(d_xsz,d_tsz))
	ytslice = ptr_new(bytarr(d_ysz,d_tsz))
	phitslice = ptr_new(bytarr(d_phisz,d_tsz))

	info_local = { master:master, title:title, data:pbd, $
		image:image, xtslice:xtslice, ytslice:ytslice, phitslice:phitslice, $
		xywid:xywid, xtwid:0, ytwid:0, phitwid:0, $
		root:(*info_root).root, xytlb:xytlb, xttlb:0, yttlb:0, phittlb:0 }
	info_local = ptr_new(info_local, /no_copy)

	widget_control, local, set_uvalue = info_local

	if keyword_set(bindkeys) then for i=0, n_elements(bindkeys)-1 do begin
		wkey = where(*(*info_root).b_keys eq bindkeys[i].key, $
			numwkey, complement=nwkey)
		if numwkey gt 0 then begin
			*(*info_root).b_keys = (*(*info_root).b_keys)[nwkey]
			*(*info_root).b_functs = (*(*info_root).b_functs)[nwkey]
			*(*info_root).b_expert = (*(*info_root).b_expert)[nwkey]
		endif
		*(*info_root).b_keys = [*(*info_root).b_keys, bindkeys[i].key]
		*(*info_root).b_functs = [*(*info_root).b_functs, bindkeys[i].funct]
		*(*info_root).b_expert = [*(*info_root).b_expert, bindkeys[i].expert]
	endfor

	pseudoevent = {widget_button, id:root, $
		top:root, handler:0l, select:1}

	xslice_t_update, pseudoevent

	if master then begin
		if keyword_set(xtshow) or not n_elements(xtshow) then begin
			widget_control, xt_button, set_button = 1
			(*info_root).showxt = 1
		endif
		if keyword_set(ytshow) or not n_elements(ytshow) then begin
			widget_control, yt_button, set_button = 1
			(*info_root).showyt = 1
		endif
		if keyword_set(phitshow) then begin
			widget_control, phit_button, set_button = 1
			(*info_root).showphit = 1
		endif
		xmanager, 'xslice', root, /no_block
	endif
	xmanager, 'xslice', xytlb, /no_block

	if (*info_root).showxt then begin
		xslice_window, d_xsz, d_tsz, $
			(*info_local).xytlb, 'xslice: X-t slice' + title, $
			xttlb, xtwid
		(*info_local).xttlb = xttlb
		(*info_local).xtwid = xtwid
		xslice_y_update, pseudoevent
	endif
	if (*info_root).showyt then begin
		xslice_window, d_ysz, d_tsz, $
			xytlb, 'xslice: Y-t slice' + title, $
			yttlb, ytwid
		(*info_local).yttlb = yttlb
		(*info_local).ytwid = ytwid
		xslice_x_update, pseudoevent
	endif
	if (*info_root).showphit then begin
		xslice_window, d_phisz, d_tsz, $
			xytlb, 'xslice: phi-t slice' + title, $
			phittlb, phitwid
		(*info_local).phittlb = phittlb
		(*info_local).phitwid = phitwid
		xslice_phi_update, pseudoevent
	endif

	xslice_draw, pseudoevent
end