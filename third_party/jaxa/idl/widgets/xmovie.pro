	PRO XMOVIE,IMAGES,RATE,NOSCALE=NOSCALE,MISSING=MISSING,MAX=MAX, $
		MIN=MIN,TOP=TOP,BOTTOM=BOTTOM,VELOCITY=VELOCITY,        $
                COMBINED=COMBINED,LOWER=LOWER,NOEXACT=NOEXACT,SIZE=SIZE,$
                SMOOTH=SMOOTH,RESIZE=RESIZE,RELATIVE=RELATIVE,TITLE=TITLE, $
		SUBSCRIPTS=SUBSCRIPTS
;+
; Project     : SOHO - CDS
;
; Name        : 
;	XMOVIE
; Purpose     : 
;	Animates a series of images under widget control.
; Explanation : 
;	BSCALE is used to scale the images, and XINTERANIMATE is called to
;	animate them.
; Use         : 
;	XMOVIE, IMAGES  [, RATE ]
; Inputs      : 
;	IMAGES	= Three dimensional array of images, in the format
;		  (X-dim,Y-dim,Frame).
; Opt. Inputs : 
;	RATE	= Optional rate of display.  The rate is a value between 0 and
;		  100 that gives the speed that the animation is displayed.
;		  The fastest animation is with a value of 100 and the slowest
;		  is with a value of 0.  The default value is 100 if not
;		  specified.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	NOSCALE  = If set, then the images are not scaled.
;	MISSING	 = Value flagging missing pixels.  These points are scaled to
;		   zero.
;	MAX	 = The maximum value to be considered in scaling the
;		   images, as used by BYTSCL.  The default is the maximum value
;		   of IMAGES.
;	MIN	 = The minimum value of IMAGES to be considered in scaling the
;		   image, as used by BYTSCL.  The default is the minimum value
;		   of IMAGES.
;	TOP	 = The maximum value of the scaled image array, as used by
;		   BYTSCL.  The default is !D.N_COLORS-1.
;	BOTTOM	 = The minimum value of the scaled image array, as used by
;		   BYTSCL.  The default is 0.
;	VELOCITY = If set, then the image is scaled using FORM_VEL as a
;		   velocity image.  Can be used in conjunction with COMBINED
;		   keyword.  Ignored if NOSCALE is set.
;	COMBINED = Signals that the image is to be displayed in one of two
;		   combined color tables.  Can be used by itself, or in
;		   conjunction with the VELOCITY or LOWER keywords.
;	LOWER	 = If set, then the image is placed in the lower part of the
;		   color table, rather than the upper.  Used in conjunction
;		   with COMBINED keyword.
;	RESIZE	 = If set, then the image will be resized up or down by integer
;		   factors to best fit within the display.  Unless RESIZE or
;		   one of the other size related keywords are set, then the
;		   image is displayed at its true pixel size.
;	NOEXACT	 = If set, then non-integer factors are allowed.
;	SIZE	 = If passed and positive, then used to determine the scale of
;		   the image.  Returned as the value of the image scale.
;	SMOOTH	 = If set, then the image is expanded with bilinear
;		   interpolation.
;	RELATIVE = Size of area to be used for displaying the image, relative
;		   to the total size available.  Must be between 0 and 1.
;		   Default is 1.  Ignored unless RESIZE or NOEXACT is set.
;	TITLE	 = Widget title for movie display.
;	SUBSCRIPTS = The subscripts of the images to display.  The default is
;		   to display them all.
; Calls       : 
;	BSCALE, WDISPLAY, XINTERANIMATE, EXPTV
; Common      : 
;	None.
; Restrictions: 
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
;	A temporary window is created to display the images as they are loaded.
;	A widget controlled window is created to display the images.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, May 1992.
;	William Thompson, August 1992, renamed BADPIXEL to MISSING.
;	William Thompson, September 1992, use COMBINED keyword in place of
;					  INTENSITY.
; Written     : 
;	William Thompson, GSFC, May 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 4 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 6 July 1993.
;		Fixed bug with RATE variable.
;	Version 3, William Thompson, GSFC, 28 December 1993.
;		Modified to call WDISPLAY and EXPTV to display images as they
;		are being loaded.  Added keywords RESIZE, NOEXACT, SIZE,
;		SMOOTH, RELATIVE.
;	Version 4, William Thompson, GSFC, 20 May 1994
;		Modified to add XALIGN=0 to EXPTV call, and to temporarily set
;		!QUIET=1 during loading of additional images after the first.
;	Version 5, William Thompson, GSFC, 8 June 1994
;		Modified so that movie widget will have correct width even if
;		Motif would otherwise force the window to be wider.
;	Version 6, William Thompson, GSFC, 20 June 1995
;		Added keywords TITLE and SUBSCRIPTS.
;	Version 7, William Thompson, GSFC, 17 October 1996
;		Fixed bug where missing pixels were not handled correctly.
;	Version 8, William Thompson, GSFC, 12 August 1997
;		Don't calculate MIN and MAX if /NOSCALE is set.
;       Version 9, William Thompson, GSFC, 3-Jan-2006
;               Added keyword BOTTOM
;       Version 10, 17-Mar-2016, WTT, Use pixmaps to speed up
; Version     : 
;	Version 10, 17-Mar-2016
;-
;
	ON_ERROR,2
;
	IF N_PARAMS() EQ 0 THEN MESSAGE,'Syntax:  XMOVIE, IMAGES  [, RATE ]'
;
;  Check the size of IMAGES.
;
	SZ = SIZE(IMAGES)
	IF SZ[0] NE 3 THEN MESSAGE,'IMAGES must be a three-dimensional array'
;
;  If RATE is not passed, then use a rate of 100.
;
	IF N_PARAMS() NE 2 THEN RATE = 100
;
;  If SUBSCRIPTS was not passed, then use all the images.
;
	IF N_ELEMENTS(SUBSCRIPTS) NE 0 THEN SS = SUBSCRIPTS ELSE	$
		SS = INDGEN(SZ[3])
	NF = N_ELEMENTS(SS)		;Number of frames
;
;  Find the maximum and minimum values to use in displaying the images.  If not
;  passed, then use the extrema of all the images combined.  Don't bother to
;  calculate the extrema if both MAX and MIN were passed.
;
	IF N_ELEMENTS(MIN)*N_ELEMENTS(MAX) EQ 1 THEN BEGIN
		IMIN = MIN
		IMAX = MAX
	END ELSE IF NOT KEYWORD_SET(NOSCALE) THEN BEGIN
		IMIN = MIN( GOOD_PIXELS(IMAGES[*,*,SS], MISSING=MISSING), $
			MAX=IMAX)
		IF N_ELEMENTS(MIN) EQ 1 THEN IMIN = MIN
		IF N_ELEMENTS(MAX) EQ 1 THEN IMAX = MAX
	ENDIF
;
;  Use WDISPLAY to load the first image.
;
	WDISPLAY,WINDOW=TEMPWINDOW,IMAGES[*,*,SS[0]],NOSCALE=NOSCALE,	$
		MISSING=MISSING,MAX=IMAX,MIN=IMIN,TOP=TOP,BOTTOM=BOTTOM,$
		VELOCITY=VELOCITY,COMBINED=COMBINED,LOWER=LOWER,	$
		NOEXACT=NOEXACT,SIZE=SIZE,SMOOTH=SMOOTH,RESIZE=RESIZE,	$
		RELATIVE=RELATIVE,/PIXMAP
;
;  Set up the widget window.
;
	CURRWINDOW = !D.WINDOW
	WSET, TEMPWINDOW
	GET_TV_SCALE,SX,SY,XSIZE,YSIZE,JX,JY,/DISABLE
	IF N_ELEMENTS(TITLE) EQ 1 THEN	$
		XINTERANIMATE, SET=[XSIZE, YSIZE, NF], TITLE=TITLE ELSE $
		XINTERANIMATE, SET=[XSIZE, YSIZE, NF]
	XINTERANIMATE, FRAME=0, WINDOW=[TEMPWINDOW,0,0,XSIZE,YSIZE]
;
;  Load the rest of the images.  Disable size messages for additional images.
;
	QUIET = !QUIET
	!QUIET = 1
        FOR I = 1,NF-1 DO BEGIN
		EXPTV,/DISABLE,/NOBOX,IMAGES[*,*,SS[I]],NOSCALE=NOSCALE,$
			MISSING=MISSING,MAX=IMAX,MIN=IMIN,TOP=TOP,BOTTOM=BOTTOM,$
			VELOCITY=VELOCITY,COMBINED=COMBINED,LOWER=LOWER,$
			SIZE=SIZE,SMOOTH=SMOOTH,XALIGN=0
		XINTERANIMATE, FRAME=I, WINDOW=[TEMPWINDOW,0,0,XSIZE,YSIZE]
	ENDFOR
	!QUIET = QUIET
;
;  Delete the temporary window and animate the images.
;
	WSET, CURRWINDOW
	WDELETE, TEMPWINDOW
	XINTERANIMATE, RATE
;
	RETURN
	END
