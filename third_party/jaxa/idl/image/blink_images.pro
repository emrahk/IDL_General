	PRO BLINK_IMAGES, ARRAY1, ARRAY2, NOSQUARE=NOSQUARE, NOBOX=NOBOX, $
		SIZE=SIZE, DISABLE=DISABLE, MISSING=MISSING, CHAR=CHAR,	$
		NOMESSAGE=NOMESSAGE
;+
; Project     : SOHO - CDS
;
; Name        : 
;	BLINK_IMAGES
; Purpose     : 
;	Blinks two images together by modifying the color tables.
; Explanation : 
;	A combined image is formed in which the lower bits are assigned to
;	ARRAY1 and the higher bits to ARRAY2.  Two color tables are defined
;	relative to the current one so that the different images are shown by
;	changing between these two color tables.
;
;	A better way to blink together two images on an X-windows display is to
;	use the routine XBLINK.
;
; Use         : 
;	BLINK_IMAGES
;	BLINK_IMAGES, ARRAY1, ARRAY2
; Inputs      : 
;	None required.
; Opt. Inputs : 
;	ARRAY1	 = First image to be blinked against the second image.
;	ARRAY2	 = Second image.  Must have the same dimensions as the first
;		   image.
;
;	If the two arrays are not passed, then it is assumed that the images
;	are already displayed, and the program goes directly to loading the
;	color tables.
;
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	NOSQUARE = If passed, then pixels are not forced to be square.
;	NOBOX	 = If passed, then box is not drawn, and no space is reserved
;		   for a border around the image.
;	SIZE	 = If passed and positive, then used to determine the scale of
;		   the image.  Returned as the value of the image scale.  May
;		   not be compatible with /NOSQUARE.
;	DISABLE  = If set, then TVSELECT not used.
;	MISSING	 = Value flagging missing pixels.  These points are scaled to
;		   zero.
;	CHAR	 = Returns the final character entered from the keyboard.
;	NOMESSAGE= If set, then the message explaining about the keys is not
;		   printed out.  This is for routines such as MOVE_AND_BLINK,
;		   which call BLINK_IMAGES, and want to print out their own message.
; Calls       : 
;	EXPTV, GET_IM_KEYWORD, TVSELECT, TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
;	ARRAY1 and ARRAY2 must have the same dimensions.
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
;	The combined image formed from ARRAY1 and ARRAY2 is left on the screen.
;	It may look a little strange.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, March 1991.
;	William Thompson, April 1992, changed to use TVLCT,/GET instead of
;				      common block.
;	William Thompson, August 1992, renamed BADPIXEL to MISSING.
; Written     : 
;	William Thompson, GSFC, March 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 14 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 3-Sep-1997
;		Renamed to BLINK_IMAGES
;	Version 3, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
; Version     : 
;	Version 3, 8 April 1998
;-
;
	GET_IM_KEYWORD, MISSING, !IMAGE.MISSING
;
;  Check the input parameters.
;
	IF N_PARAMS() EQ 0 THEN BEGIN
		PRINT,'*** Assuming the combined image is already ' + $
			'displayed, routine BLINK_IMAGES.'
	END ELSE IF N_PARAMS() EQ 2 THEN BEGIN
		SZ1 = SIZE(ARRAY1)
		SZ2 = SIZE(ARRAY2)
		IF SZ1(0) NE 2 THEN BEGIN
			PRINT,'*** ARRAY1 must be two-dimensional, ' + $
				'routine BLINK_IMAGES.'
			RETURN
		END ELSE IF SZ2(0) NE 2 THEN BEGIN
			PRINT,'*** ARRAY2 must be two-dimensional, ' + $
				'routine BLINK_IMAGES.'
			RETURN
		END ELSE IF (SZ1(1) NE SZ2(1)) OR (SZ1(2) NE SZ2(2)) THEN BEGIN
			PRINT,'*** ARRAY1 and ARRAY2 must have the same ' + $
				'dimensions, routine BLINK_IMAGES.'
			RETURN
		ENDIF
	END ELSE BEGIN
		PRINT,'*** BLINK_IMAGES must be called with zero or two parameters:'
		PRINT,'                 [ ARRAY1, ARRAY2 ]'
		RETURN
	ENDELSE
;
;  Get the current color table, and degrade to the resolution needed to combine
;  two color tables.
;
	TVSELECT, DISABLE=DISABLE
	TVLCT,R_ORIG,G_ORIG,B_ORIG,/GET
	NCOLORS = FIX(SQRT(!D.TABLE_SIZE))
	I = INDGEN(NCOLORS)
	R = R_ORIG(I*!D.TABLE_SIZE/NCOLORS)
	G = G_ORIG(I*!D.TABLE_SIZE/NCOLORS)
	B = B_ORIG(I*!D.TABLE_SIZE/NCOLORS)
;
;  Form separate color tables for each image.
;
	I1 = INDGEN(NCOLORS^2) MOD NCOLORS
	I2 = INDGEN(NCOLORS^2)  /  NCOLORS
	RR1 = R_ORIG  &  RR2 = RR1
	GG1 = G_ORIG  &  GG2 = GG1
	BB1 = B_ORIG  &  BB2 = BB1
	RR1(0) = R(I1)  &  RR2(0) = R(I2)
	GG1(0) = G(I1)  &  GG2(0) = G(I2)
	BB1(0) = B(I1)  &  BB2(0) = B(I2)
;
;  Get the data ranges for each array.
;
	IF N_PARAMS() EQ 2 THEN BEGIN
		IF N_ELEMENTS(MISSING) EQ 1 THEN BEGIN
			W = WHERE(ARRAY1 NE MISSING)
			AMIN1 = MIN(ARRAY1(W))  &  AMAX1 = MAX(ARRAY1(W))
			W = WHERE(ARRAY2 NE MISSING)
			AMIN2 = MIN(ARRAY2(W))  &  AMAX2 = MAX(ARRAY2(W))
		END ELSE BEGIN
			AMIN1 = MIN(ARRAY1)  &  AMAX1 = MAX(ARRAY1)
			AMIN2 = MIN(ARRAY2)  &  AMAX2 = MAX(ARRAY2)
		ENDELSE
;
;  Scale the images into the appropriate data ranges.
;
		TOP = BYTE(NCOLORS-1)
		A1 = BYTSCL(FLOAT(ARRAY1),MIN=AMIN1,MAX=AMAX1,TOP=TOP)
		A2 = BYTSCL(FLOAT(ARRAY2),MIN=AMIN2,MAX=AMAX2,TOP=TOP)
;
;  Set all missing pixels to zero.
;
		IF N_ELEMENTS(MISSING) EQ 1 THEN BEGIN
			W = WHERE(ARRAY1 EQ MISSING, N_FOUND)
			IF N_FOUND GT 0 THEN A1(W) = 0
			W = WHERE(ARRAY2 EQ MISSING, N_FOUND)
			IF N_FOUND GT 0 THEN A2(W) = 0
		ENDIF
;
;  Combine the two images into one and display it.
;
		A = A1 + A2*BYTE(NCOLORS)
		EXPTV,A,/NOSCALE,/DISABLE,NOSQUARE=NOSQUARE,NOBOX=NOBOX, $
			SIZE=SIZE
	ENDIF
;
;  Start out with a one second delay between color tables.  Keep changing the
;  color tables until the user enters some letter other than S or F.
;
	DELAY = 1
	IF NOT KEYWORD_SET(NOMESSAGE) THEN	$
		PRINT,"S for slower, F for faster, anything else to quit."
	CHAR = ""
	WHILE CHAR EQ "" DO BEGIN
		TVLCT,RR1,GG1,BB1
		EMPTY
		WAIT,DELAY
		TVLCT,RR2,GG2,BB2
		EMPTY
		WAIT,DELAY
		CHAR = GET_KBRD(0)
		CASE STRUPCASE(CHAR) OF
			'S':	BEGIN & DELAY = DELAY * 1.5 & CHAR = '' & END
			'F':	BEGIN & DELAY = DELAY / 1.5 & CHAR = '' & END
			ELSE:	DELAY = DELAY
		ENDCASE
	ENDWHILE
;
;  Restore the original color table and graphics device.
;
	TVLCT,R_ORIG,G_ORIG,B_ORIG
	TVUNSELECT, DISABLE=DISABLE
;
	RETURN
	END
