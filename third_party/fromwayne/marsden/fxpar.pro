	FUNCTION FXPAR, HDR, NAME, ABORT, COUNT=MATCHES, COMMENT=COMMENTS
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FXPAR()
; Purpose     : 
;	Obtain the value of a parameter in a FITS header.
; Explanation : 
;	The first 8 chacters of each element of HDR are searched for a match to
;	NAME.  If the keyword is one of those allowed to take multiple values
;	("HISTORY", "COMMENT", or "        " (blank)), then the value is taken
;	as the next 72 characters.  Otherwise, it is assumed that the next
;	character is "=", and the value (and optional comment) is then parsed
;	from the last 71 characters.  An error occurs if there is no parameter
;	with the given name.
;
;	Complex numbers are recognized as two numbers separated by one or more
;	space characters.
;
;	If a numeric value has no decimal point (or E or D) it is returned as
;	type LONG.  If it contains more than 8 numerals, or contains the
;	character 'D', then it is returned as type DOUBLE.  Otherwise it is
;	returned as type FLOAT
; Use         : 
;	Result = FXPAR( HDR, NAME  [, ABORT ] )
;
;	Result = FXPAR(HEADER,'DATE')		;Finds the value of DATE
;	Result = FXPAR(HEADER,'NAXIS*')		;Returns array dimensions as
;						;vector
; Inputs      : 
;	HDR	= FITS header string array (e.g. as returned by FXREAD).  Each
;		  element should have a length of 80 characters
;	NAME	= String name of the parameter to return.  If NAME is of the
;		  form 'keyword*' then an array is returned containing values
;		  of keywordN where N is an integer.  The value of keywordN
;		  will be placed in RESULT(N-1).  The data type of RESULT will
;		  be the type of the first valid match of keywordN found.
; Opt. Inputs : 
;	ABORT	= String specifying that FXPAR should do a RETALL if a
;		  parameter is not found.  ABORT should contain a string to be
;		  printed if the keyword parameter is not found.  If not
;		  supplied, FXPAR will return with a negative !err if a keyword
;		  is not found.
; Outputs     : 
;	The returned value of the function is the value(s) associated with the
;	requested keyword in the header array.
;
;	If the parameter is complex, double precision, floating point, long or
;	string, then the result is of that type.  Apostrophes are stripped from
;	strings.  If the parameter is logical, 1 is returned for T, and 0 is
;	returned for F.
;
;	If NAME was of form 'keyword*' then a vector of values are returned.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	COUNT	= Optional keyword to return a value equal to the number of
;		  parameters found by FXPAR.
;	COMMENTS= Array of comments associated with the returned values.
; Calls       : 
;	GETTOK, STRNUMBER
; Common      : 
;	None.
; Restrictions: 
;	None.
; Side effects: 
;	Keyword COUNT returns the number of parameters found.
;
;	The system variable !err is set to -1 if parameter not found, 0 for a
;	scalar value returned.  If a vector is returned it is set to the number
;	of keyword matches found.
;
;	If a keyword occurs more than once in a header, a warning is given,
;	and the first occurence is used.  However, if the keyword is "HISTORY",
;	"COMMENT", or "        " (blank), then multiple values are returned.
; Category    : 
;	Data Handling, I/O, FITS, Generic.
; Prev. Hist. : 
;	DMS, May, 1983, Written.
;	D. Lindler Jan 90 added ABORT input parameter
;	J. Isensee Jul,90 added COUNT keyword
;	W. Thompson, Feb. 1992, added support for FITS complex values.
;	W. Thompson, Oct. 1992, rewrote to change strategy for extracting
;		values to allow for non-standard formats and renamed to FXPAR.
;		Added COMMENT keyword.
; Written     : 
;	David M. Stern, RSI, May 1983.
; Modified    : 
;	Version 1, William Thompson, GSFC, 12 April 1993.
;		Incorporated into CDS library.
; Version     : 
;	Version 1, 12 April 1993.
;-
;------------------------------------------------------------------------------
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 2 THEN BEGIN
	    PRINT,'Syntax:  result =  FXPAR( HDR, NAME  [, ABORT ])'
	    RETURN, -1
	ENDIF
;
;  Determine the abort condition.
;
	VALUE = 0
	IF N_PARAMS() LE 2 THEN BEGIN
	    ABORT_RETURN = 0
	    ABORT = 'FITS Header'
	END ELSE ABORT_RETURN = 1
	IF ABORT_RETURN THEN ON_ERROR,1 ELSE ON_ERROR,2
;
;  Check for valid header.  Check header for proper attributes.
;
	S = SIZE(HDR)
	IF ( S(0) NE 1 ) OR ( S(2) NE 7 ) THEN $
	    MESSAGE,'FITS Header (first parameter) must be a string array'
;
;  Convert the selected keyword NAME to uppercase.
;
	NAM = STRTRIM( STRUPCASE(NAME) )
;
;  Determine if NAME is of form 'keyword*'.  If so, then strip off the '*', and
;  set the VECTOR flag.
;
	IF STRPOS( NAM, '*' ) EQ STRLEN( NAM ) - 1 THEN BEGIN    
	    NAM = STRMID( NAM, 0, STRLEN( NAM ) - 1)  
	    VECTOR = 1				;Flag for vector output  
	    NAME_LENGTH = STRLEN(NAM)  		;Length of name 
	    NUM_LENGTH = 8 - NAME_LENGTH 	;Max length of number portion  
	    IF NUM_LENGTH LE 0 THEN MESSAGE,	$
		'Keyword length must be 8 characters or less'
;
;  Otherwise, extend NAME with blanks to eight characters.
;
	ENDIF ELSE BEGIN
	    WHILE STRLEN(NAM) LT 8 DO NAM = NAM + ' '
	    VECTOR = 0
	ENDELSE
;
;  If of the form 'keyword*', then find all instances of 'keyword' followed by
;  a number.  Store the positions of the located keywords in NFOUND, and the
;  value of the number field in NUMBER.
;
	KEYWORD = STRMID( HDR, 0, 8)
	IF VECTOR THEN BEGIN
	    NFOUND = WHERE(STRPOS(KEYWORD,NAM) GE 0, MATCHES)
	    IF ( MATCHES GT 0 ) THEN BEGIN
		NUMST= STRMID(HDR(NFOUND), NAME_LENGTH, NUM_LENGTH)
		NUMBER = INTARR(MATCHES)-1
		FOR I = 0, MATCHES-1 DO		$
		    IF STRNUMBER( NUMST(I), NUM) THEN NUMBER(I) = NUM
		IGOOD = WHERE(NUMBER GE 0, MATCHES)
		IF MATCHES GT 0 THEN BEGIN
		    NFOUND = NFOUND(IGOOD)
		    NUMBER = NUMBER(IGOOD)
		ENDIF
	    ENDIF
;
;  Otherwise, find all the instances of the requested keyword.  If more than
;  one is found, and NAME is not one of the special cases, then print an error
;  message.
;
	ENDIF ELSE BEGIN
	    NFOUND = WHERE(KEYWORD EQ NAM, MATCHES)
	    IF (MATCHES GT 1) AND (NAM NE 'HISTORY ') AND		$
		(NAM NE 'COMMENT ') AND (NAM NE '        ') THEN	$
		MESSAGE,/INFORMATIONAL, 'WARNING- Keyword ' +	$
		NAM + 'located more than once in ' + ABORT
	ENDELSE
;
;  Extract the parameter field from the specified header lines.  If one of the
;  special cases, then done.
;
	IF MATCHES GT 0 THEN BEGIN
	    LINE = HDR(NFOUND)
	    SVALUE = STRTRIM( STRMID(LINE,9,71),2)
	    IF (NAM EQ 'HISTORY ') OR (NAM EQ 'COMMENT ') OR	$
		    (NAM EQ '        ') THEN BEGIN
		VALUE = STRTRIM( STRMID(LINE,8,72),2)
		COMMENTS = STRARR(N_ELEMENTS(VALUE))
;
;  Otherwise, test to see if the parameter contains a string, signalled by
;  beginning with a single quote character (') (apostrophe).
;
	    END ELSE FOR I = 0,MATCHES-1 DO BEGIN
		IF ( STRMID(SVALUE(I),0,1) EQ "'" ) THEN BEGIN
		    TEST = STRMID( SVALUE(I),1,STRLEN( SVALUE(I) )-1)
		    NEXT_CHAR = 0
		    VALUE = ''
;
;  Find the next apostrophe.
;
NEXT_APOST:
		    ENDAP = STRPOS(TEST, "'", NEXT_CHAR)
		    IF ENDAP LT 0 THEN MESSAGE,		$
			'Value of '+NAME+' invalid in '+ABORT
		    VALUE = VALUE + STRMID( TEST, NEXT_CHAR, ENDAP-NEXT_CHAR )
;
;  Test to see if the next character is also an apostrophe.  If so, then the
;  string isn't completed yet.  Apostrophes in the text string are signalled as
;  two apostrophes in a row.
;
		    IF STRMID( TEST, ENDAP+1, 1) EQ "'" THEN BEGIN    
	     		VALUE = VALUE + "'"
	      		NEXT_CHAR = ENDAP+2	 
			GOTO, NEXT_APOST
	  	    ENDIF
;
;  Extract the comment, if any.
;
		    SLASH = STRPOS(TEST, "/", ENDAP)
		    IF SLASH LT 0 THEN COMMENT = '' ELSE	$
			COMMENT = STRMID(TEST, SLASH+1, STRLEN(TEST)-SLASH-1)
;
;  If not a string, then separate the parameter field from the comment field.
;
                ENDIF ELSE BEGIN
		    TEST = SVALUE(I)
		    SLASH = STRPOS(TEST, "/")
		    IF SLASH GT 0 THEN BEGIN
			COMMENT = STRMID(TEST, SLASH+1, STRLEN(TEST)-SLASH-1)
			TEST = STRMID(TEST, 0, SLASH)
		    END ELSE COMMENT = ''
;
;  Find the first word in TEST.  Is it a logical value ('T' or 'F')?
;
		    TEST2 = TEST
		    VALUE = GETTOK(TEST2,' ')
		    TEST2 = STRTRIM(TEST2,2)
		    IF ( VALUE EQ 'T' ) THEN BEGIN
			VALUE = 1
		    END ELSE IF ( VALUE EQ 'F' ) THEN BEGIN
			VALUE = 0
		    END ELSE BEGIN
;
;  Test to see if a complex number.  It's a complex number if the value and the
;  next word, if any, both are valid numbers.
;
			IF STRLEN(TEST2) EQ 0 THEN GOTO, NOT_COMPLEX
			VALUE2 = GETTOK(TEST2,' ')
			IF STRNUMBER(VALUE,VAL1) AND STRNUMBER(VALUE2,VAL2) $
				THEN BEGIN
			    VALUE = COMPLEX(VAL1,VAL2)
			    GOTO, GOT_VALUE
			ENDIF
;
;  Not a complex number.  Decide if it is a floating point, double precision,
;  or integer number.  If an error occurs, then a string value is returned.
;
NOT_COMPLEX:
			ON_IOERROR, GOT_VALUE
			VALUE = TEST
			IF (STRPOS(VALUE,'.') GE 0) OR (STRPOS(VALUE,'E') $
				GE 0) OR (STRPOS(VALUE,'D') GE 0) THEN BEGIN
			    IF ( STRPOS(VALUE,'D') GT 0 ) OR $
				    ( STRLEN(VALUE) GE 8 ) THEN BEGIN
				VALUE = DOUBLE(VALUE)
			    END ELSE VALUE = FLOAT(VALUE)
			END ELSE VALUE = LONG(VALUE)
;
GOT_VALUE:
			ON_IOERROR, NULL
		    ENDELSE
		ENDELSE		; if string
;
;  Add to vector if required.
;
		IF VECTOR THEN BEGIN
		    MAXNUM = MAX(NUMBER)
		    IF ( I EQ 0 ) THEN BEGIN
			SZ_VALUE = SIZE(VALUE)
			RESULT = MAKE_ARRAY( MAXNUM, TYPE=SZ_VALUE(1))
			COMMENTS = STRARR(MAXNUM)
		    ENDIF 
		    RESULT(   NUMBER(I)-1 ) =  VALUE
		    COMMENTS( NUMBER(I)-1 ) =  COMMENT
		ENDIF ELSE BEGIN
		    COMMENTS = COMMENT
		ENDELSE
	    ENDFOR
;
;  Set the value of !ERR for the number of matches for vectors, or simply 0
;  otherwise.
;
	    IF VECTOR THEN BEGIN
		!ERR = MATCHES
		RETURN, RESULT
	    ENDIF ELSE !ERR = 0
;
;  Error point for keyword not found.
;
	ENDIF ELSE BEGIN
	    IF ABORT_RETURN THEN MESSAGE,'Keyword '+NAM+' not found in '+ABORT
	    !ERR = -1
	ENDELSE
;
	RETURN, VALUE
	END
