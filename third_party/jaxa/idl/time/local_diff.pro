	FUNCTION LOCAL_DIFF, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	LOCAL_DIFF()
;
; Purpose     :	Gets the current difference between local and UTC time.
;
; Explanation :	This procedure uses the IDL SYSTIME() function in different
;		ways to calculate the current local and UTC date/time values,
;		and calculates the difference (local - UTC) in hours between
;		them.
;
; Use         :	Result = LOCAL_DIFF()
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the current difference in hours
;		between local and UTC time, i.e. local-UTC.
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
;				RESULT = LOCAL_DIFF ( ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
;			  Note that no intrinsic errors will ever be
;			  encountered in this procedure.  However, this 
;			  ERRMSG keyword has been installed since it calls
;			  other procedures that include the ERRMSG keyword.
;
; Calls       :	INT2UTC, TRIM
;
; Common      :	Uses the internal common block LOCAL_DIFF to store information
;		between calls.  This common block is shared with the routine
;		LOCAL_DIFF.
;
; Restrictions:	This routine depends on the behavior of IDL's SYSTIME function.
;		Currently, it is believed that this routine will return the
;		time difference correctly on all properly configured Unix
;		systems.  However, the result may be different in other
;		operating systems; e.g. on VMS and MacIntosh computers it
;		always returns zero.  It is believed to work correctly in IDL
;		for Windows.
;
;		In order to get around this difficulty, the file
;		"local_diff.dat" can be placed in the directory given by the
;		environment variable TIME_CONV.  If this file exists, then this
;		program will read the value from this file rather than try to
;		calculate.  For example, for U.S. Eastern Standard Time, this
;		file would contain the value -5.  This means then, that this
;		file must contain the correct value, and must be updated to
;		reflect changes between standard and daylight savings time.
;
;		The file local_diff.dat is only read once.  The contents are
;		stored in a common block between calls.  Once a day, the file
;		is reread.
;
;		The accuracy of the time difference returned by this routine
;		depends on the proper configuration of the computer.
;
; Side effects:	None.
;
; Category    :	Utilities, time.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 2 October 1994
;
; Modified    :	Version 1, William Thompson, GSFC, 2 October 1994
;		Version 2, William Thompson, GSFC, 3 October 1994
;			Added check for file local_diff.dat
;		Version 3, William Thompson, GSFC, 14 November 1994
;			Changed .DAY to .MJD
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 28 December 1994
;			Added the keyword ERRMSG.
;		Version 5, William Thompson, GSFC, 25 January 1995
;			Changed to call intrinsic ROUND instead of NINT.  The
;			version of NINT in the Astronomy User's Library doesn't
;			automatically select between short and long integers as
;			the CDS version does.
;		Version 6, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;		Version 7, William Thompson, GSFC, 15 March 1995
;			Changed CDS_TIME to TIME_CONV
;		Version 8, William Thompson, GSFC, 2 June 1997
;			Store information between calls in common block.
;
; Version     :	Version 8, 2 June 1997
;-
;
	COMMON LOCAL_DIFF, FILENAME, DIFF, TEST, LAST_READ
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check for the file "local_diff.dat".  If found, then read the value from it
;  and return.  Also, get the current time in seconds since 1 January 1970.
;  (Used to know when to reread local_diff.dat, and also below.)
;
	SECONDS = SYSTIME(1)
	IF N_ELEMENTS(LAST_READ) EQ 0 THEN LAST_READ = 0
	IF SECONDS GE (LAST_READ+86400.D0) THEN BEGIN
	    FILENAME = FIND_WITH_DEF('local_diff.dat','TIME_CONV','')
	    IF FILENAME NE '' THEN BEGIN
		ON_IOERROR, HANDLE_ERROR
		OPENR, UNIT, FILENAME, /GET_LUN
		DIFF = 0.0
		READF, UNIT, DIFF
;
;  Check to see if the second line in the file is "GMT".  (Needed for GET_UTC.)
;
		TEST = ""
		IF NOT EOF(UNIT) THEN READF, UNIT, TEST
		FREE_LUN, UNIT
		ON_IOERROR, NULL
		IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	    ENDIF
	    LAST_READ = SECONDS
	ENDIF
	IF FILENAME NE '' THEN RETURN, DIFF
;
;  It is assumed that the system time SECONDS is synchronized with UTC in some
;  way (e.g. through ntp for high accuracy), but that memory of leap seconds
;  insertions is not retained.  Also, get the local time as a character string.
;
	LOCAL = SYSTIME()
;
;  Calculate the Modified Julian Day number, and the number of milliseconds
;  into the day.
;
	DAYSECONDS = 24.D0 * 60.D0^2
	MJD = LONG(SECONDS/DAYSECONDS)
	UTC = {CDS_INT_TIME,		$
		MJD: 40587L + MJD,	$
		TIME: ROUND(1000*(SECONDS-MJD*DAYSECONDS))}
;
;  Convert the date into a seven-element structure.
;
	UTC_STR = INT2UTC(UTC, ERRMSG=ERRMSG)
	IF N_ELEMENTS(ERRSMG) NE 0 THEN $
		IF ERRMSG(0) NE '' THEN RETURN,0
;
;  Restructure the local time into a format usable by STR2UTC.  Make sure that
;  the day has no spaces in it.
;
	LOCAL_DAY = STRMID(TRIM(100+FIX(STRMID(LOCAL,8,2))),1,2)
	LOCAL = STRMID(LOCAL,20,4) + '-' +	$ ;Year
		STRMID(LOCAL,4,3) + '-' +	$ ;Month	
		LOCAL_DAY + ' ' +		$ ;Day
		STRMID(LOCAL,11,8)		  ;Time
	LOCAL = STR2UTC(LOCAL, ERRMSG=ERRMSG)
	IF N_ELEMENTS(ERRSMG) NE 0 THEN $
		IF ERRMSG(0) NE '' THEN RETURN,0
;
;  Convert the date into a seven element structure.
;
	LOCAL_STR = INT2UTC(LOCAL, ERRMSG=ERRMSG)
	IF N_ELEMENTS(ERRSMG) NE 0 THEN $
		IF ERRMSG(0) NE '' THEN RETURN,0
;
;  Calculate the difference in hours, to one minute precision.  (Some time
;  zones differ by 1/2 hour or 1/4 hour increments.)
;
	LOCAL_TIME = ROUND(LOCAL_STR.HOUR*60. + LOCAL_STR.MINUTE +	$
		(LOCAL_STR.SECOND + LOCAL_STR.MILLISECOND/1000.)/60.)
	UTC_TIME = ROUND(UTC_STR.HOUR*60. + UTC_STR.MINUTE +	$
		(UTC_STR.SECOND + UTC_STR.MILLISECOND/1000.)/60.)
	DIFF = (LOCAL_TIME - UTC_TIME) / 60.
;
;  If the local date is less than the UTC date, then subtract 24 hours.
;  Conversely, if the local date is greater than the UTC date, then add 24
;  hours.
;
	IF LOCAL.MJD LT UTC.MJD THEN DIFF = DIFF - 24
	IF LOCAL.MJD GT UTC.MJD THEN DIFF = DIFF + 24
;
;  Return the UTC date/time.
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN, DIFF
;
;  Error handling point.
;
HANDLE_ERROR:
	MESSAGE = 'Error reading file local_diff.dat'
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	FREE_LUN, UNIT
	RETURN, 0
	END
