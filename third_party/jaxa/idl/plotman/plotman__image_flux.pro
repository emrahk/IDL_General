;+
; PROJECT:
;       HESSI
;
; NAME:
;       plotman__image_flux
;
; PURPOSE:
;       Plotman method to return image flux in user-specified areas
;
; METHOD:
;	Image plot should be in plotman's draw widget.  This method pops
;	up a widget that allows user to define areas on the image.  Flux
;	in each area is returned.
;
; CATEGORY:
;       Imaging (hessi/image), PLOTMAN
;
; INPUT:  None
; OUTPUT:
;	flux - total flux in image for each area defined by user
;	cancel - 0/1 - operation not cancelled / cancelled
;
; Written:  Kim Tolbert, 2001
;
; Modifications:
;  13-Jul-2002, Kim.  Added centroid calculation
;  16-Jul-2002, Kim.  Added standard deviation of centroid calculation
;  21-Jul-2002, Kim.  Added file writing capability.  Changed output format to be columns,
;		changed to use xmessage (to get fixed pitch font) instead of dialog_message.
;  26-Jul-2002, Kim.  Added box_str, header, output, units_string keywords
;  02-Aug-2002, Kim.  Added peak location and value calculations (using parapeak)
;  11-Apr-2003, Kim.  Added inverse option
;  9-Jun-2003,  Kim.  Use 'Inv' instead of 'Box' for column heading when inverse is set.  And
;		check that ind_use is not -1 before using it.
;  3-Nov-2003, Kim.  Added subtract_image keyword.
;  8-Jul-2008, Kim. Call hsi_coll_segment_list through call_function so can compile if hessi
;   not in ssw path.
;  30-Jan-2009, Kim.  Added struct_output keyword to return structure of values
;  18-May-2009, Kim.  Changed the way we expand box boundaries to compensate for the way polyfillv
;   works. Was including too many pixels outside user's box before.  Also add note_string to blob
;   text box, and print message on screen if using center of peak pixel instead of parapeak result.
;  1-Apr-2010, Kim. Corrected error in centroid.  Was passing xvals, yvals to map_xymoments, which
;   are the left,bottom of the pixel.  Should be passing in the center of the pixel.  Also added 
;   drawing +, X, and triangle for centroid, peak, and pixels used, respectively, on plot if 
;   mark_plot is set, and the box structure is not passed in (when box structure is passed, the plot 
;   we're finding flux for may not be a current active plot)  Currently nothing disables mark_plot (unless user
;   calls this method directly with mark_plot=0, but could add button on mark box widget to enable/disable.
;  5-Apr-2010, Kim. Removed earlier code that tried to account for peculiarity of POLYFILLV. Previously was expanding
;   pixels selected at top and right.  Now add 1/2 pixel size to boundary locations when converting to
;   pixel element number, so pixels passed to POLYFILLV will be shifted, and now if center of pixel is within 
;   boundary, it will be included.
;  4-Oct-2010, Kim.  Call find_box_region_index to find pixels inside box.  Code was extracted from here.
;  27-May-2014, Kim. Increase number of digits for flux, centroid xy, peak xy, and peak for both screen and file output
;
;-
;--------------------------------------------------------------------

pro plotman::image_flux, box_str=box_str, quiet=quiet, cancel=cancel, $
  wrt_err_msg=wrt_err_msg, subtract_image=subtract_image, $
	flux=flux, struct_output=struct_output, header=scr_header, output=output, $
	units_string=units_string, mark_plot=mark_plot

checkvar, mark_plot, 1
flux = 0.
cancel = 0
wrt_err_msg = ''
output = ''
header = ''

quiet = keyword_set(quiet)

; even if we asked to mark the plot, if box_str was passed in, we probably don't have current plot available
if exist(box_str) then mark_plot=0

; if box definitions weren't passed in, call mark_box to let user mark them.
if ~exist(box_str) then box_str = self -> mark_box (type='Flux', cancel=cancel)

if cancel then begin
	if not quiet then message,'Operation cancelled.', /cont
	return
endif

boxes = box_str.list
nperbox = box_str.nop
inverse = box_str.inverse
nbox = n_elements(nperbox)

if nperbox[0] le 0 then begin
	if not quiet then message,'No image flux boxes defined.', /cont
	return
endif

; if it's a hessi image, control will be control structure, otherwise -1
control = self -> get(/control)
is_hessi = size(control, /tname) eq 'STRUCT' ? 1 : 0

image_info = self -> get(/image_info)
image = image_info.image
dim = size(image, /dim)

if exist(subtract_image) then begin
	if not same_data(dim, size(subtract_image,/dim)) then $
		message,'Cannot subtract current image - different dimensions.', /cont $
	else begin
		; show image in current panel (if panel is showing already)
		image = image - subtract_image
		tvscl,congrid(image,!d.x_size,!d.y_size), top=self->get(/ncolors)
	endelse

endif

nbox = n_elements(nperbox)
image_sel = bytarr(dim[0], dim[1]) ; starts out all 0's, elements selected will be set to 1

flux = fltarr(nbox)

i1 = 0

g14 = '(g14.7)'
g14p5 = '(g14.5)'
f10p2 = '(f10.2)'
f10p4 = '(f10.4)'
format_s = '(a4, a14, a10, a11, a11, a11, a11, a8, a8, a14)'
format_f = '(a4, a13, a13, a13, a14, a10, a11, a11, a11, a11, a8, a8, a14)'

formath_scr = '(a4, a14, a10, a20, a20, a19, a14)'
formath_file = '(a4, a13, a13, a13, a14, a10, a20, a20, a19, a14)'

formatb = '(a8,a8, a36)'

box_str = inverse ? 'Inv' : 'Box'
scr_header = string(box_str, $
	'Flux', 'Area', $
	'Centroid (X,Y)', 'Peak (X,Y)', 'St Dev (X,Y)', 'Peak', format=formath_scr)

file_header = string(box_str, $
	'Date', 'Start time', 'End time', 'Flux', 'Area', $
	'Centroid (X,Y)', 'Peak (X,Y)', 'St Dev (X,Y)', 'Peak Value', format=formath_file)

if is_hessi then $
	file_header = file_header + string('E Lo', 'E Hi', 'Detectors', format=formatb)

image_units = str_chop(image_info.image_units, 'asec**(-2)')
pixel_units = image_info.pixel_units eq '' ? '?' : image_info.pixel_units
area_units = image_info.pixel_units eq '' ? '' : image_info.pixel_units + '**(2)'
peak_units = image_info.image_units

units_string = 'UNITS -  Flux: ' + image_units + '   Area: ' + area_units + $
		'   Centroid, St Dev: ' + pixel_units + '   Peak: ' + peak_units
		
notes_string = ''		

adate = anytim(image_info.times[0], /vms, /date)
atimes = anytim(image_info.times, /vms, /time)

output=''
struct_output = -1

; NOTE:  xvals, yvals are LEFT, BOTTOM edges of pixel 
xvals = image_info.xvals
yvals = image_info.yvals
xpix_siz = image_info.pixel_size[0]
ypix_siz = image_info.pixel_size[1]

for i = 0,nbox-1 do begin
 	i2 = i1 + nperbox[i]-1
 	
 	; boxes are the x,y coordinates of the boundary in data coordinates
    box = boxes(*,i1:i2)
    index_1d = find_box_region_index(xvals, yvals, box)

    if index_1d[0] ne -1 then begin
    	ind_box = intarr(dim[0], dim[1])
    	ind_box[index_1d] = 1
    	ind_use = inverse ? where(ind_box eq 0) : where (ind_box eq 1)
		if ind_use[0] ne -1 then begin
			image_use = fltarr(dim[0], dim[1])
			image_use[ind_use] = image[ind_use]
			
			if mark_plot then begin
              self->select
              z = get_ij(ind_use, dim[0])
              plots, xvals[z[0,*]] + .5*xpix_siz, yvals[z[1,*]] + .5*ypix_siz, $
                psym=4,color=255, symsize=.5 ; psym=4 is triangle, use brightest color
              self->unselect
            endif

		    flux[i] = total(image_use) * image_info.pixel_area
		    area = n_elements(ind_use) * image_info.pixel_area

		; tried different ways of handling negative values (set all negative values to 0., subtract
		; min of image) but they bias the centroid.  Maybe in future allow for user-selectable
		; threshold value, but for now use all values in selected part of image.  When user defines
		; boxes well (like with contour), should be OK.

			peak = max(image_use, elem_max)
			; pass centers of pixels. xvals,yvals are left,bottom edge
			map_xymoments, image_use, xvals + .5*xpix_siz, yvals + .5*ypix_siz, centroid, stdev 
			xy_max = get_ij (elem_max, dim[0])
			ppeak = parapeak ( extrac(image, xy_max[0]-1, xy_max[1]-1, 3, 3), err_msg=err_msg )
			if err_msg ne '' then begin
			   if not quiet then print,'Box ' + trim(i) + ' - ' + err_msg + '  Using center of peak pixel for x,y and flux of peak.'
			   ppeak = [0., 0., peak]
			   notes_string = 'Note:  In one or more box, peak is at edge so not fitted - peak values are for center of peak pixel. ' + $
			     'See IDL log for more info.' 
			endif
      xpeak = xvals[xy_max[0]] + xpix_siz*(.5 + ppeak[0])
      ypeak = yvals[xy_max[1]] + ypix_siz*(.5 + ppeak[1])
      peakval = ppeak[2]
      axpeak = trim(xpeak,f10p4)
      aypeak = trim(ypeak,f10p4)
      apeakval = trim(peakval, g14)

	    image_sel(ind_use) = 1
	;if i eq 4 then stop
			scr_line = string(trim(i), $
					trim(flux[i],g14), $
					trim(area,f10p2), $
					trim(centroid,f10p4), $
					axpeak, $
					aypeak, $
					trim(stdev,f10p2), $
					apeakval, $
					format = format_s)

			f_line = 	string(trim(i), $
					adate, $
					atimes, $
					trim(flux[i],g14), $
					trim(area,f10p2), $
					trim(centroid,f10p4), $
					axpeak, $
					aypeak, $
					trim(stdev,f10p2), $
					apeakval, $
					format = format_f)
					
      scr_output = append_arr(scr_output, scr_line)
      					
		  struct = {box: i, $
		      date: adate, $
		      times: atimes, $
		      flux: flux[i], $
		      area: area, $
		      centroid: centroid, $
		      xpeak: xpeak, $
		      ypeak: ypeak, $
		      stdev: stdev, $
		      peakval: peakval, $
		      inverse: inverse}
		      
		  struct_output = is_struct(struct_output) ? concat_struct(struct_output, struct) : struct		    

			if is_hessi then begin
				file_line = f_line + string (trim(control.energy_band[0],g14p5), trim(control.energy_band[1],g14p5), $
					 call_function('hsi_coll_segment_list',control.det_index_mask, control.a2d_index_mask, control.front_segment, control.rear_segment), $
					 format=formatb)
			endif else file_line = f_line

			file_output = append_arr(file_output, file_line)

			;print,output[i]
		endif else if not quiet then print,'Not using box ' + trim(i) + '. Nothing left in inverse.'
	endif else if not quiet then print,'Not using box ' + trim(i) + '.  Box is too small.'

	i1 = i1 + nperbox[i]
endfor

if nbox eq 1 then flux = flux[0]

ind_use_tot = where(image_sel eq 1)

if ind_use_tot[0] ne -1 then begin
	flux_tot = total( image[ind_use_tot] ) * image_info.pixel_area
	area = n_elements(ind_use_tot) * image_info.pixel_area
	;output=append_arr(output, $
	;	'Total flux in all boxes ', strtrim(string(flux_tot,form=g14),2) + ' ' + image_units + $
	;	'   Total Area = ' + strtrim(string(area,form=g14),2) + ' ' + area_units )
	trailer = $
		['',  $
		'Total flux in all boxes: ' + trim(flux_tot,g14) + $
		'  Area of all boxes: ' + trim(area,g14p5), $
		units_string, $
		notes_string ]
endif else begin
	scr_output = ''
	file_output = ''
	trailer = 'None of boxes had sufficient area to calculate flux.'
endelse


done:

if not quiet then begin
	if inverse then trailer = [trailer, 'Inverse Box Option Enabled (use area outside of box).']
	text = [scr_header, scr_output, trailer]
	print,text
	xmessage, text, font='fixedsys', xsize=max(strlen(text)), ysize=n_elements(text)+5, $
		title='Image Blobs: Flux, Centroid, Size, Peak'
endif

imgflux = self -> get(/imgflux)
if imgflux.writefile then begin
	text = [file_header, file_output]
	if imgflux.append then begin
		lines = rd_ascii (imgflux.filename, error=error)
		if not error and n_elements(lines) gt 1 then text = [lines, file_output]
	endif
	wrt_ascii, text, imgflux.filename, err_msg=wrt_err_msg
	if wrt_err_msg ne '' then begin
		if not quiet then a=dialog_message(wrt_err_msg, /error)
	endif else if not quiet then print, 'Wrote Image Info File: ' + imgflux.filename

endif

if mark_plot then begin
  self->select
  plots, struct_output.centroid[0], struct_output.centroid[1], /data, psym=1, color=0 ; psym=1 is +, use darkest color
  plots, struct_output.xpeak, struct_output.ypeak, /data, psym=7, color=0  ;psym=7 is X, use darkest color
  print,''
  message,'Centroids marked on plot with +, Peaks marked with X, Pixels used marked with tiny triangle', /cont
  print,''
  self->unselect
endif


output = scr_output

end
