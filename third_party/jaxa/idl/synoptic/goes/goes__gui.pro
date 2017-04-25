;+
; Project     : HESSI
;
; Name        : GOES__GUI
;
; Purpose     : Provide a GUI for the GOES object
;
; Category    : synoptic objects
;
; Explanation : Provide a GUI to plot GOES flux, temperature, emission measure,
;               select background time intervals, and write a save file.
;
; Syntax      : IDL> o->gui  (where o is a GOES object)
;
; History     : Written 17-Nov-2005, Kim Tolbert
;
; Contact     : kim.tolbert@gsfc.nasa.gov
;
; Modifications:
;	9-Jan-2006, Kim.  Added options for background function, plotting bk, multiple
;	  plots allowed or not (previously multiple was the only option), plotting energy
;	  loss, selecting integration times and plotting integrated energy loss.
;	10-Jan-2005, Kim.  Desensitize goes gui when select intervals widgets are started
;	11-Jan-2006, Kim.  widget_info(/map) not allowed in 5.4 so added allow_multiple
;	19-Sep-2007, Kim.  Fixed bug.  After changed plotman to always use overlay[0] for
;	  self, should have changed this (in multiplot option) to put overlays in 1-3, not 0-3.
;	  Also now that only allow 3 overlays (plus primary) have to check if user requested
;	  > 4 plots in multi, and limit it to 4.
;	12-Nov-2007, Kim.  Added 'Flux Derivative' to options to plot.
;	25-Feb-2008, Kim.  Don't start plotman until a plot is actually made - previously checked
;	  that plotman would work by creating the obj when the GUI was started.
; 30-Jul-2008, Kim. Added additional options for sdac value - either archive
; 6-Oct-2008, Kim.  Added button to set times to plot limits.
; 13-Nov-2008, Kim. Added button to display GOES event list for selected time interval
; 25-Aug-2009, Kim. Allow all 6 multi-plot plots to display (plotman overlay limit was increased to 12)
; 03-Sep-2009, Kim. Added button for writing text output file.
; 01-Dec-2009, Kim. Added kill_obj keyword.  If set, destroy goes obj when exit GUI.
; 31-Dec-2009, Kim. Get state before checking if KILL button was hit, so state.kill_obj will be available.
;
;-

;---------------------------------------------------------------------------

;----- Update GOES widget with current values of properties in GOES object

pro goes::update_widget, wbase

widget_control, wbase, get_uvalue=state

widget_control, state.wtimes, set_value=anytim([self->get(/tstart), self->get(/tend)])

q = where (trim(goes_sat(self->getprop(/sat),/num)) eq state.sat_list, count)
widget_control, state.wsat, set_droplist_select=(count eq 1 ? q[0] : 0)

sdac = self->getprop(/sdac)
widget_control, state.warchive, set_droplist_select=sdac

widget_control, state.wres, set_droplist_select=self->getprop(/mode), $
	sensitive=(sdac ne 1)

; construct array of 0s and 1s for values of plot option buttons. Don't
; set 'Multiple' button  - leave that as user set it.
val = [self->getprop(/clean), $
	self->getprop(/bsub), $
	self->getprop(/markbad), $
	self->getprop(/showclass), $
	state.use_plotman]

widget_control, state.woptions, set_value=val

abund = self->getprop(/abund)
widget_control, state.wmodel, set_value=abund

if state.allow_multiple then begin
	widget_control, state.wdata_multi, get_value=val
	if abund eq 2 then widget_control, state.wdata_multi, set_value=val*[1,1,1,0,0]
	widget_control, state.wmulti_ids[3], sensitive=(abund lt 2)
	widget_control, state.wmulti_ids[4], sensitive=(abund lt 2)
endif else begin
	widget_control, state.wdata_single, get_value=val
	if val gt 2 and abund eq 2 then widget_control, state.wdata_single, set_value=0
	widget_control, state.wsingle_ids[3], sensitive=(abund lt 2)
	widget_control, state.wsingle_ids[4], sensitive=(abund lt 2)
endelse


;bfunc = strlowcase(strmid(self->getprop(/bfunc),0,2)
;bfunc_list = strmid(strlowcase(strcompress(self.bfunc_list,/remove_all), 0, 2)
q = where (self->getprop(/bfunc) eq state.bfunc_list)
widget_control, state.wbfunc, set_droplist_select=q[0]


end

;----- GUI event handler. Event handler can't be a method, so this is just a wrapper
;   that gets the object out of the uvalue and calls the event method

pro goes_event, event
widget_control, event.top, get_uvalue=state
if obj_valid(state.object) then state.object->event,event
return & end

;----- Main event handler

pro goes::event, event

widget_control, event.top, get_uvalue=state

if tag_names(event,/struc) eq 'WIDGET_KILL_REQUEST' then begin
	msg = '     Do you really want to exit the GOES GUI?     '
    answer = xanswer (msg, /str, /suppress, default=1)
    if answer eq 'y' then goto, exit else return
endif

widget_control, event.id, get_uvalue=uvalue

case uvalue of

	'times': begin
		times = event.value
		if valid_time_range(times) then $
			self -> set, tstart=atime(event.value[0]), tend=atime(event.value[1])
		end

	'sat': self -> set, sat=fix(state.sat_list[event.index])

	'satlist': begin
		self -> sat_times, out=out
		a=dialog_message(out, /info)
		end

	'archive': self -> set, sdac=event.index

	'res': self -> set, mode=event.index

	'options': begin
		if event.value eq 0 then self -> set, clean=event.select
		if event.value eq 1 then self -> set, bsub=event.select
		if event.value eq 2 then self -> set, markbad=event.select
		if event.value eq 3 then self -> set, showclass=event.select
		if event.value eq 4 then begin
			state.use_plotman=event.select
			widget_control, event.top, set_uvalue=state
		endif
		if event.value eq 5 then begin
			state.allow_multiple = event.select
			widget_control, event.top, set_uvalue=state
			widget_control, state.wdata_multi_base, map=event.select
			widget_control, state.wdata_single_base, map=(event.select eq 0)
		endif
		end

	'model': if event.select then self -> set, abund=event.value

	'selbk': begin
		widget_control, state.wbase, sensitive=0
		self -> select_background
		widget_control, state.wbase, sensitive=1
		end

	'bfunc': self -> set, bfunc=state.bfunc_list(event.index)

	'showbk': self -> show_background

	'plotbk': if state.use_plotman then self -> plotman, /bk_overlay else self -> plot, /bk_overlay

	'selint': begin
		widget_control, state.wbase, sensitive=0
		self -> select_integration_times
		widget_control, state.wbase, sensitive=1
		end

	'showint': self -> show_integration_times

	'summary': self -> help, /widget

	'plot': begin
		if state.allow_multiple then begin
			widget_control, state.wdata_multi, get_value=plot_type
			if total(plot_type) eq 0 then plot_type=[1,0,0,0,0,0]	; default to flux if none selected
			num_plot = total(plot_type)
		endif else begin
			widget_control, state.wdata_single, get_value=val
			plot_type = intarr(6)
			plot_type[val] = 1
			num_plot = 1
		endelse
       
		if state.use_plotman then begin
			; first create each plot requested (temperature, em, flux) in plotman separately,
			; then if more than one requested, set the extras as overlays in plotman on
			; the last one plotted.  (i.e. if request temp and em, will end up in plotman
			; with a stacked plot - em on top, temp below, and plotman will let user zoom
			; into the two plots in tandem.

			; Can only do 4 at a time in plotman  If >4 selected, disable last ones and print message
			; Aug 2009 - That's no longer true.  PLOTMAN can now do up to 12 overlays

			nplotted = 0

			if plot_type[1] then begin
				self -> plotman, /derflux, desc=desc_derflux
				if not exist(desc_derflux) then return
				ov = append_arr(ov,desc_derflux)
			endif
			if plot_type[2] then begin
				self -> plotman, /temp, desc=desc_temp
				if not exist(desc_temp) then return
				ov = append_arr(ov,desc_temp)
			endif
			if plot_type[3] then begin
				self -> plotman, /emis, desc=desc_emis
				if not exist(desc_emis) then return
				ov = append_arr(ov,desc_emis)
			endif
			if plot_type[4] then begin
				self -> plotman, /lrad, desc=desc_lrad
				if not exist(desc_lrad) then return
				ov = append_arr(ov, desc_lrad)
			endif
			if plot_type[5] then begin
				self -> plotman, /lrad, /integrate, desc=desc_lrad
				if not exist(desc_lrad) then return
				ov = append_arr(ov, desc_lrad)
			endif
			if plot_type[0] then begin
				self -> plotman, desc=desc_flux
				if not exist(desc_flux) then return
				ov = append_arr(ov,desc_flux)
			endif
			if num_plot gt 1 then begin
				; now # overlays in plotman is 12, so just limit num_plot to 6, which is all the widget allows anyway.
				num_plot = num_plot < 6
				ov = ov[0:(num_plot-2)]
				overlay_panel = strarr(12)
				overlay_panel[1] = ov	;0th is reserved for self (for images) - so use 1,2,3,4,5
				pobj = self->get_plotman()
				pobj -> select
				pobj -> set, overlay_panel=overlay_panel
				pobj -> plot
			endif

		endif else begin
			;if not using plotman, if more than one plot requested, stack in a multiplot
			if num_plot gt 1 then !p.multi=[0,1,num_plot]
			err = ''
			if plot_type[0] then self -> plot, err_msg=err
			if err eq '' and plot_type[1] then self -> plot, /derflux, err_msg=err
			if err eq '' and plot_type[2] then self -> plot, /temp, err_msg=err
			if err eq '' and plot_type[3] then self -> plot, /emis, err_msg=err
			if err eq '' and plot_type[4] then self -> plot, /lrad, err_msg=err
			if err eq '' and plot_type[5] then self -> plot, /lrad, /integrate, err_msg=err
			!p.multi=0
		endelse
		end

  'settimes': begin
    newt=-1
    if state.use_plotman then begin 
      plotman_obj = self -> get_plotman (/nocreate, valid=valid)
      if valid then begin
        if plotman_obj -> valid_window(/message, /utplot) then begin
          plotman_obj -> select  ; select so !x.crange will be correct
          newt = plotman_obj->get(/utbase) + !x.crange
          plotman_obj -> unselect
        endif
      endif else a=dialog_message('No plotman time plot available.')
    endif
    if newt[0] ne -1 then begin
      newt=anytim(newt,/vms)
      self -> set, tstart=newt[0], tend=newt[1]
      message,'Setting tstart, tend to plot limits:' + newt[0] + '  ' + newt[1], /cont
    endif
    end
      
	'writefile':  self -> savefile
	
	'writetext':  self -> textfile
	
	'gev': begin
	   a = self -> get_gev(count=count, /show)
	   if count eq 0 then prstr,'No GOES events in time interval.'
	   end

	'refresh':  self -> update_widget, state.wbase

	'quit': goto, exit

	else:
endcase

self->update_widget, state.wbase
return

exit:
widget_control, event.top, /destroy
if state.kill_obj then destroy,self

end

;----- Main GUI method

pro goes::gui, kill_obj=kill_obj, _extra=_extra

checkvar, kill_obj, 0

if keyword_set(_extra) then self->set, _extra=_extra

use_plotman = self->have_plotman_dir()
;if use_plotman then begin
;	p = self->get_plotman(valid=valid)
;	if not valid then use_plotman=0
;endif

sat_list = trim(goes_sat(/number))
archive_list = ['YOHKOH', 'SDAC', 'YOHKOH,SDAC', 'SDAC,YOHKOH']
res_list = ['Three sec', 'One min', 'Five min']
plot_list = ['Flux', 'Flux Derivative', 'Temperature', 'Emission Measure', 'Energy Loss Rate', 'Integrated Energy Loss']
;option_list = ['Clean', 'Subtract Background', 'Mark Bad', 'Show Class', 'Use PLOTMAN']
option_list = ['Clean', 'Subtract Background', 'Mark Bad', 'Show GOES Class', 'Use PLOTMAN', 'Multiple']
version = ' (Chianti ' + goes_get_chianti_version() + ')'
model_list = ['Coronal'+version, 'Photospheric'+version, 'Meyer/Mewe (Original)']
bfunc_list = ['0Poly', '1Poly', '2Poly', '3Poly', 'Exp']

allow_multiple = 0

wbase = widget_base (title='GOES Workbench', /column, $
	/tlb_kill, space=3, xpad=3, ypad=3)

wdata_base = widget_base (wbase, /row, /frame)

wtimes = cw_ut_range(wdata_base, value=[0.,1.], label='', $
	uvalue='times', /noreset, /narrow, /nextprev, /frame)

wsat_base = widget_base (wdata_base, /column, /align_center)

wsat_base_row = widget_base (wsat_base, /row, space=4)
wsat = widget_droplist (wsat_base_row, title='Satellite Preference: ', value=sat_list, uvalue='sat')
wsatlist = widget_button (wsat_base_row, value='List', uvalue='satlist')

warchive = widget_droplist (wsat_base, title='Archive: ', value=archive_list, uvalue='archive')

wres = widget_droplist (wsat_base, title='Resolution: ', value=res_list, uvalue='res')

wplot_base = widget_base (wbase, /row, /frame)

w_bulletin = widget_base (wplot_base)
wdata_multi_base = widget_base (w_bulletin, /column, map=0)

wdata_multi = cw_bgroup (wdata_multi_base, plot_list, /column, /nonexclusive, $
	label_top='Data to Plot: ', set_value=[1,0,0,0,0,0], uvalue='', ids=wmulti_ids)

wdata_single_base = widget_base(w_bulletin, /column, map=1)
wdata_single = cw_bgroup (wdata_single_base, plot_list, /column, /exclusive, $
	label_top='Data to Plot: ', set_value=0, uvalue='', ids=wsingle_ids)

woptions = cw_bgroup (wplot_base, option_list, /column, /nonexclusive, $
	label_top='Plot Options: ', uvalue='options')

wmodel = cw_bgroup (wplot_base, model_list, /column, /exclusive, $
	label_top='Spectral Model:', uvalue='model')

wbk_base = widget_base (wbase, /row, /frame, space=6)
tmp = widget_label (wbk_base, value='Background Options: ')
tmp = widget_button (wbk_base, value='Select Bk Times', uvalue='selbk', /align_center)
wbfunc = widget_droplist(wbk_base, title='Bk Function: ', value=bfunc_list, uvalue='bfunc')
tmp = widget_button (wbk_base, value='Show Bk Times', uvalue='showbk', /align_center)
tmp = widget_button (wbk_base, value='Plot Bk', uvalue='plotbk', /align_center)

wint_base = widget_base (wbase, /row, /frame, space=10)
tmp = widget_label (wint_base, value='Energy Loss Integration: ')
tmp = widget_button (wint_base, value='Select Integration Times', uvalue='selint')
tmp = widget_button (wint_base, value='Show Integration Times', uvalue='showint')

wbutton_base1 = widget_base (wbase, /row, /align_center, space=20)

tmp = widget_button (wbutton_base1, value='Plot', uvalue='plot')
tmp = widget_button (wbutton_base1, value='Set times to plot limits', uvalue='settimes')
tmp = widget_button (wbutton_base1, value='Write save file', uvalue='writefile')
tmp = widget_button (wbutton_base1, value='Write text file', uvalue='writetext')

wbutton_base2 = widget_base (wbase, /row, /align_center, space=20)
tmp = widget_button (wbutton_base2, value='Event List', uvalue='gev')
tmp = widget_button (wbutton_base2, value='Summary', uvalue='summary')
tmp = widget_button (wbutton_base2, value='Refresh', uvalue='refresh')
tmp = widget_button (wbutton_base2, value='Quit', uvalue='quit')

state = {object: self, $
  kill_obj: kill_obj, $
	wbase: wbase, $
	wtimes: wtimes, $
	wsat: wsat, $
	warchive: warchive, $
	wres: wres, $
	wdata_multi_base: wdata_multi_base, $
	wdata_multi: wdata_multi, $
	wmulti_ids: wmulti_ids, $
	wdata_single_base: wdata_single_base, $
	wdata_single: wdata_single, $
	wsingle_ids: wsingle_ids, $
	woptions: woptions, $
	wmodel: wmodel, $
	wbfunc: wbfunc, $
	sat_list: sat_list, $
	archive_list: archive_list, $
	res_list: res_list, $
	plot_list: plot_list, $
	option_list: option_list, $
	allow_multiple: allow_multiple, $
	use_plotman: use_plotman, $
	model_list: model_list, $
	bfunc_list: bfunc_list}

widget_control, wbase, set_uvalue=state

widget_control, wbase, /realize

self -> update_widget, wbase

xmanager, 'goes', wbase, event='goes_event', /no_block


end

