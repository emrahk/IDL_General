; Widget interface to animate any selection of plotman panels
; Modified:
;	Mar-2005, Kim.  Use xinteranimate2 instead of xinteranimate.  Add prog bars.
; 6-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont to remove hessi dependencies.
; 25-Mar-2010 - Fixed bug - wasn't setting set_plot,'Z' when making movie of channels in one panel
; 17-Jul-2013, Kim. Renamed from animate to movie_widget.  Added java output option.
;  Added square button, charsize control, and reset yrange to 0 when a norm option is set.
;  Also extracted code from 'movie' event handler that actually makes the movie and moved 
;  to standalone movie method, so user can call from command line via p->movie
; 18-Aug-2013, Kim. Changed default java directory to include current date
; 08-Nov-2013, Kim. If a movie_widget already running, previously just brought it to foreground.
;   Now, kill it, and start a new one (want selection of panels to be current)
;   Added 'Make Movie and Exit' button.
;   Java dir for movie now includes dir name, also use pickfile without dir option, seems more
;   confusing since shows more files, but allows for a dir name that doesn't exist yet.
;   
;-----

;--- Event handler for plotman_animate (can't be a method, so this calls the method)

pro plotman_movie_widget_event, event
widget_control, event.top, get_uvalue=state
state.plotman_obj -> movie_widget_event, event
end

;-----

pro plotman::movie_widget_event, event

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

exit = 0

;catch, err
err=0
if err ne 0 then begin
	catch, /cancel
	message, /cont, 'Aborting.'
	msg = 'Animation aborted. Try using fewer frames, or a smaller movie size.'
	a=dialog_message(msg,/error)
	return
endif

if uvalue eq 'movie_exit' then begin
  uvalue = 'movie'
  exit = 1
endif

case uvalue of

	'panel_plot': begin
		state.panel_plot = event.value eq 'panel_plot'
		widget_control, state.w_base_norm, sensitive=(state.panel_plot eq 0)
		widget_control, state.w_color, sensitive=(state.panel_plot eq 0)
		end

	'norm':  begin
	  state.norm_each = event.value eq 'each'
	  state.yrange = [0.,0.]
	  if xalive(state.w_yrange) then widget_control, state.w_yrange, set_value=state.yrange
	  end

	'yrange': state.yrange = event.value

	'movie_size': begin
    new = event.value
    if state.square then begin
      old =state.movie_size
      if new[0] eq old[0] then new[0] = new[1]
      if new[1] eq old[1] then new[1] = new[0]
    endif
    state.movie_size = new
    widget_control, event.id, set_value=new
    end
	
	'square': begin
	  state.square = event.select
    if state.square then state.movie_size[1] = state.movie_size[0]
    widget_control, state.w_size, set_value=state.movie_size
    end

  'output': begin

    case event.value of
      0: if xalive(state.w_filebase2) then widget_control, state.w_filebase2, /destroy
      1: begin
        label = 'Java directory: '
        text_uval = 'javadir'
        val = state.dir_java
        end
    endcase
    if event.value gt 0 then begin
      if xalive(state.w_filebase2) then begin
        widget_control, state.w_filelab, set_value=label
        widget_control, state.w_filetext, set_value=val, set_uvalue=text_uval
      endif else begin
        state.w_filebase2 = widget_base (state.w_filebase, /row)
        state.w_filelab = widget_label(state.w_filebase2, value=label)
        state.w_filetext = widget_text (state.w_filebase2, /edit, xsize=60, value=val, uvalue=text_uval)
        state.w_filebut = widget_button (state.w_filebase2, value='Browse...', uvalue='browse')
      endelse
    endif

    end

  'browse': begin
    widget_control, state.w_output, get_value=output
    if output eq 1 then begin
      title = 'Select Directory for Java Movie and JPEG Files'
      widget_control, state.w_filetext, get_value=dir_java
      ; Don't use directory option, because then it only shows existing directories; the dir_java may not exist yet
      ; But without the dir option, if the directory does exist, when user 
      val = ssw_pickfile(title = title, file=dir_java, filter=filter, $
        default_extension=default_extension, dialog_parent=event.top)
      if val ne '' then begin
        if file_basename(file_dirname(val)) eq file_basename(val) then val = file_dirname(val)
        widget_control, state.w_filetext, set_value = val
      endif
    endif

    end


	'color': xloadct, /modal, group=event.top

	'movie': begin
	  widget_control, state.w_output, get_value=java
	  widget_control, state.w_char, get_value=charsize	  
	  if java then widget_control, state.w_filetext, get_value=dir_java else dir_java = ''
	  widget_control, /hourglass	  
	  self->movie, panels_selected=state.panels_selected, $
	               movie_size=state.movie_size, $
	               panel_plot=state.panel_plot, $
	               norm_each=state.norm_each, $
	               yrange=state.yrange, $
	               charsize=charsize, $
	               java=java, $
	               dir_java=dir_java[0], $
	               /progbar	            	              
		end

	'exit': exit = 1

  else:
  
endcase

if exit then begin
  widget_control, state.w_base, /destroy
  tvlct, state.orig_colors.r, state.orig_colors.g, state.orig_colors.b
  free_var, state, exclude='plotman_obj'
  return
endif

widget_control, state.w_base, set_uvalue=state

end

;-----

pro plotman::movie_widget, panels_selected, group=group

; check if a plotman::animate is already up that's associated with this plotman
; if so, then send an 'Exit' event and bring up a new one (selection of panels may have changed)

if xregistered('plotman_movie_widget') gt 0 then begin
  pp_id = get_handler_id('plotman_movie_widget', /all)
  for i=0,n_elements(pp_id)-1 do begin
    widget_control, pp_id[i], get_uvalue=pstate
    if pstate.plotman_obj eq self then $
        widget_control, pstate.w_exit, send_event={id:pstate.w_exit, top:pstate.w_base, handler:pstate.w_base, select:1}
  endfor
endif

if panels_selected[0] eq -1 then begin
	a = dialog_message('No panels selected.  Aborting.')
	return
endif

all_images = 1
panels = self -> get(/panels)
n_panels = n_elements(panels_selected)
panel_types = self->get(/all_panel_plot_type)
q = where(panel_types[panels_selected] ne 'image',count)
all_images = count eq 0

if n_panels eq 1 and all_images then begin
	a=dialog_message('For images, you must select more than one panel.  Aborting.')
	return
endif

tvlct, rorig, gorig, borig, /get
loadct, 0, /silent
norm_each = 1
panel_plot = 1
movie_size = [500,500]
square = 1
charsize = 1.
dir_java = concat_dir(curdir(), 'java_dir_' + strlowcase( trim( str_replace(anytim(!stime, /vms, /date), '-', '_') )))

get_font, font, big_font=big_font

widget_control, default_font = font

w_base = widget_base (group=group, $
					title='PLOTMAN MOVIES', $
					/column, $
					space=5, $
					/frame)

tmp = widget_label(w_base, value='PLOTMAN MOVIES', /align_center, font=big_font)
tmp = widget_label(w_base, value='Single line plot panel selected -> animate the traces.', /align_center)
tmp = widget_label(w_base, value='Multiple images selected -> animate as simple images (norm and color control) or panel snapshots (no control).', /align_center)
tmp = widget_label(w_base, value='Mixed line plots and images selected -> animate the panel snapshots.', /align_center)
tmp = widget_label(w_base, value='')
tmp = widget_label(w_base, value=trim(n_elements(panels_selected)) + ' Frames Selected', /align_center)

w_base1b = widget_base(w_base, /row, /frame)
w_panel = cw_bgroup (w_base1b, ['Images only, no labels', 'Panel snapshots'], button_uvalue=['flat_images', 'panel_plot'], $
	uvalue='panel_plot', /row, /exclusive, ids=panel_ids, /frame)
widget_control, panel_ids[panel_plot], /set_button
if all_images eq 0 then widget_control, panel_ids[0], sensitive=0

;w_base2c = widget_base (w_base1b, /column, /frame)
;tmp = widget_label (w_base2c, value='Movie size (screen pixels): ')
w_base2d = widget_base (w_base1b, /row, /frame)
w_size = cw_range (w_base2d, $
          label1='Size: ', $
          label2=' x ', $
          value=movie_size, $
          format='(i5)', $
          dropvals1=[100, 200, 300, 400, 500, 600, 700, 800], $
          dropvals2=[100, 200, 300, 400, 500, 600, 700, 800], $
          uvalue='movie_size', $
          xsize=6)
w_square = widget_base (w_base2d, /nonexclusive)
tmp = widget_button (w_square, value='Square', uvalue='square')
widget_control, tmp, /set_button


w_base_norm = widget_base (w_base, /row, /frame)
tmp = cw_bgroup (w_base_norm, ['to entire movie', 'separately'], button_uvalue=['all', 'each'], $
	uvalue='norm', /row, /exclusive, ids=ids, $
	label_left='Normalize: ')
widget_control, ids[norm_each], /set_button
widget_control, w_base_norm, sensitive=0

w_yrange = 0L
if n_panels eq 1 then begin
	w_yrange = cw_range (w_base_norm, $
					uvalue='yrange', $
					value=[0.,0.], $
					format='(g12.2)', $
					label1=' or set Y Limits: ', $
					label2=' - ', ypad=0)
	widget_control, w_base_norm, sensitive=1
endif

w_char = cw_field(w_base, title='Character size: ', value=1., xsize=5, /return_events, uvalue='charsize')

w_base4a = widget_base (w_base, /column, /frame)
output_options = ['Xinteranimate', 'Java']
w_output = cw_bgroup (w_base4a, output_options, $
  uvalue='output', /row, /exclusive, ids=ids, $
  label_left='Format: ', /no_release, set_value=1)
;widget_control, ids[1], /set_button

w_filebase = widget_base (w_base4a, /row) ; this will get filled in depending on xinter/java

w_buttons1 = widget_base (w_base, /row, space=10, /align_center)

w_color = widget_button (w_buttons1, $
					value='Select Color', $
					uvalue='color')
widget_control, w_color, sensitive=0

tmp = widget_button (w_buttons1, $
					value='Make Movie', $
					uvalue='movie')
tmp = widget_button (w_buttons1, $
          value='Make Movie and Exit', $
          uvalue='movie_exit')
          
w_exit = widget_button (w_buttons1, $
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
	square: square, $	
	w_size: w_size, $
	w_yrange: w_yrange, $
	w_char: w_char, $
	w_output: w_output, $
  w_filebase: w_filebase, $
  w_filebase2: 0L, $
  w_filelab: 0L, $
  w_filetext: 0L, $
  w_filebut: 0L, $
  dir_java: dir_java, $
  w_exit: w_exit, $
	orig_colors: {r:rorig, g:gorig, b:borig} }

widget_control, w_base, /realize

widget_control, w_base, set_uvalue=state

; send an event that selects java output, so the widget for the output directory will be created
widget_control, w_output, send_event={id:w_output, top:w_base, handler:w_base, select:1 , value:1}

xmanager, 'plotman_movie_widget', w_base, /no_block

end

