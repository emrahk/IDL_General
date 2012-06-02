	PRO FXBFIND,P1,KEYWORD,COLUMNS,VALUES,N_FOUND,DEFAULT
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FXBFIND
; Purpose     : 
;	Find column keywords in a FITS binary table header.
; Explanation : 
;	Finds the value of a column keyword for all the columns in the binary
;	table for which it is set.  For example,
;
;		FXBFIND, UNIT, 'TTYPE', COLUMNS, VALUES, N_FOUND
;
;	Would find all instances of the keywords TTYPE1, TTYPE2, etc.  The
;	array COLUMNS would contain the column numbers for which a TTYPEn
;	keyword was found, and VALUES would contain the values.  N_FOUND would
;	contain the total number of instances found.
;
; Use         : 
;	FXBFIND, [UNIT or HEADER], KEYWORD, COLUMNS, VALUES, N_FOUND
;		[, DEFAULT ]
; Inputs      : 
;	Either UNIT or HEADER must be passed.
;
;	UNIT	= Logical unit number of file opened by FXBOPEN.
;	HEADER	= FITS binary table header.
;	KEYWORD	= Prefix to a series of FITS binary table column keywords.  The
;		  keywords to be searched for are formed by combining this
;		  prefix with the numbers 1 through the value of TFIELDS in the
;		  header.
; Opt. Inputs : 
;	DEFAULT	= Default value to use for any column keywords that aren't
;		  found.  If passed, then COLUMNS and VALUES will contain
;		  entries for every column.  Otherwise, COLUMNS and VALUES only
;		  contain entries for columns where values were found.
; Outputs     : 
;	COLUMNS	= Array containing the column numbers for which values of the
;		  requested keyword series were found.
;	VALUES	= Array containing the found values.
;	N_FOUND	= Number of values found.  The value of this parameter is
;		  unaffected by whether or not DEFAULT is passed.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	None.
; Calls       : 
;	FXBFINDLUN, FXPAR
; Common      : 
;	Uses common block FXBINTABLE--see "fxbintable.pro" for more
;	information.
; Restrictions: 
;	If UNIT is passed, then the file must have been opened with FXBOPEN.
;	If HEADER is passed, then it must be a legal FITS binary table header.
;
;	The type of DEFAULT must be consistent with the values of the requested
;	keywords, i.e. both most be either of string or numerical type.
;
;	The KEYWORD prefix must not have more than five characters to leave
;	room for the three digits allowed for the column numbers.
;
; Side effects: 
;	None.
; Category    : 
;	Data Handling, I/O, FITS, Generic.
; Prev. Hist. : 
;	William Thompson, Feb. 1992.
; Written     : 
;	William Thompson, GSFC, February 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 12 April 1993.
;		Incorporated into CDS library.
; Version     : 
;	Version 1, 12 April 1993.
;-
;
@fxbintable
	ON_ERROR,2
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 5 THEN MESSAGE,	$
		'Syntax:  FXBFIND,[UNIT/HEADER],KEYWORD,COLUMNS,VALUES,' + $
		'N_FOUND [,DEFAULT]'
;
;  Get the header.
;
	IF N_ELEMENTS(P1) EQ 1 THEN BEGIN
		ILUN = FXBFINDLUN(P1)
		HEADER = HEAD(*,ILUN)
	END ELSE HEADER = P1
;
;  Get the value of TFIELDS from HEADER.
;
	TFIELDS0 = FXPAR(HEADER,'TFIELDS')
	IF TFIELDS0 EQ 0 THEN MESSAGE,'No columns found in HEADER'
;
;  Step through the columns one by one.
;
	N_COLUMNS = 0
	N_FOUND = 0
	FOR I = 1,TFIELDS0 DO BEGIN
		VALUE = FXPAR(HEADER,STRTRIM(KEYWORD,2)+STRTRIM(I,2))
		IF !ERR GE 0 THEN BEGIN
			N_FOUND = N_FOUND + 1
			ADD_COL = 1
		END ELSE IF N_PARAMS() EQ 6 THEN BEGIN
			VALUE = DEFAULT
			ADD_COL = 1
		END ELSE BEGIN
			ADD_COL = 0
		ENDELSE
;
;  Append the found (or default) data to the arrays.
;
		IF ADD_COL THEN BEGIN
			IF N_COLUMNS EQ 0 THEN BEGIN
				COLUMNS = I
				VALUES = VALUE
			END ELSE BEGIN
				COLUMNS = [COLUMNS,I]
				VALUES = [VALUES,VALUE]
			ENDELSE
			N_COLUMNS = N_COLUMNS + 1
		ENDIF
	ENDFOR
;
	RETURN
	END
