	FUNCTION FXBMHEADER, UNIT
;+
; Project     :	SOHO - CDS
;
; Name        :	FXBMHEADER()
;
; Purpose     :	Returns the file header of an open FITS binary table.
;
; Explanation :	This procedure returns the FITS primary file header of a FITS
;		binary table opened for read with the command FXBOPEN.
;
; Use         :	Result = FXBMHEADER(UNIT)
;
; Inputs      :	UNIT	= Logical unit number returned by FXBOPEN routine.
;			  Must be a scalar integer.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a string array containing the
;		header for the FITS file that UNIT points to.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	FXBFINDLUN
;
; Common      :	None.
;
; Restrictions:	UNIT must point to an open FITS file.
;
; Side effects:	If UNIT does not point to a binary table, then a string array
;		of nulls is returned.
;
;		If UNIT is an undefined variable, then the null string is
;		returned.
;
; Category    :	Data Handling, I/O, FITS, Generic.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 17 November 1995
;
; Modified    :	Version 1, William Thompson, GSFC, 17 November 1995
;
; Version     :	Version 1, 17 November 1995
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE,'Syntax:  Result = FXBMHEADER(UNIT)'
;
;  If UNIT is undefined, then return the null string.
;
	IF N_ELEMENTS(UNIT) EQ 0 THEN RETURN, ''
;
;  Check the validity of UNIT.
;
	IF N_ELEMENTS(UNIT) GT 1 THEN MESSAGE,'UNIT must be a scalar'
	SZ = SIZE(UNIT)
	IF SZ(SZ(0)+1) GT 3 THEN MESSAGE,'UNIT must be an integer'
;
;  Get the state associated with UNIT.
;
	STATE = FSTAT(UNIT)
	IF NOT STATE.OPEN THEN MESSAGE, 'UNIT does not point to an open file'
;
;  Open the file and read the header.
;
	OPENR, LUN, STATE.NAME, /GET_LUN
	FXHREAD, LUN, HEADER
	FREE_LUN, LUN
;
	RETURN, HEADER
	END
