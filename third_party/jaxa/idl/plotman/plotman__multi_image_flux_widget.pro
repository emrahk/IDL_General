;+
; Name: plotman::multi_image_flux_widget
;
; Category: HESSI
;
; Purpose: plotman method with widget to select options for computing flux, centroid, peak for multiple images
;
; Input arguments:
;	group - widget id of parent widget
;	panels - panel numbers of panels to compute image info for
;
; Method:  After setting up options, calls multi_image_flux method to do the work.
;
; Written:  28-Jul-2002, Kim Tolbert
; Modifications:
;	9-Jun-2003, Kim.  Added inverse button (if enabled use area outside of box)
;	3-Nov-2003, Kim.  Added subtract button (if enabled, subtract current image from all
;	   images before doing flux calculations.
; 8-Jul-2008, Kim.  Use file_search instead of hsi_loc_file to find help file (for move to ssw gen)
; 25-Aug-2008, Kim.  Look for help files in $SSW/gen/idl/plotman/doc after move to gen
; 23-Apr-2015, Kim.  Use free_lun instead of close
;-

;-----

pro plotman_multi_image_flux_widget_update, state

if xalive(state.w_filename) then widget_control, state.w_filename, sensitive=state.imgflux.writefile
if xalive(state.w_append) then widget_control, state.w_append, sensitive=state.imgflux.writefile
if xalive(state.w_clear_file) then widget_control, state.w_clear_file, sensitive=state.imgflux.writefile

end

;-----

pro plotman_multi_image_flux_widget_event, event

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

if not exist(uvalue) then uvalue='none'

exit = 0

case uvalue of

	'use_box': state.use_box = event.select

	'use_cont': state.use_cont = event.select

	'contpercent': state.contpercent = event.select

	'inverse': state.inverse = event.select

	'subtract': state.subtract = event.select

	'writefile': state.imgflux.writefile = event.select

	'append': state.imgflux.append = event.select

	'clearfile': begin
		; to erase the contents of the file, just open for writing, and close
		widget_control, state.w_filename, get_value=filename
		openw, lun, filename, /get_lun
		free_lun, lun
		end

	'more_info': begin
    check = concat_dir(local_name('$SSW/gen/idl/plotman/doc'), 'image_flux_info.txt')
    file = file_search (check, count=count)
		if count gt 0 then begin
			msg = rd_ascii(file[0], error=error)
			if not error then a = dialog_message(msg, /info)
		endif else error=1

		if error then a = dialog_message('Error finding or reading info file ' + check)
		end

	'cancel': begin
		exit = 1
		end

	'accept': begin
		exit = 1

		; save imgflux structure and contour level and percent selection back in plotman object
		widget_control, state.w_filename, get_value=filename
		state.imgflux.filename = filename
		; if writing a file and not appending, then clear out the file, but set append back on so output from all images
		; will be written in file
		if state.imgflux.writefile and (state.imgflux.append eq 0) then begin
			openw, lun, filename, /get_lun
			free_lun, lun
			state.imgflux.append = 1
		endif
		state.plotman_obj -> set, imgflux = state.imgflux

		widget_control, state.w_contlevel, get_value=level
		state.plotman_obj -> set, mark_box_contour_level=level, mark_box_contour_percent=state.contpercent

		if state.subtract then begin
			image_info=state.plotman_obj -> get(/image_info)
			if not is_struct(image_info) then message,'Current plot is not an image.  Not subtracting.', /cont else $
				subtract_image = image_info.image
		endif
		state.plotman_obj -> multi_image_flux, state.panels, use_box=state.use_box, use_cont=state.use_cont, $
			inverse=state.inverse, subtract_image=subtract_image

		end

	else:

endcase

if exit then widget_control, event.top, /destroy else begin
	widget_control, event.top, set_uvalue=state
	plotman_multi_image_flux_widget_update, state
endelse

end

;------------------

pro plotman::multi_image_flux_widget, group, panels

common plotman_mark_box_common, boxes_save

if xregistered('plotman_multi_image_flux_widget') then begin
	xmessage,'plotman_multi_image_flux_widget is already running.  Only one copy allowed.'
	return
endif

if not exist(boxes_save) then boxes_save = {clean_box: ptr_new(0), $
			cw_list: ptr_new(0), $
			cw_nop: ptr_new(0), $
			cw_inverse: ptr_new(0) }

tlb = widget_base (group=group, $
					title='Options for multiple image flux calculation', $
					/base_align_center, $
					/column, $
					ypad=5, $
					/frame)
					;/modal )

tmp = widget_label (tlb, value='Set options for defining regions and writing file below.', /align_center)
tmp = widget_label (tlb, value='When you click Accept, Image Flux and Centroid will be', /align_center)
tmp = widget_label (tlb, value='calculated for every image selected.  Results will be ', /align_center)
tmp = widget_label (tlb, value='displayed on the screen and written in the file selected.', /align_center)
tmp = widget_label (tlb, value=' ')
tmp = widget_label (tlb, value='Stored boxes include any boxes drawn in the interactive Image Flux', /align_center)
tmp = widget_label (tlb, value='widget, either manually or via contours.', /align_center)
tmp = widget_label (tlb, value='Order of boxes in the output list is, for each image, stored boxes', /align_center)
tmp = widget_label (tlb, value='first, followed by box created by contour.', /align_center)
tmp = widget_label (tlb, value=' ')

tlb2 = widget_base (tlb, /column, /frame, ypad=10, space=10)

w_use_box_base = widget_base (tlb2, /row, /frame)

w_use_box_base2 = widget_base (w_use_box_base, /nonexclusive, /row)

w_use_box = widget_button (w_use_box_base2, value='Use Stored Boxes', uvalue='use_box')

if (*boxes_save.cw_nop)[0] eq 0 then ncw = 0 else ncw = n_elements(*boxes_save.cw_nop)
nbox = ncw
label = '   Number of boxes defined:  ' + strtrim(nbox,2) + '   '
w_nbox = widget_label (w_use_box_base, value=label)
if ncw eq 0 then widget_control, w_use_box, sensitive=0
if ncw eq 0 then widget_control, w_nbox, sensitive=0

temp = widget_label (tlb2, value='and / or', /align_center)

w_use_cont_base = widget_base (tlb2, /row, /frame)

w_use_cont_base2 = widget_base (w_use_cont_base, /nonexclusive, /row)

w_use_cont = widget_button (w_use_cont_base2, value='Use Contour Levels', uvalue='use_cont')
widget_control, w_use_cont, /set_button

level = self.mark_box_contour_level
alevel = level lt 10000. ? trim(level, '(f8.2)') : trim(level, '(g14.5)')
w_contlevel = cw_field (w_use_cont_base, $
					title='Contour level: ', $
					value=alevel, $
					xsize=14, $
					/return_events, $
					uvalue='contlevel')

contpercent = self.mark_box_contour_percent
w_cont_perc_base = widget_base (w_use_cont_base, /nonexclusive, /row)
w_contpercent = widget_button (w_cont_perc_base, value='Percent', uvalue='contpercent')
widget_control, w_contpercent, set_button = contpercent

inverse = *boxes_save.cw_inverse
w_invsubbase = widget_base(tlb2, /row, /nonexclusive)
w_inverse = widget_button (w_invsubbase, value='Inverse boxes (use area outside box)', uvalue='inverse')
widget_control, w_inverse, set_button = inverse

subtract = 0
w_subtract = widget_button (w_invsubbase, value='Subtract Current Image from All', uvalue='subtract')
widget_control, w_subtract, set_button = subtract

imgflux = self->get(/imgflux)
w_file_base = widget_base ( tlb2, /row, /frame)
w_writefile_base = widget_base(w_file_base, /nonexclusive, /row)
w_writefile = widget_button (w_writefile_base, value='Write to File: ', uvalue='writefile')
widget_control, w_writefile, set_button=imgflux.writefile
w_filename = widget_text (w_file_base, value=imgflux.filename, /edit)
w_append_base = widget_base (w_file_base, /nonexclusive, /row)
w_append = widget_button (w_append_base, value='Append', uvalue='append')
widget_control, w_append, set_button=imgflux.append
w_clear_file = widget_button (w_file_base, value='Clear file', uvalue='clearfile')

w_button_base2 = widget_base (tlb2, $
					/row, $
					space=20, ypad=10, /align_center )

tmp = widget_button (w_button_base2, value='More Info', uvalue='more_info')

tmp = widget_button (w_button_base2, $
					value='Cancel', uvalue='cancel')

tmp = widget_button (w_button_base2, $
					value='Accept', uvalue='accept')

state = { $
	plotman_obj: self, $
	panels: panels, $
	w_nbox: w_nbox, $
	w_contlevel: w_contlevel, $
	w_contpercent:w_contpercent, $
	w_writefile: w_writefile, $
	w_filename: w_filename, $
	w_append: w_append, $
	w_clear_file: w_clear_file, $
	contpercent: contpercent, $
	imgflux: imgflux, $
	use_box: 0, $
	use_cont: 1, $
	inverse: inverse, $
	subtract: subtract }

plotman_multi_image_flux_widget_update, state

if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=tlb
	widget_control, tlb, xoffset=xoffset, yoffset=yoffset
endif

widget_control, tlb, /realize

widget_control, tlb, set_uvalue=state

xmanager, 'plotman_multi_image_flux_widget', tlb

return

end





