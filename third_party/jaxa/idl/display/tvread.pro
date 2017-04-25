	FUNCTION TVREAD,RED,GREEN,BLUE,WINDOW=WINDOW,DISABLE=DISABLE,	$
		GREYSCALE=GREYSCALE, REVERSE=REVERSE, TRUECOLOR=TRUE,	$
		PSEUDOCOLOR=PSEUDO, QUIET=QUIET, _EXTRA=_EXTRA
;+
; Project     : SOHO - CDS
;
; Name        : 
;	TVREAD()
; Purpose     : 
;	Reads contents of an image display screen into an array.
; Explanation : 
;	Reads the contents of an image display screen, or window, into an
;	array.  Uses TVRD.  Reads the entire window.
; Use         : 
;	Result = TVREAD()
;	Result = TVREAD(RED,GREEN,BLUE)
; Inputs      : 
;	None.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	RED, GREEN, BLUE = The active color tables in the selected
;		  window/device.
; Keywords    : 
;	WINDOW	  = Which window to read from.  If passed, then overrides the
;		    TVSELECT routine.
;	DISABLE   = If set, then the current graphics device/window is read.
;		    Otherwise, TVSELECT is called to select the image display
;		    device/window.  Ignored if WINDOW keyword is passed.
;	GREYSCALE = If set, then a greyscale approximation of the color image
;		    is returned.
;	REVERSE	  = If set, then the image is returned in inverse video.  Only
;		    applicable if GREYSCALE is set.
;	TRUECOLOR = If set, then the result is returned as a TrueColor image
;		    with dimensions (M,N,3).  This is the default if the device
;		    being read is a TrueColor device.
;	PSEUDOCOLOR = If set, then the routine COLOR_QUAN is called to convert
;		    the image into an 8-bit image.  Other keywords to
;		    COLOR_QUAN can also be passed.  Ignored if the image is
;		    already 8-bit.
; Calls       : 
;	HAVE_WINDOWS, TVSELECT, TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
;	Device must be capable of the TVRD function.
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
;	None.
; Category    : 
;	None.
; Prev. Hist. : 
;	William Thompson, June 1991.
;	William Thompson, May 1992, added output parameters RED, GREEN, BLUE.
; Written     : 
;	William Thompson, GSFC, June 1991
; Modified    : 
;	Version 1, William Thompson, GSFC, 11 May 1993
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 30 June 1995
;		Added keywords GREYSCALE and REVERSE.  The translation from
;		colors to greyscale is as suggested by Alan Youngblood of RSI.
;	Version 3, William Thompson, GSFC, 10 April 1997
;		Use pixmap to read even if window is obscured.
;	Version 4, William Thompson, GSFC, 16 April 2003
;		Added support for TrueColor displays.
;               Added keywords TRUECOLOR, PSEUDOCOLOR
;       Version 5, William Thompson, GSFC, 27 February 2006
; Version     : 
;	Version 6, 27 Feb 2006
;-
;
	ON_ERROR,2
;
;  Select the graphics device or window to read from, if applicable.
;
	IF N_ELEMENTS(WINDOW) EQ 1 THEN BEGIN
		GRAPHICS_WINDOW = !D.WINDOW
		WSET,WINDOW
	END ELSE TVSELECT, DISABLE=DISABLE
;
;  Read in the entire window.  Also get the color tables.
;
	XSIZE = !D.X_SIZE
	YSIZE = !D.Y_SIZE
	IF HAVE_WINDOWS() THEN BEGIN
		OLD_WINDOW = !D.WINDOW
		WINDOW, XSIZE=XSIZE, YSIZE=YSIZE, /FREE, /PIXMAP
		DEVICE, COPY=[0, 0, XSIZE, YSIZE, 0, 0, OLD_WINDOW]
	ENDIF
;
;  Read in the window, depending on whether it's true- or pseudo-color.
;
	TVLCT, RED, GREEN, BLUE, /GET
	IF !D.N_COLORS GT !D.TABLE_SIZE THEN BEGIN
	    RESULT = TVRD(0,0,XSIZE,YSIZE,TRUE=3)
	    IF KEYWORD_SET(PSEUDO) THEN		$
	    	    RESULT=COLOR_QUAN(RESULT,3,RED,GREEN,BLUE,_EXTRA=_EXTRA)
	END ELSE BEGIN
	    RESULT = TVRD(0,0,XSIZE,YSIZE)
	    IF KEYWORD_SET(TRUE) THEN BEGIN
		TEMP = TEMPORARY(RESULT)
		RESULT = RED[TEMP]
		BOOST_ARRAY, RESULT, GREEN[TEMP]
		BOOST_ARRAY, RESULT, BLUE[TEMP]
	    ENDIF
	ENDELSE
;
	IF HAVE_WINDOWS() THEN BEGIN
		WDELETE, !D.WINDOW
		WSET, OLD_WINDOW
	ENDIF
;
	IF NOT KEYWORD_SET(QUIET) THEN PRINT,'Image acquired'
;
;  If the GREYSCALE keyword was set, then convert the image to a greyscale
;  representation.
;
	IF KEYWORD_SET(GREYSCALE) THEN BEGIN
	    SZ = SIZE(RESULT)
	    IF SZ[0] EQ 3 THEN BEGIN
                RESULT = 0.3*RESULT[*,*,0] + 0.59*RESULT[*,*,1] +       $
                    0.11*RESULT[*,*,2]
	    END ELSE BEGIN
		BWTABLE = BYTSCL(0.3*RED + 0.59*GREEN + 0.11*BLUE)
		RESULT = BWTABLE[RESULT]
	    ENDELSE
;
;  If the keyword REVERSE is set, then do the plot in inverse video.
;
	    IF KEYWORD_SET(REVERSE) THEN RESULT = MAX(RESULT) - RESULT
	ENDIF
;
;  Reset to the previous graphics device or window.
;
	IF N_ELEMENTS(WINDOW) EQ 1 THEN BEGIN
		IF GRAPHICS_WINDOW NE -1 THEN WSET,GRAPHICS_WINDOW
	END ELSE BEGIN
		TVUNSELECT, DISABLE=DISABLE
	ENDELSE
;
	RETURN,RESULT
	END
