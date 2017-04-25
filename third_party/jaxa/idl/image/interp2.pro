FUNCTION INTERP2,IMAGE,X,Y,MISSING=MISSING
;+
; Project     : SOHO - CDS
;
; Name        : 
;	INTERP2()
; Purpose     : 
;	Performs a two-dimensional interpolation on IMAGE.
; Explanation : 
;	An average is made between the four nearest neighbors of the point to 
;	be interpolated to.
; Use         : 
;	OUTPUT = INTERP2( IMAGE, X, Y )
; Inputs      : 
;	IMAGE	= Image to be interpolated.
;	X	= X coordinate position(s) of the interpolated point(s).
;	Y	= Y coordinate position(s) of the interpolated point(s).
; Opt. Inputs : 
;	None.
; Outputs     : 
;	The function returns a one-dimensional array of the interpolated 
;	points.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	MISSING	 = Value flagging missing pixels.  Any such pixels are not
;		   included in the interpolation.  If any interpolation point
;		   is surrounded only by missing pixels, then the output value
;		   for that point is set to MISSING.
; Calls       : 
;	GET_IM_KEYWORD, IS_NOT_MISSING, FLAG_MISSING
; Common      : 
;	None.
; Restrictions: 
;	IMAGE must be two-dimensional.
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
;	W.T.T., Oct. 1987.
;	W.T.T., Jan. 1991.  Changed FLAG to keyword BADPIXEL.
;	William Thompson, August 1992, renamed BADPIXEL to MISSING.
;	William Thompson, 5 May 1993, fixed bug when Y > first dim. of IMAGE.
; Written     : 
;	William Thompson, October 1987.
; Modified    : 
;	Version 1, William Thompson, GSFC, 13 May 1993.
;		Incorporated into CDS library.
;       Version 2, 11-May-2005, William Thompson, GSFC
;               Handle NaN values, and otherwise modernize
; Version     : 
;	Version 2, 11-May-2005
;-
;
GET_IM_KEYWORD, MISSING, !IMAGE.MISSING
;
;  Check the number of parameters.
;
IF N_PARAMS() NE 3 THEN MESSAGE, 'Syntax:  Result = INTERP2(IMAGE,X,Y)'
;
;  Check the size of the array IMAGE.
;
S = SIZE(IMAGE)
IF S[0] NE 2 THEN MESSAGE, 'IMAGE  must be two-dimensional'
;
;  Find the boundaries of the square containing the point X,Y to interpolate
;  to.
;
NX = S[1] - 1
NY = S[2] - 1
IX1 = 0 > FIX(X) < NX
IY1 = 0 > FIX(Y) < NY
IX2 = IX1 + 1 < NX
IY2 = IY1 + 1 < NY
DX = 0 > (X - IX1) < 1
DY = 0 > (Y - IY1) < 1
;
;  Initialize the arrays (or scalers) INT and W_TOTAL.
;
INT = 0. * (X + Y)
W_TOTAL = 0. * (X + Y)
;
;  Start adding together the contributions from each corner of the box
;  containing the point X,Y.  Ignore any corners that have the value MISSING.
;
POS = IX1 + S[1]*IY1
WEIGHT = (1. - DX) * (1. - DY) * IS_NOT_MISSING(IMAGE[POS], MISSING=MISSING)
INT = INT + IMAGE[POS]*WEIGHT
W_TOTAL = W_TOTAL + WEIGHT
;
POS = IX1 + S[1]*IY2
WEIGHT = (1. - DX) * DY        * IS_NOT_MISSING(IMAGE[POS], MISSING=MISSING)
INT = INT + IMAGE[POS]*WEIGHT
W_TOTAL = W_TOTAL + WEIGHT
;
POS = IX2 + S[1]*IY1
WEIGHT = DX * (1. - DY)        * IS_NOT_MISSING(IMAGE[POS], MISSING=MISSING)
INT = INT + IMAGE[POS]*WEIGHT
W_TOTAL = W_TOTAL + WEIGHT
;
POS = IX2 + S[1]*IY2
WEIGHT = DX * DY               * IS_NOT_MISSING(IMAGE[POS], MISSING=MISSING)
INT = INT + IMAGE[POS]*WEIGHT
W_TOTAL = W_TOTAL + WEIGHT
;
;  Set any points that cannot be interpolated to the value MISSING.
;
WMISSING = WHERE(W_TOTAL EQ 0, N_MISSING)
IF N_MISSING GT 0 THEN BEGIN
    POS = WHERE(W_TOTAL NE 0, N_FOUND)
    IF N_FOUND GT 0 THEN INT[POS] = INT[POS] / W_TOTAL[POS]
    FLAG_MISSING, INT, WMISSING, MISSING=MISSING
END ELSE INT = INT / W_TOTAL
;
RETURN,INT
END
