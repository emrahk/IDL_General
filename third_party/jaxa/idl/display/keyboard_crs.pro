	PRO KEYBOARD_CRS,X_VALUE,Y_VALUE,PRINT_SWITCH
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	KEYBOARD_CRS
; Purpose     :	
;	Move the graphics cursor with the keyboard.
; Explanation :	
;	This procedure uses the routine CURSOR to find the coordinates,
;	expressed in data units, of a point selected with the cursor.  Rather
;	than letting the mouse move the cursor, the cursor is moved from the
;	keyboard, allowing the user to move in one direction without moving in
;	the other direction.
; Use         :	
;	KEYBOARD_CRS  [, X_VALUE  [, Y_VALUE  [, PRINT_SWITCH ]]]
;
;	KEYBOARD_CRS		;Values printed to screen.
;	KEYBOARD_CRS, X, Y	;Values stored in variables X and Y
;	KEYBOARD_CRS, X, Y, 1	;Values stored in X,Y, and printed to screen.
;
; Inputs      :	
;	None required.
; Opt. Inputs :	
;	PRINT_SWITCH	- Switch used to control printing the values of 
;			  X_VALUE, Y_VALUE to the screen.  If not passed,
;			  then assumed 0 (no printing) unless no parameters
;			  are passed, in which case 1 (printing) is assumed.
; Outputs     :	
;
; Opt. Outputs:	
;	X_VALUE		- X position in data coordinates of cursor.
;	Y_VALUE		- Y position in data coordinates of cursor.
; Keywords    :	
;	None.
; Calls       :	
;	None.
; Common      :	
;	None.
; Restrictions:	
;	None.
; Side effects:	
;	None.
; Category    :	
;	Utilities, User_interface.
; Prev. Hist. :	
;	William Thompson	Applied Research Corporation
;	September, 1987		8201 Corporate Drive
;				Landover, MD  20785
; Written     :	
;	William Thompson, GSFC, September 1987.
; Modified    :	
;	Version 1, William Thompson, GSFC, 9 July 1993.
;		Incorporated into CDS library.
;		Added call to CONVERT_COORD so as to be compatible with
;			logarithmic plots.
; Version     :	
;	Version 1, 9 July 1993.
;-
;
	ON_ERROR, 2
;
;  Assign the default value of PRINT_SWITCH.
;
	IF N_PARAMS(0) LT 3 THEN PRINT_SWITCH = 0
	IF N_PARAMS(0) EQ 0 THEN PRINT_SWITCH = 1
;
;  Get the size of the window, and the initial cursor position.
;
	NX = !D.X_SIZE
	NY = !D.Y_SIZE
	CURSOR,X0,Y0,0,/DEVICE
;
	PRINT,'Use shift key to move faster.'
	PRINT,'Enter:  U (up), D (down), L (left), or R (right)' +	$
		';  Return to exit'
;
;  Keep looping until the return or linefeed key is entered.
;
	KEY = ' '
	RET = STRING(13B)
	LF  = STRING(10B)
	WHILE (KEY NE RET) AND (KEY NE LF) DO BEGIN
		KEY = GET_KBRD(1)
		CASE KEY OF
;
;  Lowercase, move by 1.
;
			'u':  Y0 = (Y0 + 1) < (NY - 1)
			'd':  Y0 = (Y0 - 1) > 0
			'r':  X0 = (X0 + 1) < (NX - 1)
			'l':  X0 = (X0 - 1) > 0
;
;  Uppercase, move by 10.
;
			'U':  Y0 = (Y0 + 10) < (NY - 1)
			'D':  Y0 = (Y0 - 10) > 0
			'R':  X0 = (X0 + 10) < (NX - 1)
			'L':  X0 = (X0 - 10) > 0
;
;  Otherwise, do nothing.
;
			ELSE:  X0 = X0
		ENDCASE
		TVCRS,X0,Y0,/DEVICE
	ENDWHILE
;
;  Convert to data coordinates.
;
	IF (!X.S(1)*!Y.S(1) NE 0) THEN BEGIN
		DATA = CONVERT_COORD(X0,Y0,/DEVICE,/TO_DATA)
		X_VALUE = DATA(0)
		Y_VALUE = DATA(1)
	END ELSE MESSAGE,'Data coordinates not initialized'
;
;  If requested, print the cursor position.
;
	IF PRINT_SWITCH NE 0 THEN BEGIN
		IF !D.NAME EQ 'REGIS'				$
			THEN PRINT,STRING(27B) + '[H'		$
			ELSE PRINT,' '
		PRINT,' Position:  ' + TRIM(X_VALUE) + ', ' + TRIM(Y_VALUE) + $
			'     '
	ENDIF
;
	RETURN
	END
