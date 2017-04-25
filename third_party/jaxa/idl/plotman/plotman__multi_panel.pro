;+
; Name: plotman__multi_panel
; Purpose: Allow users to select panels for plotting, exporting, summarizing, writing image cube, etc.
;
; Written, Kim Tolbert, 2001
; Modifications:
;	5-Sep-2001, Kim.  reconfigure widgets to allow for longer panel description names
;	15-Jun-2002, Kim.  Major redesign to allow printing, exporting, plot files, from multiple panels
;	27-Jul-2002, Kim.  Added option for computing image flux, etc for multiple panels.
;	21-Aug-2002, Kim.  Don't reset list widget and reset which are selected every time we exit
;		event handler - makes the list jump around.
;	09-Oct-2002, Kim.  Added nacross option
;	07-Dec-2002, Kim.  Added 'show as movie' option
;	14-Dec-2002, Kim.  Added search options for selecting panels
;	09-Jan-2003, Kim.  Show text message while deleting panels, and save the panel_desc to
;	  set current_panel_number back to current panel when done deleting.
;	31-Oct-2003, Kim.  Added Change Limits to Current Plot option.
;	5-Nov-2003, Kim.  Added Z limits to change limits option.
;	6-Nov-2003, Kim.  Added a bunch of things to change to current plot settings. (uvalue=reset_...)
;	30-Jun-2004, Kim.  Added timestamp setting to reset selections.
;	?-Mar-2005, Kim.   Call image_fitswrite instead of write_image_cube method
;	16-Nov-2006, Kim.  Don't need to unmap and remap main widget while deleting files any more
;	  (because now in set_window_control_pulldown method don't redo the whole list anymore)
;	30-Oct-2007, Kim.  Removed old way of resetting many characteristics of plots (had long pulldown of
;	  items to be changed).  Now use new defaults options widget to select the items to change.
; 6-Jul-2008,  Kim. Call get_font instead of hsi_ui_getfont to remove hessi dependencies.
;   Also, call call_procedure,'hsi_image_plotman2fits',... instead of self->image_fitswrite... so that
;   if hessi isn't in path, will still compile.  The fits write option only works for hessi anyway.
; 22-Jul-2009, Kim. Major changes to add a Refresh Panel List button.  Now panel_descs, panel_flags, and
;   cube_nums in uvalue structure are pointers, so the arrays can change size if panels are added. After
;   refreshing
; 14-Aug-2009, Kim. Added cleanup routine.
; 02-Oct-2009, Kim. Move multi_panel_update to after init and listupdate, so cube info is correct
; 06-Nov-2009, Kim. In multi_panel_listupdate, put panel number as well as desc in panel list
; 20-Jan-2010, Kim. Added Set Multiple Overlays button
; 23-May-2011, Kim. Added Invert Selection button
; 19-Mar-2013, Kim. In multi_panel_select, add comma after cube number in search string
; 17-Jul-2013, Kim. 'Show as movie' event now calls movie_widget (previously animate, which was renamed)
; 23-Jul-2015, Kim. Added PS multipage option (each selected panel is a page in a single PS file) 
;
;-

;-----

pro plotman_multi_panel_cleanup, id
widget_control, id, get_uvalue=conf_state
free_var, conf_state.panel_descs
free_var, conf_state.panel_flags
free_var, conf_state.cube_nums
end

;-----

pro plotman::multi_panel_select, conf_state, $
  search_string=search_string, cube=cube, subset=subset, invert=invert

if exist(cube) then begin
	q = where (strpos(*conf_state.panel_descs, 'Cube ' + trim(cube) + ',') ne -1)
endif

if exist(search_string) then begin
	if keyword_set(subset) then begin
		qsub = where (*conf_state.panel_flags, count)
		if count gt 0 then begin
			q = where (strpos(strlowcase((*conf_state.panel_descs)[qsub]), search_string) ne -1, count)
			if count gt 0 then q = qsub[q]
		endif else q = -1
	endif else begin
		q = where (strpos(strlowcase(*conf_state.panel_descs), search_string) ne -1)
	endelse
endif

if keyword_set(invert) then q= where(*conf_state.panel_flags eq 0, nq)

(*conf_state.panel_flags)[*] = 0
if q[0] ne -1 then (*conf_state.panel_flags)[q] = 1
set = where (*conf_state.panel_flags)
if set[0] eq -1 then widget_control, conf_state.w_list, set_value=*conf_state.panel_descs $
	else widget_control, conf_state.w_list, set_list_select = set

end

;-----

pro plotman::multi_panel_init, conf_state

; Save description of selected panels if any, so can restore user's selection if those panels still exist
; (can't store panel numbers because they may have changed)
save_descs = ''
if ptr_exist(conf_state.panel_flags) then begin
  q = where (*conf_state.panel_flags, count)
  if count gt 0 then save_descs = (*conf_state.panel_descs)[q]
endif

panels = self -> get(/panels)
conf_state.npanels = panels -> get_count()


*conf_state.panel_descs = self -> get(/all_panel_desc)
*conf_state.panel_flags = conf_state.npanels gt 0 ? intarr(conf_state.npanels) : 0

; Set selected panels to what was selected before.  If none are still there, then
; set to current panel, if one is currently selected.
q = where_arr(*conf_state.panel_descs, save_descs, count)
if count gt 0 then (*conf_state.panel_flags)[q] = 1 else begin
  curr_panel = self -> get(/current_panel)
  if curr_panel ne -1 then (*conf_state.panel_flags)[curr_panel] = 1
endelse

q = where(strpos(*conf_state.panel_descs, 'Cube ') ne -1, count)
if count eq 0 then begin
	*conf_state.cube_nums = -1
	conf_state.ncubes = 0
endif else begin
	tail = ssw_strsplit((*conf_state.panel_descs)[q], 'Cube ', /tail)
	nums = get_uniq(trim( ssw_strsplit(tail, ',') ))
	s=sort(fix(nums))
	*conf_state.cube_nums = nums[s]
	conf_state.ncubes = n_elements(*conf_state.cube_nums)
endelse

end

;-----
; Update widget options (except for list itself - that's done in 
; plotman::multi_panel_listupdate only when list changes)
pro plotman::multi_panel_update, conf_state

widget_control, conf_state.w_allfull, set_button=conf_state.allfull
widget_control, conf_state.w_linefull, set_button=conf_state.linefull
widget_control, conf_state.w_nacross, set_droplist_select=conf_state.nacross
widget_control, conf_state.w_cube_nums, sensitive=conf_state.ncubes gt 0
end

;-----

; Update list of panels, currently selected panels, and cube numbers available.
pro plotman::multi_panel_listupdate, conf_state

npanel = n_elements(*conf_state.panel_descs)
list = trim(indgen(npanel)) + ' ' + *conf_state.panel_descs
widget_control, conf_state.w_list, set_value=list

q = where (*conf_state.panel_flags, count)
if count gt 0 then widget_control, conf_state.w_list, set_list_select=q

widget_control, conf_state.w_cube_nums, set_value=conf_state.ncubes gt 0 ? ['-',*conf_state.cube_nums] : '-'
end

;-----  Event handler for multi_panel (can't be a method, so this calls the method)

pro plotman_multi_panel_event, event
widget_control, event.top, get_uvalue=state
state.plotman_obj -> multi_panel_event, event
end

;-----

pro plotman::multi_panel_event, event

if tag_names(event,/struc) eq 'WIDGET_KILL_REQUEST' then goto, exit

widget_control, event.top, get_uvalue=conf_state

widget_control, event.id, get_uvalue=uvalue

;if strpos(uvalue,'reset') eq 0 then begin
;	reset = ssw_strsplit(uvalue, 'reset_' ,/tail)
;	uvalue='reset'
;endif

case uvalue of
	'list': begin
		; toggle state of selected panel
		ind = widget_selected(event.id, /index)
		(*conf_state.panel_flags)[*] = 0
		if ind[0] ne -1 then (*conf_state.panel_flags)[ind] = 1
		end

	'selectall': self->multi_panel_select, conf_state, search_string=''

	'unselectall': begin
		(*conf_state.panel_flags)[*] = 0
		widget_control, conf_state.w_list, set_value=*conf_state.panel_descs
		end

    'invertsel': self->multi_panel_select, conf_state, /invert
    
	'selcube': begin
		; 0'th element is just -
		if event.index ne 0 then begin
			cube = (*conf_state.cube_nums)[event.index-1]
			self->multi_panel_select, conf_state, cube=cube
		endif
		end

	'search_all': begin
		widget_control, conf_state.w_search_string, get_value=ss
		self -> multi_panel_select, conf_state, search_string=strlowcase(trim(ss))
		end

	'search_sel': begin
		widget_control, conf_state.w_search_string, get_value=ss
		self -> multi_panel_select, conf_state, search_string=strlowcase(trim(ss)), /subset
		end

	'chgoptions': begin
		sel_panel = where(*conf_state.panel_flags, count)
		if count gt 0 then begin
			; if the current panel showing is one of the selected panels, use it's settings as the
			; basis for the options widget.  If not, plot the first selected panel, and use that
			; as the basis for the options widget.
			curr_panel = self -> get(/current_panel)
			if not is_member(curr_panel, sel_panel) then $
				self -> show_panel, panel_number=sel_panel[0]
			; this call will set new preferences in self.temp_pref
			self -> options, event, defaults='existing'

			; New preferences will already be set in current plot since we plotted in options and
			; plotting calls update_panel.  Now set them in other selected panels.
			temp_pref = self->get(/temp_pref)
			q = where (*conf_state.panel_flags, count)
			if count gt 0 then self -> reset_panel_pc, temp_pref, panels=*conf_state.panel_flags
		endif else a = dialog_message('No panels selected', /info)
		end

	'summselected': begin
		q = where (*conf_state.panel_flags, count)
		out = ''
		if count gt 0 then begin
			panels = self -> get(/panels)
			for ip = 0, conf_state.npanels-1 do begin
				if (*conf_state.panel_flags)[ip] then begin
					p = panels -> get_item(ip)
					self -> focus_panel, *p, ip
					thisout = ''
					self -> summ_params, screen=0, param=thisout, /quiet
					self -> unselect
					if thisout[0] ne '' then out = [out, $
						'Summary of Panel ' + (*conf_state.panel_descs)[ip], $
						thisout, $
						'----------------------------------------------------', $
						'']
				endif
			endfor
			if n_elements(out) eq 1 then out = 'None of selected panels can be summarized.'
		endif else out = 'No panels selected.'
		a = dialog_message(out, /info)
		end

	'delselected': begin
		save_desc = self -> get(/current_panel_desc)
		widget_control, /hourglass
		for i = conf_state.npanels-1, 0, -1 do begin 	; do loop backwards
			if (*conf_state.panel_flags)(i) eq 1 then self -> delete_panel, panel_number=i
		endfor
		;just in case panel numbers changed due to deletions, reset current panel number
		panel_number = self -> desc2panel(save_desc, /number)
		self -> set, current_panel_number=panel_number

		; put configure widget back on top
		widget_control, conf_state.tlb, /map

		prev_npanels = conf_state.npanels
		
		; update list of remaining panels in conf_state structure, and update widget
		self -> multi_panel_init, conf_state
    self -> multi_panel_listupdate, conf_state
    
		n_deleted = conf_state.npanels - prev_npanels
		if n_deleted eq 0 then out = 'No panels selected for deletion.' else $
			out = 'Deleted ' + trim(n_deleted) + ' panels.'
		a = dialog_message(out, /info, dialog_parent=conf_state.tlb)
		end

	'nacross': begin
		conf_state.nacross = event.index
		if conf_state.nacross ne 0 then begin
			conf_state.linefull = 0
			conf_state.allfull = 0
		endif
		end

	'allfull': begin
		conf_state.allfull = event.select
		if event.select then begin
			conf_state.linefull = 0
			conf_state.nacross = 0
		endif
		end

	'linefull': begin
		conf_state.linefull = event.select
		if event.select then begin
			conf_state.allfull = 0
			conf_state.nacross = 0
		endif
		end

	'plotselected': begin
		q = where (*conf_state.panel_flags, count)
		if conf_state.nacross ne 0 then nacross= conf_state.nacross
		if count gt 0 then begin
			self -> show_panel, $
				panel_number=q, $
				nacross=nacross, $
				all_1across=conf_state.allfull, $
				lineplots_1across=conf_state.linefull
		endif else a = dialog_message('No panels selected', /info)

		end

	'plotfile': begin
		widget_control, event.id, get_value=value
		self -> multi_file_output, *conf_state.panel_flags, value
		end

	'printplot': self -> multi_file_output, *conf_state.panel_flags, 'printplot'

	'writefits': self -> multi_file_output, *conf_state.panel_flags, 'writefits'

	'writesav': self -> multi_file_output, *conf_state.panel_flags, 'writesav'

;	'writecube': self -> image_fitswrite, panels_selected=where(conf_state.panel_flags eq 1)
  'writecube': call_procedure, 'hsi_image_plotman2fits', plotman_obj=self, $
       panels_selected=where(*conf_state.panel_flags)
  
	'imageflux': self -> multi_image_flux_widget, conf_state.tlb, where(*conf_state.panel_flags)

	'animate': self -> movie_widget, where(*conf_state.panel_flags), group=event.top
	
	'multiprofiles': self -> multi_profile_widget, conf_state.tlb, where(*conf_state.panel_flags)
	
	'multioverlays': self -> multi_overlay, conf_state.tlb, where(*conf_state.panel_flags)
	
	'refresh': begin
	  self -> multi_panel_init, conf_state
	  self -> multi_panel_listupdate, conf_state
	  end

	'close': goto, exit

	else: print, 'Unknown'

	endcase

if xalive(event.top) then begin
	widget_control, event.top, set_uvalue=conf_state
	self -> multi_panel_update, conf_state
endif

;print,conf_state.panel_flags
return

exit:
widget_control, event.top, /destroy

end

;-----

pro plotman::multi_panel, state=state

parent = self -> get(/plot_base)

; check if a plotma::multi_panel is already up that's associated with this plotman
; if so, the xregistered command brings it to foreground, and just return.
if xregistered('plotman_multi_panel') gt 0 then begin
	pp_id = get_handler_id('plotman_multi_panel', /all)
	for i=0,n_elements(pp_id)-1 do begin
		widget_control, pp_id[i], get_uvalue=pstate
		if pstate.plotman_obj eq self then begin
			widget_control,pp_id[i], /show
			return
		endif
	endfor
endif

handler = get_handler_name(parent)
title = 'PLOTMAN Multi-Panel Options' + $
	(strpos(handler,'plotman') eq -1 ? ' for '+ strupcase(handler) + ' GUI' : '')

nacross = 0
allfull = 0
linefull = 1

;if npanels eq 0 then return

get_font, font, big_font=big_font

widget_control, default_font = font

tlb = widget_base ( /column, $
					title=title, $
					mbar=mbar, $
					/tlb_kill, $
					group=parent, $
					space = 10 )

;tmp = widget_label (tlb, value='Multi-Panel Options', font=big_font)

w_base = widget_base (tlb, /row, space=10)

w_base1 = widget_base (w_base, /column, space=2, /frame)

tmp = widget_label (w_base1, value='Multi-Panel Options', font=big_font)

tmp = widget_label (w_base1, value='Click on a panel description to toggle select/unselect', $
	/align_center)
tmp = widget_label (w_base1, value='(Hold Control or Shift while clicking to select multiple panels)', $
	/align_center)
tmp = widget_label (w_base1, value=' ')
tmp = widget_label (w_base1, value='Available panels:', /align_left)

; On windows, need to define x size of widgets
if os_family() eq 'Windows' then xsize=40 ;10+max(strlen(panel_descs))
w_list = widget_list (w_base1,  $
					/multiple, $
					ysize=20, $
					xsize=xsize, $
					value='', $
					uvalue='list')

w_buttons = widget_base (w_base1, /row, space=10, /align_center)

tmp = widget_button (w_buttons, value='Select All', uvalue='selectall')

tmp = widget_button (w_buttons, value='Unselect All', uvalue='unselectall')

tmp = widget_button (w_buttons, value='Invert Selection', uvalue='invertsel')

w_cube_nums = widget_droplist (w_buttons, title='Select Image Cube: ', $
	value='    -    ', uvalue='selcube')

w_search = widget_base (w_base1, /row, space=10, /align_center)

w_search_string = cw_field (w_search, $
					/string, $
					title='Search String: ', $
					value='                            ')

tmp = widget_button (w_search, value='Search All', uvalue='search_all')

tmp = widget_button (w_search, value='Search on Selected', uvalue='search_sel')

w_but = widget_base (w_base1, /row, space=10, /align_center)
tmp = widget_button (w_but, value='Refresh Panel List', uvalue='refresh')
tmp = widget_button (w_but, value='Close', uvalue='close')

w_base2 = widget_base (w_base, /column, space=8, /frame)

tmp = widget_label (w_base2, value='For Selected Panels: ')

w_plotbase = widget_base (w_base2, /column, /align_center, /frame)
tmp = widget_button (w_plotbase, value='Plot', uvalue='plotselected', /align_center)
w_nacross = widget_droplist (w_plotbase, title='# plots across', $
	value=[' ','  '+strtrim(indgen(8)+1, 2)], uvalue='nacross')
w_plotbase2 = widget_base (w_plotbase, /nonexclusive, /column)
w_allfull = widget_button (w_plotbase2, value='All plots full width', uvalue='allfull')
w_linefull = widget_button (w_plotbase2, value='Line plots full width', uvalue='linefull')

tmp = widget_button (w_base2, value='Change Plot Options...', uvalue='chgoptions')

tmp = widget_button (w_base2, value='Summarize', uvalue='summselected', /align_center)

tmp = widget_button (w_base2, value='Delete', uvalue='delselected', /align_center)

w_plotfile = widget_button (w_base2, value='Create Plot Files ->', /menu, /align_center)

tmp = widget_button (w_plotfile, value='PS', uvalue='plotfile')

tmp = widget_button (w_plotfile, value='Multipage PS', uvalue='plotfile')

tmp = widget_button (w_plotfile, value='PNG', uvalue='plotfile')

tmp = widget_button (w_plotfile, value='TIFF', uvalue='plotfile')

tmp = widget_button (w_plotfile, value='JPEG', uvalue='plotfile')

tmp = widget_button (w_base2, value='Print Plots', uvalue='printplot', /align_center)

w_export = widget_button (w_base2, value='Export Data ->', /menu, /align_center)

tmp = widget_button (w_export, value='Write FITS files', uvalue='writefits')

tmp = widget_button (w_export, value='Write IDL save files', uvalue='writesav')

tmp = widget_button (w_base2, value='Write Image Cube FITS file', uvalue='writecube', /align_center)

tmp = widget_button (w_base2, value='Compute Image Flux...', uvalue='imageflux', /align_center)

tmp = widget_button (w_base2, value='Show as Movie...', uvalue='animate', /align_center)

tmp = widget_button (w_base2, value='Get Image Profiles...', uvalue='multiprofiles', /align_center)

tmp = widget_button (w_base2, value='Set Multi Overlays...', uvalue='multioverlays', /align_center)

conf_state = {plotman_obj: self, $
	npanels: 0, $
	panel_descs: ptr_new(/alloc), $
	panel_flags: ptr_new(/alloc), $
	cube_nums: ptr_new(/alloc), $
	ncubes: 0, $
	nacross: nacross, $
	allfull: allfull, $
	linefull: linefull, $
	tlb: tlb, $
	w_list: w_list, $
	w_cube_nums: w_cube_nums, $
	w_search_string: w_search_string, $
	w_nacross: w_nacross, $
	w_allfull: w_allfull, $
	w_linefull: w_linefull}

self -> multi_panel_init, conf_state
self -> multi_panel_listupdate, conf_state
self -> multi_panel_update, conf_state

widget_control, tlb, set_uvalue=conf_state

if xalive(parent) then begin
	widget_offset, parent, xoffset, yoffset, newbase=tlb
	widget_control, tlb, xoffset=xoffset, yoffset=yoffset
endif

widget_control, tlb, /realize

xmanager, 'plotman_multi_panel', tlb, /no_block, cleanup='plotman_multi_panel_cleanup'

end


