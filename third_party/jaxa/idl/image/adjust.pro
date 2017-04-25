	FUNCTION ADJUST,ARRAY,MINIMUM=MINIMUM,MAXIMUM=MAXIMUM,MISSING=MISSING
;+
; Project     : SOHO - CDS
;
; Name        : 
;	ADJUST()
; Purpose     : 
;	Adjust the range of an image.
; Explanation : 
;	Adjusts the range of an image.  Basically equivalent to using the
;	">" and "<" operators, except that pixels equal to MISSING are ignored
;	and not changed by this procedure.
; Use         : 
;	Result = ADJUST( ARRAY, <keywords> )
; Inputs      : 
;	ARRAY	= Array to be scaled.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	Result of function is scaled image.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	MINIMUM	= Lower limit to scale image into.  If not passed, then
;		  MIN(ARRAY) is assumed.
;	MAXIMUM	= Upper limit to scale image into.  If not passed, then
;		  MAX(ARRAY) is assumed.
;	MISSING	= Value flagging missing pixels.
; Calls       : 
;	GET_IM_KEYWORD, GOOD_PIXELS
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
;	None.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, March 1991.
;	William Thompson, August 1992, renamed BADPIXEL to MISSING.
; Written     : 
;	William Thompson, GSFC, March 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 14 May 1993.
;		Incorporated into CDS library.
;       Version 2, 11-May-2005, William Thompson, GSFC
;               Handle NaN values
; Version     : 
;	Version 2, 11-May-2005
;-
;
	GET_IM_KEYWORD, MISSING, !IMAGE.MISSING
;
	IF N_ELEMENTS(MINIMUM) EQ 0 THEN MINIMUM = $
          1.*MIN(GOOD_PIXELS(ARRAY, MISSING=MISSING))
;
	IF N_ELEMENTS(MAXIMUM) EQ 0 THEN MAXIMUM = $
          1.*MAX(GOOD_PIXELS(ARRAY, MISSING=MISSING))
;
	RESULT = MINIMUM > ARRAY < MAXIMUM
	IF N_ELEMENTS(MISSING) EQ 1 THEN BEGIN
		W = WHERE(ARRAY EQ MISSING, N_FOUND)
		IF N_FOUND GT 0 THEN RESULT(W) = MISSING
	ENDIF
;
	RETURN, RESULT
	END
