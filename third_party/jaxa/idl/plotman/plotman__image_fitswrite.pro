;+
; Name: plotman::image_fitswrite
; Purpose: Plotman method for writing a FITS file from a single or collection of panels.
;	Can only be used for HESSI images.
;
; Written: Kim Tolbert, 22-Jan-2005.  This replaces plotman__write_image_cube
; 29-Jul-2005, Kim.  Added quiet keyword
; 9-Aug-2005, Kim.  Ask for filename at the beginning, instead of using the built-in feature
;   in fitswrite, since merging panels into a single object takes way longer than it should.
;-

pro plotman::image_fitswrite, panels_selected=psel, filename=filename, err_msg=err_msg, quiet=quiet

err_msg = ''
checkvar, psel, self -> get(/current_panel_number)
count = n_elements(psel)

if psel[0] ne -1 then begin

	if not keyword_set(filename) then begin
		outfile = dialog_pickfile (path=curdir(),  $
			filter='*.fits', $
			title = 'Select output FITS file name')
		if outfile eq '' then begin
			a = dialog_message('No output file name selected.  Aborting.')
			return
		endif
		filename = outfile
	endif

	check_control = hsi_get_basic_params(/image)
	q = where_arr (check_control, ['energy_band', 'filename', 'time_range', 'obs_time_interval'], /notequal)
	check_control = check_control(q)
	; previously used check_control names to check if params with those names had same values,
	; in each obj, and printed warning if they didn't.  Maybe this should be in hsi_image_strategy::merge?
	; not included in either place for now

	panels = self -> get(/panels)

	obj = objarr(count)

	for ii = 0, count-1 do begin
		p = panels -> get_item(psel[ii])
		if (*p).saved_data.class ne 'HSI_IMAGE' then begin
			err_msg = 'Panel ' + trim(psel[ii]) + ' is not a HESSI image. Aborting.'
			a = dialog_message(err_msg, /error)
			return
		endif
		obj[ii] = hsi_image(data_str=(*p).saved_data)
	endfor

	; thought I could just call fitswrite directly, when only one obj, but the pseudo obj
	; doesn't have info_summary set.  After if goes through the merge it does, so do merge even for one obj

	if count gt 1 then $;begin
		xmessage,['', '      Merging images into a single cube...       ', ''], wbase=wxmessage
	o = hsi_image_merge(obj)
;	endif else o = obj[0]
	strat = o->getstrategy()
	strat -> fitswrite, o->getdata(use_single=0), this_out_file=filename, err_msg=err_msg
	if xalive(wxmessage) then widget_control, wxmessage, /destroy

	if not keyword_set(quiet) then begin
		if err_msg eq '' then begin
			a = dialog_message ('FITS file written: ' + filename, /info)
		endif else begin
			a = dialog_message ('Error.  FITS file not written.  Check IDL log for error messages.', /error)
		endelse
	endif

	for ii=0,count-1 do obj_destroy,obj[ii]
	obj_destroy,o

endif  else print, 'No panels selected.'


end
