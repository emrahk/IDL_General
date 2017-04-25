;+
; Project     : SOHO - CDS
;
; Name        : 
;	SETVIEW
; Purpose     : 
;	Switch between several plots on one page.
; Explanation : 
;	SETVIEW modifies the viewport parameters !P.POSITION to allow several
;	plots on one page, arranged horizontally and/or vertically.
;
;	Calling SETVIEW with nontrivial parameters also sets !P.NOERASE to 1.
;	New plots must be started with an explicit ERASE command.
; 
;	Calling SETVIEW without any parameters, or IX,NX and IY,NY all equal
;	to 1 resets the viewport, and sets !P.NOERASE to 0.
;
;	Recalling SETVIEW with the same parameters as before will restore the
;	system variables associated with that setting.  This allows the user to
;	switch between several plots without losing the scaling information
;	associated with each.  Note that when switching between windows that
;	both WSET and SETVIEW must be called each time for this to work.
;	Alternatively, SETWINDOW can be used to switch between windows.
; 
; Use         : 
;	SETVIEW  [, IX, NX  [, IY, NY  [, SX  [, SY ]]]]
; Inputs      : 
;	None required.  Calling SETVIEW without any parameters resets to the
;	default behavior.
; Opt. Inputs : 
;	IX, NX	= Relative position along X axis, expressed as position IX
;		  out of a possible NX, from left to right.  If not passed,
;		  then 1,1 is assumed. 
;	IY, NY	= Relative position along Y axis, from top to bottom.  If
;		  not passed, then 1,1 is assumed. 
;	SX	= Multiplication factor for space between plots in X 
;		  direction.  A value of SX between 0 and 1 decreases the 
;		  amount of space between plots, a value greater than 1 
;		  increases the amount of space.  If not passed, then 1 is 
;		  assumed.
;	SY	= Multiplication factor for space between plots in Y 
;		  direction.  If not passed, then 1 is assumed.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	None.
; Calls       : 
;	ADD_VIEWPORT, SETSCALE, TRIM
; Common      : 
;	VIEWPORT  = Contains data to maintain information about the viewports
;		    as a function of graphics device and window.
; Restrictions: 
;	IX must be between 1 and NX.  IY must be between 1 and NY.
;
;	SX and SY must not be negative.
;
;	This routine must be called separately for each graphics device.
;
;	In general, the SERTS graphics devices routines use the special system
;	variables !BCOLOR and !ASPECT.  These system variables are defined in
;	the procedure DEVICELIB.  It is suggested that the command DEVICELIB be
;	placed in the user's IDL_STARTUP file.
;
; Side effects: 
;	The system variable !P.NOERASE is changed.
;
;	Any SETSCALE settings will be lost.
;
; Category    : 
;	Utilities, Devices.
; Prev. Hist. : 
;	William Thompson	Applied Research Corporation
;	September, 1988		8201 Corporate Drive
;				Landover, MD  20785
;
;	William Thompson, Nov 1992, changed common block to allow system
;				    variables to be saved between multiple
;				    plots.  Also added call to disable
;				    possible SETSCALE settings.
; Written     : 
;	William Thompson, GSFC, September 1988.
; Modified    : 
;	Version 1, William Thompson, GSFC, 27 April 1993
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 4 January 1994
;		Fixed bug where original state was not being completely
;		restored.
;	Version 3, William Thompson, GSFC, 19 August 1996
;		Removed requirement that IX, NX, IY, NY be integer.
;	Version 4, William Thompson, GSFC, 30 January 1997
;		Fixed bug involving resizing windows.
;	Version 5, 05-Apr-1999, William Thompson, GSFC
;		Modified to properly manipulate !P.POSITION
; Version     : 
;	Version 5, 05-Apr-1999
;-
;
;******************************************************************************
;  ****    ****    ****    ****    ****    ****    ****    ****    ****    ****
;******************************************************************************
	PRO ADD_VIEWPORT, SETTING, SV
;
;  Called from SETVIEW.  Used to add devices to the VIEWPORT common block.
;
	ON_ERROR,1
	COMMON VIEWPORT,NAMES,SET,XMARGIN,YMARGIN,SETTINGS,SAVE,SETTING0
;
;  Check to see if the common block variables have been initialized.  Either
;  initialize the common block with this device, or add this device to the
;  common block.
;
	IF N_ELEMENTS(SETTINGS) EQ 0 THEN BEGIN
		SETTINGS = SETTING
		SAVE = SV
	END ELSE BEGIN
		SETTINGS = [SETTINGS,SETTING]
		SAVE = [SAVE,SV]
	ENDELSE
;
	RETURN
	END
;******************************************************************************
;  ****    ****    ****    ****    ****    ****    ****    ****    ****    ****
;******************************************************************************
	PRO SETVIEW,IXX,NXX,IYY,NYY,SX,SY
;
	ON_ERROR,2
	COMMON VIEWPORT,NAMES,SET,XMARGIN,YMARGIN,SETTINGS,SAVE,SETTING0
;
;  Interpret the input variables.
;
	IF N_PARAMS(0) EQ 0 THEN BEGIN
		IX = 1
		NX = 1
		IY = 1
		NY = 1
	END ELSE IF N_PARAMS(0) EQ 2 THEN BEGIN
		IX = IXX
		NX = NXX
		IY = 1
		NY = 1
	END ELSE IF N_PARAMS(0) GE 4 THEN BEGIN
		IX = IXX
		NX = NXX
		IY = IYY
		NY = NYY
	END ELSE BEGIN
		PRINT,'*** SETVIEW must be called with up to six parameters:'
		PRINT,'        [ IX, NX  [, IY, NY  [, SX  [, SY ]]]]'
		RETURN
	ENDELSE
	IF N_PARAMS(0) LT 5 THEN SX = 1
	IF N_PARAMS(0) LT 6 THEN SY = 1
;
;  Check the input parameters.
;
	IF NX LT 1 THEN BEGIN
		PRINT,'*** NX must be GE 1, routine SETVIEW.'
		RETURN
	END ELSE IF NY LT 1 THEN BEGIN
		PRINT,'*** NY must be GE 1, routine SETVIEW.'
		RETURN
	END ELSE IF (IX LT 1) OR (IX GT NX) THEN BEGIN
                PRINT,'*** IX must be in the range 1 to ' + TRIM(NX) + $
                        ', routine SETVIEW.'
		RETURN
	END ELSE IF (IY LT 1) OR (IY GT NY) THEN BEGIN
                PRINT,'*** IY must be in the range 1 to ' + TRIM(NY) + $
                        ', routine SETVIEW.'
		RETURN
	ENDIF
;
;  Disable any SETSCALE settings.
;
	SETSCALE
;
;  Check to see if the common block variables have been initialized.
;
	IF N_ELEMENTS(NAMES) EQ 0 THEN BEGIN
		NAMES	= !D.NAME
		SET	= 0.
		XMARGIN	= FLTARR(2)
		YMARGIN	= FLTARR(2)
	ENDIF
;
;  Get the number of the current plotting device.
;
	I_DEVICE = WHERE(NAMES EQ !D.NAME,N_FOUND)
	IF N_FOUND EQ 0 THEN BEGIN
		NAMES	= [NAMES, !D.NAME]
		SET	= [SET,0.]
		XMARGIN	= [[XMARGIN],[FLTARR(2)]]
		YMARGIN	= [[YMARGIN],[FLTARR(2)]]
		I_DEVICE = WHERE(NAMES EQ !D.NAME)
	ENDIF
	I_DEVICE = I_DEVICE(0)
;
;  Check to see if the screen coordinates have been stored for the currently 
;  selected device.
;
	IF SET(I_DEVICE) EQ 0 THEN BEGIN
		IF !P.CHARSIZE LE 0 THEN CHARSIZE = 1 ELSE CHARSIZE=!P.CHARSIZE
		XMARGIN(0,I_DEVICE) = !X.MARGIN * CHARSIZE
		YMARGIN(0,I_DEVICE) = !Y.MARGIN * CHARSIZE
	ENDIF
;
;  Save the current settings into SV.
;
	SV = {SV_VIEW,	REGION:	 !P.REGION,	$
			CLIP:	 !P.CLIP,	$
			XTYPE:	 !X.TYPE,	$
			XCRANGE: !X.CRANGE,	$
			XS:	 !X.S,		$
			XWINDOW: !X.WINDOW,	$
			XREGION: !X.REGION,	$
			YTYPE:	 !Y.TYPE,	$
			YCRANGE: !Y.CRANGE,	$
			YS:	 !Y.S,		$
			YWINDOW: !Y.WINDOW,	$
			YREGION: !Y.REGION,	$
			ZTYPE:	 !Z.TYPE,	$
			ZCRANGE: !Z.CRANGE,	$
			ZS:	 !Z.S,		$
			ZWINDOW: !Z.WINDOW,	$
			ZREGION: !Z.REGION,	$
			X_SIZE:	 !D.X_SIZE,	$
			Y_SIZE:	 !D.Y_SIZE}
;
;  Check to see if the VIEWPORT common block has been initialized.
;
	IF N_ELEMENTS(SETTING0) EQ 0 THEN SETTING0 = !D.NAME + ',' +	$
		TRIM(!D.WINDOW) + ',1,1,1,1,1,1'
	IF N_ELEMENTS(SETTINGS) EQ 0 THEN ADD_VIEWPORT,SETTING0,SV
;
;  Get the number of the current setting, and store the current parameters.
;
	I_SETTING = WHERE(SETTINGS EQ SETTING0, N_FOUND)
	IF N_FOUND EQ 0 THEN BEGIN
		ADD_VIEWPORT, SETTING0, SV
		I_SETTING = WHERE(SETTINGS EQ SETTING0)
	ENDIF
;
;  Only store the settings if the window size has not changed since the last
;  call.
;
	TEMP = SAVE(I_SETTING(0))
	IF (TEMP.X_SIZE EQ !D.X_SIZE) AND (TEMP.Y_SIZE EQ !D.Y_SIZE) THEN $
		SAVE(I_SETTING(0)) = SV
;
;  Translate XMARGIN and YMARGIN into the plot corners X0, X1, Y0 and Y1.
;
	X = XMARGIN(*,I_DEVICE) * !D.X_CH_SIZE / !D.X_SIZE
	X0 = X(0)
	X1 = 1 - X(1)
	Y = YMARGIN(*,I_DEVICE) * !D.Y_CH_SIZE / !D.Y_SIZE
	Y0 = Y(0)
	Y1 = 1 - Y(1)
;
;  Calculate the variables needed to set the viewport.
;
	LX = X1 - X0
	LY = Y1 - Y0
	DX = 1 - LX
	DY = 1 - LY
	!P.POSITION = [X0,Y0,X1,Y1]
	IF SX GE 0 THEN DX = DX * SX
	IF SY GE 0 THEN DY = DY * SY
	LX = (LX - (NX - 1)*DX) / NX
	LY = (LY - (NY - 1)*DY) / NY
	IF LX LE 0 THEN BEGIN
		PRINT,'*** Cannot fit ' + TRIM(NX) +	$
			' plots along X dimension, routine SETVIEW.'
		RETURN
	END ELSE IF LY LE 0 THEN BEGIN
		PRINT,'*** Cannot fit ' + TRIM(NY) +	$
			' plots along Y dimension, routine SETVIEW.'
		RETURN
	ENDIF
;
;  Set the viewport.
;
	IF IX NE NX THEN X1 = X0 + (IX -  1) * (LX + DX) + LX
	IF IX NE  1 THEN X0 = X0 + (IX -  1) * (LX + DX)
	IF IY NE  1 THEN Y1 = Y0 + (NY - IY) * (LY + DY) + LY
	IF IY NE NY THEN Y0 = Y0 + (NY - IY) * (LY + DY)
	!P.POSITION = [X0,Y0,X1,Y1]
	IF (IX EQ 1) AND (NX EQ 1) AND (IY EQ 1) AND (NY EQ 1) THEN	$
		!P.POSITION = [0,0,0,0]
;
;  Set the variable !P.NOERASE and the switch SET, depending on whether the
;  full screen, or a part of the screen was selected.
;
	IF (NX EQ 1) AND (NY EQ 1) THEN BEGIN
		SET(I_DEVICE) = 0
		!P.NOERASE = 0
	END ELSE BEGIN
		SET(I_DEVICE) = 1
		!P.NOERASE = 1
	ENDELSE
;
;  Define the new setting.
;
	SETTING0 = !D.NAME + ',' + TRIM(!D.WINDOW) + ',' + TRIM(IX) + ',' + $
		TRIM(NX) + ',' + TRIM(IY) + ',' + TRIM(NY) + ',' + TRIM(SX) + $
		',' + TRIM(SY)
;
;  Find the saved parameters for this setting, if any.  Don't do the restore if
;  the window size has changed.
;
	I_SETTING = WHERE(SETTINGS EQ SETTING0, N_FOUND)
	IF N_FOUND NE 0 THEN BEGIN
	    SV = SAVE(I_SETTING(0))
	    IF (SV.X_SIZE EQ !D.X_SIZE) AND (SV.Y_SIZE EQ !D.Y_SIZE) THEN BEGIN
		!P.REGION = SV.REGION
		!P.CLIP   = SV.CLIP
		!X.TYPE   = SV.XTYPE
		!X.CRANGE = SV.XCRANGE
		!X.S      = SV.XS
		!X.WINDOW = SV.XWINDOW
		!X.REGION = SV.XREGION
		!Y.TYPE   = SV.YTYPE
		!Y.CRANGE = SV.YCRANGE
		!Y.S      = SV.YS
		!Y.WINDOW = SV.YWINDOW
		!Y.REGION = SV.YREGION
		!Z.TYPE   = SV.ZTYPE
		!Z.CRANGE = SV.ZCRANGE
		!Z.S      = SV.ZS
		!Z.WINDOW = SV.ZWINDOW
		!Z.REGION = SV.ZREGION
	    ENDIF
;
;  Keep track of the window size to compare for future calls.
;
	    SAVE(I_SETTING(0)).X_SIZE = !D.X_SIZE
	    SAVE(I_SETTING(0)).Y_SIZE = !D.Y_SIZE
	END ELSE ADD_VIEWPORT, SETTING0, SV
;
	RETURN
	END
