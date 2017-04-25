	PRO LABEL_IMAGE, TITLE, BELOW=BELOW, LEFT=LEFT, RIGHT=RIGHT,	$
		CENTER=CENTER, DISABLE=DISABLE, CHARSIZE=CHAR_SIZE,	$
		COLOR=COLOR, REVERSE=REVERSE, GAP=GAP, CHARTHICK=CHAR_THICK
;+
; Project     : SOHO - CDS
;
; Name        : 
;	LABEL_IMAGE
; Purpose     : 
;	Puts labels on images.
; Explanation : 
;	The routine XYOUTS is used to display the title centered either above
;	or below the image, or to either side of the image.
; Use         : 
;	LABEL_IMAGE, TITLE
; Inputs      : 
;	TITLE	 = Character string to be output to image.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	BELOW	 = If set, then the title is displayed below the image.
;	LEFT	 = If set, then the title is displayed to the left of the
;		   image.  Overrides BELOW keyword.
;	RIGHT	 = If set, then the title is displayed to the right of the
;		   image.  Overrides BELOW and LEFT keywords.
;	CENTER	 = If set, then the title is centered on the screen, regardless
;		   of where the image is.  Centering is in X, unless the LEFT
;		   or RIGHT keywords are set, in which case it is in Y.
;	CHARSIZE = Character size to use in displaying titles.  Normally 1.
;	CHARTHICK= Character thickness to use in displaying titles.
;	COLOR	 = Color to display label in.
;	DISABLE  = If set, then TVSELECT not used.
;	REVERSE	 = If set, then the orientation of the letters is 180 degrees
;		   from what it ordinarily would be.
;	GAP	 = Amount of extra space to place between the label and the
;		   image, in character units.
; Calls       : 
;	GET_TV_SCALE, TVSELECT, TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
;	There must be enough space to display the title.
;
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
;	William Thompson, March 1991.
;	William Thompson, May 1992, modified to use GET_TV_SCALE.
;	William Thompson, Nov 1992, modified algorithm for getting the relative
;		character size.
; Written     : 
;	William Thompson, GSFC, March 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 13 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 14 March 1996
;		Added keywords GAP and CHARSIZE
;		Allow for multiple line titles
;		Correct bug with use of reverse keyword
;	Version 3, William Thompson, GSFC, 18 December 2002
;		Changed !COLOR to !P.COLOR
; Version     : 
;	Version 3, 18 December 2002
;-
;
	ON_ERROR,2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE,'Syntax:  LABEL_IMAGE, TITLE'
;
;  Get the relative character size and thickness
;
	IF N_ELEMENTS(CHAR_SIZE) EQ 1 THEN CHARSIZE = CHAR_SIZE	$
		ELSE CHARSIZE = !P.CHARSIZE
	IF CHARSIZE LE 0 THEN CHARSIZE = 1
	IF N_ELEMENTS(CHAR_THICK) EQ 1 THEN CHARTHICK = CHAR_THICK $
		ELSE CHARTHICK = !P.CHARTHICK
;
;  If the GAP keyword was not set, then set it equal to 0.
;
	IF N_ELEMENTS(GAP) EQ 0 THEN GAP = 0
;
;  Get the size of the image display screen.
;
	TVSELECT, DISABLE=DISABLE
	X_SIZE = !D.X_SIZE  &  X_CH_SIZE = !D.X_CH_SIZE * CHARSIZE
	Y_SIZE = !D.Y_SIZE  &  Y_CH_SIZE = !D.Y_CH_SIZE * CHARSIZE
	TVUNSELECT, DISABLE=DISABLE
;
;  Get the parameters describing the displayed image.
;
	GET_TV_SCALE,SX,SY,MX,MY,IX,IY,DISABLE=DISABLE
;
;  If the CENTER keyword is set, then modify the parameters to center the
;  title.
;
	IF KEYWORD_SET(CENTER) THEN BEGIN
		IF KEYWORD_SET(LEFT) OR KEYWORD_SET(RIGHT) THEN BEGIN
			MY = Y_SIZE  &  IY = 0
		END ELSE BEGIN
			MX = X_SIZE  &  IX = 0
		ENDELSE
	ENDIF
;
;  Calculate the position of the center of label.
;
	XCEN = IX + MX/2  &  XSPACE = 0
	YCEN = IY + MY/2  &  YSPACE = 0
	ORIENTATION = 0
	IF KEYWORD_SET(RIGHT) THEN BEGIN
		XCEN = IX + MX + (0.875+GAP)*Y_CH_SIZE
		XSPACE = Y_CH_SIZE
		XMIN = XCEN
		XMAX = XCEN + XSPACE*(N_ELEMENTS(TITLE)-1)
		ORIENTATION = 90
	END ELSE IF KEYWORD_SET(LEFT) THEN BEGIN
		XCEN = IX - (0.375+GAP+N_ELEMENTS(TITLE)-1)*Y_CH_SIZE
		XSPACE = Y_CH_SIZE
		XMIN = XCEN + XSPACE*(N_ELEMENTS(TITLE)-1)
		XMAX = XCEN
		ORIENTATION = 90
	END ELSE IF KEYWORD_SET(BELOW) THEN BEGIN
		YCEN = IY - (0.875+GAP)*Y_CH_SIZE
		YSPACE = -Y_CH_SIZE
		YMIN = YCEN - YSPACE*(N_ELEMENTS(TITLE)-1)
		YMAX = YCEN
	END ELSE BEGIN
		YCEN = IY + MY + (0.375+GAP+N_ELEMENTS(TITLE)-1)*Y_CH_SIZE
		YSPACE = -Y_CH_SIZE
		YMIN = YCEN
		YMAX = YCEN + YSPACE*(N_ELEMENTS(TITLE)-1)
	ENDELSE
;
;  Check to make sure that the label will fit within the confines of the
;  graphics device.
;
	IF ORIENTATION EQ 0 THEN BEGIN
		ZMIN = YMIN - 0.25*Y_CH_SIZE  &  H_SIZE = Y_SIZE
		ZMAX = YMAX + 0.75*Y_CH_SIZE  &  W_SIZE = X_SIZE
	END ELSE BEGIN
		ZMIN = XMIN - 0.25*Y_CH_SIZE  &  H_SIZE = X_SIZE
		ZMAX = XMAX + 0.75*Y_CH_SIZE  &  W_SIZE = Y_SIZE
	ENDELSE
;
	IF (ZMIN LT 0) OR (ZMAX GT H_SIZE) THEN BEGIN
		PRINT,'*** Not enough space to display the label, ' +	$
			'routine LABEL_IMAGE.'
		RETURN
	END ELSE IF MAX(STRLEN(TITLE))*X_CH_SIZE GT W_SIZE THEN BEGIN
		PRINT,'*** Label is too wide to display, routine LABEL_IMAGE.'
		RETURN
	ENDIF
;
;  If necessary, then rotate the label.
;
	IF KEYWORD_SET(REVERSE) THEN BEGIN
		ORIENTATION = ORIENTATION + 180
		IF KEYWORD_SET(RIGHT) THEN BEGIN
			XCEN = XCEN - 0.5*Y_CH_SIZE
		END ELSE IF KEYWORD_SET(LEFT) THEN BEGIN
			XCEN = XCEN - 0.5*Y_CH_SIZE
		END ELSE IF KEYWORD_SET(BELOW) THEN BEGIN
			YCEN = YCEN + 0.5*Y_CH_SIZE
		END ELSE BEGIN
			YCEN = YCEN + 0.5*Y_CH_SIZE
		ENDELSE
	ENDIF
;
;  Display the label.
;
	TVSELECT, DISABLE=DISABLE
	IF N_ELEMENTS(COLOR) EQ 0 THEN COLOR = !P.COLOR
	FOR I=0,N_ELEMENTS(TITLE)-1 DO BEGIN
		IF KEYWORD_SET(REVERSE) THEN J = N_ELEMENTS(TITLE)-I-1 ELSE $
			J = I
		XYOUTS, XCEN+XSPACE*J, YCEN+YSPACE*J, TITLE(I), /DEVICE, $
			ALIGNMENT=0.5, CHARSIZE=CHARSIZE, COLOR=COLOR,	$
			CHARTHICK=CHARTHICK, ORIENTATION=ORIENTATION
	ENDFOR
	TVUNSELECT, DISABLE=DISABLE
;
	RETURN
	END
