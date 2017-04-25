FUNCTION MJD2STR, MJD, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	MJD2STR
;
; Purpose     :	Converts MJD to string format.
;
; Explanation :	This function takes a Modified Julian Day number, and returns
;		the corresponding calendar date as a string.
;
; Use         :	DATE = MJD2DATE( MJD )
;
; Inputs      :	MJD	= Modified Julian Day number.
;
; Opt. Inputs :	None.
;
; Outputs     :	Function returns string in the form 'yyyy-mm-dd'
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG	= If defined and passed, then any error messages 
;			  will be returned to the user in this parameter 
;			  rather than being handled by the IDL MESSAGE 
;			  utility.  If no errors are encountered, then a null 
;			  string is returned.  In order to use this feature, 
;			  the string ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				DATE = MJD2DATE( MJD, ERRMSG=ERRMSG)
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	Based on MJD2DATE
;
; Written     :	C D Pike, RAL 8-Jul-97
;
; Modified    :	
;
; Version     :	Version 1, 8-Jul-97.
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  PRINT,MJD2DATE( MJD)
		GOTO, HANDLE_ERROR
	ENDIF
;
;  From the Modified Julian Day, calculate the Julian Day number corresponding
;  to noon of that same day.
;
	JD = LONG(2400001.D0 + MJD)
;
;  From the Julian Day number, calculate the year, month and day, using the
;  algorithm by Fliegel and Van Flandern (1968) reprinted in the Explanatory
;  Supplement to the Astronomical Almanac, 1992.
;
	L = JD + 68569
	N = 4 * L / 146097
	L = L - (146097 * N + 3) / 4
	YEAR = 4000 * (L + 1) / 1461001
	L = L - 1461 * YEAR / 4 + 31
	MONTH = 80 * L / 2447
	DAY = L - 2447 * MONTH / 80
	L = MONTH / 11
	MONTH = MONTH + 2 - 12 * L
	YEAR = 100 * (N - 49) + YEAR + L
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
        RETURN,TRIM(YEAR)+'-'+TRIM(MONTH)+'-'+TRIM(DAY)
;
; Error handling point.
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN,''
;
	END
