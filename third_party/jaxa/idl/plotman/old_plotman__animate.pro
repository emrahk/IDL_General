; Widget interface to animate any selection of plotman panels
; Modified:
;	Mar-2005, Kim.  Use xinteranimate2 instead of xinteranimate.  Add prog bars.
;   6-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont to remove hessi dependencies.
; 25-Mar-2010 - Fixed bug - wasn't setting set_plot,'Z' when making movie of channels in one panel

function plotman_animate_frames, state, error=error, colors_used=colors_used

error = 0

psel = state.panels_selected

count = n_elements(psel)

if count gt 1 then 	progbar, progobj, /init

panels = state.plotman_obj -> get(/panels)

dim = state.movie_size

if state.panel_plot then begin
	current_panel_number = state.plotman_obj -> get(/current_panel_number)
	save_dev = !d.name
	set_plot,'Z'
	device,set_resolution=[dim[0], dim[1]]
	set_plot,save_dev  ; first thing we do is progbar, and that needs x or win
endif

catch, animate_error
;animate_error=0
if animate_error then begin
	catch, /cancel
	message,/cont,!error_state.msg
	message,/cont,'Aborting.'
	msg = 'Animation aborted. Try using fewer frames, or a smaller movie size.'
	a=dialog_message(msg,/error)
	error = 1
	frames = 1
	goto, cleanup
endif

; if there's more than one frame, then we're either recreating panels in Z buffer, and tvrd'ing
; them into the frames array, or we're getting the actual image data, and congrid'ing it into
; the frames array

; if there's only one panel, then we're animating the different channels (or whatever dim1 is)
; in that panel.

if count gt 1 then begin
		frames = fltarr(dim[0], dim[1], count)

	for ii=0, count-1 do begin

		if ii mod 10 eq 0 then begin
			progbar, progobj, /update, $
		         percent = (float(ii)/count)*100, $
		         message_text = 'Making movie frames...   Current image: ' + trim(ii) + ' of ' + trim(count)
			progbar, progobj, cancel=cancelled
		    if cancelled then begin
		    	error = 1
				frames = 1
				goto, cleanup
			endif
		endif

		panel = panels -> get_item(psel[ii])
		if state.panel_plot then begin
			set_plot,'Z'
			state.plotman_obj -> focus_panel, *panel, psel[ii]
			state.plotman_obj -> plot
			frames[*,*,ii] = tvrd()
			if ii eq 0 then begin
				tvlct,r,g,b,/get
				colors_used = {r:r, g:g, b:b}
			endif
			set_plot, save_dev
		endif else begin
			im = *(*panel).saved_data.data
			if size(im,/tname) eq 'OBJREF' then im = im->get(/data)
			if size(im,/n_dim) ne 2 then im = fltarr(dim[0],dim[1])
			if state.norm_each then frames[0,0,ii] = congrid(bytscl(im), dim[0], dim[1]) else $
				frames[0,0,ii] = congrid(im, dim[0], dim[1])
		endelse
	endfor
	if not state.norm_each then frames = bytscl(frames)
endif else begin
  set_plot,'Z'
	panel = panels-> get_item(psel[0])
	state.plotman_obj -> focus_panel, *panel, psel[0]
	pc = state.plotman_obj -> get(/plot_control)
	dim1_use_save = *pc.dim1_use
	yrange_save = pc.yy.range

	dim1_ids = *pc.dim1_ids
	nchan = n_elements(dim1_ids)
	frames = fltarr(dim[0], dim[1], nchan)

	if state.yrange[0] ne 0. or state.yrange[1] ne 0. then begin
		yrange = state.yrange
	endif else begin
		if state.norm_each then yrange = [0.,0.] else begin
			state.plotman_obj -> plot, yrange=[0.,0.], dim1_use=indgen(nchan)  ; first plot to get full limits (will be to Z)
			yrange = crange('Y')
		endelse
	endelse

	for i = 0, nchan-1 do begin
		state.plotman_obj->plot, dim1_use=i, yrange=yrange
		frames[*,*,i] = tvrd()
	endfor
	state.plotman_obj -> set, dim1_use=dim1_use_save, yrange=yrange_save
	state.plotman_obj -> update_panel
endelse

cleanup:

if state.panel_plot then begin
	set_plot,save_dev
	state.plotman_obj->focus_panel, dummy, current_panel_number
endif
if obj_valid(progobj) then progbar, progobj, /destroy
return, frames

end

;-----

pro plotman_animate_event, event

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

exit = 0

catch, err
if err ne 0 then begin
	catch, /cancel
	message, /cont, 'Aborting.'
	msg = 'Animation aborted. Try using fewer frames, or a smaller movie size.'
	a=dialog_message(msg,/error)
	return
endif

case uvalue of

	'panel_plot': begin
		state.panel_plot = event.value eq 'panel_plot'
		widget_control, state.w_base_norm, sensitive=(state.panel_plot eq 0)
		widget_control, state.w_color, sensitive=(state.panel_plot eq 0)
		end

	'norm':  state.norm_each = event.value eq 'each'

	'yrange': state.yrange = event.value

	'movie_size': state.movie_size = event.value

	'color': xloadct, /modal, group=event.top

	'movie': begin

		if xregistered('XInterAnimate2') then begin
			a = dialog_message('Xinteranimate2 is already running.  Can only run one copy.', /error)
			return
		endif

		widget_control, /hourglass
		movie = plotman_animate_frames(state, error=error,colors_used=colors_used)
		widget_control, /hourglass
		count = n_elements(movie[0,0,*])

		if not error then begin
			if exist(colors_used) then begin
				tvlct, rr, gg, bb, /get
				tvlct, colors_used.r, colors_used.g, colors_used.b
			endif
			xinteranimate2, set=[state.movie_size[0], state.movie_size[1], count], $
				showload=0, /track, title='Xinteranimate Movie'
			progbar, progobj, /init
			for i = 0,count-1 do begin
				xinteranimate2, frame=i, image=movie[*,*,i], abort=abort
				if abort then break
				if i mod 10 eq 0 then begin
					progbar, progobj, /update, $
	                         percent = (float(i)/count)*100, $
	                         message_text = 'Making movie... Current image: ' + trim(i) + ' of ' + trim(count)
	                progbar, progobj, cancel=cancelled
	                if cancelled then begin
	                	progbar, progobj, /destroy
	                	return
	                endif
	            endif
			endfor
			progbar,  progobj, /destroy
			movie=0	; release the memory
			if not abort then xinteranimate2, 4, group=group
			if exist(rr) then tvlct, rr, gg, bb
		endif
		a = xregistered('plotman_animate')
		return
		end

	'exit': begin
		widget_control, state.w_base, /destroy
		tvlct, state.orig_colors.r, state.orig_colors.g, state.orig_colors.b
		free_var, state, exclude='plotman_obj'
		return
		end

endcase

widget_control, state.w_base, set_uvalue=state

end

;-----

pro plotman::animate, panels_selected, group=group

if panels_selected[0] eq -1 then begin
	a = dialog_message('No panels selected.  Aborting.')
	return
endif

all_images = 1
panels = self -> get(/panels)
n_panels = n_elements(panels_selected)
for ii = 0,n_panels-1 do begin
	p = panels->get_item(panels_selected[ii])
	if (*p).plot_control.plot_type ne 'image' then begin
		all_images = 0
		goto, endofloop
	endif
	;if ii eq 0 then plot_type = (*p).plot_control.plot_type
	;if (*p).plot_control.plot_type eq plot_type then p_new = append_arr(p_new,panels_selected[ii])
endfor
endofloop:
;count = n_elements(p_new)
;panels_selected = p_new

if n_panels eq 1 and all_images then begin
	a=dialog_message('You must select more than one panel.  Aborting.')
	return
endif

tvlct, rorig, gorig, borig, /get
loadct, 0, /silent
norm_each = 1
panel_plot = 1
movie_size = [512,512]

get_font, font, big_font=big_font

widget_control, default_font = font

w_base = widget_base (group=group, $
					title='MOVIES', $
					/column, $
					space=10, $
					/frame)

tmp = widget_label (w_base, value='MOVIES', /align_center, font=big_font)

tmp = widget_label (w_base, value=trim(n_elements(panels_selected)) + ' Frames Selected', /align_center)

w_base1b = widget_base(w_base, /column, /frame)
w_panel = cw_bgroup (w_base1b, ['Images only, no labels', 'Panel snapshots'], button_uvalue=['flat_images', 'panel_plot'], $
	uvalue='panel_plot', /column, /exclusive, ids=panel_ids)
widget_control, panel_ids[panel_plot], /set_button
if all_images eq 0 then widget_control, panel_ids[0], sensitive=0

w_base_norm = widget_base (w_base, /column, /frame)
tmp = cw_bgroup (w_base_norm, ['to entire movie', 'separately'], button_uvalue=['all', 'each'], $
	uvalue='norm', /column, /exclusive, ids=ids, $
	label_top='Normalize each frame ')
widget_control, ids[norm_each], /set_button
widget_control, w_base_norm, sensitive=0

if n_panels eq 1 then begin
	w_yrange = cw_range (w_base, $
					uvalue='yrange', $
					value=[0.,0.], $
					format='(g12.2)', $
					label1='Y Limits: ', $
					label2=' - ', ypad=0, /frame )
	widget_control, w_base_norm, sensitive=1
endif

w_base2c = widget_base (w_base, /column, /frame)
tmp = widget_label (w_base2c, value='Movie size (screen pixels): ')
w_size = cw_range (w_base2c, $
					label1='', $
					label2=' x ', $
					value=movie_size, $
					format='(i5)', $
					dropvals1=[128, 256, 512, 768, 1024], $
					dropvals2=[128, 256, 512, 768, 1024], $
					uvalue='movie_size', $
					xsize=6)

w_buttons1 = widget_base (w_base, /row, space=10, /align_center)

w_color = widget_button (w_buttons1, $
					value='Select Color', $
					uvalue='color')
widget_control, w_color, sensitive=0

tmp = widget_button (w_buttons1, $
					value='Show Movie', $
					uvalue='movie')

tmp = widget_button (w_buttons1, $
					value='Exit', $
					uvalue='exit')


if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=w_base
	widget_control, w_base, xoffset=xoffset, yoffset=yoffset
endif

state = { $
	w_base: w_base, $
	w_base_norm: w_base_norm, $
	w_color: w_color, $
	panel_plot:panel_plot, $
	plotman_obj: self, $
	panels_selected: panels_selected, $
	norm_each: norm_each, $
	yrange: [0.,0.], $
	movie_size: movie_size, $
	orig_colors: {r:rorig, g:gorig, b:borig} }

widget_control, w_base, /realize

widget_control, w_base, set_uvalue=state

xmanager, 'plotman_animate', w_base, /no_block

end

