pro tv2, image, x00, y00, init=init, landscape=landscape, $
		window=window, already=already, ppinch=ppinch_in, $
		color=color, hwfont=hwfont, revcolor=revcolor, $
		xsize=xsize, ysize=ysize, xoff=xoffi, yoff=yoffi, $
		xy_size=xy_size
;+
;NAME:
;	tv2
;PURPOSE:
;	To allow a user to output an image to a PostScript device and
;	to specify the location (and size) in pseudo-pixel coordinates.
;SAMPLE CALLING SEQUENCE:
;	tv2, xsiz_pix, ysiz_pix, /init
;	tv2, xsiz_pix, ysiz_pix, /init, window=0    ; "X" version
;	tv2, xsiz_pix, ysiz_pix, /init, ppinch=100. ; Specify 100 pixs/inch
;	tv2, xsiz_pix, ysiz_pix, /init, xsize=6.    ; Specify xsize=6inch
;
;	tv2, image, x0, y0			; tv image at x0, y0
;
;	tv2, bytscl(image, top=!d.n_colors)
;
;	The tv2 routine makes it easy to send plots to the PostScript
;	printer by creating a pseudo-pixel coordinate system.  tv2
;	also works in the normal way for 'X' output, so that the same
;	calling statements can work with either 'X' or 'PS' output.
;
;	Typically, an application should first:
;	IDL> set_plot, 'PS', /interpolate 		; or set_plot,'Z'
;	IDL> tv2, xsiz_pix, ysiz_pix, /init	; Sets up coordinates
;       for example,
;	IDL> tv2, 512, 512, /init, window=0	; Sets up 512x512 window
;	Then send the plot with the command:
;	IDL> tv2, image
;	or
;	IDL> tv2, image, x0, y0		; x0,y0=lower left coordinate
;
;	Also see: plot2, xyouts2, ocontour, draw_grid and arrow2
;
;INPUTS:
;	image	- The byte scaled image to display 
;		  (except when /INIT is used -- in that case it is 
;		  the X size of the window in pixels)
;	x00	- The left corner pixel coordinate of the image
;		  (except when /INIT is used -- in that case it is
;		  the Y size of the window in pixels)
;	y00	- The lower corner pixel coordinate of the image
;OPTIONAL KEYWORD INPUT:
;	init	- Set this to set up the plotting characteristics.
;
;   ** Note: The following keywords only work WITH the /init option. **
;
;	landscape - If set, output in postscript mode
;		  Has no effect when the output device is "X"
;	window	- The window number to create 
;		  Has no effect when the output device is "PS"
;	already	- Do not create the window if it already exists
;		  and is the proper size
;		  Has no effect when the output device is "PS"
;	ppinch	- Force the size of the output to be a fixed number
;		  of "pixels per inch".
;	xsize	- Force the X size of the output to be xsize inches.
;		  If xsize is specified, then ppinch=xsize_pix/xsize
;		  xsize is ignored if ppinch is explicitly defined.
;	ysize	- Force the Y size of the output to be ysize inches.
;		  ysize is ignored if either ppinch or xsize is defined.
;	color	- If set, issue the device commands for color
;		  Has no effect when the output device is "X"
;	hwfont	- If set, use hardware fonts
;		  Has no effect when the output device is "X"
;	revcolor - If set, set !p.color to 0 for device PS so that
;		  writing will be in black on white paper.  Set
;		  !p.color to 255 for device X so that writing is
;		  white on a black background.
;OPTIONAL KEYWORD OUTPUT:
;	xy_size	- Vector containing the PS size [xsize,ysize] in inches.  
;		  Nothing returned when the output device is "X".
;METHOD:
;	Since the output size of the window is defined in pixels,
;	TV2, XYOUTS2, DRAW_GRID (Stonyhurst grid), OCONTOUR, PLOTS2,
;	and ARROW2 can convert the pixel coordinates into inches when 
;	sending the output to the postscript device. The aspect ratios 
;	are all figured out to maintain proper proportions.
;	MK_REFBAR will make a reference color bar.
;
;	tv2 reads back the color table using tvlct,/get,red,green,blue.
;       If tv2 thinks that the current table is a grey-scale, then the
;	image will be plotted using a tv,red(image).  This will preserve
;	the grey-scale characteristics when printing to a non-color
;	PostScript file.
;NOTES:
;	To work properly to the screen, the bytscl command should use
;	the "top=!d.n_colors" option
;
;	To work properly to the PS device, the 'set_plot,"ps"' command
;	needs to be 'set_plot,"ps",/interpolate' (so that the current
;	X colors are mapped properly to 256 PS colors).
;COMMON BLOCK:
;	tv2_blk
;SIDE EFFECTS:
;    1. If /color is set, the device,/color,bits=8,/helvetica is called.
;	When non-color PS output is next desired, this will have to be
;	reset by the user.
;    2. If /landscape is set, the device,/land call will be issued.  When
;	non-landscape PS output is next desired, this will have to be
;	reset by the user.
;    3. If tv2,/init is called for an 'X' device and the window keyword
;	is not specified, then window 0 will be created.
;ROUTINES CALLED:
;	wdef and delvarx
;HISTORY:
;	Written Feb-94 by M.Morrison
;	 9-Jun-94 (MDM) - 
;	10-Aug-94 (MDM) - Added ppinch optional input
;	 7-Apr-95 (MDM) - Added /COLOR and /HWFONT options
;	26-Jan-96 (JRL) - Added xsize, ysize, xoff, yoff, xy_size keywords. 
;			  For PS application, changed tv,img to tv,red(img), where
;			  red is from tvlct,/get,red
;	28-Jan-96 (LWA) - Made ppinch floating.
;       24-Oct-96 (MDM) - Modified to use the current window as
;                         long as it's greater than 0 (used to use
;                         window 0 all of the time)
;	 5-Nov-96 (MDM) - Re-added 24-Oct to merge with 26-Jan and 28-Jan
;			  modifications
;			- Added some documentation information
;	18-Dec-2002, William Thompson, GSFC
;		Changed !COLOR to !P.COLOR
;       24-Sep-2010, WTT, use [] indexing
;-
;
common tv2_blk, xsiz_pix, ysiz_pix, xsiz_inch, ysiz_inch, ppinch
;
if (n_elements(x00) eq 0) then x0 = 0 else x0 = x00
if (n_elements(y00) eq 0) then y0 = 0 else y0 = y00
if (n_elements(window) eq 0) then win = !d.window>0 else win = window
;
if (keyword_set(init) and (n_elements(image) eq 0)) then begin
    message, 'Warning: The X window size (pixels) is NOT defined.  Using 512.',/info
    image = 512
end
if (keyword_set(init) and (n_elements(x00) eq 0)) then begin
    message, 'Warning: The Y window size (pixels) is NOT defined.  Using 512.',/info
    x00 = 512
end
;
if (!d.name ne 'PS') then begin
    if (keyword_set(init)) then begin
	xsiz_pix = image
	ysiz_pix = x00
	wdef, win, xsiz_pix, ysiz_pix, already=already
	if (keyword_set(hwfont)) then !p.font=-1
	if (keyword_set(revcolor)) then !p.color=255	;write in white on black background
    end else begin
	tv, image, x0, y0
    end
    delvarx, xy_size					;To not confuse the issue
end else begin
    if (keyword_set(init)) then begin
        
	xsiz_pix = image
	ysiz_pix = x00
	xpage = 7.0
	ypage = 9.5
	if n_elements(xoffi) eq 0 then xoffs = 0.75 else xoffs = xoffi
	if n_elements(yoffi) eq 0 then yoffs = 1.   else yoffs = yoffi
	qland = 0
	if (keyword_set(landscape)) then begin
	    qland = 1
	    ypage = 7.0
	    xpage = 9.5
;	    xoffs = 0.75
	    if n_elements(yoffi) eq 0 then yoffs = xpage+0.75 else yoffs = yoffi
	end
;;	if (n_elements(ppinch_in) eq 0) then ppinch = (xsiz_pix/xpage) > (ysiz_pix/ypage) $	;pixels per inch
;;					else ppinch = ppinch_in
; Set up the page size (xsiz_inch, ysiz_inch) and plate scale (ppinch - pixels per inch)
;	This information is derived from ppinch or xsize OR YSIZE. If two or more of these
;	keywords are present, ppinch has highest priority, xsize the next highest, and 
;	ysize the lowest.  If no keywords are present, use the default page size.

; 	Set ppinch: pixles per inch:
	if n_elements(ppinch_in) ne 0 then ppinch = float(ppinch_in)      else $	; Yes, ppinch_in supplied
	if n_elements(xsize)     ne 0 then ppinch = xsiz_pix/float(xsize) else $	; Yes, xsize supplied
	if n_elements(ysize)     ne 0 then ppinch = ysiz_pix/float(ysize) else $	; Yes, ysize supplied
					   ppinch = (xsiz_pix/xpage) > (ysiz_pix/ypage) ; Default
; 	Set size (in inches):
	xsiz_inch = xsiz_pix/ppinch
	ysiz_inch = ysiz_pix/ppinch
	;
	;;device, /inches, xsize=xsiz_inch, ysize=ysiz_inch, xoffset=xoffs, yoffset=yoffs, portrait=1-qland, land=qland
	if (keyword_set(landscape)) then begin
	    device, /inches, xsize=xsiz_inch, ysize=ysiz_inch, xoffset=xoffs, yoffset=yoffs, /land
	end else begin
	    device, /inches, xsize=xsiz_inch, ysize=ysiz_inch, xoffset=xoffs, yoffset=yoffs, /portrait
	end
	;
	if (keyword_set(color)) then device, /color, bits=8, /helvetica
	if (keyword_set(hwfont)) then !p.font=0
	if (keyword_set(revcolor)) then !p.color=0	;write in black on white paper
    end else begin
	xi0 = x0 / ppinch
	yi0 = y0 / ppinch
	xisiz = n_elements(reform(image[*,0])) / ppinch
	yisiz = n_elements(reform(image[0,*])) / ppinch
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Added 24-Jan-96 by JRL.  The next lines of code checks to see if a grey-scale color
; table is current.  If yes, then the image is folded through the red color vector.
; This will make gamma changes effective for PostScript output, and will have no
; effect on 'X' or /color output.

	tvlct, red, green, blue, /get
	if min(red-green) + max(red-green) + min(red-blue) + max(red-blue) eq 0 then begin
	    image0 = red[image]
	end else begin
	    image0 = image
	    ;;message,'Current color table is not grey-scale--Using default color table',/info
        endelse
	tv, image0, xi0, yi0, xsiz=xisiz, ysiz=yisiz, /inch
    end
    xy_size = [xsiz_inch,ysiz_inch]		; Return PS page size (inches) as an optional keyword
end
;
end
