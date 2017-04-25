	PRO TVBOXCRS,XX1,XX2,YY1,YY2,P0,P1,P2,P3,P4,P5,DISABLE=DISABLE,	$
		INIT=INIT,FIXED_SIZE=FIXED_SIZE
;+
; Project     : SOHO - CDS
;
; Name        : 
;	TVBOXCRS
; Purpose     : 
;	Interactively select a box on displayed images.
; Explanation : 
;	SELECT_BOX is called to select a box on a displayed image.
; Use         : 
;	TVBOXCRS, [ X1, X2, Y1, Y2 [, PRINT_SWITCH ]] [, IMAGE, MX, MY, IX, IY ]
; Inputs      : 
;	None required.
; Opt. Inputs : 
;	PRINT_SWITCH	= Switch used to control printing the values of
;			  X1,X2,Y1,Y2 to the screen.  If not passed, then
;			  assumed 0 (no printing) unless X1,X2 and Y1,Y2 are
;			  not passed, in which case 1 (printing) is assumed.
;
;	IMAGE		= The image to find positions on.
;	MX, MY		= Size of displayed image.
;	IX, IY		= Position of the lower left-hand corner of the image.
;
;	If the last five optional parameters are not passed, then they are
;	retrieved with GET_TV_SCALE.  It is anticipated that these optional
;	parameters will only be used in extremely rare circumstances.
;
; Outputs     : 
;	None required.  IF the output parameters are not passed, then their
;	values are printed to the screen.
; Opt. Outputs: 
;	X1,X2,Y1,Y2	= The X,Y positions of the corners of the selected box.
; Keywords    : 
;	DISABLE    = If set, then TVSELECT not used.
;
;	The following keywords are only relevant when used on a graphics device
;	that supports windows:
;
;	INIT	   = If this keyword is set, X1, X2, and Y1, Y2 contain the
;		     initial parameters for the box.
;
;	FIXED_SIZE = If this keyword is set, X1, X2, and Y1, Y2 describe the
;		     initial size of the box.  This size may not be changed by
;		     the user.
;
; Calls       : 
;	GET_TV_SCALE, SELECT_BOX, TRIM, TVSELECT, TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
;	It is important that the user select the graphics device/window, and
;	image region before calling this routine.  For instance, if the image
;	was displayed using EXPTV,/DISABLE, then this routine should also be
;	called with the /DISABLE keyword.  If multiple images are displayed
;	within the same window, then use SETIMAGE to select the image before
;	calling this routine.
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
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, Nov. 1992.
; Written     : 
;	William Thompson, GSFC, November 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 11 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 25 June 1993.
;		Added INIT and FIXED_SIZE keywords.
;	Version 3, William Thompson, GSFC, 17 January 1997
;		Renamed to TVBOXCRS to avoid conflict with Astron routine
;		called TVBOX.
; Version     : 
;	Version 3, 17 January 1997
;-
;
	ON_ERROR,2
;
;  Parse the input parameters.
;
	CASE N_PARAMS(0) OF
		0:  BEGIN
			PASSED_XY = 0
			PRINT_SWITCH = 1
			PASSED_MI = 0
			END
		4:  BEGIN
			PASSED_XY = 1
			PRINT_SWITCH = 0
			PASSED_MI = 0
			END
		5:  BEGIN
			PASSED_XY = 1
			PRINT_SWITCH = P0
			PASSED_MI = 0
			END
		7:  BEGIN
			PASSED_XY = 0
			PRINT_SWITCH = 1
			PASSED_MI = 1
			S = SIZE(XX1)
			IF S(0) NE 2 THEN MESSAGE,	$
				'IMAGE must be two-dimensional'
			SX = S(1)
			SY = S(2)
			MX = XX2
			MY = YY1
			IX = YY2
			IY = P0
			END
		9:  BEGIN
			PASSED_XY = 1
			PRINT_SWITCH = 0
			PASSED_MI = 1
			S = SIZE(P0)
			IF S(0) NE 2 THEN MESSAGE,	$
				'IMAGE must be two-dimensional'
			SX = S(1)
			SY = S(2)
			MX = P1
			MY = P2
			IX = P3
			IY = P4
			END
		10:  BEGIN
			PASSED_XY = 1
			PRINT_SWITCH = P0
			PASSED_MI = 1
			S = SIZE(P1)
			IF S(0) NE 2 THEN MESSAGE,	$
				'IMAGE must be two-dimensional'
			SX = S(1)
			SY = S(2)
			MX = P2
			MY = P3
			IX = P4
			IY = P5
			END
		ELSE:  BEGIN
			PRINT,'*** TVBOXCRS must be called with 0-10 parameters:'
			PRINT,'	[ X1, X2, Y1, Y2  [, PRINT_SWITCH ]]  [, IMAGE, MX, MY, IX, IY ]'
			RETURN
			END
	ENDCASE
;
;  Scale image if necessary.
;
	IF NOT PASSED_MI THEN GET_TV_SCALE,SX,SY,MX,MY,IX,IY,DISABLE=DISABLE
;
;  Check to see if image was properly scaled.
;
	IF ((MX LE 1) OR (MY LE 1)) THEN BEGIN
		PRINT,'*** The dimensions MX,MY must be > 1, routine TVBOXCRS.'
		GOTO, EXIT_POINT
	ENDIF
;
;  Select the image display device or window.
;
	TVSELECT, DISABLE=DISABLE
;
;  If either the INIT or FIXED SIZE keywords were set, then convert them into
;  device coordinates.
;
	IF KEYWORD_SET(INIT) OR KEYWORD_SET(FIXED_SIZE) THEN BEGIN
		NX = FLOAT(MX) / SX
		NY = FLOAT(MY) / SY
		X1 = NX*XX1 + IX  &  X2 = NX*XX2 + IX
		Y1 = NY*YY1 + IY  &  Y2 = NY*YY2 + IY
		WX = ABS(X2 - X1)  &  X1 = X1 < X2
		WY = ABS(Y2 - Y1)  &  Y1 = Y1 < Y2
	ENDIF
;
;  Read in the cursor position.
;
	SELECT_BOX,WX,WY,X1,Y1,INIT=INIT,FIXED_SIZE=FIXED_SIZE
	X2 = X1 + WX
	Y2 = Y1 + WY
;
;  Convert device position into data position.
;
	NX = FLOAT(MX) / SX
	NY = FLOAT(MY) / SY
	X1 = (X1 - IX) / NX
	X2 = (X2 - IX) / NX
	Y1 = (Y1 - IY) / NY
	Y2 = (Y2 - IY) / NY
	IF !ORDER NE 0 THEN BEGIN
		Y1 = SY - Y1 - 1
		Y2 = SY - Y2 - 1
	ENDIF
	IF PRINT_SWITCH NE 0 THEN PRINT,' Box:  (' + TRIM(X1) + ' : ' +	$
		TRIM(X2) + ',  ' + TRIM(Y1) + ' : ' + TRIM(Y2) + ')'
	IF PASSED_XY THEN BEGIN
		XX1 = X1
		XX2 = X2
		YY1 = Y1
		YY2 = Y2
	ENDIF
;
EXIT_POINT:
	TVUNSELECT, DISABLE=DISABLE
	RETURN
	END
