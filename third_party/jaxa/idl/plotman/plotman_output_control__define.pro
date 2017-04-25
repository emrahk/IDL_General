;+
; Name: plotman_output_control_define
;
; Purpose:  Define output control structure for plotman
;
; Written: Kim Tolbert, 2000
; Modifications:
;	21-Jul-2001, Kim.  Added imgflux structure
;-

pro plotman_output_control__define

cd, current=thisdir

ps =   {ps_form_info, xsize:6.0, xoff:1.75, ysize:6.0, $
       yoff:3.0, filename:filepath(root_dir=thisdir,'plotman.ps'), $
       inches:1, color:1, bits_per_pixel:8, $
       encapsulated:0, landscape:0}

pslocal = {ps_form_info, xsize:6.0, xoff:1.75, ysize:6.0, $
       yoff:3.0, filename:filepath(root_dir=thisdir,'plotman.ps'), $
       inches:1, color:1, bits_per_pixel:8, $
       encapsulated:0, landscape:0}

png =  {xwindow_png,xsize:600, ysize:600, color:1, $
       filename:filepath(root_dir=thisdir,'plotman.png'), $
       order:0, quality:-1}

jpeg = {xwindow_jpeg,xsize:600, ysize:600, color:1, $
       filename:filepath(root_dir=thisdir,'plotman.jpg'), $
       order:0, quality:75}

tiff = {xwindow_tiff,xsize:600, ysize:600, color:1, $
       filename:filepath(root_dir=thisdir,'plotman.tif'), $
       order:1, quality:-1}

imgflux = {flux_options, writefile: 0, filename:'', append: 0}

output_control = {plotman_output_control, $
	printers: ptr_new(), $
	printer: '', $
	psprint: ps, $
	ps: ps, $
	pslocal: pslocal, $
	png: png, $
	tiff: tiff, $
	jpeg: jpeg, $
	imgflux: imgflux }

end