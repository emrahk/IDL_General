	PRO OPLOT_IMAGE,IMAGE,ORIGIN=ORIGIN,SCALE=SCALE,SMOOTH=SMOOTH,	$
		NOSCALE=NOSCALE,MISSING=MISSING,COLOR=COLOR,MAX=MAX,	$
		MIN=MIN,TOP=TOP,BOTTOM=BOTTOM,VELOCITY=VELOCITY,        $
                COMBINED=COMBINED,LOWER=LOWER,TRUE=K_TRUE,BSCALED=BSCALED
;+
; Project     : SOHO - CDS
;
; Name        : 
;	OPLOT_IMAGE
; Purpose     : 
;	Overplot an image.
; Explanation : 
;	Displays images over pre-existing plots.  The concept is to make
;	displaying an image a graphics command, like OPLOT or OCONTOUR.  Then
;	the special TV calls don't have to be used.
;
;	Will plot true color images if the device has enough colors and if
;	IMAGE is a 3D Array with the third dimension color (red, green, blue).
;	(See also the TRUE keyword.)
;
; Use         : 
;	OPLOT_IMAGE, IMAGE
; Inputs      : 
;	IMAGE	 = Two dimensional image array to be displayed, or 3 images in 
;		   an array [Nx,Ny,3] to be displayed as a true color image.
;		   (See also the TRUE keyword.)
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	ORIGIN	 = Two-element array containing the coordinate value in
;		   physical units of the center of the first pixel in the
;		   image.  If not passed, then [0,0] is assumed.
;	SCALE	 = Pixel scale in physical units.  Can have either one or two
;		   elements.  If not passed, then 1 is assumed in both
;		   directions.
;	SMOOTH	 = If set, then the image is expanded with bilinear
;		   interpolation.
;	NOSCALE  = If set, then the command TV is used instead of TVSCL to
;		   display the image.
;	MISSING	 = Value flagging missing pixels.  These points are scaled to
;		   zero.  Ignored if NOSCALE is set.
;	COLOR	 = Color used for drawing the box around the image.
;	MAX	 = The maximum value of ARRAY to be considered in scaling the
;		   image, as used by BYTSCL.  The default is the maximum value
;		   of ARRAY.
;	MIN	 = The minimum value of ARRAY to be considered in scaling the
;		   image, as used by BYTSCL.  The default is the minimum value
;		   of ARRAY.
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
;	TRUE	 = If passed, then contains the dimension containing the color
;		   dimension.  For example, if the input array has the
;		   dimensions (3,Nx,Ny), then one would set TRUE=1.  If not
;		   passed, then TRUE=3 is assumed.  Ignored if the image only
;		   has two dimensions.
;       BSCALED  = Returns the bytescaled image passed to the TV command.
;
; Calls       : 
;	EXPAND_TV
; Common      : 
;	None.
; Restrictions: 
;	The graphics device must be capable of displaying images.
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
;	Messages about the size and position of the displayed image are printed
;	to the terminal screen.  This can be turned off by setting !QUIET to 1.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, May 1992.
;	William Thompson, August 1992, renamed BADPIXEL to MISSING.
;	William Thompson, September 1992, use COMBINED keyword in place of
;		INTENSITY.
;	William Thompson, October 1992, modified so that keyword ORIGIN refers
;		to the center of the first pixel, rather than to the lower left
;		corner.
; Written     : 
;	William Thompson, GSFC, May 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 13 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 9 November 1993.
;		Removed restriction that scales be positive.
;	Version 3, William Thompson, GSFC, 26 December 1995
;		Removed NOSTORE keyword from EXPAND_TV call.
;	Version 4, William Thompson, GSFC, 13 November 2001
;		Added capability for true-color images.
;       Version 5, William Thompson, GSFC, 12 October 2004
;               Extend true-color to PostScript
;       Version 6, William Thompson, GSFC, 3-Jan-2006
;               Added keyword BOTTOM
;       Version 7, William Thompson, GSFC, 26-Sep-2006
;               Added keyword BSCALED
; Version     : 
;	Version 7, 26-Sep-2006
;-
;
	ON_ERROR,2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE,'Syntax:  OPLOT_IMAGE, IMAGE'
;
;  Check the image size.
;
	S = SIZE(IMAGE)
	SX = S(1)
	SY = S(2)
	SZ = 0
        IF S(0) EQ 3 THEN BEGIN
	    IF N_ELEMENTS(K_TRUE) EQ 1 THEN TRUE=K_TRUE ELSE TRUE=3
	    CASE TRUE OF
		1:  BEGIN
		    SX = S(2)
		    SY = S(3)
		    SZ = S(1)
		    END
		2:  BEGIN
		    SX = S(1)
		    SY = S(3)
		    SZ = S(2)
		    END
		ELSE: BEGIN
		    TRUE = 3
		    SX = S(1)
		    SY = S(2)
		    SZ = S(3)
		    END
	    ENDCASE
	ENDIF
	IF (S(0) NE 2) AND (SZ NE 3) THEN MESSAGE,		$
		'IMAGE must be two-dimensional or an array of three 2D images' 
        IF (SZ EQ 3) AND (!D.N_COLORS LE 256) AND (!D.NAME NE 'PS') THEN $
          MESSAGE, 'This screen cannot show true color images.'
;
;  Get the image origin.
;
	IF N_ELEMENTS(ORIGIN) EQ 0 THEN BEGIN
		ORIGIN = [0,0]
	END ELSE IF N_ELEMENTS(ORIGIN) NE 2 THEN BEGIN
		MESSAGE,'ORIGIN must have two elements'
	ENDIF
;
;  Get the image scale.
;
	CASE N_ELEMENTS(SCALE) OF
		0:  BEGIN
			XSCALE = 1
			YSCALE = 1
			END
		1:  BEGIN
			XSCALE = SCALE
			YSCALE = SCALE
			END
		2: BEGIN
			XSCALE = SCALE(0)
			YSCALE = SCALE(1)
			END
	ENDCASE
;
;  Set the image display parameters, and display the image.
;
	XS = !X.S * !D.X_SIZE
	YS = !Y.S * !D.Y_SIZE
	MX = XS(1)*SX*XSCALE
	MY = YS(1)*SY*YSCALE
	IX = XS(0) + (ORIGIN(0) - XSCALE/2.)*XS(1)
	IY = YS(0) + (ORIGIN(1) - YSCALE/2.)*YS(1)
;
	IM = IMAGE
	IF MX LT 0 THEN BEGIN
		MX = ABS(MX)
		IX = IX - MX
		IM = REVERSE(IM,1)
	ENDIF
	IF MY LT 0 THEN BEGIN
		MY = ABS(MY)
		IY = IY - MX
		IM = REVERSE(IM,2)
	ENDIF
	EXPAND_TV,IM,MX,MY,IX,IY,SMOOTH=SMOOTH,/NOBOX,NOSCALE=NOSCALE,	$
		MISSING=MISSING,/DISABLE,COLOR=COLOR,MAX=MAX,MIN=MIN,	$
		TOP=TOP,BOTTOM=BOTTOM,VELOCITY=VELOCITY,COMBINED=COMBINED, $
                LOWER=LOWER,TRUE=K_TRUE,BSCALED=BSCALED
;
	RETURN
	END
