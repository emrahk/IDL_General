;+
; Name: PLOTMAN::CREATE_PLOT_FILE
; Purpose: Create output plot file
; Method:  For each plot type, uses the configuration structure stored in plotman's
;   output_control.xx structure.  For PS, changes any white items to black and sets
;   line thickness thicker.  For other than PS, uses Z buffer and TVRD to get image
;   to store in file.
;   This method provides a widget interface to change the settings in the output_control.xx
;   structure for the xx file type.
;
; Keyword Arguments:
;   ps- if set, create PostScript file
;   print - if set, create PostScript file and print it
;   png - if set, create PNG file
;   tiff - if set, create TIFF file
;   jpeg - if set, create JPEG file
;   type - string of type of file (can use this or the individual keywords above) e.g. type='ps'
;   filename - output filename. If not set, uses what's in config structure (output_control.xx.filename)
;   quiet - if set, then suppress popup widgets with error messages
;   msg - '' if no error. Otherwise error message.
;   firstpage - 0 or 1. Set to 1 when on first page of PS output that will contain more pages. Default is 1.
;   midpage - 0 or 1. Set to 1 if on a middle page of a multi-page PS file. Default is 0.
;   lastpage - 0 or 1. Set to 1 if on last page of a multi-page PS file. Default is 1.
;
; Written: Kim Tolbert 2000?
; Modifications:
;	Kim, 17 Oct 2000.  Call wset,-1 and cleanplot after making plot.
;	Kim, 21-Apr-2001.  Changed plot control tags from r,g,b to rcolors,...
;   Kim, 31-Aug-2001.  For PS plots, change any dim1_colors that are white to black
;	Kim, 21-Jun-2002.  Added filename, quiet, msg keywords
;	Kim, 22-Jan-2003.  Previously hardcoded color of contour on PS plot to red (??)  No more.
;	Kim, 18-Aug-2003.  Put " around filename before passing to psplot
;	Kim, 10-Feb-2004,  For PS, increase thickness of lines
;	Kim, 20-Feb-2004,  For non-color, set dim1_colors to all 0's, so does diff line styles.
;	Kim, 22-Feb-2004,  For b/w PS, save all colors, set to 0, then set back to saved
;	Kim, 15-Sep-2006,  Use '' for b/w, not 0
;	Kim, 16-May-2007,  contour_color not used anymore, don't save in PS
;	Kim,  8-Jun-2007,  For PS, multiply thickness of axes by two, and if charthick>1, set /bold
; Kim, 14-Jul-2008,  For PS, if thick or charthick le 1 set thicker (previously check for = 0)
; Kim, 21-Nov-2008,  For PS, if main image is contour, then switch any contours and legend colors to black
; Kim, 21-Nov-2008,  Converted from a routine (plotman_create_files_event) to a method
; Kim, 03-Feb-2009,  Increased max number of overlays to 12 (from 4)
; Kim, 03-Sep-2009,  Increased thickness of lines for PS (previously *2., now *3.)
; Kim, 16-Nov-2012,  Added _extra so users can call from command line and pass keywords to
;   be set in the device configuration for the selected device
; Kim, 26-Jun-2014,  Added warning if user is going to overwrite existing file.  Also for tiff output,
;   images were backwards so now reverse image first.
; Kim, 23-Apr-2015,  Something has changed, and image files (all except PS) have colors wrong. Now call
;   TVRD with /true, and call device with set_pixel_depth=24 after setting to 'Z'. For jpeg, don't convert
;   to 24 bit color since read with /true. (tiff is still backward, but will fix later)
; Kim,23-Jul-2015, Kim. Added firstpage, midpage, lastpage keywords to enable multipage PS output. Also force
;   decomposed to 0, pixel_depth to 24 for Z buffer. Save setting before changing, and restore after.  (The 23-April change
;   was necessary because of a change in aia::colors that changed decomp to 0 and pixel_depth to 24 without restoring original.
;   Didn't understand the problem then - probably could have just set decomp=0,pixel_depth=8, here and left tvrd etc code 
;   alone.)  Also, order was deprecated in write_tiff command, so use reverse and default orientation of 1.
; Kim,10-Feb-2016. Non-color jpegs, tiffs and pngs didn't work.  Use tvrd(true=0) for them.  Also when error handler
;   caught error in writing jpeg, set_plot had already been called to set back to user's device, but then call to 
;   set decomp to saved value for Z device, left user's device in decomposed mode! 
;   
;-

pro plotman::create_plot_file, type=type, ps=ps, png=png, tiff=tiff, jpeg=jpeg, print=print, $
  filename=filename, quiet=quiet, msg=msg, _extra=_extra, $
  firstpage=firstpage, midpage=midpage, lastpage=lastpage

checkvar, firstpage, (keyword_set(midpage) or keyword_set(lastpage)) ? 0 : 1
checkvar, midpage, 0
checkvar, lastpage, midpage ? 0 : 1

msg = ''
if  not self->valid_window(/message) then return

;print,'in plotman::create_plot_file'
w = self->get(/widgets)

widget_control, w.w_message, set_value='Writing plot output file... '

; There can be all kinds of problems writing a file.
; Trap errors here and try to get out of here.
CATCH, error
IF error ne 0 THEN BEGIN
   if not keyword_set(quiet) then ok = dialog_message(!Err_String, /error)
   message, !err_string, /cont
   msg = !err_string
   goto, error_exit
ENDIF

self -> select

output_control = self -> get(/output_control)
pc = self -> get(/plot_control)

; What kind of file to create?
checkvar, type, ''
type = strlowcase(type)
ps = keyword_set(ps) or type eq 'ps'
png = keyword_set(png) or type eq 'png'
tiff = keyword_set(tiff) or type eq 'tiff'
jpeg = keyword_set(jpeg) or type eq 'jpeg'
printplot = keyword_set(print) or type eq 'printplot'
if printplot then begin
  if output_control.printer eq 'None' then begin
    msg = 'No printers available.  Aborting  print...'
    a = dialog_message(msg)
    return
  endif
  ps = 1
endif

file_msg = ['File filename already exists and will be overwritten.',$
  ' ', $
  'Do you want to proceed? ']
  
CASE 1 OF

   ps: BEGIN
    
     	config = printplot ? output_control.psprint : output_control.ps
     	if keyword_set(_extra) then copy_tag_values, config, _extra
     	if keyword_set(filename) then config.filename=filename
     	if firstpage then begin
     	  if file_exist(config.filename) then $
     	    if xanswer(str_replace(file_msg, 'filename', config.filename), /suppress, justify='|', /str) eq 'n' then return
     	  msg = printplot ? 'Printed from file ' + config.filename : 'PS file written: ' + config.filename
     	endif
   	  savefont = !p.font
   	  !p.font = 0
   	  savethick=!p.thick
   	  !p.thick = !p.thick le 1. ? 2. : !p.thick*3.
   	  savexthick = !x.thick & saveythick = !y.thick
   	  !x.thick = !x.thick le 1 ? 3. : !x.thick*3.
   	  !y.thick = !y.thick le 1 ? 3. : !y.thick*3.
   	  ;!x.thick = 3. & !y.thick = 3.
      thisDevice = !D.NAME
      TVLCT, r, g, b, /GET
      SET_PLOT, 'PS'
      !P.Background = pc.pp.background
      TVLCT, pc.rcolors, pc.gcolors, pc.bcolors, pc.bottom
      if firstpage then DEVICE, _EXTRA=config
      if !p.charthick gt 1. then device, /bold else device, bold=0
      save_axis_color = pc.axis_color
;      save_contour_color = pc.contour_color
      save_dim1_colors = *pc.dim1_colors
      save_overlay_color = pc.overlay_color
      save_limb_color = pc.limb_color
      save_grid_color = pc.grid_color
      save_legend_color = pc.legend_color
      if config.color then begin
      	self -> set, axis_color = pc.color_names.black
      	;self -> set, contour_color = pc.color_names.red
      	q = where (*pc.dim1_colors eq pc.color_names.white, count)
      	if count gt 0 then begin
      		(*pc.dim1_colors)[q] = pc.color_names.black
      		self -> set, dim1_colors = *pc.dim1_colors
      	endif
      	if pc.contour_image then begin
      	  if pc.legend_color eq pc.color_names.white then begin
      	     self -> set, legend_color=pc.color_names.black
      	  endif
      	  q = where (pc.overlay_color eq pc.color_names.white, count)
      	  if count gt 0 then begin
      	     pc.overlay_color[q] = pc.color_names.black
      	     self -> set, overlay_color = pc.overlay_color
      	  endif
        endif

      endif else begin
      	self -> set, axis_color = 0, $
;      		contour_color = 0, $
      		dim1_colors = ' ', $
      		overlay_color = intarr(pc.nmax_overlay)+0, $
      		limb_color = 0, $
      		grid_color = 0, $
      		legend_color = 0
      endelse

      ok = EXECUTE('self -> plot')

         ; Make sure the command can execute in the PS device.

      IF NOT ok THEN BEGIN
      	msg = 'Error creating PS file.'
      	message, msg, /cont
      	if not keyword_set(quiet) then a = dialog_message(msg)
      	goto, error_exit
      ENDIF

      if lastpage then  DEVICE, /CLOSE_FILE
      SET_PLOT, thisDevice
      TVLCT, r, g, b
      ; after plotting, updated panel info with PS parameters.  Set back to screen parameters
      ; and update panel again.
      !P.Background =pc.pp.background
      !p.font = savefont
      !p.thick = savethick
      !x.thick = savexthick
      !y.thick = saveythick
      self -> set, axis_color=save_axis_color, $
;      					contour_color=save_contour_color, $
      					dim1_colors = save_dim1_colors, $
      					overlay_color = save_overlay_color, $
      					limb_color = save_limb_color, $
      					grid_color=save_grid_color, $
      					legend_color = save_legend_color, $
      					pp=!p, xx=!x, yy=!y
      self -> update_panel

      if printplot then begin
      	; put " around filename in case of blanks in directory names 8/18/03
      	psplot, '"' + config.filename + '"', queue=output_control.printer, $
	        	color=config.color, /delete
	    endif

      END

   png: BEGIN
      config = output_control.png
      if keyword_set(_extra) then copy_tag_values, config, _extra
   	  if keyword_set(filename) then config.filename=filename
      if file_exist(config.filename) then $
        if xanswer(str_replace(file_msg, 'filename', config.filename), /suppress, justify='|', /str) eq 'n' then return
   	  msg = 'PNG file written: ' + config.filename
         ; Render graphic in Z-buffer.

      thisDevice = !D.NAME
      TVLCT, rr, gg, bb, /GET
      SET_PLOT, 'Z'
      device2, get_decomposed=z_decomp, get_pixel_depth=z_pixel_depth
      !P.Background = pc.pp.background
      ERASE, COLOR=pc.pp.background
      DEVICE2, SET_RESOLUTION=[config.xsize, config.ysize], $
         SET_COLORS=pc.wcolors, decomposed=0, set_pixel_depth=24
      ok = EXECUTE('self -> plot')

      IF NOT ok THEN BEGIN
         msg = 'Could not execute plot in the Z-Buffer Device for the PNG file.'
         if not keyword_set(quiet) then a = dialog_message(msg)
         message, msg, /cont
         goto, error_exit
      ENDIF

      true = config.color
      thisImage = TVRD(true=true)
      IF config.color NE 1 THEN LOADCT, 0, NColors=pc.wcolors, Bottom=pc.bottom $
        ELSE TVLCT, pc.rcolors, pc.gcolors, pc.bcolors, pc.bottom
      TVLCT, r, g, b, /GET
      if exist(z_decomp) then device2, decomp=z_decomp, set_pixel_depth=z_pixel_depth
      SET_PLOT, thisDevice
      !P.Background = pc.pp.background
      TVLCT, rr, gg, bb

         ; Write PNG file.

      if not since_version('5.4') then thisImage = rotate(reverse(thisImage),2)
      if config.order then thisImage = reverse(thisImage,2)
      WRITE_PNG, config.filename, thisImage, r, g, b
      END ; of PNG file creation.

   tiff: BEGIN
      config = output_control.tiff
      if keyword_set(_extra) then copy_tag_values, config, _extra
   	  if keyword_set(filename) then config.filename=filename
   	  if file_exist(config.filename) then $
   	    if xanswer(str_replace(file_msg, 'filename', config.filename), /suppress, justify='|', /str) eq 'n' then return
   	  msg = 'TIFF file written: ' + config.filename
         ; Render graphic in Z-buffer.

      thisDevice = !D.NAME
      TVLCT, rr, gg, bb, /GET
      SET_PLOT, 'Z'
      device2, get_decomposed=z_decomp, get_pixel_depth=z_pixel_depth
      !P.Background = pc.pp.background
      TVLCT, pc.rcolors, pc.gcolors, pc.bcolors, pc.bottom
      ERASE, COLOR=pc.pp.background
      DEVICE2, SET_RESOLUTION=[config.xsize, config.ysize], $
         SET_COLORS=pc.wcolors, decomposed=0, set_pixel_depth=24
      ok = EXECUTE('self -> plot')

      IF NOT ok THEN BEGIN
	    	msg = 'Could not execute plot in the Z-Buffer Device for the TIFF file.'
         if not keyword_set(quiet) then a = dialog_message(msg)
         message, msg, /cont
         goto, error_exit
      ENDIF

      true = config.color eq 1
      thisImage = (TVRD(true=true))
      TVLCT, r, g, b, /GET
      if exist(z_decomp) then device2, decomp=z_decomp, set_pixel_depth=z_pixel_depth
      SET_PLOT, thisDevice
      !P.Background = pc.pp.background
      TVLCT, rr, gg, bb

         ; Write TIFF file. Use screen resolution.

      IF config.color EQ 1 THEN $
         WRITE_TIFF, config.filename, reverse(thisImage,3), orientation=1, $
            RED=r, GREEN=g, BLUE=b, XRESOL=ROUND(!D.X_PX_CM * 2.54), $
            YRESOL=ROUND(!D.X_PX_CM * 2.54) ELSE $
         WRITE_TIFF, config.filename, rotate(reverse(thisImage),2), orientation=1, $
            XRESOL=ROUND(!D.X_PX_CM * 2.54), YRESOL=ROUND(!D.X_PX_CM * 2.54)
      END

   jpeg: BEGIN
      config = output_control.jpeg
      if keyword_set(_extra) then copy_tag_values, config, _extra
   	  if keyword_set(filename) then config.filename=filename
   	  if file_exist(config.filename) then $
   	    if xanswer(str_replace(file_msg, 'filename', config.filename), /suppress, justify='|', /str) eq 'n' then return
   	  msg = 'JPEG file written: ' + config.filename
         ; Render graphic in Z-buffer.

      thisDevice = !D.NAME
      TVLCT, rr, gg, bb, /GET
      SET_PLOT, 'Z'
      device2, get_decomposed=z_decomp, get_pixel_depth=z_pixel_depth
      !P.Background = pc.pp.background
      ERASE, COLOR=pc.pp.background
      DEVICE2, SET_RESOLUTION=[config.xsize, config.ysize], $
         SET_COLORS=pc.wcolors, decomposed=0, set_pixel_depth=24 
      TVLCT, pc.rcolors, pc.gcolors, pc.bcolors, pc.bottom
      ok = EXECUTE('self -> plot')

      IF NOT ok THEN BEGIN
	  	msg = 'Could not execute plot in the Z-Buffer Device for the JPEG file.'
         if not quiet then a = dialog_message(msg)
         message, msg, /cont
         goto, error_exit
      ENDIF

      true = config.color eq 1
      thisimage = TVRD(true=true)
;      thisImage = TVRD()
;      TVLCT, r, g, b, /GET
      if exist(z_decomp) then device2, decomp=z_decomp, set_pixel_depth=z_pixel_depth
      SET_PLOT, thisDevice
      !P.Background = pc.pp.background
      TVLCT, rr, gg, bb

         ; Write JPEG file.

;      IF config.color EQ 1 THEN BEGIN
;         image24 = BYTARR(3, config.xsize, config.ysize)
;         image24(0,*,*) = r(thisImage)
;         image24(1,*,*) = g(thisImage)
;         image24(2,*,*) = b(thisImage)
         WRITE_JPEG, config.filename, thisimage, TRUE=true, $
            QUALITY=config.quality, ORDER=config.order
;      ENDIF ELSE $
;          WRITE_JPEG, config.filename, thisimage, $
;            QUALITY=config.quality, ORDER=config.order
      END
ENDCASE

widget_control, w.w_message, set_value=msg

; Reset all plot parameters back to defaults so if user makes a plot outside of plotman,
; it will be shown in a new window with clean defaults.
; Unselect is called in plotman::plot, but when creating a plot file, device isn't a windows device
; (and wset and cleanplot aren't valid for non-windows devices)  until we reset it here, so
; call unselect again here.
self -> unselect
return

error_exit:
   if exist(z_decomp) and !d.name eq 'Z' then device2, decomp=z_decomp, set_pixel_depth=z_pixel_depth
   IF N_ELEMENTS(thisDevice) GT 0 THEN SET_PLOT, thisDevice
   RETURN

END
