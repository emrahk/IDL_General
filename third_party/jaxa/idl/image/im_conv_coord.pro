	PRO IM_CONV_COORD, X, Y, DATA=DATA, DEVICE=DEVICE, $
		NORMAL=NORMAL, IMAGE=IMAGE, TO_DATA=TO_DATA,	$
		TO_DEVICE=TO_DEVICE, TO_NORMAL=TO_NORMAL, TO_IMAGE=TO_IMAGE, $
		DISABLE=DISABLE
;+
; Project     :	SOHO - CDS
;
; Name        :	IM_CONV_COORD
;
; Purpose     :	Convert between different image coordinate systems.
;
; Category    :	Image display
;
; Explanation :	
;
; Syntax      :	IM_CONV_COORD, X, Y, /from_keyword, /to_keyword
;
; Examples    :	The following example converts a cursor postion from a widget
;		event into a pixel position within the image.
;
;		X = EVENT.X
;		Y = EVENT.Y
;		IM_CONV_COORD, X, Y, /DEVICE, /TO_IMAGE
;
; Inputs      :	X, Y	= Input coordinates to convert
;
; Opt. Inputs :	None.
;
; Outputs     :	X, Y	= The output coordinates are returned in the same
;			  parameters.
;
; Opt. Outputs:	None.
;
; Keywords    :	Choose one of the following keywords to select the input data
;		type.
;
;		DATA	  = Set this keyword if the input coordinates are in
;			    data space.
;		DEVICE	  = Set this keyword if the input coordinates are in
;			    device space.
;		NORMAL	  = Set this keyword if the input coordinates are in
;			    normalized space.
;		IMAGE	  = Set this keyword if the input coordinates are in
;			    image pixel space.
;
;		And choose one of the following to select the output data type.
;
;		TO_DATA   = Set this keyword if the output coordinates are to
;			    be in data space.
;		TO_DEVICE = Set this keyword if the output coordinates are to
;			    be in device space.
;		TO_NORMAL = Set this keyword if the output coordinates are to
;			    be in normalized space.
;		TO_IMAGE  = Set this keyword if the output coordinates are to
;			    be in image pixel space. 
;
;		Additional keywords:
;
;		DISABLE	  = If set, then TVSELECT not used.
;
;
; Calls       :	GET_TV_SCALE
;
; Common      :	
;
; Restrictions:	
;
; Side effects:	
;
; Prev. Hist. :	
;
; History     :	
;
; Contact     :	
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  IM_CONV_COORD, X, Y, /from_keyword, /to_keyword'
;
;  Make sure that X and Y have the same dimensions.
;
	IF N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN MESSAGE,	$
		'X and Y must have the same dimensions.
	SZ = SIZE(X)
	IF SZ(0) GT 0 THEN DIM = SZ(1:SZ(0))
;
;  Make sure that one and only one of the input keywords was passed.
;
	TEST = KEYWORD_SET(DATA) + KEYWORD_SET(DEVICE) +	$
		KEYWORD_SET(NORMAL) + KEYWORD_SET(IMAGE)
	IF TEST NE 1 THEN MESSAGE, 'One and only one of DATA, DEVICE, ' + $
		'NORMAL, or IMAGE keywords must be set'
;
;  Make sure that one and only one of the output keywords was passed.
;
	TEST = KEYWORD_SET(TO_DATA) + KEYWORD_SET(TO_DEVICE) +	$
		KEYWORD_SET(TO_NORMAL) + KEYWORD_SET(TO_IMAGE)
	IF TEST NE 1 THEN MESSAGE, 'One and only one of TO_DATA, ' +	$
		'TO_DEVICE, TO_NORMAL, or TO_IMAGE keywords must be set'
;
;  First, get the scale of the displayed image.
;
	GET_TV_SCALE,SX,SY,MX,MY,IX,IY,DISABLE=DISABLE
;
;  Convert the input coordinates into image pixels.
;
	IF NOT KEYWORD_SET(IMAGE) THEN BEGIN
		IF KEYWORD_SET(DATA) THEN BEGIN
			TEMP = CONVERT_COORD(X,Y,/DATA,/TO_DEVICE)
			X = TEMP(0,*)
			Y = TEMP(1,*)
		END ELSE IF KEYWORD_SET(NORMAL) THEN BEGIN
			TEMP = CONVERT_COORD(X,Y,/NORMAL,/TO_DEVICE)
			X = TEMP(0,*)
			Y = TEMP(1,*)
		ENDIF
;
		IF SZ(0) EQ 0 THEN BEGIN
			X = X(0)
			Y = Y(0)
		END ELSE BEGIN
			X = REFORM(X,DIM)
			Y = REFORM(Y,DIM)
		ENDELSE
;
		NX = FLOAT(MX) / SX
		NY = FLOAT(MY) / SY
		X = (X - IX) / NX
		Y = (Y - IY) / NY
		IF !ORDER NE 0 THEN Y = SY - YVAL - 1
	ENDIF
;
;  Convert to the output format.
;
	IF NOT KEYWORD_SET(TO_IMAGE) THEN BEGIN
		XS = SX / FLOAT(MX)
		YS = SY / FLOAT(MY)
		X = IX + X/XS
		Y = IY + Y/YS
;
		IF KEYWORD_SET(TO_DATA) THEN BEGIN
			TEMP = CONVERT_COORD(X,Y,/DEVICE,/TO_DATA)
			X = TEMP(0,*)
			Y = TEMP(1,*)
		END ELSE IF KEYWORD_SET(TO_NORMAL) THEN BEGIN
			TEMP = CONVERT_COORD(X,Y,/DEVICE,/TO_NORMAL)
			X = TEMP(0,*)
			Y = TEMP(1,*)
		ENDIF
;
		IF SZ(0) EQ 0 THEN BEGIN
			X = X(0)
			Y = Y(0)
		END ELSE BEGIN
			X = REFORM(X,DIM)
			Y = REFORM(Y,DIM)
		ENDELSE
	ENDIF
;
	RETURN
	END
