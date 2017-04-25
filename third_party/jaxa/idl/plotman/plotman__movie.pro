;+
; Name: plotman::movie
; 
; Purpose: Make java or xinteranimate movie of plotman panels.  Can be called directly by a user
; but is usually called through plotman::movie_widget which is called from the Window Control / 
; Multi-Panel Options 'Show as Movie' button.  If all selected panels are images,
; user can choose to show the panels as snapshots (they'll look exactly the way they look
; when displayed in plotman) or as simple images (no labels, but you can choose color and
; whether to normalize to all frames or each frame individually).  If single panel is selected,
; and it's not an image, then the movie loop through the plot traces (channels).
; 
; Calling sequence: p->movie
; 
; Input Keywords (note - the ones that don't show up on plotman::movie procedure declaration
;   are passed to movie_frames through _extra):
;   panels_selected - index of panel(s) to show in movie. Default is all panels in plotman session.
;   movie_size - size of movie in pixels. Scalar (assume square) or [nx,ny]. Default is [500,500]
;   panel_plot - for images only, if set just show panel plot. otherwise get image array and tv it. Default is 1.
;   norm_each - if set normalize each frame separately, otherwise normalize to whole movie. Default is 1. (meaningless
;     for images if panel_plot is 1)
;   yrange -  for non-images, control yrange for movie. Default is [0.,0.] (i.e. autoscale).
;   charsize - charsize for plot labels. Default is 1.
;   progbar - if set, show progress bar for making movie frames, and for making jpegs for java movie. Default is 0.
;   java - if set, make javascript movie, otherwise xinteranimate. Default is 1.
;   dir_java - directory for jpegs and javascript movie. Default is 'java_dir' in current dir.
;   clobber - if set, don't care if we wipe out existing files. If not set, and files exist, ask user. Default is 0.
;
; Output: If java selected, a jpeg file for each movie frame and an html file are created in the 
;  directory specified by dir_java.  If java not selected, an xinteranimate movie is shown on 
;  screen - has a button to produce an mpeg movie.
;  
; Written: Kim Tolbert 2004.  Originally this code was embedded in plotman__animate.
; Modifications:
;  16-Jul-2013, Kim.  Extensively modified and renamed to plotman__movie.
;    - Made standalone so user could call via p->movie
;    - Also works from widget which is now called plotman__movie_widget
;    - Added java output option
;  16-Aug-2013, Kim. Added clobber keyword, and if clobber=0 (default) ask question before overwriting
;  23-Apr-2015, Kim. Use true color.  frames now dimensioned [3,nx,ny,nframes], use set_pixel_depth=24 on
;    'z' buffer, don't call saveimage (has bug) just call write_jpeg myself.  This change was forced after
;    something changed with the map images (suspect a change DMZ made to make true color images for Wei Liu).
;    
;-

; movie_frames method creates the frames for plotman__movie.  In addition to input keywords 
; described above, passes out keywords
;  colors_used - r,g,b color arrays used
;  error - 0/1 means no error / error

function plotman::movie_frames, $
  panels_selected=panels_selected, $
  movie_size=movie_size, $
  panel_plot=panel_plot, $
  norm_each=norm_each, $
  yrange=yrange, $
  charsize=charsize, $
  progbar=do_progbar, $
  colors_used=colors_used, $
  error=error

npanels_tot = self.panels ->get_count()
checkvar, panels_selected, indgen(npanels_tot)
checkvar, panel_plot, 1
checkvar, norm_each, 1
checkvar, yrange, [0.,0.]
checkvar, charsize, 1.
checkvar, do_progbar, 0

psel = get_uniq(panels_selected > 0 < (npanels_tot-1))
nframe = n_elements(psel)

error = 0

panel_types = self->get(/all_panel_plot_type)
if nframe eq 1 && panel_types[psel] eq 'image' then begin
  message,/cont,'For images, you must select more than one panel.  Aborting.'
  error = 1
  return, 1
endif
if panel_plot eq 0 then begin  
  q = where(panel_types[psel] ne 'image',count)
  if count gt 0 then begin
    message,/cont,'Panel_plot=0 is for images only.  Your panels are not all images.  Resetting panel_plot=1'
    panel_plot = 1
  endif
endif

if nframe gt 1 and do_progbar then  progbar, progobj, /init

panels = self -> get(/panels)
pc = self -> get(/plot_control)
dim = movie_size

current_panel_number = self -> get(/current_panel_number)
save_dev = !d.name
;set_plot,'Z'
;device,set_resolution=[dim[0], dim[1]], set_pixel_depth=24 
;set_plot,save_dev  ; first thing we do is progbar, and that needs x or win


;catch, movie_frames_error
movie_frames_error=0
if movie_frames_error then begin
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

if nframe gt 1 then begin   ; More than 1 panel, movie over different panels

    frames = fltarr(3, dim[0], dim[1], nframe)

  for ii=0, nframe-1 do begin

    if do_progbar and (ii mod 10 eq 0) then begin
      progbar, progobj, /update, $
             percent = (float(ii)/nframe)*100, $
             message_text = 'Making movie frames...   Current image: ' + trim(ii) + ' of ' + trim(nframe)
      progbar, progobj, cancel=cancelled
        if cancelled then begin
          error = 1
        frames = 1
        goto, cleanup
      endif
    endif

    panel = panels -> get_item(psel[ii])
    if panel_plot then begin
      set_plot,'Z'
      device,set_resolution=[dim[0], dim[1]], set_pixel_depth=24      
      self -> focus_panel, *panel, psel[ii]
      self -> plot, charsize=charsize
      frames[*,*,*,ii] = tvrd(/true)
      if ii eq 0 then begin
        tvlct,r,g,b,/get
        colors_used = {r:r, g:g, b:b}
      endif
      set_plot, save_dev
    endif else begin
;      set_plot,'Z'
;      device,set_resolution=[dim[0], dim[1]], set_pixel_depth=24
      im = *(*panel).saved_data.data      
      if size(im,/tname) eq 'OBJREF' then im = im->get(/data)
      if size(im,/n_dim) ne 2 then im = fltarr(dim[0],dim[1])      
;      if norm_each then tv, congrid(bytscl(im, top=pc.ncolors), dim[0], dim[1]) else $
;        tv, congrid(im, dim[0], dim[1])
;      frames[*,*,*,ii] = tvrd(/true)
      frames[0,*,*,ii] = congrid(im, dim[0], dim[1])
;      if norm_each then frames[0,*,*,ii] = congrid(bytscl(im), dim[0], dim[1]) else $
;        frames[0,*,*,ii] = congrid(im, dim[0], dim[1])
    endelse
  endfor
  
  if ~panel_plot then begin
    if ~norm_each then frames = bytscl(frames, top=pc.ncolors)
    set_plot,'Z'
    device,set_resolution=[dim[0], dim[1]], set_pixel_depth=24
    for ii=0, nframe-1 do begin
      if norm_each then tv, bytscl(frames[0,*,*,ii], top=pc.ncolors) else tv,frames[0,*,*,ii]
      frames[*,*,*,ii] = tvrd(/true)
    endfor
  endif
  set_plot, save_dev
  
endif else begin  ; Only 1 panel, movie over different channels in that panel
  set_plot,'Z'
  device,set_resolution=[dim[0], dim[1]], set_pixel_depth=24
  panel = panels-> get_item(psel[0])
  self -> focus_panel, *panel, psel[0]
  pc = self -> get(/plot_control)
  dim1_use_save = *pc.dim1_use
  yrange_save = pc.yy.range

  dim1_ids = *pc.dim1_ids
  nchan = n_elements(dim1_ids)
  frames = fltarr(3, dim[0], dim[1], nchan)

  if yrange[0] ne 0. or yrange[1] ne 0. then begin
    yrange_use = yrange
  endif else begin
    if norm_each then yrange_use = [0.,0.] else begin
      self -> plot, yrange=[0.,0.], dim1_use=indgen(nchan)  ; first plot to get full limits (will be to Z)
      yrange_use = crange('Y')
    endelse
  endelse

  for i = 0, nchan-1 do begin
    self->plot, dim1_use=i, yrange=yrange_use, charsize=charsize
    frames[*,*,*,i] = tvrd(/true)
  endfor
  set_plot, save_dev
  self -> set, dim1_use=dim1_use_save, yrange=yrange_save
  self -> update_panel
endelse

cleanup:

set_plot,save_dev
self->focus_panel, dummy, current_panel_number

if obj_valid(progobj) then progbar, progobj, /destroy
return, frames

end

;-----

pro plotman::movie, $
  movie_size=movie_size, $
  java=java, $
  dir_java=dir_java, $
  clobber=clobber, $
  progbar=do_progbar, $
  _extra=_extra
 
checkvar, movie_size, [500,500]
checkvar, java, 1
checkvar, dir_java, 'java_dir'
checkvar, clobber, 0
checkvar, do_progbar, 0

if n_elements(movie_size) eq 1 then movie_size=[movie_size,movie_size]

if java then begin
  if file_test(dir_java, /directory) then begin
    if ~clobber then begin
      chk1 = file_search(dir_java, 'plotman*.jpeg', count=nchk1)
      chk2 = file_search(dir_java, 'plotman*.html', count=nchk2)
      if nchk1+nchk2 gt 0 then begin
        msg = ['Selected directory ', $
              dir_java, $
              'already exists and contains plotman jpegs and html,  ', $
              "which you may overwrite if you haven't renamed them.", $
              '', $
               'Do you want to use it anyway?']          
        answer = dialog_message(msg, /question)
        if answer eq 'No' then begin
          message,/cont,'Aborting movie.'
          return
        endif
      endif
    endif
  endif else file_mkdir, dir_java        
endif else begin
  if xregistered('XInterAnimate2') then begin
    a = dialog_message('Xinteranimate2 is already running.  Can only run one copy.', /error)
    return
  endif
endelse

movie = self->movie_frames(movie_size=movie_size, $
  progbar=do_progbar, $
  _extra=_extra, $
  error=error, $
  colors_used=colors_used)
  
if error then return
    
dim_movie = size(movie, /dim)
nframe = last_item(dim_movie)
    
;nframe = n_elements(movie[0,0,*])

if exist(colors_used) then begin
  tvlct, rr, gg, bb, /get
  tvlct, colors_used.r, colors_used.g, colors_used.b
endif

if ~java then begin
  xinteranimate2, set=[movie_size[0], movie_size[1], nframe], $
    showload=0, /track, title='Xinteranimate Movie'
endif
      
save_dev = !d.name
device2,get_decomposed=decomp

if do_progbar then progbar, progobj, /init

if ~java then device, /decomposed ; since frames are true color, need to set decomposed for xanimate

for i = 0,nframe-1 do begin
  
  if java then begin
;    set_plot, 'z'
;    tv,movie[*,*,*,i],/true
    jpeg_file = 'plotman'+trim(i)+'.jpeg'
    write_jpeg, concat_dir(dir_java, jpeg_file), movie[*,*,*,i], /true, quality=100

;    saveimage, concat_dir(dir_java, jpeg_file), /jpeg, quality=100
    jfiles = append_arr(jfiles, jpeg_file)
    set_plot, save_dev
    abort=0
  endif else xinteranimate2, frame=i, image=movie[*,*,*,i], abort=abort
      
  if abort then break
  
  if do_progbar and (i mod 10 eq 0) then begin
    progbar, progobj, /update, $
                     percent = (float(i)/nframe)*100, $
                     message_text = 'Making movie... Current image: ' + trim(i) + ' of ' + trim(nframe)
    progbar, progobj, cancel=cancelled
    if cancelled then begin
      progbar, progobj, /destroy
      return
    endif
  endif
endfor

if ~java then device, decomposed=decomp  ; restore original decomposed setting

if do_progbar then progbar,  progobj, /destroy
movie=0 ; release the memory
set_plot, save_dev
if exist(rr) then tvlct, rr, gg, bb

if not abort then begin
  if java then begin
    status = 0
    if exist(jfiles) then jsmovie, concat_dir(dir_java,'plotman_movie.html'),jfiles, /range, status=status
    if status then message, /cont, 'Created JPEG files and Java movie in: ' + dir_java else $
      message, /cont, 'Java movie creation failed.  Look in IDL log for error messages.'                  
  endif else begin
    rate = 4  ; can be from 0 (slowest) to 100 (fastest)
    xinteranimate2, rate, group=group
  endelse
endif

a = xregistered('plotman_animate') ; just to bring to foreground
return
end