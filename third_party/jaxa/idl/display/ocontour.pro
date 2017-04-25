pro ocontour, img, x0, y0, bin=bin, qstop=qstop, $
	levels=levels, max_value=max_value, color=color, spline=spline, $
	c_thick=c_thick, c_linestyle=c_linestyle, nlevels=nlevels, $
	c_labels=c_labels, c_color=c_color, c_charsize=c_charsize, $
	c_annotation=c_annotation, c_orientation=c_orientation, $
	c_spacing=c_spacing, tv2=tv2, nodata=nodata
;
;+
;NAME:
;	ocontour
;PURPOSE:
;	To overlay a contour on top of an image
;EXPLANATION:
;	Note that the SOHO-CDS version of OCONTOUR.PRO was displaced by
;	this version.  To get the same functionality of the SOHO-CDS
;	version, use the CONTOUR command with /OVERPLOT switch.
;CALLING SEQUENCE:
;	ocontour, img
;	ocontour, data(*,*,5), bin=6
;	ocontour, img, 100, 100
;INPUT:
;	img	- the image to be contoured on top of the
;		  image aleady displayed with "TV"
;OPTIONAL INPUT:
;	x0	- If the origin of the image is not (0,0) then it is
;		  necessary to pass the left corner
;	y0	- see "x0"
;	bin	- If the image was displayed using REBIN or CONGRID
;		  then the routine needs to know that so that it scales
;		  properly.  This is the rebinning factor that was used
;		  to display the first image.
;OPTIONAL INPUT:
;	levels	- IDL contour command
;	max_value- IDL contour command
;	color	- IDL contour command
;	c_thick	- IDL contour command
;	c_linestyle - IDL contour command
;	nlevels	- IDL contour command
;	c_labels- IDL contour command
;	c_color	- IDL contour command
;	c_charsize - IDL contour command
;	c_annotation - IDL contour command
;	c_orientation - IDL contour command
;	c_spacing - IDL contour command
;	nodata	- IDL contour command
;	
;	tv2	- If set, then the image display is being done with TV2 and
;		  if the output device is PS, then set the position a bit
;		  differently.
;HISTORY:
;	Written 28-Oct-91 by M.Morrison
;	12-May-94 (MDM) - Corrected typo on "c_labels" parameter
;	12-May-94 (MDM) - Added /TV2 option
;	 6-Sep-94 (MDM) - Included a check that the window is the
;			  proper size (large enough to fit the image)
;	16-Feb-95 (MDM) - Added /NODATA option
;	 9-Mar-95 (MDM) - Fixed a typo on the window size check
;			  (it was using "x0" instead of "y0")
;	25-May-95 (LWA) - Added /c_orientation and /c_spacing options.
;	21-Jun-95 (MDM) - Updated header information (SOHO-CDS note)
;	18-Jul-95 (MDM) - Added /NORMAL to the contour call for /TV2 option
;-
;
common tv2_blk, xsiz_pix, ysiz_pix, xsiz_inch, ysiz_inch, ppinch
;
siz = size(img)
nx = siz(1)
ny = siz(2)
;
if (n_elements(x0) eq 0) then x0 = 0
if (n_elements(y0) eq 0) then y0 = 0
if (n_elements(bin) eq 0) then bin = 1
x1 = x0 + nx*bin
y1 = y0 + ny*bin
;
nxout = nx*bin
nyout = ny*bin
;
cmd = 'contour, img'
if (!d.name eq 'X') then if (!d.x_size-x0 lt nxout) or (!d.y_size-y0 lt nyout) then begin
    ;-----   6-Sep-94 (MDM) - added check for window size
    print, 'OCONTOUR: The current window cannot fit the image.  Trimming...'
    tbeep, 2
    xx2 = fix((!d.x_size-x0)/bin)
    yy2 = fix((!d.y_size-y0)/bin)
    cmd = 'contour, img(0:xx2-1, 0:yy2-1)'
    x1 = x0 + fix(xx2)*bin
    y1 = y0 + fix(yy2)*bin
end
cmd = cmd + ', xstyle=1+4, ystyle=1+4, /noerase, position = [x0,y0, x1,y1], /device'
if (keyword_set(tv2) and (!d.name eq 'PS')) then begin
    xn0 = x0 / float(xsiz_pix)
    yn0 = y0 / float(ysiz_pix)
    xn1 = xn0 + (nx*bin) / float(xsiz_pix)
    yn1 = yn0 + (ny*bin) / float(ysiz_pix)
    cmd = 'contour, img, xstyle=1+4, ystyle=1+4, /noerase, position = [xn0, yn0, xn1, yn1], /normal '
end
;
if (keyword_set(levels)) 	then cmd = cmd + ', levels=levels'
if (keyword_set(max_value)) 	then cmd = cmd + ', max_value=max_value'
if (keyword_set(color)) 	then cmd = cmd + ', color=color  '
if (keyword_set(c_thick)) 	then cmd = cmd + ', c_thick=c_thick'
if (keyword_set(c_linestyle)) 	then cmd = cmd + ', c_linestyle=c_linestyle'
if (keyword_set(spline)) 	then cmd = cmd + ', spline=spline'
if (keyword_set(nlevels)) 	then cmd = cmd + ', nlevels=nlevels'
if (keyword_set(c_labels)) 	then cmd = cmd + ', c_labels=c_labels'
if (keyword_set(c_color)) 	then cmd = cmd + ', c_color=c_color'
if (keyword_set(c_charsize)) 	then cmd = cmd + ', c_charsize=c_charsize'
if (keyword_set(c_annotation)) 	then cmd = cmd + ', c_annotation=c_annotation'
if (keyword_set(c_orientation)) then cmd = cmd + ', c_orientation=c_orientation'
if (keyword_set(c_spacing))     then cmd = cmd + ', c_spacing=c_spacing'
if (keyword_set(nodata)) 	then cmd = cmd + ', nodata=nodata'
;
stat = execute(cmd)
;
if (keyword_set(qstop)) then stop
end

