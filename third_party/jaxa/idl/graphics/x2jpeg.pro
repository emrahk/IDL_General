;+
; Project     :	SDAC
;
; Name        :	X2JPEG
;
; Purpose     :	Read X window and write to JPEG file.
;
; Explanation :	Uses TVRD to grab window, and writes it to a JPEG file.
;
; Use         :	X2JPEG  [, FILE ]
;              
; Inputs      :	None required.
;
; Opt. Inputs : FILE	= JPEG file name.  If not passed, then the output is
;			  written to "idl.jpg"
;
; Keywords    :	WINDOW = Index of window to be read.  If not passed, then the
;			 currently active window is read.
;
;               RESIZE = [nx,ny] = Dimensions to resize JPEG image to.
;
;		ERRMSG = Returned error message.
;               
; Category    :	Graphics
;
; Prev. Hist. :	Modified from X2GIF by Dominic Zarro.
;
; Written     :	16-May-2001, William Thompson, GSFC
;               Version 2, 25-Jan-2006, William Thompson
;                       Fixed problem with plotting parameters being reset by
;                       unnecessary set_plot call.
;               Version 3, 17-Mar-2016, WTT, call TVREAD for Mac compatibility
;
; Version     :	Version 3, 17-Mar-2016
;-
 
pro x2jpeg, file, r, g, b, window=window, resize=resize, errmsg=errmsg

errmsg = ''

;  Determine the filename.

if datatype(file) ne 'STR' then begin
    file = 'idl.jpg'
    message, 'JPEG file saved in ' + file, /continue
endif

;  Make sure that the file can be written okay.

break_file,file,dsk,dir,name,ext
out_dir = trim(dsk+dir)
cd,curr = curr
if out_dir eq '' then out_dir = curr
ok = test_open(out_dir,/write)
if not ok then begin
    errmsg = 'Cannot write JPEG file to ' + out_dir
    message, errmsg, /continue
    return
endif

;  Make sure there's a window to read.

dev_save = !d.name
select_windows
if ((n_elements(window) eq 0) and (!d.window eq -1)) or (not have_windows()) $
	then begin
    errmsg = 'NO WINDOW ACTIVE'
    message, errmsg, /continue
    return
endif

wsave = !d.window
if n_elements(window) ne 0 then	$
	if window gt -1 then wset,window
 
;  Read the window.  If not a true-color system, then read in the color table
;  as well, and separate the image into its component colors.

true = !d.n_colors ne !d.table_size
a = tvread(true=true)
if not true then begin
    tvlct, r, g, b, /get
    sz = size(a)
    temp = bytarr(sz[1],sz[2],3)
    temp[*,*,0] = r[a]
    temp[*,*,1] = g[a]
    temp[*,*,2] = b[a]
    a = temporary(temp)
endif

;  If the RESIZE keyword was used, then resize the image.

if n_elements(resize) eq 2 then begin
    if (resize[0] ne xsize) or (resize[1] ne ysize) then begin
	temp = bytarr(resize[0],resize[1],3)
	for i=0,2 do temp[*,*,i] =	$
		congrid(reform(a[*,*,i],resize[0],resize[1]))
	a = temporary(temp)
    endif
endif

;  Write out the JPEG file.

write_jpeg, form_filename(file,'.jpg'), a, true=3, quality=100

;  Reset the graphics device and window.

if !d.name ne dev_save then set_plot, dev_save
if wsave gt 0 then wset, wsave

return
end
