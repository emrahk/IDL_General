;+
; Name: plotman::multi_image_flux
;
; Category: HESSI
;
; Purpose: Plotman method for computing flux, centroid, peak for multiple image panels.
;
; Input:
;	panels_selected - Panel numbers of panels to use
; Input keywords:
;	use_box - if set, use stored boxes
;	use_cont - if set, compute contour for each image and use that region
;	inverse - if set, use area outside of boxes instead of inside
;	Note: both use_box and use_cont can be set
;
; Written: Kim Tolbert, 26-Jul-2002
; Modifications:
;	9-Jun-2003, Kim.  Added inverse keyword
;	3-Nov-2003, Kim.  Added _extra keyword (so we can pass subtract_image through)
;
;-

pro plotman::multi_image_flux, panels_selected, use_box=use_box, use_cont=use_cont, $
	inverse=inverse, err_msg=err_msg, _extra=_extra

common plotman_mark_box_common, boxes_save

checkvar, inverse, 0

use_box = keyword_set(use_box)
use_cont = keyword_set(use_cont)
if not (use_box or use_cont) then begin
	err_msg = 'You must select saved boxes or contours.  Aborting.'
	goto, error_exit
endif

if use_box then begin
	if (*boxes_save.cw_nop)[0] gt 0 then begin
		list_save = *boxes_save.cw_list
		nop_save = *boxes_save.cw_nop
		list = list_save
		nop = nop_save
	endif
endif

out = ''
psel = panels_selected
count = n_elements(psel)
if psel[0] ne -1 then begin

	current_panel_number = self -> get(/current_panel_number)
	panels = self -> get(/panels)

	for ii = 0, count-1 do begin
		p = panels -> get_item(psel[ii])

		self -> focus_panel, *p, psel[ii]

		if (self->get(/plot_control)).plot_type eq 'image' then begin

			if use_cont then begin
				image_info = self -> get(/image_info)
				level = self -> get(/mark_box_contour_level)
				percent = self -> get(/mark_box_contour_percent)

				if percent then level = level * max(image_info.image) / 100.
				mid = image_info.pixel_size / 2.
				contour, image_info.image, image_info.xvals+mid[0], image_info.yvals+mid[1], level=level, $
					path_xy=path_xy, /path_data, path_info=path_info
				if n_elements(path_info) ge 1 then begin
					list = exist(list_save) ? [[list_save], [path_xy]] : path_xy
					nop = append_arr (nop_save, path_info.n)
				endif
			endif

			if exist(list) then begin
				self -> image_flux, box_str = {list: list, nop: nop, inverse: inverse}, $
					/quiet, header=header, output=output, units_string=units_string, $
					wrt_err_msg=err_msg, _extra=_extra
				if err_msg ne '' then goto, error_exit
				if not exist(total_output) then total_output = header
				total_output = append_arr(total_output, output)
			endif
		endif

	endfor
	;out = 'Completed image flux calculations on ' + trim(count) + ' panels'
	out = exist(total_output) ? [total_output, units_string] : 'None of selected images had valid boxes'

	self->focus_panel, dummy, current_panel_number

endif  else out = 'No panels selected.'

if inverse then out = [out, 'Inverse Box Option Enabled (use area outside of box).']

xmessage, out, font='fixedsys', xsize=max(strlen(out)), ysize=n_elements(out)+5, $
	title='Image Blobs: Flux, Centroid, Size, Peak'

imgflux = self -> get(/imgflux)
if imgflux.writefile then print,'Wrote Image Info File: ' + imgflux.filename

return

error_exit:
	a = dialog_message(err_msg, /error)
	return

end
