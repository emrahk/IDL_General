;+
; Name: plotman::write_image_cube
; Purpose: Plotman method for writing an image cube FITS file from a collection of panels.
;	Can only be used for HESSI images.
;
; Written: Kim Tolbert, 20-Jun-2002
; Modifications:
; 20-Aug-2002, Kim.  Handle writing separate info structures for each image
; 16-Jul-2003, Kim.  If couldn't find current time and energy in times_all,ebands_all (so
;    ind = -1) then set a fake info structure with just absolute_time_range.  Before still
;    tried to use info[ind].
; 30-Nov-2004, Kim.  use strlowcase for check for desc='hessi image'
;-

pro plotman::write_image_cube, panels_selected, filename=filename, err_msg=err_msg

out = ''
psel = panels_selected
count = n_elements(psel)
if psel[0] ne -1 then begin

	check_control = hsi_get_basic_params(/image)
	q = where_arr (check_control, ['energy_band', 'filename', 'time_range', 'obs_time_interval'], /notequal)
	check_control = check_control(q)

	self -> prepare_data, $
		data=data, madedummyobj=madedummyobj, use_obj_method=use_obj_method, err_msg=err_msg

	if not use_obj_method then begin
		err_msg = 'Error - can not write image cube for data that is not in an object.'
		goto, error_exit
	endif

	current_panel_number = self -> get(/current_panel_number)
	panels = self -> get(/panels)

	ebands_all = fltarr(count,2)
	times_all = dblarr(count,2)

	info_arr = ptrarr(count, /alloc)

	for ii = 0, count-1 do begin
		p = panels -> get_item(psel[ii])
		if strpos(strlowcase((*p).description), 'hessi image') eq -1 then begin
			err_msg = 'Panel ' + trim(psel[ii]) + ' is not a HESSI image. Aborting.'
			self->focus_panel, dummy, current_panel_number
			goto, error_exit
		endif
		;self -> restore_saved_data, *p
		self -> focus_panel, *p, psel[ii]
		if ii eq 0 then begin
			control = *(*p).saved_data.control
			dim = control.image_dim
			images = make_array(dim[0],dim[1], count, /float)
		endif else begin
			sub_control = struct_subset(control, check_control)
			sub_this = struct_subset (*(*p).saved_data.control, check_control)
			if not same_data(sub_control, sub_this) then begin
				out2 = ['NOTE:  control parameters for images (other than energy and time) are DIFFERENT.', $
					'USER BEWARE']
			endif
		endelse
		*(info_arr[ii]) = *(*p).saved_data.info
		ebands_all[ii,*] = (*(*p).saved_data.control).energy_band
		times_all[ii,*] = hsi_get_time_range (*(*p).saved_data.control,*(*p).saved_data.info)
		images[*,*,ii] = *(*p).saved_data.data
	endfor

	ebands_all = transpose(ebands_all)
	times_all = transpose(times_all)
	tmp = get_uniq(avg(ebands_all,0), sorder)
	ebands = ebands_all[*,sorder]
	tmp = get_uniq(avg(times_all,0), sorder)
	times = times_all[*,sorder]
	nebands = n_elements(ebands[0,*])
	ntimes = n_elements(times[0,*])

	if keyword_set(filename) then cubefile = filename else begin
		def_file = 'hsi_imagecube_' + time2file(times[0,0],/sec) + '.fits'
		cubefile = dialog_pickfile (filter='*.fits', $
			file=def_file, $
			title = 'Select image cube output file name',  $
			group=group)
		if cubefile eq '' then begin
			err_msg = 'No output file selected.'
			message, err_msg, /cont
			return
		endif
	endelse
	mk_file, cubefile, err=err
	if err ne '' then begin
		a=dialog_message(err)
		return
	endif
	rm_file, cubefile

	cube = obj_new('hsi_image_cube', [dim[0], dim[1], nebands, ntimes])
	cube -> set, orig_control = control, eband = ebands, times=times

	; have to loop in this order since image cube stores energy index first, and time index second
	; and info structure to be saved in file, must be passed to fitswrite in the same order
	for it = 0,ntimes-1 do begin
		for ie = 0,nebands-1 do begin
			ind = where(avg(ebands[*,ie]) eq avg(ebands_all,0) and $
				avg(times[*,it]) eq avg(times_all,0))
			ind = ind[0]
			if ind eq -1 then begin
				out3 = append_arr (out3, 'Image missing at energy band ' + format_intervals(ebands[*,ie]) + $
					' times ' + format_intervals(times[*,it],/ut) )
				cube -> set, index=[ie,it], image=fltarr(dim[0],dim[1])
				this_info = {absolute_time_range:[0.d0,0.d0]}
			endif else begin
				cube -> set, index=[ie,it], image = images[*,*,ind]
				this_info = *(info_arr[ind])
			endelse

			saved_data = {data: ptr_new(cube->get(/image_cube)), $
				control: ptr_new(control), $
				info: ptr_new(this_info)}

			ok = execute ('data -> fitswrite, create=(ie+it eq 0), fitsfile=cubefile, err_msg=err_msg, ' + $
				'_extra={saved_data: saved_data, ebands_arr: ebands, times_arr: times }')

			ptr_free, saved_data.data, saved_data.control, saved_data.info
			if not ok then begin
				out = 'Error.  No fitswrite method for this object or error writing FITS file.'
				err_msg = out
				self->focus_panel, dummy, current_panel_number
				goto, error_exit
			endif

		endfor
	endfor

	out = 'Image cube FITS file written: ' + cubefile

	if madedummyobj then obj_destroy, data

	self->focus_panel, dummy, current_panel_number

endif  else out = 'No panels selected.'

if exist (out2) then out = [out, out2]
if exist (out3) then out = [out, out3]

a=dialog_message( out, /info)
return

error_exit:
	a = dialog_message(err_msg, /error)
	if madedummyobj then obj_destroy, data
	return

end
