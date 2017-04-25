;+
; Project     :	SOHO - CDS
;
; Name        :	ROTPIC
;
; Purpose     :	Rotate a picture that is described by X & Y vectors.
;
; Explanation :	The IDL Users Library contains a function called ROT, which
;		will rotate an image stored in a 2-D array.  However, this is
;		not useful when drawing pictures by storing "corner indices"
;		in separate X and Y vectors.  This procedure will rotate such
;		picture vectors similar to the way ROT rotates an image array.
;
; Use         :	ROTPIC, X, Y, ROTANG, XROT, YROT
;
; Inputs      :	X:	The x-coordinates of the picture corners.
;
;		Y:	The y-coordinates of the picture corners.
;
;		ROTANG:	The angle PICTURE(X,Y) is to be rotated.
;
; Opt. Inputs :	None.
;
; Outputs     :	XROT:	The x-coordinates of the rotated picture corners.
;
;		YROT:	The y-coordinates of the rotated picture corners.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG:	If defined and passed, then any error messages will 
;			be returned to the user in this parameter rather than
;			being handled by the IDL MESSAGE utility.  If no 
;			errors are encountered, then a null string is 
;			returned.  In order to use this feature, the string 
;			ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				ROTPIC, X, Y, 34., XROT, YROT, ERRMSG=ERRMSG
;				IF ERRMSG(0) NE '' THEN ...
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utilities, arrays
;
; Prev. Hist. :	None.
;
; Written     :	Donald G. Luttermoser, GSFC/ARC, 19 October 1995
;
; Modified    :	Version 1, Donald G. Luttermoser, GSFC/ARC, 19 October 1995
;			Initial program.
;
; Version     :	Version 1,  19 October 1995.
;
;-
;
PRO ROTPIC, X, Y, ROTANG, XROT, YROT
;
ON_ERROR, 2   ; Return to caller if error is encountered.
MESSAGE = ''  ; Set to non-null string if error is encountered.
;
; Check input.
;
IF N_PARAMS() NE 5 THEN BEGIN
	MESSAGE = 'Syntax:  ROTPIC, X, Y, ROTANG, XROT, YROT'
	GOTO, HANDLE_ERROR
ENDIF
;
XIN = REFORM(X)  &  YIN = REFORM(Y)
AX = SIZE(XIN)   &  AY = SIZE(YIN)
;
IF AX(AX(0)+2) NE AY(AY(0)+2) THEN $
	MESSAGE = 'X & Y vectors must be the same size.'
IF AY(0) NE 1 THEN MESSAGE = 'Y vector must be 1-D.'
IF AX(0) NE 1 THEN MESSAGE = 'X vector must be 1-D.'
IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Rotate picture.
;
XROT =  XIN * COS(ROTANG/!RADEG) + YIN * SIN(ROTANG/!RADEG)
YROT = -XIN * SIN(ROTANG/!RADEG) + YIN * COS(ROTANG/!RADEG)
;
IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
IF N_ELEMENTS(ERRMSG) GT 0 THEN ERRMSG=MESSAGE
RETURN
;
; Error handling portion of the procedure.
;
HANDLE_ERROR:
;
IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
ERRMSG = MESSAGE
RETURN
;
END
