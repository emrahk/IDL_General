	FUNCTION PRIV_ZDBASE, DEFINITION=DEFINITION, DAILY=DAILY,	$
		CATALOG=CATALOG, CPT=CPT, SEALED=SEALED,		$
		CALIBRATION=CALIBRATION, ERRMSG=ERRMSG, QUIET=XQUIET
;+
; Project     :	SOHO - CDS
;
; Name        :	PRIV_ZDBASE()
;
; Purpose     :	Checks if current database has write access.
;
; Explanation :	This routine checks to see if one has write access into the CDS
;		Definition, Daily, Catalog, Calibration and/or Sealed
;		databases.
;
; Use         :	Result = PRIV_ZDBASE(/keywords)
;
;		IF PRIV_ZDBASE(/keywords)
;
; Inputs      :	None.  However, at least one of the keywords /DEFINITION,
;		/DAILY, /CATALOG, /CPT, /CALIBRATION or /SEALED must be passed
;		to the routine.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is 1 if the user has privilege to
;		write into the requested databases, or 0 otherwise.
;
; Opt. Outputs: None.
;
; Keywords    : DEFINITION = If set, then check to see if the user has
;			     privilege to write into the study/raster
;			     definition databases.
;
;		DAILY	   = If set, then check to see if the user has
;			     privilege to write into the daily plan databases.
;
;		CATALOG	   = If set, then check to see if the user has
;			     privilege to write into the catalog databases.
;
;		CPT	   = If set, then check to see if the user has
;			     privilege to write into the databases used by CPT.
;
;		CALIBRATION= If set, then check to see if the user has
;			     privilege to write into the calibration databases.
;			     Normally, write access to these databases is
;			     restricted.
;
;		SEALED	   = If set, then check to see if the user has
;			     privilege to write into the "sealed" databases.
;			     Normally, write access to these databases is
;			     restricted.
;
;		See CDS software note #29 for a description of the above
;		database categories.  At least one of the above keywords must
;		be set.  If more than one is set, then the user must have
;		privilege to write into all the requested databases for a 1 to
;		be returned.
;
;		ERRMSG     = If defined and passed, then any error messages
;			     will be returned to the user in this parameter
;			     rather than depending on the MESSAGE routine in
;			     IDL.  If no errors are encountered, then a null
;			     string is returned.  In order to use this feature,
;			     ERRMSG must be defined first, e.g.
;
;				ERRMSG = ''
;				Result = PRIV_ZDBASE( ERRMSG=ERRMSG, ... )
;				IF ERRMSG NE '' THEN ...
;
;		QUIET	   = If set, then any error messages are not printed to
;			     the screen.  Using the ERRMSG keyword above
;			     automatically implies /QUIET.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	The software works by testing against three files,
;		study.dbf for the Definition databases, sci_plan.dbf for the
;		Daily databases, main.dbf for the Catalog databases,
;		comm_prep.dbf for the CPT databases, nis_wave.dbf for the
;		Calibration databases, and cdhsstate.dbf for the Sealed
;		databases.  The assumption is made that if one can open those
;		files for write, then one has write privilege for that entire
;		category of databases.
;
; Category    :	Planning, Database.
;
; Prev. Hist. :	Based on WR_DBASE by Dominic Zarro (ARC), 1 May 1995
;
; Written     :	Version 1, William Thompson, GSFC, 17 May 1995
;		Version 2, William Thompson, GSFC, 16 October 1995
;			Added keyword /CATALOG
;		Version 3, William Thompson, GSFC, 18 October 1995
;			Added keyword /CPT
;		Version 4, William Thompson, GSFC, 11 January 1996
;			Check cdhsstate instead of obsolete state database.
;		Version 5, William Thompson, GSFC, 31 January 1996
;			Fixed typo introduced in version 3.
;		Version 6, William Thompson, GSFC, 7 August 1996
;			Don't call getenv--let find_with_def handle it.
;		Version 7, William Thompson, GSFC, 16 September 1996
;			Added keyword CALIBRATION
;
; Version     :	Version 7, 16 September 1996
;-
;
	ON_ERROR, 2
;
;  Initialize the result to -1, and MESSAGE to the null string.  They will be
;  updated below.
;
	RESULT = -1
	MESSAGE = ''
;
;  Decide whether or not error messages should be written to the screen.
;
	QUIET = KEYWORD_SET(XQUIET) OR (N_ELEMENTS(ERRMSG) NE 0)
;
;  If requested, test to see if the user has write privilege in the Definitions
;  databases.
;
	IF KEYWORD_SET(DEFINITION) THEN BEGIN
		FILE = FIND_WITH_DEF('study.dbf', 'ZDBASE')
		RESULT = TEST_OPEN(FILE, /WRITE, QUIET=QUIET)
		IF RESULT EQ 0 THEN BEGIN
			MESSAGE = 'No write privilege in Definition databases'
			GOTO, HANDLE_ERROR
		ENDIF
	ENDIF
;
;  If requested, test to see if the user has write privilege in the Daily Plan
;  databases.
;
	IF KEYWORD_SET(DAILY) THEN BEGIN
		FILE = FIND_WITH_DEF('sci_plan.dbf', 'ZDBASE')
		RESULT = TEST_OPEN(FILE, /WRITE, QUIET=QUIET)
		IF RESULT EQ 0 THEN BEGIN
			MESSAGE = 'No write privilege in Daily Plan databases'
			GOTO, HANDLE_ERROR
		ENDIF
	ENDIF
;
;  If requested, test to see if the user has write privilege in the Catalog
;  databases.
;
	IF KEYWORD_SET(CATALOG) THEN BEGIN
		FILE = FIND_WITH_DEF('main.dbf', 'ZDBASE')
		RESULT = TEST_OPEN(FILE, /WRITE, QUIET=QUIET)
		IF RESULT EQ 0 THEN BEGIN
			MESSAGE = 'No write privilege in Catalog databases'
			GOTO, HANDLE_ERROR
		ENDIF
	ENDIF
;
;  If requested, test to see if the user has write privilege in the CPT
;  databases.
;
	IF KEYWORD_SET(CPT) THEN BEGIN
		FILE = FIND_WITH_DEF('comm_prep.dbf', 'ZDBASE')
		RESULT = TEST_OPEN(FILE, /WRITE, QUIET=QUIET)
		IF RESULT EQ 0 THEN BEGIN
			MESSAGE = 'No write privilege in CPT databases'
			GOTO, HANDLE_ERROR
		ENDIF
	ENDIF
;
;  If requested, test to see if the user has write privilege in the Sealed
;  databases.
;
	IF KEYWORD_SET(SEALED) THEN BEGIN
		FILE = FIND_WITH_DEF('cdhsstate.dbf', 'ZDBASE')
		RESULT = TEST_OPEN(FILE, /WRITE, QUIET=QUIET)
		IF RESULT EQ 0 THEN BEGIN
			MESSAGE = 'No write privilege in Sealed databases'
			GOTO, HANDLE_ERROR
		ENDIF
	ENDIF
;
;  If requested, test to see if the user has write privilege in the Calibration
;  databases.
;
	IF KEYWORD_SET(CALIBRATION) THEN BEGIN
		FILE = FIND_WITH_DEF('nis_wave.dbf', 'ZDBASE')
		RESULT = TEST_OPEN(FILE, /WRITE, QUIET=QUIET)
		IF RESULT EQ 0 THEN BEGIN
			MESSAGE = 'No write privilege in Calibration databases'
			GOTO, HANDLE_ERROR
		ENDIF
	ENDIF
;
;  If RESULT is still -1, then the user must not have passed any keywords.
;
	IF RESULT EQ -1 THEN BEGIN
		MESSAGE = 'At least one of the keywords /DEFINITION, ' + $
			'/DAILY, /CATALOG, /CPT, /CALIBRATION, or ' +	$
			'/SEALED must be passed'
		RESULT = 0
		GOTO, HANDLE_ERROR
	ENDIF
;
	GOTO, FINISH
;
;  Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) NE 0 THEN BEGIN
		ERRMSG = 'PRIV_ZDBASE: ' + MESSAGE
	END ELSE IF NOT KEYWORD_SET(QUIET) THEN BEGIN
		MESSAGE, MESSAGE, /CONTINUE
	ENDIF
;
;  Exit point.
;
FINISH:
	RETURN, RESULT
	END
