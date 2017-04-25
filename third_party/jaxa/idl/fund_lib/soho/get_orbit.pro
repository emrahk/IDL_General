	FUNCTION GET_ORBIT, DATE, TYPE, OLD=OLD, ERRMSG=ERRMSG, RETAIN=RETAIN
;+
; Project     :	SOHO - CDS
;
; Name        :	GET_ORBIT()
;
; Purpose     :	Get the SOHO orbit information.
;
; Category    :	Class3, Orbit
;
; Explanation :	Reads orbit information from either the definitive or
;		predictive orbit file, whichever it can find first.
;
; Syntax      :	Result = GET_ORBIT( DATE  [, TYPE ] )
;
; Examples    :	
;
; Inputs      :	DATE	= The date/time value to get the orbit information for.
;			  Can be in any CDS time format.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a structure containing the
;		spacecraft orbit information.  It contains the following tags.
;
;
;		If unable to find this information, zeroes are returned
;		instead.
;
; Opt. Outputs:	TYPE	= Returns whether predictive or definitive data was
;			  used to calculate the result.  Returned as either
;			  "Definitive" or "Predictive".  If the routine fails
;			  to return an answer, then the null string is
;			  returned.
;
; Keywords    :	RETAIN	= No longer used.  Kept for backwards compatibility.
;
;		ERRMSG	= If defined and passed, then any error messages will
;			  be returned to the user in this parameter rather than
;			  depending on the MESSAGE routine in IDL.  If no
;			  errors are encountered, then a null string is
;			  returned.  In order to use this feature, ERRMSG must
;			  be defined first, e.g.
;
;				ERRMSG = ''
;				Result = GET_ORBIT( ERRMSG=ERRMSG, ... )
;				IF ERRMSG NE '' THEN ...
;
;		OLD	= If set, then files are read in from the subdirectory
;			  "old_samples".  This is used to test the software
;			  until real data files are available.
;
; Calls       :	CONCAT_DIR, FXBOPEN, FXBREAD
;
; Common      :	Private common block GET_ORBIT is used to store data from the
;		last orbit file read.  Speeds up subsequent reads when the same
;		day is referenced.
;
; Restrictions:	The orbit entries for the time closest to that requested is
;		used to calculate the orbit parameters.  Since the orbit data
;		is calculated every 10 minutes, this should be correct within
;		+/-5 minutes.  No attempt is made to interpolate to closer
;		accuracy than that.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 04-Dec-1995, William Thompson, GSFC
;		Version 2, 03-Sep-1996, William Thompson, GSFC
;			Also look for filename with a dollar sign
;			prepended--this is how VMS treats uppercase filenames.
;		Version 3, 11-Oct-1996, William Thompson, GSFC
;			Only prepend $ in VMS.  Use in both places where
;			needed.
;		Version 4, 22-Nov-1996, William Thompson, GSFC
;			Fixed bug introduced in version 3, where only
;			predictive data was being returned in Unix.
;		Version 5, 22-Jan-1997, William Thompson, GSFC
;			Modified to reflect reorganization of orbit files.
;		Version 6, 30-Jan-1997, William Thompson, GSFC
;			Fixed VMS bug introduced in version 5
;		Version 7, 28-Mar-2002, William Thompson, GSFC
;			Replaced RETAIN keyword with reading in entire file,
;			and storing in common block.
;               Version 8, 10-Sep-2008, William Thompson, GSFC
;                       Use alternative SPICE ephemerides when available.  This
;                       option requires that the STEREO software be loaded.
;
; Contact     :	WTHOMPSON
;-
;
;	ON_ERROR, 2
	COMMON GET_ORBIT, LAST_DATE, UNIT, ROWS, TIME, GCI_X, GCI_Y, GCI_Z, $
		GCI_VX, GCI_VY, GCI_VZ, GSE_X, GSE_Y, GSE_Z, GSE_VX, GSE_VY, $
		GSE_VZ, GSM_X, GSM_Y, GSM_Z, GSM_VX, GSM_VY, GSM_VZ,	$
		SUN_VECTOR_X, SUN_VECTOR_Y, SUN_VECTOR_Z, HEC_X, HEC_Y,	$
		HEC_Z, HEC_VX, HEC_VY, HEC_VZ, CAR_ROT_EARTH, HEL_LON_EARTH, $
		HEL_LAT_EARTH, CAR_ROT_SOHO, HEL_LON_SOHO, HEL_LAT_SOHO
;
;  Make sure that LAST_DATE is defined.
;
	IF N_ELEMENTS(LAST_DATE) EQ 0 THEN LAST_DATE = ''
;
;  Initialize RESULT.  If the routine is successful, this will be updated
;  later.
;
	RESULT = {SOHO_ORBIT,		$
		GCI_X:		0.0,	$
		GCI_Y:		0.0,	$
		GCI_Z:		0.0,	$
		GCI_VX:		0.0,	$
		GCI_VY:		0.0,	$
		GCI_VZ:		0.0,	$
		GSE_X:		0.0,	$
		GSE_Y:		0.0,	$
		GSE_Z:		0.0,	$
		GSE_VX:		0.0,	$
		GSE_VY:		0.0,	$
		GSE_VZ:		0.0,	$
		GSM_X:		0.0,	$
		GSM_Y:		0.0,	$
		GSM_Z:		0.0,	$
		GSM_VX:		0.0,	$
		GSM_VY:		0.0,	$
		GSM_VZ:		0.0,	$
		SUN_VECTOR_X:	0.0,	$
		SUN_VECTOR_Y:	0.0,	$
		SUN_VECTOR_Z:	0.0,	$
		HEC_X:		0.0,	$
		HEC_Y:		0.0,	$
		HEC_Z:		0.0,	$
		HEC_VX:		0.0,	$
		HEC_VY:		0.0,	$
		HEC_VZ:		0.0,	$
		CAR_ROT_EARTH:	0.0,	$
		HEL_LON_EARTH:	0.0,	$
		HEL_LAT_EARTH:	0.0,	$
		CAR_ROT_SOHO:	0.0,	$
		HEL_LON_SOHO:	0.0,	$
		HEL_LAT_SOHO:	0.0}
	TYPE = ""
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = GET_ORBIT( DATE  [, TYPE ] )'
		GOTO, HANDLE_ERROR
	ENDIF
;
;  Make up to two passes through the software.  In the first pass, look in the
;  top level directory.  In the second pass, if needed, try appending the year
;  to the directory.
;
	USE_YEAR = 0
	TEMP = ANYTIM2UTC(DATE,/EXT)
	S_YEAR = TRIM(TEMP.YEAR)
START_PASS:
;
;  Form the filename for the definitive orbit file.
;
	TYPE = "Definitive"
	PATH = CONCAT_DIR('$ANCIL_DATA', 'orbit', /DIR)
	PATH = CONCAT_DIR(PATH, 'definitive', /DIR)
	IF KEYWORD_SET(OLD) THEN PATH = CONCAT_DIR(PATH, 'old_samples', /DIR)
	IF USE_YEAR THEN PATH = CONCAT_DIR(PATH, S_YEAR, /DIR)
	SDATE = ANYTIM2CAL(DATE,FORM=8,/DATE)
	NAME = 'SO_OR_DEF_' + SDATE + '_V*.FITS'
	FILENAME = CONCAT_DIR(PATH, NAME)
;
;  Look for any files that match the search criteria.
;
	IF SDATE NE LAST_DATE THEN BEGIN
	    FILES = FINDFILE(FILENAME, COUNT=COUNT)
	    IF COUNT EQ 0 THEN BEGIN
		IF OS_FAMILY() EQ 'vms' THEN BEGIN
		    FILENAME = CONCAT_DIR(PATH, '$'+NAME)
		    FILES = FINDFILE(FILENAME, COUNT=COUNT)
		ENDIF
		IF COUNT GT 0 THEN GOTO, READ_FILE
	    END ELSE GOTO, READ_FILE
;
;  No definitive file was found.  Form the filename for the predictive orbit
;  file.
;
	    TYPE = "Predictive"
	    PATH = CONCAT_DIR('$ANCIL_DATA', 'orbit', /DIR)
	    PATH = CONCAT_DIR(PATH, 'predictive', /DIR)
	    IF KEYWORD_SET(OLD) THEN PATH =	$
		    CONCAT_DIR(PATH, 'old_samples', /DIR)
	    IF USE_YEAR THEN PATH = CONCAT_DIR(PATH, S_YEAR, /DIR)
	    NAME = 'SO_OR_PRE_' + SDATE + '_V*.FITS'
	    FILENAME = CONCAT_DIR(PATH, NAME)
;
;  Look for any files that match the search criteria.
;
	    FILES = FINDFILE(FILENAME, COUNT=COUNT)
	    IF COUNT EQ 0 THEN BEGIN
		IF OS_FAMILY() EQ 'vms' THEN BEGIN
		    FILENAME = CONCAT_DIR(PATH, '$'+NAME)
		    FILES = FINDFILE(FILENAME, COUNT=COUNT)
		ENDIF
		IF COUNT EQ 0 THEN BEGIN
		    IF USE_YEAR THEN BEGIN
			MESSAGE = 'No orbit files found for requested date'
			TYPE = ""
			GOTO, TRY_SPICE
		    END ELSE BEGIN
			USE_YEAR = 1
			GOTO, START_PASS
		    ENDELSE
		ENDIF
	    ENDIF
;
;  A file was found.  Read in the one with the highest version number.
;
READ_FILE:
	    IF COUNT GT 1 THEN FILES = FILES(REVERSE(SORT(FILES)))
	    FXBOPEN, UNIT, FILES(0), 1
	    LAST_DATE = SDATE
;
;  Read in the year and the time.  Filter out any entries with a zero year.
;
	    FXBREAD, UNIT, YEAR, 'YEAR'
	    FXBREAD, UNIT, TIME, 'ELLAPSED MILLISECONDS OF DAY'
	    ROWS = INDGEN(N_ELEMENTS(YEAR)) + 1
	    W = WHERE(YEAR NE 0, COUNT)
	    IF COUNT EQ 0 THEN BEGIN
		MESSAGE = 'Empty data file'
		GOTO, HANDLE_ERROR
	    ENDIF
	    ROWS = ROWS(W)
	    TIME = TIME(W)
	ENDIF
;
;  Find the closest entry to the target time.
;
	TARGET = ANYTIM2UTC(DATE)
	TARGET = TARGET.TIME
	DIFF = ABS(TIME - TARGET)
	MINDIF = MIN(DIFF, W)
	ROW = ROWS(W)
;
;  Read in the orbit parameters.
;
	IF FXBISOPEN(UNIT) THEN BEGIN
	    FXBREAD, UNIT, GCI_X,	  'GCI X (KM)'
	    FXBREAD, UNIT, GCI_Y,	  'GCI Y (KM)'
	    FXBREAD, UNIT, GCI_Z,	  'GCI Z (KM)'
	    FXBREAD, UNIT, GCI_VX,	  'GCI VX (KM/S)'
	    FXBREAD, UNIT, GCI_VY,	  'GCI VY (KM/S)'
	    FXBREAD, UNIT, GCI_VZ,	  'GCI VZ (KM/S)'
	    FXBREAD, UNIT, GSE_X,	  'GSE X (KM)'
	    FXBREAD, UNIT, GSE_Y,	  'GSE Y (KM)'
	    FXBREAD, UNIT, GSE_Z,	  'GSE Z (KM)'
	    FXBREAD, UNIT, GSE_VX,	  'GSE VX (KM/S)'
	    FXBREAD, UNIT, GSE_VY,	  'GSE VY (KM/S)'
	    FXBREAD, UNIT, GSE_VZ,	  'GSE VZ (KM/S)'
	    FXBREAD, UNIT, GSM_X,	  'GSM X (KM)'
	    FXBREAD, UNIT, GSM_Y,	  'GSM Y (KM)'
	    FXBREAD, UNIT, GSM_Z,	  'GSM Z (KM)'
	    FXBREAD, UNIT, GSM_VX,	  'GSM VX (KM/S)'
	    FXBREAD, UNIT, GSM_VY,	  'GSM VY (KM/S)'
	    FXBREAD, UNIT, GSM_VZ,	  'GSM VZ (KM/S)'
	    FXBREAD, UNIT, SUN_VECTOR_X,  'SUN VECTOR X (KM)'
	    FXBREAD, UNIT, SUN_VECTOR_Y,  'SUN VECTOR Y (KM)'
	    FXBREAD, UNIT, SUN_VECTOR_Z,  'SUN VECTOR Z (KM)'
	    FXBREAD, UNIT, HEC_X,	  'HEC X (KM)'
	    FXBREAD, UNIT, HEC_Y,	  'HEC Y (KM)'
	    FXBREAD, UNIT, HEC_Z,	  'HEC Z (KM)'
	    FXBREAD, UNIT, HEC_VX,	  'HEC VX (KM/S)'
	    FXBREAD, UNIT, HEC_VY,	  'HEC VY (KM/S)'
	    FXBREAD, UNIT, HEC_VZ,	  'HEC VZ (KM/S)'
	    FXBREAD, UNIT, CAR_ROT_EARTH, 'CARRINGTON ROTATION EARTH'
	    FXBREAD, UNIT, HEL_LON_EARTH, 'HELIOGRAPHIC LONG. EARTH'
	    FXBREAD, UNIT, HEL_LAT_EARTH, 'HELIOGRAPHIC LAT. EARTH'
	    FXBREAD, UNIT, CAR_ROT_SOHO,  'CARRINGTON ROTATION SOHO'
	    FXBREAD, UNIT, HEL_LON_SOHO,  'HELIOGRAPHIC LONG. SOHO'
	    FXBREAD, UNIT, HEL_LAT_SOHO,  'HELIOGRAPHIC LAT. SOHO'
	ENDIF
;
;  Store the result in the output structure.
;
	RESULT.GCI_X		= GCI_X(ROW-1)
	RESULT.GCI_Y		= GCI_Y(ROW-1)
	RESULT.GCI_Z		= GCI_Z(ROW-1)
	RESULT.GCI_VX		= GCI_VX(ROW-1)
	RESULT.GCI_VY		= GCI_VY(ROW-1)
	RESULT.GCI_VZ		= GCI_VZ(ROW-1)
	RESULT.GSE_X		= GSE_X(ROW-1)
	RESULT.GSE_Y		= GSE_Y(ROW-1)
	RESULT.GSE_Z		= GSE_Z(ROW-1)
	RESULT.GSE_VX		= GSE_VX(ROW-1)
	RESULT.GSE_VY		= GSE_VY(ROW-1)
	RESULT.GSE_VZ		= GSE_VZ(ROW-1)
	RESULT.GSM_X		= GSM_X(ROW-1)
	RESULT.GSM_Y		= GSM_Y(ROW-1)
	RESULT.GSM_Z		= GSM_Z(ROW-1)
	RESULT.GSM_VX		= GSM_VX(ROW-1)
	RESULT.GSM_VY		= GSM_VY(ROW-1)
	RESULT.GSM_VZ		= GSM_VZ(ROW-1)
	RESULT.SUN_VECTOR_X	= SUN_VECTOR_X(ROW-1)
	RESULT.SUN_VECTOR_Y	= SUN_VECTOR_Y(ROW-1)
	RESULT.SUN_VECTOR_Z	= SUN_VECTOR_Z(ROW-1)
	RESULT.HEC_X		= HEC_X(ROW-1)
	RESULT.HEC_Y		= HEC_Y(ROW-1)
	RESULT.HEC_Z		= HEC_Z(ROW-1)
	RESULT.HEC_VX		= HEC_VX(ROW-1)
	RESULT.HEC_VY		= HEC_VY(ROW-1)
	RESULT.HEC_VZ		= HEC_VZ(ROW-1)
	RESULT.CAR_ROT_EARTH	= CAR_ROT_EARTH(ROW-1)
	RESULT.HEL_LON_EARTH	= HEL_LON_EARTH(ROW-1)
	RESULT.HEL_LAT_EARTH	= HEL_LAT_EARTH(ROW-1)
	RESULT.CAR_ROT_SOHO	= CAR_ROT_SOHO(ROW-1)
	RESULT.HEL_LON_SOHO	= HEL_LON_SOHO(ROW-1)
	RESULT.HEL_LAT_SOHO	= HEL_LAT_SOHO(ROW-1)
	GOTO, FINISH
;
;  Alternative SPICE ephemerides.  If SPICE is not available, then proceed to
;  the error handling code with the already stored error message.
;
TRY_SPICE:
        WHICH, 'test_spice_icy_dlm', OUTFILE=OUTFILE, /QUIET
        IF OUTFILE EQ '' THEN GOTO, HANDLE_ERROR
        IF NOT CALL_FUNCTION('TEST_SPICE_ICY_DLM') THEN GOTO, HANDLE_ERROR
;
;  Load the SOHO SPICE files.
;
        MESSAGE = ''
        LOAD_SOHO_SPICE, ERRMSG=MESSAGE
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Read in the SPICE data.
;
        GCI = CALL_FUNCTION('GET_STEREO_COORD', DATE, 'SOHO', SYSTEM='GEI', $
                            ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        RESULT.GCI_X = GCI[0]  &  RESULT.GCI_VX = GCI[3]
        RESULT.GCI_Y = GCI[1]  &  RESULT.GCI_VY = GCI[4]
        RESULT.GCI_Z = GCI[2]  &  RESULT.GCI_VZ = GCI[5]
;
        GSE = CALL_FUNCTION('GET_STEREO_COORD', DATE, 'SOHO', SYSTEM='GSE', $
                            ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        RESULT.GSE_X = GSE[0]  &  RESULT.GSE_VX = GSE[3]
        RESULT.GSE_Y = GSE[1]  &  RESULT.GSE_VY = GSE[4]
        RESULT.GSE_Z = GSE[2]  &  RESULT.GSE_VZ = GSE[5]
;
        GSM = CALL_FUNCTION('GET_STEREO_COORD', DATE, 'SOHO', SYSTEM='GSM', $
                            ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        RESULT.GSM_X = GSM[0]  &  RESULT.GSM_VX = GSM[3]
        RESULT.GSM_Y = GSM[1]  &  RESULT.GSM_VY = GSM[4]
        RESULT.GSM_Z = GSM[2]  &  RESULT.GSM_VZ = GSM[5]
;
        VEC = CALL_FUNCTION('GET_STEREO_COORD', DATE, 'SUN', SYSTEM='GEI', $
                            ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        RESULT.SUN_VECTOR_X = VEC[0]
        RESULT.SUN_VECTOR_Y = VEC[1]
        RESULT.SUN_VECTOR_Z = VEC[2]
;
        HEC = CALL_FUNCTION('GET_STEREO_COORD', DATE, 'SOHO', SYSTEM='HAE', $
                            ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        RESULT.HEC_X = HEC[0]  &  RESULT.HEC_VX = HEC[3]
        RESULT.HEC_Y = HEC[1]  &  RESULT.HEC_VY = HEC[4]
        RESULT.HEC_Z = HEC[2]  &  RESULT.HEC_VZ = HEC[5]
;
        CAR_ROT = CALL_FUNCTION('GET_STEREO_CARR_ROT', DATE, 'EARTH', $
                                ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        RESULT.CAR_ROT_EARTH = FLOOR(CAR_ROT)
;
        LONLAT = CALL_FUNCTION('GET_STEREO_LONLAT', DATE, 'EARTH', $
                               SYSTEM='Carrington', ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        TWOPI = 2.D0 * !DPI
        IF LONLAT[1] LT 0 THEN LONLAT[1] = LONLAT[1] + TWOPI
        RESULT.HEL_LON_EARTH = LONLAT[1]
        RESULT.HEL_LAT_EARTH = LONLAT[2]
;
        CAR_ROT = CALL_FUNCTION('GET_STEREO_CARR_ROT', DATE, 'SOHO', $
                                ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        RESULT.CAR_ROT_SOHO = FLOOR(CAR_ROT)
;
        LONLAT = CALL_FUNCTION('GET_STEREO_LONLAT', DATE, 'SOHO', $
                               SYSTEM='Carrington', ERRMSG=MESSAGE)
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
        IF LONLAT[1] LT 0 THEN LONLAT[1] = LONLAT[1] + TWOPI
        RESULT.HEL_LON_SOHO = LONLAT[1]
        RESULT.HEL_LAT_SOHO = LONLAT[2]
;
        TYPE = 'Predictive'
        GOTO, FINISH
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = 'GET_ORBIT: ' + MESSAGE $
		ELSE MESSAGE, MESSAGE, /CONTINUE
;
;  Close the FITS file and return the result.
;
FINISH:
	IF FXBISOPEN(UNIT) THEN FXBCLOSE, UNIT
	UNIT = -1
	RETURN, RESULT
;
	END
