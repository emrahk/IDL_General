pro xy_raster, index, data, factor, noscale=noscale, individual_scale=individual_scale, $
		notimes=notimes, ss=ss, xsiz=xsiz, ysiz=ysiz, charsize=charsize
;+
; NAME: xy_raster
;
; PURPOSE: Generate a raster pattern of time series images
;
; CALLING SEQUENCE:
;	xy_raster, index, data
;	xy_raster, index, data, 3, ss=ss, /individual_scale
;	xy_raster, index, data, 0.5, /notimes, /noscale
;
; INPUTS:
;	index	- The index structure (containg Yohkoh or SSW style times)
;	data	- The data array      
;
; OPTIONAL INPUTS:
;	factor	- The rebin factor (factor = 2 to double the size).  The
;		  default is same size (=1)
;
; OPTIONAL KEYWORD INPUTS:
;	noscale	- If set, do not scale the data cube (use TV 
;		  instead of TVSCL)
;		  Default is to auto scale on the whole cube, so that
;		  the intensities relative to each image is maintained.
;	individual_scale - If set, then use TVSCL on each individual image.
;		  Default is to auto scale on the whole cube, so that
;		  the intensities relative to each image is maintained.
;	ss	- A list of the subscripts of the images to display
;	notimes	- If set, then do not display the times
;	xsiz	- The xsize of the window (default = 800).  This is only
;		  used if the data cube requires multiple pages
;	ysiz	- The ysize of the window (default = 800).  This is only
;		  used if the data cube requires multiple pages.  If 
;		  xsiz is specified, and ysiz is not, then xsiz is used.
;	charsize- The character size for the time label
;
; HISTORY:
;	HSH, written some time in early 1992
;	HSH, May 3, 1992, modified to handle odd-size images and 
;	  to trap obese windows
;	MDM,  3-Sep-93, Modified to calculate number of panels properly
;	MDM, 20-Dec-93	- Modified significantly, more robust
;			- Reverse data,index calling sequence
;	MDM,  2-Sep-94  - Added conditional on when to print statement
;			  "XY_RASTER: Cube will not fit on one page...."
;	MDM,  6-Sep-94  - Corrected error which would not all "SS"
;			  option to work.
;       SLF,  2-may-97  - remove SXT references (any SSW index,data ok)
;	William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;-
;
if (data_type(data) eq 8) then begin
    print, 'XY_RASTER: The calling sequence has been changed to'
    print, '           "index,data".  Please re-try'
    return
end
;
n  = n_elements(data(0,0,*))
if (n_elements(factor) eq 0) then factor = 1
if (n_elements(ss) eq 0) then ss = indgen(n)
if (n_elements(charsize) eq 0) then charsize = 1
;
nx = n_elements(data(*,0,0))
ny = n_elements(data(0,*,0))
n  = n_elements(ss)
;
nx1 = factor * nx
ny1 = factor * ny
;
qcongrid = 0
if (factor lt 1) then if ( ((nx mod nx1) ne 0) or ((ny mod ny1) ne 0) ) then qcongrid = 1
if (factor gt 1) then if ( ((nx1 mod nx) ne 0) or ((ny1 mod ny) ne 0) ) then qcongrid = 1
if (qcongrid) then print, 'XY_RASTER: Non multiple binning factor requested.  Using CONGRID'
;
nximg = fix(sqrt(n))
nyimg = n/nximg
if ((n mod nximg) ne 0) then nyimg = nyimg + 1
npage = 1
;
if (keyword_set(xsiz)) then begin
    wxmax = xsiz
    if (keyword_set(ysiz)) then wymax = ysiz else wymax = wxmax
end else begin
    wxmax = 800
    wymax = 800
end
;
if ((nx1 gt wxmax) or (ny1 gt wymax)) then begin
    print, 'XY_RASTER: The single image size is bigger than the window size'
    return
end
;
if (nximg*nx1 gt wxmax) or (nyimg*ny1 gt wymax) then begin
    nximg = fix(wxmax/nx1)
    nyimg = fix(wymax/ny1)
    npage = n / (nximg*nyimg)
    if (n mod (nximg*nyimg) ne 0) then npage = npage + 1
    if (npage gt 1) then print, 'XY_RASTER: Cube will not fit on one page.  Displaying on ' + strtrim(npage,2) + ' pages'
end
;
imin = min(data)
imax = max(data)
;
window, xsiz=nximg*nx1, ysiz=nyimg*ny1, /free
;
for i=0,n-1 do begin
	j = ss(i)
	x0 = (i mod nximg ) * nx1
	y0 = ((nyimg-1) - (i mod (nximg*nyimg))/nximg ) * ny1
	data0 = data(*,*,j)
	if (not keyword_set(noscale)) then begin
	    if (keyword_set(individual_scale)) then data0 = bytscl(temporary(data0)) $
				else data0 = bytscl(data0, min = imin, max = imax, top = !d.table_size)
	end
	;
	if (factor eq 1) then begin
	    tv, data0, x0, y0
	end else begin
	    if (qcongrid) then tv, congrid(data0, nx1, ny1), x0, y0 $
			else tv, rebin(data0, nx1, ny1, /sample), x0, y0
	end
	;
	if (not keyword_set(notimes)) then xyouts, x0, y0, gt_time(index(j), /str), /dev, charsize=charsize
	;
	if (((i mod (nximg*nyimg)) eq nximg*nyimg-1) and (i ne n-1)) then begin
	    ans = ''
	    read, 'Hit <CR> to continue to the next page (q to quit)', ans
	    if (strupcase(ans) eq 'Q') then return
	    erase
	end
end
;
end

