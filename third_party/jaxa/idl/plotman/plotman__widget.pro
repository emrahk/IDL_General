;+
; Name: plotman__widget
;
; Purpose: Create and handle most events in plotman widget.   Called by plotman__define.
;
; CATEGORY: HESSI WIDGETS
;
; Written: Kim Tolbert, 2000
; Modifications:
;   21-Jan-2001, Kim - enabled export fits option
;	Kim, 21-Apr-2001.  Changed plot control tags from r,g,b to rcolors,...
;	7-May-2001, Kim.  Added imageflux option
;	10-Jul-2001, Kim.  call magnify method
;	1-Sep-2001, Kim.  Added zoom to previous button
;	18-Mar-2002, Kim.  Added angled image profiles button
;	9-Jun-2002, Kim.  Enabled export to idlsave file
;	18-Jun-2002, Kim.  Added /namedialog to idlsave export call
;	30-Jun-2002, Kim.  Don't handle 'summparams' uvalue here.  Now handled in
;	  plotman_window_control_event
;   01-Aug-2002, Kim.  Added reset button
;	23-Sep-2002, Kim.  Use /relaxed on restgenx call in case structure def has changed.
;	01-Oct-2002, Kim.  Save exit widget id in widgets structure.
;	06-Sep-2002, Kim.  Added spectrogram plot 'specplot' button
;	10-Jan-2003, Kim.  Use widget size info a little differently to make it work in IDL 5.6 on UNIX
;	17-Jan-2003, Kim.  added plotman_cleanup procedure to clean up when widget is killed (even from outside)
;	??-Mar-2003, Kim.  Added spectrogram integrate option.  Also initialized the upper buttons under
;	  Plot_Control to sensitive=0.
;	16-Sep-2003, Kim.  Widget resizing didn't work in IDL 6.0.  Fixed this.  Now save x_borders, y_borders
;	  (diff between overall widget and main draw widget) and
;	16_Mar-2004, Kim.  For standalone plotman, use widget_offset to position if group available
;	21-Mar-2005, Kim.  Added average option to image profiles button
;	24-May-2005, Kim.  Added nomap option.
;	17-Jun-2005, Kim.  Added submenu for integrating spectrograms - full y or select y range.
;	22-May-2006, Kim.  Fixed nomap in realize (had it backwards)
;	16-Nov-2006, Kim.  Call widget_offset only if group is alive.
;	5-Nov-2007,  Kim.  Made plotman_widget into a method, renamed plotman__widget (so changed everything
;	  to self.  Got rid of all old defaults changing stuff.  Added Set Preferences button.  Call new ..options
;	  widgets.
;	6-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont to remove hessi dependencies.
; 25-Aug-2008, Kim.  Look for help file in $SSW/gen/idl/plotman/doc after move to gen
; 24-Nov-2008, Kim.  Buttons for configuring and printing plots to files or printer don't call 
;   plotman_configure_files_event and plotman_create_files_event any more.  Now they just have uvalues
;   and are handled in widget_event method with calls to new methods conf_plot_file and create_plot_file
; 11-May-2010, Kim.  Default size of initial widget was based on width of device.  On unix, if have
;   two monitors, device returns the width of both.  So now use the height as the basis of the size.
; 27-Jun-2013, Kim.  For resizing event, added check that new window is not too small.  
; 06-Apr-2015, Kim. Don't understand why, but for some types of plots, an event is generated when it shouldn't be.
;   The event handler thinks it's a resize event and redraws the plot.  Happens over and over, sometimes won't stop 
;   (usually with rhessi obs summ corrected count rate from sep dets).  Added a test - if size hasn't changed, just return.
;
;-

; cleanup for plotman widget and object

pro plotman_widget_cleanup, id
widget_control, id, get_uvalue=state
obj_destroy, state.plotman_obj
end

;--- Event handler for plotman_widget (can't be a method, so this calls the method)

pro plotman_widget_event, event
widget_control, event.top, get_uvalue=state
state.plotman_obj -> widget_event, event
end

;--- The real event handler method

pro plotman::widget_event, event

;print,'in plotman_widget_event'
;help,event,/st

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue
;print,'uvalue=', uvalue
widget_control, state.widgets.w_message, set_value=' '

com=''

; check if user clicked X in top right corner of window, and if so quit

if tag_names(event,/struc) eq 'WIDGET_KILL_REQUEST' then goto, exit

; if id is top, then event is a resize window event

if event.id eq event.top then begin

;	this was the old way.  Now save x,y_borders and just use event position, 16-sep-2003
;	topgeom = widget_info(event.top, /geom)
;	maingeom = widget_info (state.widgets.w_maindrawbase, /geom)
;	; Unix seems to return event.y differently from Windows
;	yadd = os_family() eq 'Windows' ? 0 : -25
;	newx = event.x - (topgeom.xsize - maingeom.xsize) + 5
;	newy = event.y - (topgeom.ysize - maingeom.ysize) + yadd
;	WIDGET_CONTROL, state.widgets.w_maindrawbase, XSIZE=newx, YSIZE=newy

  
	newx = event.x - state.widgets.x_borders
	newy = event.y - state.widgets.y_borders
	
	; Added this test 4/6/2015 to try to stop the endless re-plotting of panels.
	; newx, newy are new size of full plot base minus top and side borders.  Compare to geometry
	; of maindrawbase. They are same unless we're really resizing. If same, just return.
	geom = widget_info(state.widgets.w_maindrawbase, /geom)
;	help,newx,newy,geom.xsize,geom.ysize
	if newx eq geom.xsize and newy eq geom.ysize then return
	
	if newx gt 10 and newy gt 10 then $
	  WIDGET_CONTROL, state.widgets.w_maindrawbase, XSIZE=newx, YSIZE=newy $
	else message,/info,'Trying to shrink plotman too much. Not resizing.'

;	replot was was already in window
	last_window_choice = self -> get(/last_window_choice)
	plotman_window_control_event, 1, saved_uvalue=last_window_choice, state=state

	return

endif

if size(uvalue, /tname) ne 'STRING' then uvalue = ''
if size(uvalue, /n_dim) ne 0 then uvalue = ''	; must be a scalar
uname = widget_info(event.id,/uname)

case uvalue of

  'ps_file': self->create_plot_file, /ps
  'png_file': self->create_plot_file, /png
  'tiff_file': self->create_plot_file, /tiff
  'jpeg_file': self->create_plot_file, /jpeg
  'print_plot': self->create_plot_file, /print
  
  'confps': self->conf_plot_file, /ps
  'confpng': self->conf_plot_file, /png
  'conftiff': self->conf_plot_file, /tiff
  'confjpeg': self->conf_plot_file, /jpeg
  'confpsprint': self->conf_plot_file, /print
  
	'export_text': begin
		if self ->valid_window(/message) then self -> export, /text, /file_text
		end

	'export_fits': begin
		if self ->valid_window(/message) then self -> export, /fits, /namedialog
		end

	'export_idlsave': begin
		if self ->valid_window(/message) then self -> export, /idlsave, /namedialog
		end

	'imageoptions': begin
		if xalive(state.widgets.w_message) then widget_control, state.widgets.w_message, set_value=' '
		self -> options, event
		end

	'imageprofiles': begin
		if  self->valid_window(/message) then self -> profiles
		end

	'imageprofiles_ave': begin
		if  self->valid_window(/message) then self -> profiles, /average
		end

	'imageprofiles_ang': begin
		if  self->valid_window(/message) then self -> profiles, /angled
		end

	'imageflux': begin
		if  self->valid_window(/message) then self -> image_flux
		end

	'imagecolor': begin
		if xalive(state.widgets.w_message) then widget_control, state.widgets.w_message, set_value=' '
		if  self->valid_window(/message) then self -> colors, event, /replot
		end

	'xyoptions': begin
		if xalive(state.widgets.w_message) then widget_control, state.widgets.w_message, set_value=' '
		self -> options, event
		end

	'specoptions': begin
		if xalive(state.widgets.w_message) then widget_control, state.widgets.w_message, set_value=' '
		self -> options, event
		end

	'specintegr_full': begin
		if  self->valid_window(/message) then self -> spec_integr, /full
		end

	'specintegr_sel': begin
		if  self->valid_window(/message) then self -> spec_integr
		end

	'zoom': begin
		if  self->valid_window(/message) then plotman_zoom, state ; new routine so that if user just clicks in plot can zoom too, 3/21/00
		end

	'zoom_prev': begin
		if  self->valid_window(/message) then plotman_zoom, state, /use_previous ; new routine so that if user just clicks in plot can zoom too, 3/21/00
		end

	'unzoom': begin
		if  self->valid_window(/message) then begin
			com = 'self -> set, xrange=[0,0], yrange=[0,0], zrange=[0,0], timerange=[0.d0,0.d0]'
		endif
		end

	'magnify': 	self -> magnify

	'magnify2': self -> magnify, size=200

	'intervals': plotman_intervals, event, 'int'

	'bintervals': plotman_intervals, event, 'bkgd'

	'refresh': begin
		if  self->valid_window(/message) then begin
			com = ' '  ; just redraw plot (this is a blank, not an empty string)

;			; check if this event was from xcolors.  If colors have changed
;			; then redraw. Otherwise set com='', which does nothing.
;			thisevent = tag_names (event, /structure)
;			if thisevent eq 'XCOLORS_LOAD' then begin
;				pc = self -> get(/plot_control)
;				r = event.r(pc.bottom:pc.bottom+pc.wcolors-1)
;				g = event.g(pc.bottom:pc.bottom+pc.wcolors-1)
;				b = event.b(pc.bottom:pc.bottom+pc.wcolors-1)
;				; do something only if colors have changed
;				if total(r-pc.rcolors) + total(g-pc.gcolors) + total(b-pc.bcolors) ne 0 then begin
;					pc.rcolors = r  &  pc.gcolors = g  &  pc.bcolors = b
;					self -> set, plot_control=pc
;					imdef = self -> get(/plot_defaults)
;					imdef.rcolors = r  &  imdef.gcolors = g  &  imdef.bcolors = b
;					self -> set, plot_defaults=imdef
;				endif else begin
;					com = ''
;				endelse
;			endif
		endif

		end

	'set_xypref': self -> options, event, defaults='xyplot'
	'set_utpref': self -> options, event, defaults='utplot'
	'set_imagepref': self -> options, event, defaults='image'
	'set_specpref': self -> options, event, defaults='specplot'

;	'summparams': begin
;		which_panel = self -> which_panel (event.id, panel_number=panel_number)
;		self -> focus_panel, which_panel, panel_number
;		if self ->valid_window(/message) then self -> summ_params
;		self -> unselect
;		widget_control, event.top, get_uvalue=state
;		end

	'stop': stop

	'help_topics': begin ; gui_help, 'plotman_help.htm'
		check = concat_dir(local_name('$SSW/gen/idl/plotman/doc'), 'plotman_help.htm')
		file = file_search (check, count=count)
		if count eq 0 then begin
			a=dialog_message(['Help file ' + check + 'not found.', $
				'Please notify kim.tolbert@nasa.gov'], $
				title='Help file not found')
			return
		endif else netscape_control, file[0]
		end

	'help_about': begin
		widget_control, /hour
		msg = ['The Plot Manager package was developed by', $
		 		'Kim Tolbert of Wyle Information Systems at NASA/GSFC.', $
		 		' ', $
		 		'kim.tolbert@nasa.gov     301-286-3965']
		ok = dialog_message(msg, title='PLOTMAN Contact Information', /info)
		end

	'reset': plotman_reset, self

	'exit': goto, exit

	'printsetup': begin
		widget_control, state.widgets.confpsid, send_event={id:state.widgets.confpsid, $
        	top:event.top, handler:0l}
        end

	'printersel': begin
		plotman_printer, event
		end

	else: print, 'Unknown user value in plotman = ', uvalue

endcase
;print,'command = ', com

;if strmid(uvalue,0,4) eq 'def_' then begin
;	if what eq 'this' or what eq 'all' then begin
;		; this modifies plot control for current panel
;;		self -> reset_panel_pc, pc
;		self -> set, _extra=pc
;		self -> select
;		self -> plot
;		self -> unselect
;	endif
;	if what eq 'new' or what eq 'all' then begin
;		; this modifies xx_curr_defaults for future plots
;		case plot_type of
;			'xyplot': self -> set, xy_curr_pref = pc
;			'utplot': self -> set, ut_curr_pref = pc
;			'image':  self -> set, image_curr_pref = pc
;			'specplot': self -> set, spec_curr_pref = pc
;		endcase
;;		if plot_type eq 'im' then $
;;			self -> set, image_defaults = pc else $
;;			self -> set, xy_defaults = pc
;		; this modifies plot control saved all all saved plots
;		if what eq 'all' then self -> reset_panel_pc, pc;, /all
;	endif
;endif

if com ne '' then begin
	result = execute(com)
	self -> select
	self -> plot
endif

if xalive (event.top) then begin
	widget_control, event.top, set_uvalue=state
endif

return

exit:
widget_control, event.top, /destroy  ; this will call plotman_widget_cleanup to clean up

end

;-----

function plotman::widget, group=group, $
	wxsize=wxsize, wysize=wysize, wxpos=wxpos, wypos=wypos, $
	mainbase=mainbase, widgets=widgets, multi_panel=multi_panel, nomap=nomap

plot_control = self -> get(/plot_control)
;help,plot_control,/st
output_control = self -> get(/output_control)
plot_type = self -> get(/plot_type)

device, get_screen_size=scr
;if not exist(wxsize) then wxsize = fix (scr[0] * .4)
;if not exist(wysize) then wysize = wxsize * 1.1
if not exist(wxsize) then wxsize = fix (scr[1] * .52)
if not exist(wysize) then wysize = wxsize * 1.1

get_font, font, big_font=big_font

widget_control, default_font = font

standalone = not keyword_set(mainbase)
multi_panel = keyword_set(multi_panel)

if standalone then begin
	if xalive (group) then begin
		geom = widget_info (group, /geometry)
		xoffset = geom.xoffset
		yoffset = geom.yoffset
	endif else begin
		xoffset = 100
		yoffset = 100
	endelse

	if exist(wxpos) then xoffset = wxpos
	if exist(wypos) then yoffset = wypos

	plot_base = widget_base (group_leader=group, $
						title='Plot Manager', $
						xoffset=xoffset, $
						yoffset=yoffset, $
						/column, $
						mbar=mbar, $
						/tlb_size_events, $
						/tlb_kill  )

	w_file = widget_button (mbar, value='File', /menu)

	mbar_control_name = 'Plot_Control'

	separator = 0

endif else begin

	plot_base = mainbase

	widget_control, mainbase, get_uvalue=mw_state
	mbar = mw_state.mbar
	w_file = mw_state.w_file

	mbar_control_name = 'Plot_Control'

	separator = 1

endelse

w_setdef = widget_button (w_file, value='Set Plot Preferences', /menu, $
	separator=separator, event_pro='plotman_widget_event')
tmp = widget_button (w_setdef, value='for XY Plots', uvalue='set_xypref')
tmp = widget_button (w_setdef, value='for UT Plots', uvalue='set_utpref')
tmp = widget_button (w_setdef, value='for Image Plots', uvalue='set_imagepref')
tmp = widget_button (w_setdef, value='for Spectrogram Plots', uvalue='set_specpref')

configure = widget_button (w_file, $
					value='Configure Plot File', $
					/menu, $
					event_pro='plotman_widget_event', $
					separator=separator)

confpsid = widget_button (configure, $
					value='Configure PS File...', $
					uvalue='confps' )

confpngid = widget_button (configure, $
					value='Configure PNG File...', $
					uvalue='confpng' )

conftiffid = widget_button (configure, $
					value='Configure TIFF File...', $
					uvalue='conftiff' )

confjpegid = widget_button (configure, $
					value='Configure JPEG File...', $
					uvalue='confjpeg' )

createplot = widget_button (w_file, $
					value='Create Plot File', $
					/menu, $
					event_pro='plotman_widget_event')

psid = widget_button (createplot, $
					value='Create PS File', $
					uvalue='ps_file')

pngid = widget_button (createplot, $
					value='Create PNG File', $
					uvalue='png_file')

tiffid = widget_button (createplot, $
					value='Create TIFF File', $
					uvalue='tiff_file')

jpegid = widget_button (createplot, $
					value='Create JPEG File', $
					uvalue='jpeg_file')

temp = widget_button (w_file, $
					/separator, $
					value='Select Printer...', $
					uvalue='printersel', $
					event_pro='plotman_widget_event' )

temp = widget_button (w_file, $
					value='Configure Print Plot Output...', $
					uvalue='confpsprint', $
					event_pro='plotman_widget_event', $
					/separator)

printid = widget_button (w_file, $
					value='Print Plot', $
					uvalue='print_plot', $ 
					event_pro='plotman_widget_event' )

w_export = widget_button (w_file, $
					value='Export Data', $
					/menu, $
					/separator, $
					event_pro='plotman_widget_event', $
          uname='export_data')

	temp = widget_button (w_export, value='Write text file...', uvalue='export_text')
	temp = widget_button (w_export, value='Write FITS file...', uvalue='export_fits')
	temp = widget_button (w_export, value='Write IDL save file...', uvalue='export_idlsave')


w_exit=0L
if standalone then begin

		temp = widget_button (w_file, $
					value='Stop (for debug purposes only)', $
					uvalue='stop', $
					/separator )

		temp = widget_button (w_file, value='Reset Widgets (Recover from Problems)', uvalue='reset')

		w_exit = widget_button (w_file, value='Exit', uvalue='exit' )

endif

w_control = widget_button (mbar, $
					value=mbar_control_name, $
					/menu, $
					event_pro='plotman_widget_event')

w_img = widget_button (w_control, $
				value='Image Display Options...', $
				uvalue='imageoptions', sensitive=0 )

w_imgprofile = widget_button (w_control, $
				value='Image or Spectrogram Profiles', $
				/menu, sensitive=0)

tmp = widget_button (w_imgprofile, value='Rows or Columns', uvalue='imageprofiles')
tmp = widget_button (w_imgprofile, value='Rows or Columns, Averaged', uvalue='imageprofiles_ave')
tmp = widget_button (w_imgprofile, value='Any Angle', uvalue='imageprofiles_ang')

w_imgflux = widget_button (w_control, $
				value='Image Flux', $
				uvalue='imageflux', sensitive=0)

w_colors = widget_button (w_control, $
				value='Image Colors...', $
				uvalue='imagecolor', $
				sensitive=0 )

;w_colors = widget_button (w_control, $
;				event_pro='plotman_colors', $
;				value='Image Colors...', $
;				uvalue=[plot_control.ncolors, plot_control.bottom], sensitive=0 )

w_xy = widget_button (w_control, $
					value='XY Plot Display Options...', $
					uvalue='xyoptions', sensitive=0 )

w_spec = widget_button (w_control, $
					value='Spectrogram Plot Display Options...', $
					uvalue='specoptions', sensitive=0 )

w_spec_integr = widget_button (w_control, $
					value='Spectrogram Integrate Over Y', $
					/menu, sensitive=0 )

tmp = widget_button (w_spec_integr, value='Use full Y range', uvalue='specintegr_full')
tmp = widget_button (w_spec_integr, value='Select Y range with mouse', uvalue='specintegr_sel')

tmp = widget_button (w_control, $
					/separator, $
					value='Zoom', $
					uvalue='zoom', $
					event_pro='plotman_widget_event' )

tmp = widget_button (w_control, $
					value='Zoom to previous zoom limits', $
					uvalue='zoom_prev', $
					event_pro='plotman_widget_event' )

tmp = widget_button (w_control, $
					value='Unzoom', $
					uvalue='unzoom', $
					event_pro='plotman_widget_event' )

w_mag = widget_button (w_control, $
					value='Magnify', $
					/menu, $
					;uvalue='magnify', $
					event_pro='plotman_widget_event' )

tmp = widget_button (w_mag, $
					value='Default box size', $
					uvalue='magnify')

tmp = widget_button (w_mag, $
					value='Bigger box size', $
					uvalue='magnify2')

w_refresh = widget_button (w_control, $
					/separator, $
					value='Refresh', $
					uvalue='refresh', $
					event_pro='plotman_widget_event' )

if multi_panel then begin
	w_window_control = widget_button (mbar, $
					value='Window_Control', $
					/menu, $
					event_pro='plotman_window_control_event' )
	plotman_set_window_control_pulldown_basic, plot_base, w_window_control
endif else w_window_control = 0L

if standalone then begin
	w_help = widget_button (mbar, value='Help',  /menu, event_pro='plotman_widget_event' )
	w_help2 = widget_button (w_help, value='Help Topics', uvalue='help_topics' )
	w_help3 = widget_button (w_help, value='About PLOTMAN', uvalue='help_about')
endif

w_maindrawbase = widget_base (plot_base, $
					xsize=wxsize, $
					ysize=wysize, $
					frame=3, $
					event_pro='plotman_widget_event', $
					uvalue='mainbase')

window_id = -1
w_drawbase = 0L
w_draw = 0L

w_message = widget_text (plot_base, $
					ysize=1, $
					/scroll, $
					/wrap, $
					/frame)

widget_control, plot_base, /realize, map=keyword_set(nomap) eq 0

; get some widget geometry info.  Save difference between overall widget and main draw widget
; so that when resizing, we can maintain this border (for labels on top, messages below)
topgeom = widget_info(plot_base, /geom)
maingeom = widget_info(w_maindrawbase, /geom)
x_borders = topgeom.xsize - maingeom.xsize
y_borders = topgeom.ysize - maingeom.ysize
if os_family() eq 'unix' then y_borders = y_borders + 30

widgets = { $
	plot_base: plot_base, $
	x_borders: x_borders, $
	y_borders: y_borders, $
	psid: psid, $
	pngid: pngid, $
	tiffid: tiffid, $
	jpegid: jpegid, $
	confpsid: confpsid, $
	confpngid: confpngid, $
	conftiffid: conftiffid, $
	confjpegid: confjpegid, $
	printid: printid, $
	w_img: w_img, $
	w_imgprofile: w_imgprofile, $
	w_imgflux: w_imgflux, $
	w_colors: w_colors, $
	w_xy: w_xy, $
	w_spec: w_spec, $
	w_spec_integr: w_spec_integr, $
;	w_curr_xy_all: w_curr_xy_all, $
;	w_curr_xy_future: w_curr_xy_future, $
;	w_curr_im_all: w_curr_im_all, $
;	w_curr_im_future: w_curr_im_future, $
	w_window_control: w_window_control, $
	w_maindrawbase: w_maindrawbase, $
	w_drawbase: w_drawbase, $
	w_draw: w_draw, $
	w_refresh: w_refresh, $
	w_message: w_message, $
	window_id: window_id, $
	w_exit: w_exit }

state = {mbar: mbar, $
	plotman_obj: self, $
	widgets: widgets }

if standalone then begin
	widget_control, plot_base, set_uvalue=state
	if xalive(group) then begin
		widget_offset, group, xoffset, yoffset, newbase=plot_base
		widget_control, plot_base, xoffset=xoffset, yoffset=yoffset
	endif
	xmanager, 'plotman_widget', plot_base, /no_block, cleanup='plotman_widget_cleanup'
endif

widget_control, /hourglass

return, plot_base

end
