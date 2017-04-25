	PRO PUT,ARRAY,IIX,NNX,IIY,NNY,NOSQUARE=NOSQUARE,SMOOTH=SMOOTH,	$
		NOBOX=NOBOX,NOSCALE=NOSCALE,MISSING=MISSING,SIZE=SIZE,	$
		DISABLE=DISABLE,NOEXACT=NOEXACT,XALIGN=XALIGN,YALIGN=YALIGN, $
		RELATIVE=RELATIVE,COLOR=COLOR,MAX=MAX,MIN=MIN,TOP=TOP,	$
		BOTTOM=BOTTOM,VELOCITY=VELOCITY,COMBINED=COMBINED,LOWER=LOWER,$
		NORMAL=NORMAL,ORIGIN=ORIGIN,SCALE=SCALE,DATA=DATA,	$
		ADJUST=ADJUST,GEOMETRY=GEOMETRY,FRAME=FRAME,TRUE=K_TRUE, $
                BSCALED=BSCALED
;+
; Project     : SOHO - CDS
;
; Name        : 
;	PUT
; Purpose     : 
;	Places one of several images on the image display screen.
; Explanation : 
;	Uses SETIMAGE, SCALE_TV and EXPAND_TV to place an image on the TV
;	display screen.  The image is placed at position IX out of NX from the
;	left and position IY out of NY from the top.
;
;	Will plot true color images if the device has enough colors and if
;	ARRAY is a 3D Array with the third dimension color (red, green, blue).
;	(See also the TRUE keyword.)
;
; Use         : 
;	PUT, ARRAY, II, NN
;	PUT, ARRAY, IX, NX, IY, NY
;	PUT, ARRAY, X1, X2, Y1, Y2, /NORMAL
;
;	Examples: Display the third in a series of five images, and let the
;	computer decide how to arrange the images.  All of the images should be
;	of the same size.
;
;		PUT, image, 3, 5
;
;	In this example, the computer will decide to put the images into one of
;	the following configurations, depending on the size of the screen, and
;	the size of the images.
;
;		1       1 2     1 2 3     1 2 3 4     1 2 3 4 5
;		2       3 4     4 5       5
;		3       5
;		4
;		5
;
;	Display an image as the third of five from the left, and the second of
;	three from the top.
;
;		PUT, image, 3, 5, 2, 3
;
;	Display an image in a box using the top 80% of the screen, with 5%
;	margins on either side.
;
;		PUT, image, 0.05, 0.95, 0.2, 1, /NORMAL
;
; Inputs      : 
;	ARRAY	 = Two dimensional image array to be displayed, or 3 images in 
;		   an array [Nx,Ny,3] to be displayed as a true color image.
;		   (See also the TRUE keyword.)
;
;	Also, either the parameters II, NN or the parameters IX, NX, IY, NY
;	must be passed.
;
; Opt. Inputs : 
;
;	II, NN	 = Relative position within a series of NN images.  The program
;		   chooses how to arrange the images along the X and Y axes
;		   depending on the size of the image and the size of the
;		   window.
;
;		or
;
;	IX, NX	= Relative position along X axis, expressed as position IX
;		  out of a possible NX, from left to right.
;	IY, NY	= Relative position along Y axis, from top to bottom.
;
;		or
;
;	X1, X2	= Coordinates along the X axis of an arbitrary box in
;		  normalized coordinates.  Can have values between 0 and 1.
;	Y1, Y2	= Coordinates along the Y axis of an arbitrary box in
;		  normalized coordinates.  Can have values between 0 and 1.
;
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	NORMAL	 = If set, then the input parameters are in normalized
;		   coordinates.  Otherwise, they refer to the relative position
;		   of the image on the screen in a regular array of images.
;	NOSQUARE = If passed, then pixels are not forced to be square.
;	SMOOTH	 = If passed, then interpolation used in expanding array.
;	NOBOX	 = If passed, then box is not drawn, and no space is reserved
;		   for a border around the image.
;	NOSCALE  = If passed, then the command TV is used instead of TVSCL to
;		   display the image.
;	MISSING	 = Value flagging missing pixels.  These points are scaled to
;		   zero.  Ignored if NOSCALE is set.
;	SIZE	 = If passed and positive, then used to determine the scale of
;		   the image.  Returned as the value of the image scale.  May
;		   not be compatible with /NOSQUARE.
;	DISABLE  = If set, then TVSELECT not used.
;	NOEXACT  = If set, then exact scaling is not imposed.  Otherwise, the
;		   image scale will be either an integer, or one over an
;		   integer.  Ignored if SIZE is passed with a positive value.
;	XALIGN	 = Alignment within the image display area.  Ranges between 0
;		   (left) to 1 (right).  Default is 0.5 (centered).
;	YALIGN	 = Alignment within the image display area.  Ranges between 0
;		   (bottom) to 1 (top).  Default is 0.5 (centered).
;	RELATIVE = Size of area to be used for displaying the image, relative
;		   to the total size available.  Must be between 0 and 1.
;		   Default is 1.  Passing SIZE explicitly will override this
;		   keyword.
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
;	ORIGIN	 = Two-element array containing the coordinate value in
;		   physical units of the center of the first pixel in the
;		   image.  If not passed, then [0,0] is assumed.
;	SCALE	 = Pixel scale in physical units.  Can have either one or two
;		   elements.  If not passed, then 1 is assumed in both
;		   directions.
;	DATA	 = If set, then immediately activate the data coordinates for
;		   the displayed image.
;	ADJUST	 = If set, then adjust the pixel size separately in the two
;		   dimensions, so that the physical scale given by the SCALE
;		   parameter is the same along both axes.  For example, if a
;		   100x100 image is displayed with
;
;			PUT, A, SCALE=[2,1], /ADJUST
;
;		   then it will be shown twice as wide as it is high.  Use of
;		   this keyword forces NOEXACT to also be set.  Also, NOSQUARE
;		   is ignored.
;	GEOMETRY = Returns the geometry used to display the image.  Of most use
;		   when called with the "PUT, ARRAY, II, NN" calling sequence.
;		   The returned value of GEOMETRY is an array containing the
;		   calculated parameters IX,NX,IY,NY.
;	FRAME	 = A four-element vector which contains the corners of the area
;		   in which all of the images will appear, in normalized
;		   coordinates.  The first two numbers are the minimum and
;		   maximum X coordinates, and the second two numbers are the Y
;		   coordinates.  For example, if one wants to reserve the lower
;		   20% of the window for a label, then one can set FRAME to
;
;			PUT, IMAGE, II, NN, FRAME=[0, 1, 0.2, 1]
;
;		   The FRAME keyword is only used when PUT is called with three
;		   parameters as above, and is ignored in the five parameter
;		   call.  However, the same behavior can be obtained in the
;		   five parameter mode by using fractional values, e.g.
;
;			PUT, IMAGE, 1, 3, 2, 2.5
;
;	TRUE	 = If passed, then contains the dimension containing the color
;		   dimension.  For example, if the input array has the
;		   dimensions (3,Nx,Ny), then one would set TRUE=1.  If not
;		   passed, then TRUE=3 is assumed.  Ignored if the image only
;		   has two dimensions.
;       BSCALED  = Returns the bytescaled image passed to the TV command.
;
; Calls       : 
;	EXPAND_TV, GET_IM_KEYWORD, SCALE_TV, SETIMAGE, TRIM, TVSELECT,
;	TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
;	ARRAY must be two-dimensional.  If /NORMAL is set, then X1, X2, Y1, Y2
;	must be between 0 and 1.  Otherwise, IX must be between 1 and NX, and
;	(if passed) IY must be between 1 and NY.
;
;	If the II, NN option is used, then II must be between 1 and NN.  This
;	option really only works if all the images to be displayed are the same
;	size.
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
;	SETIMAGE is set to the portion of the window the image is displayed in.
;
;	Messages about the size and position of the displayed image are printed
;	to the terminal screen.  This can be turned off by setting !QUIET to 1.
;
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	W.T.T., Oct. 1987.
;	W.T.T., Jan. 1991, added BADPIXEL keyword.
;	W.T.T., Feb. 1991, modified to use SETIMAGE.
;	W.T.T., Feb. 1991, added SIZE keyword.
;	W.T.T., Mar. 1991, this used to be PLACE_TV, and PUT was somewhat
;			   different.
;	W.T.T., Mar. 1991, added NOEXACT keyword.
;	W.T.T., Nov. 1991, added MAX, MIN, and TOP keywords.
;	W.T.T., Nov. 1991, added INTENSITY, VELOCITY and COMBINED keywords.
;	W.T.T., Jan. 1992, changed SETIMAGE behavior, and added RETAIN keyword.
;	W.T.T., Feb. 1992, added LOWER keyword.
;	W.T.T., Feb. 1992, returned SETIMAGE behavior to the way it was before.
;	William Thompson, August 1992, renamed BADPIXEL to MISSING.
;	William Thompson, September 1992, use COMBINED keyword in place of
;					  INTENSITY.
;	William Thompson, Oct. 1992, changed strategy used when II,NN are
;				     passed instead of IX,NX,IY,NY.
;	William Thompson, November 1992, added /NORMAL keyword.
; Written     : 
;	William Thompson, October 1987.
; Modified    : 
;	Version 1, William Thompson, GSFC, 12 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 24 June 1993.
;		Fixed problem with /NORMAL keyword.
;	Version 3, William Thompson, GSFC, 2 September 1993.
;		Added ORIGIN, SCALE and DATA keywords.
;	Version 4, William Thompson, GSFC, 25 July 1996
;		Added keywords SCALE and ADJUST
;	Version 5, William Thompson, GSFC, 25 July 1997
;		Added keyword FRAME
;	Version 6, William Thompson, GSFC, 22-Oct-1997
;		Take /ADJUST into account when arranging images.
;	Version 7, William Thompson, GSFC, 13 November 2001
;		Added capability for true-color images.
;       Version 8, William Thompson, GSFC, 12 October 2004
;               Extend true-color to PostScript
;       Version 9, William Thompson, GSFC, 3-Jan-2006
;               Added keyword BOTTOM
;       Version 10, William Thompson, GSFC, 26-Sep-2006
;               Added keyword BSCALED
; Version     : 
;	Version 10, 26-Sep-2006
;-
;
	ON_ERROR,2
	GET_IM_KEYWORD, MISSING, !IMAGE.MISSING
;
;  Check the dimensions of ARRAY.
;
	S = SIZE(ARRAY)
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
	ARRAY_TYPE = S(S(0) + 1)
	IF (S(0) NE 2) AND (SZ NE 3) THEN MESSAGE,		$
		'ARRAY must be two-dimensional or an array of three 2D images' 
        IF (SZ EQ 3) AND (!D.N_COLORS LE 256) AND (!D.NAME NE 'PS') THEN $
          MESSAGE, 'This screen cannot show true color images.'
;
;  Check the number of parameters.  If only three, then choose how to arrange
;  along the X and Y axes based on the size of the image and the size of the
;  window.
;
	IF N_PARAMS(0) EQ 3 THEN BEGIN
	    IF KEYWORD_SET(NORMAL) THEN MESSAGE,	$
		    '/NORMAL can only be used if X1,X2,Y1,Y2 are passed'
	    IF NNX LT 1 THEN MESSAGE,'NX should be GE 1'
	    IF (IIX LT 1) OR (IIX GT NNX) THEN MESSAGE,	$
		    'IX should be between 1 and ' + TRIM(NX)
	    TVSELECT,DISABLE=DISABLE
;
;  If the frame parameter was set, then calculate the size of the box that the
;  image can be put into.
;
	    IF N_ELEMENTS(FRAME) EQ 4 THEN BEGIN
		IF (FRAME(0) LT 0) OR (FRAME(1) GT 1) OR (FRAME(2) LT 0) OR $
			(FRAME(3) GT 1) OR (FRAME(1) LE FRAME(0)) OR	$
			(FRAME(3) LE FRAME(2)) THEN MESSAGE,	$
			'FRAME must be in normalized coordinates'
		XSIZE = (FRAME(1)-FRAME(0)) * !D.X_SIZE
		YSIZE = (FRAME(3)-FRAME(2)) * !D.Y_SIZE
	    END ELSE BEGIN
		XSIZE = !D.X_SIZE
		YSIZE = !D.Y_SIZE
	    ENDELSE
;
;  If /ADJUST was set, then determine how it affects the placement of the
;  images.
;
	    IF KEYWORD_SET(ADJUST) THEN BEGIN
		CASE N_ELEMENTS(SCALE) OF
		    0: BEGIN
			XSCALE = 1
			YSCALE = 1
			END
		    1: BEGIN
			XSCALE = ABS(SCALE)
			YSCALE = ABS(SCALE)
			END
		    2: BEGIN
			XSCALE = ABS(SCALE(0))
			YSCALE = ABS(SCALE(1))
			END
		ENDCASE
	    END ELSE BEGIN
		XSCALE = 1
		YSCALE = 1
	    ENDELSE
;
;  Figure out how to best arrange the images in this space.
;
	    NX = NNX
	    NY = 1
	    AMAX = 0
	    FOR NI = 1,NNX DO BEGIN
		NJ = (NNX + NI - 1) / NI
		AX = XSIZE / (SX*FLOAT(NI)*XSCALE)
		AY = YSIZE / (SY*FLOAT(NJ)*YSCALE)
		AA = AX < AY
		IF AA GT AMAX THEN BEGIN
		    AMAX = AA
		    NX = NI
		    NY = NJ
		ENDIF
	    ENDFOR
	    IX = ((IIX - 1) MOD NX) + 1
	    IY = (IIX - 1)/NX + 1
	    TVUNSELECT,DISABLE=DISABLE
;
;  If FRAME was passed, then modify the parameters.
;
	    IF N_ELEMENTS(FRAME) EQ 4 THEN BEGIN
		IX = IX + FRAME(0)*NX / (FRAME(1) - FRAME(0))
		IY = IY + (1-FRAME(3))*NY / (FRAME(3) - FRAME(2))
		NX = NX / (FRAME(1) - FRAME(0))
		NY = NY / (FRAME(3) - FRAME(2))
	    ENDIF
;
;  Otherwise, there have to be five parameters passed.
;
	END ELSE IF N_PARAMS(0) NE 5 THEN BEGIN
	    PRINT,'*** PUT must be called with three or five parameters:'
	    PRINT,'               ARRAY, II, NN
	    PRINT,'               ARRAY, IX, NX, IY, NY'
	    RETURN
	END ELSE BEGIN
	    IX = IIX  &  NX = NNX
	    IY = IIY  &  NY = NNY
	ENDELSE
;
;  Check the parameters IX, NX and IY, NY.
;
	IF KEYWORD_SET(NORMAL) THEN BEGIN
	    IF (IX LT 0) OR (IX GT 1) THEN MESSAGE,	$
		    'X1 should be between 0 and 1'
	    IF (NX EQ IX) THEN MESSAGE, 'X1 and X2 must not be equal'
	    IF (NX LT IX) OR (NX GT 1) THEN MESSAGE, $
		    'X2 should be between X1 and 1'
	    IF (IY LT 0) OR (IY GT 1) THEN MESSAGE,	$
		    'Y1 should be between 0 and 1'
	    IF (NY EQ IY) THEN MESSAGE, 'Y1 and Y2 must not be equal'
	    IF (NY LT IY) OR (NY GT 1) THEN MESSAGE, $
		    'Y2 should be between Y1 and 1'
	END ELSE BEGIN
	    IF (NX LT 1) OR (NY LT 1) THEN MESSAGE,'NX, NY should be GE 1'
	    IF (IX LT 1) OR (IX GT NX) THEN MESSAGE,	$
		    'IX should be between 1 and ' + TRIM(NX)
	    IF (IY LT 1) OR (IY GT NY) THEN MESSAGE,	$
		    'IY should be between 1 and ' + TRIM(NY)
	ENDELSE
;
;  Call SETIMAGE and SCALE_TV to calculate MX, MY and JX, JY.
;
	SETIMAGE,IX,NX,IY,NY,NORMAL=NORMAL
	SCALE_TV,ARRAY,MX,MY,JX,JY,NOSQUARE=NOSQUARE,SIZE=SIZE,NOBOX=NOBOX, $
		DISABLE=DISABLE,NOEXACT=NOEXACT,XALIGN=XALIGN,YALIGN=YALIGN,$
		RELATIVE=RELATIVE,SCALE=SCALE,ADJUST=ADJUST,TRUE=K_TRUE
;
;  Call EXPAND_TV to display the image.
;
	EXPAND_TV,ARRAY,MX,MY,JX,JY,SMOOTH=SMOOTH,NOBOX=NOBOX,		$
		NOSCALE=NOSCALE,MISSING=MISSING,DISABLE=DISABLE,	$
		COLOR=COLOR,MAX=MAX,MIN=MIN,TOP=TOP,BOTTOM=BOTTOM,      $
                VELOCITY=VELOCITY,COMBINED=COMBINED,LOWER=LOWER,        $
                ORIGIN=ORIGIN,SCALE=SCALE,DATA=DATA,TRUE=K_TRUE,        $
                BSCALED=BSCALED
;
;  Return the geometry.
;
	GEOMETRY = [IX,NX,IY,NY]
;
	RETURN
	END
