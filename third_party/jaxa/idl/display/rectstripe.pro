;+
; Project     :	SOHO - CDS
;
; Name        :	RECTSTRIPE
;
; Purpose     :	Plot a solid rectagle of arbitary size with stripes.
;
; Explanation : Plot a solid rectagle of arbitary size with stripes.
;
; Use         :	RECTSTRIPE, x, y, [KEYWORDS]
;
; Inputs      :	x	2 element vector which specifies the X coordinates
;			of the opposing corners of the rectagle to be plotted.
;			If no value is specified for y, then this must
;			consist of an array of 2 vectors where each vector
;			consists of two elements which specify the X and Y
;			coordinate of one of the opposing corners of the 
;			rectangle to be plotted.
;
; Opt. Inputs : y	2 element vector which specifies the Y coordinates
;			of the opposing corners of the rectagle to be plotted.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    : color	2 element vector which specifies to the colors to
;			use when drawing the rectangle.  The first element
;			is the background color and the second element is
;			the stripe color.
;
;		width	Stripe width in pixels.
;
;		device	When set, assumes that the coordinates are in the
;			device coordinate scheme.  Otherwise, it is assumed
;			that the coordinates are in the data coordinate
;			scheme.
;
;		horizontal	If set, the stripes will be drawn horizontally
;
;		vertical	If set, the stripes will be drawn vertically
;
; Common      :	None.
;
; Restrictions:	Routine currently uses only DEVICE and DATA coordinates.
;
; Side effects:	Plots rectangle to current display window.
;
; Category    :	Graphics
;
; Prev. Hist. :	None.
;
; Written     :	Ronald Yurow (EITI)
;
; Modified:   : Ronald Yurow, EITI, October 4, 2001
;                  Initial Release
;
; Version     :	Version 1, October 4, 2001
;-

	PRO RECTSTRIPE, x, y, 					$
	                COLOR = color, 				$
	                WIDTH = width, 				$
	                DEVICE = device, 			$
	                VERTICAL = vertical,			$
	                HORIZONTAL = horizontal

ON_ERROR, 0

;
; Check if x and y are both 2 x 1 element arrays or that x is 
; 2 x 2 element array.
;

	sizex = SIZE (X)
	sizey = SIZE (Y)

	IF sizex (0) GT 2 THEN GOTO, ERROR1
	IF sizey (0) GT 2 THEN GOTO, ERROR1
	
	IF sizex (0) EQ 2 AND sizex (1) NE 2 THEN GOTO, ERROR1
	IF sizex (0) EQ 2 AND sizex (2) NE 2 THEN GOTO, ERROR1

	IF sizex (0) EQ 1 AND sizex (1) NE 2 THEN GOTO, ERROR1
	IF sizey (0) EQ 1 AND sizex (1) NE 2 THEN GOTO, ERROR1

;
; Extract the y array from the x array, if needed.
;

	IF sizex (0) EQ 2 THEN BEGIN

	   y = REFORM (x (1, *))
	   x = REFORM (x (0, *))

	ENDIF

;
; Set the transpose flag to 0
;

	tflag = 0

;
; Set the color array.  If color is not already defined then it will 
; default to black and white.
;

	IF N_ELEMENTS (color) LT 2 THEN BEGIN

	   color = INTARR (2)

	   color (0) = 0
	   color (1) = 255

	ENDIF

;
; Check if we need to transform the coordinates into device coordinates.
;

	IF NOT KEYWORD_SET (device) THEN BEGIN

	   x = CONVERT_COORD (X, Y, /DATA, /TO_DEVICE)

	   y = REFORM (x (1, *))
	   x = REFORM (x (0, *))

	ENDIF

;
; Calculate the height and the width of the polygon.
;

	dx = MAX (x) - MIN (x) + 1
	dy = MAX (y) - MIN (y) + 1

;
; Check for a zero size area.
;

	IF dx EQ 0 or dy EQ 0 THEN GOTO, ERROR2

;
; Check if the height is greater then the width.  If it is then we may need
; to do a transpose (if the horizontal keyword is set then no transpose
; will be done).  If the keyword vertical is set, then we will always do
; a transpose.
;

	IF (dy GT dx) AND NOT KEYWORD_SET (horizontal) THEN tflag = 1

        IF KEYWORD_SET (vertical) THEN tflag = 1

;
; Dertermine the height of the pattern array along the y axis used to 
; create the polygon.  Normally this will be the height of the polygon
; itself, unless the transpose flag is set.
;

	IF tflag THEN BEGIN 

           pat_y_len = dx
           pat_x_len = dy

        ENDIF ELSE BEGIN 

	   pat_y_len = dy
	   pat_x_len = dx

	ENDELSE

;
; Check if the keyword width is set.  If it is not set, then set width to 
; 1/3 the height of the polygon.  However, make sure that it is at least
; two pixels wide.
;

	IF NOT KEYWORD_SET (width) THEN BEGIN

           width = (FIX (.333 * pat_y_len) - 1) > 2

	ENDIF

;
; Create the pattern array.  Set the entire array to color 0.  This is 
; the background color
; 

	pwidth = FIX (pat_y_len / 2) + width

	pat = BYTARR (pwidth, pat_y_len)
	pat (*, *) = color (0)

;
; Create the stripe in the forground color (color 1).
;

	stripe = BYTARR (width)
	stripe (*) = color (1)

; 
; Add the stripe into the pattern array.
;
	
	FOR i = 0, pat_y_len - 1 DO BEGIN

	  offset = FIX (i / 2)

	  pat (offset:offset+width-1, i) = stripe

	ENDFOR

;
; Figure out how many times we need to expand the pat array by so that 
; it is at least as long as the requested rectangle.
;

	IF pat_x_len MOD pwidth EQ 0 THEN BEGIN 

	   f = pat_x_len / pwidth 

	ENDIF ELSE BEGIN 

	   f = (pat_x_len / pwidth) + 1

	ENDELSE

;
; Create array of consisting of multiple pattern arrays.
;

	shape = BYTARR (pwidth * f, pat_y_len)

	FOR i = 0, f - 1 DO BEGIN

	   offset = i * pwidth

	   shape (offset:offset+pwidth-1, *) = pat

	ENDFOR

;
; Check if the transpose flag was set.  If it was, then transpose the shape
; array.
;

	IF tflag THEN shape = TRANSPOSE (shape) 

;
; Resize the array shape so that it has the dimensions specified by the
; x and y parameters.
;

	shape = shape (0:dx-1, 0:dy-1)

;
; Display the rectangle.
;

	TV, shape, MIN (x), MIN (y)

	RETURN

ERROR1:

	PRINT, "ERROR - Routine not called with correct paramenters."
	PRINT, "USAGE: RECTSTRIPE, 2x2 Array, [KEYWORDS] or"
	PRINT, "       RECTSTRIPE, 1x2 Array, 1x2 Array, [KEYWORDS]"

	RETURN

ERROR2:

	PRINT, "ERROR - Rectange must not have any dimension = 0."

	END
	

	
	