	PRO SHOW_MOVIE, IMAGES, RATE, NOSCALE=NOSCALE
;+
; Project     :	SOHO - CDS
;
; Name        :	SHOW_MOVIE
;
; Purpose     :	Uses XINTERANIMATE to show a movie.
;
; Category    :	Class1, Animation
;
; Explanation :	This is a simple routine to display a movie using
;		XINTERANIMATE.  It's meant to stand alone, without the need of
;		any other routines except those in the standard IDL
;		distribution.
;
; Syntax      :	SHOW_MOVIE, IMAGES  [, RATE ]
;
; Examples    :	
;
; Inputs      :	IMAGES	= Three dimensional array of images, with the
;			  dimensions (NX, NY, N_FRAMES)
;
; Opt. Inputs :	RATE	= Optional rate of display.  The rate is a value
;			  between 0 and 100 that gives the speed that the
;			  animation is displayed.  The fastest animation is
;			  with a value of 100 and the slowest is with a value
;			  of 0.  The default value is 100 if not specified.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	NOSCALE	= If set, then the images are not scaled before
;			  displaying.
;
; Calls       :	BYTSCL, XINTERANIMATE
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 02-May-1997, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR, 2
;
;  Check the input parameters.
;
	IF N_PARAMS() EQ 0 THEN MESSAGE, 'Syntax:  SHOW_MOVIE, IMAGES'
;
;  Get the size of the input array.
;
	SZ = SIZE(IMAGES)
	IF SZ(0) NE 3 THEN MESSAGE, 'IMAGES must be three-dimensional'
;
;  If RATE is not passed, then use a rate of 100.
;
	IF N_PARAMS() NE 2 THEN RATE = 100
;
;  Set up XINTERANIMATE
;
	XINTERANIMATE, SET=SZ(1:3), /SHOWLOAD
;
;  Scale the images, and load the frames.
;
	IF KEYWORD_SET(NOSCALE) THEN A = IMAGES ELSE	$
		A = BYTSCL(IMAGES, TOP=!D.TABLE_SIZE-1)
	FOR I=0,SZ(3)-1 DO XINTERANIMATE, FRAME=I, IMAGE=A(*,*,I)
;
;  Display the movie.
;
	XINTERANIMATE, RATE
;
	RETURN
	END
