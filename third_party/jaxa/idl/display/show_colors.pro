	PRO SHOW_COLORS, DISABLE=DISABLE, _EXTRA=_EXTRA
;+
; Project     : SOHO - CDS
;
; Name        : 
;	SHOW_COLORS
; Purpose     : 
;	Displays the current color table.
; Explanation : 
;	The color tables are read using TVLCT,/GET.  Each color table (red,
;	green and blue) is plotted with a different value of !P.COLOR, and then
;	the color tables are modified so that the red color table is plotted in
;	red, etc.  The background (color 0) is changed to black, and the axes
;	(color 4) are changed to white.
; Use         : 
;	SHOW_COLORS
; Inputs      : 
;	None.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	DISABLE  = If set, then TVSELECT not used.
; Calls       : 
;	LINECOLOR, TVSELECT, TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
;	The plotting device must have at least five available colors, and be
;	able to load color tables.
;
;	In general, the SERTS image display routines use several non-standard
;	system variables.  These system variables are defined in the procedure
;	IMAGELIB.  It is suggested that the command IMAGELIB be placed in the
;	user's IDL_STARTUP file.
;
;	Some routines also require the SERTS graphics devices software,
;	generally found in a parallel directory at the site where this software
;	was obtained.  Those routines have their own special system variables.
;
; Side effects: 
;	The first five colors (0-4) in the color table are changed after
;	plotting, so that the red color table is plotted in red, etc.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, April 1992, changed to use TVLCT,/GET instead of
;				      common block, and added DISABLE keyword.
; Written     : 
;	William Thompson, GSFC.
; Modified    : 
;	Version 1, William Thompson, GSFC, 12 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 27 July 1994
;		Rewrote not to use PLOTC or OPLOTC.
;	Version 3, William Thompson, GSFC, 18 December 2002
;		Changed !COLOR to !P.COLOR
; Version     : 
;	Version 3, 18 December 2002
;-
;
	ON_ERROR,2
;
;  Check the number of colors.
;
	IF !D.N_COLORS LT 5 THEN BEGIN
		PRINT,'*** Plotting device does not have enough colors to display color table, routine SHOW_COLORS.'

		RETURN
	ENDIF
;
;  Get the current color table.
;
	TVSELECT,DISABLE=DISABLE
	TVLCT,RED,GREEN,BLUE,/GET
	TVUNSELECT,DISABLE=DISABLE
;
;  Save the current value of !P.COLOR, and set !P.COLOR to 4 for the plotting
;  axes.
;
	COLOR = !P.COLOR
	!P.COLOR= 4
        BACKGROUND = !P.BACKGROUND
        !P.BACKGROUND = 0
;
;  Change the colors to reflect the meaning of the graphs.
;
	LINECOLOR,0,/DISABLE,'BLACK'
	LINECOLOR,1,/DISABLE,'RED'
	LINECOLOR,2,/DISABLE,'GREEN'
	LINECOLOR,3,/DISABLE,'BLUE'
	LINECOLOR,4,/DISABLE,'WHITE'
;
;  Plot the color tables.
;
	PLOT, RED, /NODATA, YRANGE=[0,255], _EXTRA=_EXTRA
	OPLOT, _EXTRA=_EXTRA, RED, COLOR=1
	OPLOT, _EXTRA=_EXTRA, GREEN, COLOR=2
	OPLOT, _EXTRA=_EXTRA, BLUE, COLOR=3
;
;  Restore !P.COLOR and exit.
;
	!P.COLOR = COLOR
        !P.BACKGROUND = BACKGROUND
	END
