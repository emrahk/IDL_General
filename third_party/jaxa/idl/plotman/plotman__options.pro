;+
; Name: plotman::options
; Purpose: Main widget to control changing plot options.  Calls different widget setup and processing
;  routines depending on whether plot type is xy, ut, image, or spectrogram.  This routine
;  does the common stuff.
; Keywords:
;	defaults - Nothing, or one of 'xyplot', 'utplot', 'image', 'specplot', or 'existing'
; There are 3 modes:
;	1. When setting options for a single plot (by clicking button under Plot_Control),
;		defaults keyword is not passed in.  Widgets appear as they did before the Oct 1007 changes
;		and user can change options for current plot.
;	2. When setting default options for the session (for all future plots, and to save options for
;		next session), the string indicating the type of defaults to set is passed in - 'xyplot',
;		'utplot', 'image',  or 'specplot'.  This option is called by clicking 'Set Plot Preferences'
;		under the File button.
;	3, When changing options for multiple plots, defaults='existing' is passed in.  The plot_type is
;		set to whatever the current plot is.  This option is called by clicking 'Change Plot Options'
;		in the Multi-Panel Options widget after selecting the panels you want to change.
;
; In modes 2 and 3, little red boxes appear next to every widget option, and all the options are
; grayed out.  When the user clicks the red box, it turns green and the widget becomes sensitive.
; When exiting (unless cancelled) any options with a green box are used.
;
; In option 2, the green box items are stored in self.zz_pref, and written to file .plotman_zz_pref.geny
; in the temp dir.
;
; In option 3, the green box items are stored in self.temp_pref and will be set in the selected panels.
;
; Written, Kim Tolbert, October 2007
; Modifications:
;	24-Mar-2008, Kim. Changed data_dep_tags prop to tags_data_dep because of conflict with data prop.
;	17-Aug-2009, Kim. Added cleanup method.  And use set_plot_control to prevent memory leaks
;	20-Jan-2011, Kim. Widget created by the plot_type widget (e.g. plotman__imageoptions_widget) is
;	 now scrollable if necessary.  Put buttons into the first child of the top widget (for unix, needed
;	 to determine full size of widget), and call widget_limit_ysize to reduce y size of widget if necessary.
;-

pro plotman_options_cleanup, id
widget_control, id, get_uvalue=ostate, /no_copy
;free_var, ostate, exclude='obj'
if n_elements(ostate) eq 0 then return
ptr_free, ostate.defaults.green_wid
heap_free, ostate.original_plot_control
end

;-------

pro plotman::options_widget_update, ostate

case ostate.type of
	'xyplot': self -> xyopt_widget_update, ostate
	'utplot': self -> xyopt_widget_update, ostate
	'image': self -> imageopt_widget_update, ostate
	'specplot': self -> specopt_widget_update, ostate
endcase

plotman_update_axes_widgets, ostate

end

;--------- Event handler for options (can't be a method, so this calls the method)

pro plotman_options_event, event
widget_control, event.top, get_uvalue=ostate
ostate.obj -> options_event, event
end

;----------  The real event handler method

pro plotman::options_event, event

forward_function plotman_defaults_getvals

widget_control, event.top, get_uvalue=ostate

error = 0;catch, error
if error ne 0 then begin
	catch,/cancel
	;17-Aug-2009, use set_plot_control to prevent memory leaks
	self -> set_plot_control, ostate.original_plot_control
;	self.plot_control=ostate.original_plot_control
	case ostate.type of
		'xyplot': xkill,'plotman_xyoptions'
		'utplot': xkill,'plotman_xyoptions'
		'image': xkill,'plotman_imageoptions'
		'specplot': xkill,'plotman_specoptions'
	endcase
	message, 'Aborting.  ' + !error_state.msg, /cont
	return
endif

widget_control, event.id, get_uvalue=uvalue

;help,event,/st
;print,'uvalue = ', uvalue

exit = 0
redraw = 0

; if doing defaults, check if a red/green button caused event. If it did, uvalue
; will be returned as 'donothing'
if ostate.defaults.do_def then plotman_defaults_event, ostate, event, uvalue

com = ''
if ostate.applynow then redraw = 1 else redraw = 0

writefile = 0

case uvalue of

	'applyoption': begin
		ostate.applynow = event.select
		if not ostate.applynow then redraw = 0
		end

	'apply': redraw = 1

	'exit': begin
		redraw = 1
		exit = 1
		end

	'cancel': begin
		redraw = 1
		ostate.any_change = ostate.any_change_atall
    ;17-Aug-2009, use set_plot_control to prevent memory leaks
    self -> set_plot_control, ostate.original_plot_control		
;		self.plot_control=ostate.original_plot_control
		self -> options_widget_update, ostate
		exit = 1
		end

	'setall':

	'writefile':

	'canceldef': begin
		exit = 1
    ;17-Aug-2009, use set_plot_control to prevent memory leaks
    self -> set_plot_control, ostate.original_plot_control		
;		self.plot_control=ostate.original_plot_control
		goto, getout
		end

	'resetdef':  begin
		ostate.reset_to_defaults = 1
;		; get plot_defaults, remove data-dependent tags, and dereference any tags that are pointers
;		; so we can set them via _extra in plot_control
		self -> set, _extra= tag_dereference(rem_tag(self.plot_defaults,self.tags_data_dep))
		self -> options_widget_update, ostate
		*ostate.defaults.green_wid = -1
		; find all red/green buttons (have uname redgreen) and set to red
		wid = find_all_uname(event.top, 'redgreen')
		if wid[0] ne 0 then begin
			for i=0,n_elements(wid)-1 do begin
				widget_control, wid[i], set_value=self.red_bmp
				widget_control, wid[i], get_uvalue=uv
				widget_control, uv.wid, sensitive=0
				if uv.state eq 1 then begin
					uv.state = 0
					widget_control, wid[i], set_uvalue=uv
				endif
			endfor
		endif
		end

	'acceptdef': exit = 1

	'donothing':

	else: begin

		case ostate.type of
			'xyplot': self -> xyoptions_event, event, com, exit, redraw, found
			'utplot': self -> xyoptions_event, event, com, exit, redraw, found
			'image': self -> imageoptions_event, event, com, exit, redraw, found
			'specplot': self -> specoptions_event, event, com, exit, redraw, found
		endcase

		if not found then begin
			if strmid(uvalue, 0, 4) eq 'axes' then begin
				self -> setaxes, event, com
				ostate.any_change = 1
				ostate.any_change_atall = 1
			endif else begin
				print,'Unknown command in plotman::options_event.'
			endelse
		endif
		end

endcase

if com ne '' then begin
	ostate.any_change = 1
	ostate.any_change_atall = 1
;	result = execute(com)
endif

; gather up all values that wouldn't cause an event unless user hit return
; note: cw_field does not cause an event, but cw_range and cw_edroplist do cause
; event when value has changed and focus is placed on another field in widget.

case ostate.type of
	'xyplot': self -> xyoptions_checkvals, ostate
	'utplot': self -> xyoptions_checkvals, ostate
	'image': self -> imageoptions_checkvals, ostate
	'specplot': self -> specoptions_checkvals, ostate
endcase

if ostate.defaults.do_def then redraw = 0

if ostate.any_change and redraw then begin
	self -> select
	self -> plot
	ostate.any_change = 0
endif

;if writefile and ostate.defaults.do_def then begin
;	; struct will be structure of all names/values that have green button on
;	struct = plotman_defaults_getvals(ostate, status=status)
;	file = 'plotman_'+ostate.type+'_defaults.sav'
;	outfile = ssw_pickfile( file=file, $
;							exists=exists, $
;							title='Select file name for ' + ostate.type + ' defaults', $
;							filter='*.sav', $
;							_extra=_ref_extra )
;	print,outfile
;endif


if exit and ostate.defaults.do_def then begin
	; struct will be structure of all names/values that have green button on
	struct = plotman_defaults_getvals(ostate, status=status)

	if ostate.defaults.do_existing then begin
		; show change in current plot and set temp_pref, so changes will be put into other selected plots
		self -> select
		self -> plot
		; if we're changing existing plots, and we did a reset to defaults, merge
		; green button items into plot_defaults structure (after excluding data-dependent tags)
		; then save into the temp_pref structure
		if ostate.reset_to_defaults then begin
			struct_def = tag_dereference(rem_tag( self.plot_defaults, self.tags_data_dep))
			if status then copy_struct, struct, struct_def
			*self.temp_pref =struct_def
		endif else begin
			*self.temp_pref = struct  ; do this even if status=0 (struct=-1 - no changes)
		endelse

	endif else begin
		; otherwise save green button items into the correct .._pref structure (or if the 'Set
		; for all Plot Types' button was set, set in all the _pref structures), and then restore
		; the original plot control structure.  Write to file(s) if write file button was set
		; and the directory is writable.
		if status then begin
			doall = widget_info(ostate.w_setall, /button_set)
			dowrite = widget_info(ostate.w_writefile, /button_set)
			if dowrite then begin ; check that directory we want to write in is writeable
				name=file_break(self.xy_file_pref,path=dir)
				dowrite = write_dir(dir, /quiet)
			endif

			; in each case, when setting the pref types other than the one we're really on (as a result of
			; setall button being clicked), join the new struct with the existing one, with struct values overriding existing

			; do image first, then remove all overlay tags before storing the other types (if doall, and type was image,
			; don't want overlay stuff set in other types.  If type was any of other types, there won't be any overlay
			; tags anyway)
			if ostate.type eq 'image' or doall then begin
				tmp_str = struct
				if ostate.type ne 'image' then if is_struct(*self.image_pref)  then tmp_str = join_struct(tmp_str, *self.image_pref)
				*self.image_pref = tmp_str
				if dowrite then savegenx, file=self.image_file_pref, tmp_str, /over
			endif
			; remove ..overlay.. tags
			if is_struct(struct) then begin
				if doall and ostate.type eq 'image' then begin
					tags = tag_names(struct)
					q = where (strpos(tags, 'OVERLAY') ne -1, count)
					if count gt 0 then struct = rem_tag (struct, tags[q])
				endif
			endif
			; now set the rest of types if requested using struct with no overlay tags
			if ostate.type eq 'xyplot' or doall then begin
				tmp_str = struct
				if ostate.type ne 'xyplot' then if is_struct(*self.xy_pref)  then tmp_str = join_struct(tmp_str, *self.xy_pref)
				*self.xy_pref = tmp_str
				if dowrite then savegenx, file=self.xy_file_pref, tmp_str, /over
			endif
			if ostate.type eq 'utplot' or doall then begin
				tmp_str = struct
				if ostate.type ne 'utplot' then if is_struct(*self.ut_pref)  then tmp_str = join_struct(tmp_str, *self.ut_pref)
				*self.ut_pref = tmp_str
				if dowrite then savegenx, file=self.ut_file_pref, tmp_str, /over
			endif

			if ostate.type eq 'specplot' or doall then begin
				tmp_str = struct
				if ostate.type ne 'specplot' then if is_struct(*self.spec_pref)  then tmp_str = join_struct(tmp_str, *self.spec_pref)
				*self.spec_pref = tmp_str
				if dowrite then savegenx, file=self.spec_file_pref, tmp_str, /over
			endif
		endif
    ;17-Aug-2009, use set_plot_control to prevent memory leaks
    self -> set_plot_control, ostate.original_plot_control		
;		self.plot_control=ostate.original_plot_control
	endelse
endif

getout:
if exit then begin
;	free_var, ostate.defaults
	widget_control, event.top, /destroy
endif else begin
	self -> options_widget_update, ostate
	widget_control, event.top, set_uvalue=ostate
endelse

end

;-----

pro plotman::options, event, defaults=defaults_in

; if defaults_in passed in, we're doing either global preferences, or changing options
; for existing plots, so set def_struct with the defaults we want to start with.
; NOTE:  this is a structure containing ONLY the items the user wanted to set as default
; For 'existing', it's none (so -1)
if keyword_set(defaults_in) then begin
	do_def = 1
	case defaults_in of
		'xyplot': def_struct = *self.xy_pref
		'utplot': def_struct = *self.ut_pref
		'image': def_struct = *self.image_pref
		'specplot': def_struct = *self.spec_pref
		'existing': begin
			def_struct = -1
			do_existing = 1
			end
	endcase
	if defaults_in ne 'existing' then type = defaults_in
endif

; defaults structure values:
;  do_def - 0/1,if set means we're doing defaults (either general, or for existing plots)
;  do_existing - 0/1, if set means we're changing options on existing plots
;  def_names - the names of the options that already have default values
;  green_wid - will contain the widget ids of any widgets that have been set to green
defaults = {do_def: fcheck(do_def,0), $
	do_existing: fcheck(do_existing, 0), $
	def_names: (is_struct(def_struct) ? strlowcase(tag_names(def_struct)) : ''), $
	green_wid: ptr_new(-1), $
	red_bmp: self.red_bmp, $
	green_bmp: self.green_bmp }

; if type not already set, means we're doing existing, so get current plot type
checkvar, type, self->get(/plot_type)

original_plot_control = stc_clone(self.plot_control)

if defaults.do_def and not defaults.do_existing then begin

  ;17-Aug-2009, use set_plot_control to prevent memory leaks
  self -> set_plot_control, self.plot_defaults
;	self.plot_control=stc_clone(self.plot_defaults)
	
	self -> set, plot_type = type
	if is_struct(def_struct) then self -> set, _extra=def_struct
endif else begin
	; if not doing general defaults, then must have valid plot up
	if  not self->valid_window(/message) then return
endelse

case type of
	'xyplot': self -> xyoptions_widget, event, ostate, defaults
	'utplot': self -> xyoptions_widget, event, ostate, defaults
	'image': self -> imageoptions_widget, event, ostate, defaults
	'specplot': self -> specoptions_widget, event, ostate, defaults
endcase

; Put buttons into the base that's inside the tlb (needed on unix).  This is so the size of the 
; scrollable tlb can be set later on by widget_limit_ysize
w_box = widget_info(ostate.tlb, /child)

w_buttons = widget_base (w_box, $
					/row, $
					space=5, /align_center)

if defaults.do_def then begin

	if not defaults.do_existing then begin
		w_setbase = widget_base (w_buttons, /row, /nonexclusive)
		w_setall = widget_button (w_setbase, value='Set for all Plot Types', uvalue='setall')
	endif

	if not defaults.do_existing then begin
		w_writebase = widget_base (w_buttons, /row, /nonexclusive)
		w_writefile = widget_button (w_writebase, value='Write in File', uvalue='writefile')
		widget_control, w_writefile, set_button=1
	endif

	temp = widget_button (w_buttons, value='Cancel', uvalue='canceldef')
	if not defaults.do_existing then temp = widget_button (w_buttons, value='Reset to Defaults', uvalue='resetdef')

	temp = widget_button (w_buttons, value='Accept and Close', uvalue='acceptdef')

endif else begin

	w_applynow_base = widget_base (w_buttons, /row, /nonexclusive, /align_center)
	w_applynow = widget_button (w_applynow_base, value='Auto Apply', uvalue='applyoption' )
	widget_control, w_applynow, set_button = 1

	temp = widget_button (w_buttons, value=' Cancel ', uvalue='cancel' )
	temp = widget_button (w_buttons, value=' Apply ', uvalue='apply' )
	w_exit = widget_button (w_buttons, value=' Accept and Close', uvalue='exit') ; /menu)

endelse

temp = { $
	obj: self, $
	type: type, $
	w_setall: fcheck(w_setall,0L), $
	w_writefile: fcheck(w_writefile,0L), $
	applynow: defaults.do_def? 0 : 1, $
	reset_to_defaults: 0, $
	original_plot_control: original_plot_control, $
	any_change: 0, $		; to decide whether we need to replot
	any_change_atall: 0, $	; to decide whether we need to replot if user cancelled
	defaults: defaults }

; merge with ostate returned by plotman_zzoptions_widget
ostate = create_struct(temp, ostate)

; make sure y size is not bigger than some fraction of display screen
widget_limit_ysize, ostate.tlb, w_box

widget_offset, ostate.parent, newbase=ostate.tlb, xoffset, yoffset

widget_control, ostate.tlb, xoffset=xoffset, yoffset=yoffset

widget_control, ostate.tlb,  /realize

widget_control, ostate.tlb, set_uvalue=ostate

self -> options_widget_update, ostate

case type of
	'xyplot': xmanager, 'plotman_xyoptions', ostate.tlb, event_handler='plotman_options_event', cleanup='plotman_options_cleanup'
	'utplot': xmanager, 'plotman_xyoptions', ostate.tlb, event_handler='plotman_options_event', cleanup='plotman_options_cleanup'
	'image': xmanager, 'plotman_imageoptions', ostate.tlb, event_handler='plotman_options_event', /modal, cleanup='plotman_options_cleanup'
	'specplot': xmanager, 'plotman_specoptions', ostate.tlb, event_handler='plotman_options_event', cleanup='plotman_options_cleanup'
endcase

return

end
