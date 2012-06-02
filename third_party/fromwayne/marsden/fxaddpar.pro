	PRO FXADDPAR, HEADER, NAME, VALUE, COMMENT, BEFORE=BEFORE,	$
		AFTER=AFTER, FORMAT=FORMAT
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FXADDPAR
; Purpose     : 
;	Add or modify a parameter in a FITS header array.
; Explanation : 
;
; Use         : 
;	FXADDPAR, HEADER, NAME, VALUE, COMMENT
; Inputs      : 
;	HEADER	= String array containing FITS header.  The maximum string
;		  length must be equal to 80.  If not defined, then FXADDPAR
;		  will create an empty FITS header array.
;
;	NAME	= Name of parameter.  If NAME is already in the header the
;		  value and possibly comment fields are modified. Otherwise a
;		  new record is added to the header.  If NAME is equal to
;		  either "COMMENT" or "HISTORY" then the value will be added to
;		  the record without replacement.  In this case the comment
;		  parameter is ignored.
;
;	VALUE	= Value for parameter.  The value expression must be of the
;		  correct type, e.g. integer, floating or string.  String
;		  values of 'T'	or 'F' are considered logical values.
;
; Opt. Inputs : 
;	COMMENT	= String field.  The '/' is added by this routine.  Added
;		  starting in position 31.  If not supplied, or set equal to ''
;		  (the null string), then any previous comment field in the
;		  header for that keyword is retained (when found).
; Outputs     : 
;	HEADER	= Updated header array.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	BEFORE	= Keyword string name.  The parameter will be placed before the
;		  location of this keyword.  For example, if BEFORE='HISTORY'
;		  then the parameter will be placed before the first history
;		  location.  This applies only when adding a new keyword;
;		  keywords already in the header are kept in the same position.
;
;	AFTER	= Same as BEFORE, but the parameter will be placed after the
;		  location of this keyword.  This keyword takes precedence over
;		  BEFORE.
;
;       FORMAT	= Specifies FORTRAN-like format for parameter, e.g. "F7.3".  A
;		  scalar string should be used.  For complex numbers the format
;		  should be defined so that it can be applied separately to the
;		  real and imaginary parts.
; Calls       : 
;	FXPAR, FXPARPOS
; Common      : 
;	None.
; Restrictions: 
;	Warning -- Parameters and names are not checked against valid FITS
;	parameter names, values and types.
;
;	The required FITS keywords SIMPLE (or XTENSION), BITPIX, NAXIS, NAXIS1,
;	NAXIS2, etc., must be entered in order.  The actual values of these
;	keywords are not checked for legality and consistency, however.
;
; Side effects: 
;	All HISTORY records are inserted in order at the end of the header.
;
;	All COMMENT records are also inserted in order at the end of the
;	header, but before the HISTORY records.  The BEFORE and AFTER keywords
;	can override this.
;
;	All records with no keyword (blank) are inserted in order at the end of
;	the header, but before the COMMENT and HISTORY records.  The BEFORE and
;	AFTER keywords can override this.
;
;	All other records are inserted before any of the HISTORY, COMMENT, or
;	"blank" records.  The BEFORE and AFTER keywords can override this.
;
; Category    : 
;	Data Handling, I/O, FITS, Generic.
; Prev. Hist. : 
;	William Thompson, Jan 1992, from SXADDPAR by D. Lindler and J. Isensee.
;	Differences include:
;
;		* LOCATION parameter replaced with keywords BEFORE and AFTER.
;		* Support for COMMENT and "blank" FITS keywords.
;		* Better support for standard FITS formatting of string and
;		  complex values.
;		* Built-in knowledge of the proper position of required
;		  keywords in FITS (although not necessarily SDAS/Geis) primary
;		  headers, and in TABLE and BINTABLE extension headers.
;
;	William Thompson, May 1992, fixed bug when extending length of header,
;	and new record is COMMENT, HISTORY, or blank.
; Written     : 
;	William Thompson, GSFC, January 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 12 April 1993.
;		Incorporated into CDS library.
; Version     : 
;	Version 1, 12 April 1993.
;-
;
	ON_ERROR,2				;Return to caller
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 3 THEN MESSAGE, $	;Need at least 3 parameters
		'Syntax:  FXADDPAR, HEADER, NAME, VALUE [, COMMENT ]'
;
; Define a blank line and the END line
;
	ENDLINE = 'END' + STRING(REPLICATE(32B,77))	;END line
	BLANK = STRING(REPLICATE(32B,80))		;BLANK line
;
;  If no comment was passed, then use a null string.
;
	IF N_PARAMS() LT 4 THEN COMMENT = ''
;
;  Check the HEADER array.
;
	N = N_ELEMENTS(HEADER)		;# of lines in FITS header
	IF N EQ 0 THEN BEGIN		;header defined?
		HEADER=STRARR(36)	;no, make it.
		HEADER(0)=ENDLINE
		N=36
	ENDIF ELSE BEGIN
		S = SIZE(HEADER)	;check for string type
		IF (S(0) NE 1) OR (S(2) NE 7) THEN MESSAGE, $
			'FITS Header (first parameter) must be a string array'
	ENDELSE
;
;  Make sure NAME is 8 characters long
;
	NN = STRING(REPLICATE(32B,8))	;8 char name
	STRPUT,NN,STRUPCASE(NAME)       ;Insert name
;
;  Check VALUE.
;
	S = SIZE(VALUE)		;get type of value parameter
	STYPE = S(S(0)+1)
	IF S(0) NE 0 THEN BEGIN
		MESSAGE,'Keyword Value (third parameter) must be scalar'
	END ELSE IF STYPE EQ 0 THEN BEGIN
		MESSAGE,'Keyword Value (third parameter) is not defined'
	END ELSE IF STYPE EQ 8 THEN BEGIN
		MESSAGE,'Keyword Value (third parameter) cannot be structure'
	ENDIF
;
;  Extract first 8 characters of each line of header, and locate END line
;
	KEYWRD = STRMID(HEADER,0,8)			;Header keywords
	IEND = WHERE(KEYWRD EQ 'END     ',NFOUND)
;
;  If no END, then add it.  Either put it after the last non-null string, or
;  append it to the end.
;
	IF NFOUND EQ 0 THEN BEGIN
		II = WHERE(STRTRIM(HEADER) NE '',NFOUND)
		II = MAX(II) + 1
		IF (NFOUND EQ 0) OR (II EQ N_ELEMENTS(HEADER)) THEN	$
			HEADER = [HEADER,ENDLINE] ELSE HEADER(II) = ENDLINE
		KEYWRD = STRMID(HEADER,0,8)
		IEND = WHERE(KEYWRD EQ 'END     ',NFOUND)
	ENDIF
;
	IEND = IEND(0) > 0			;Make scalar
;
;  History, comment and "blank" records are treated differently from the
;  others.  They are simply added to the header array whether there are any
;  already there or not.
;
	IF (NN EQ 'COMMENT ') OR (NN EQ 'HISTORY ') OR		$
			(NN EQ '        ') THEN BEGIN
;
;  If the header array needs to grow, then expand it in increments of 36 lines.
;
		IF IEND GE (N-1) THEN BEGIN
			HEADER = [HEADER,REPLICATE(BLANK,36)]
			N = N_ELEMENTS(HEADER)
		ENDIF
;
;  Format the record.
;
		NEWLINE = BLANK
		STRPUT,NEWLINE,NN+STRING(VALUE),0
;
;  If a history record, then append to the record just before the end.
;
		IF NN EQ 'HISTORY ' THEN BEGIN
			HEADER(IEND) = NEWLINE		;add history rec.
			HEADER(IEND+1)=ENDLINE		;move end up
;
;  The comment record is placed immediately after the last previous comment
;  record, or immediately before the first history record, unless overridden by
;  either the BEFORE or AFTER keywords.
;
		END ELSE IF NN EQ 'COMMENT ' THEN BEGIN
			I = FXPARPOS(KEYWRD,IEND,AFTER=AFTER,BEFORE=BEFORE)
			IF I EQ IEND THEN I =	$
			    FXPARPOS(KEYWRD,IEND,AFTER='COMMENT',BEFORE='HISTORY')
			HEADER(I+1) = HEADER(I:N-2)	;move rest up
			HEADER(I) = NEWLINE		;insert comment
;
;  The "blank" record is placed immediately after the last previous "blank"
;  record, or immediately before the first comment or history record, unless
;  overridden by either the BEFORE or AFTER keywords.
;
		END ELSE BEGIN
			I = FXPARPOS(KEYWRD,IEND,AFTER=AFTER,BEFORE=BEFORE)
			IF I EQ IEND THEN I =	$
			    FXPARPOS(KEYWRD,IEND,AFTER='',BEFORE='COMMENT')<$
			    FXPARPOS(KEYWRD,IEND,AFTER='',BEFORE='HISTORY')
			HEADER(I+1) = HEADER(I:N-2)	;move rest up
			HEADER(I) = NEWLINE		;insert "blank"
		ENDELSE
		RETURN
	ENDIF				;history/comment/blank
;
;  Find location to insert keyword.  If the keyword is already in the header,
;  then simply replace it.  If no new comment is passed, then retain the old
;  one.
;
	IPOS  = WHERE(KEYWRD EQ NN,NFOUND)
	IF NFOUND GT 0 THEN BEGIN
		I = IPOS(0)
		IF COMMENT EQ '' THEN BEGIN
			SLASH = STRPOS(HEADER(I),'/')
			IF SLASH NE -1 THEN	$
				COMMENT = STRMID(HEADER(I),SLASH+1,80) ELSE $
				COMMENT = STRING(REPLICATE(32B,80))
		ENDIF
		GOTO, REPLACE
	ENDIF
;
;  Start of section dealing with the positioning of required FITS keywords.  If
;  the keyword is SIMPLE, then it must be at the beginning.
;
	IF NN EQ 'SIMPLE  ' THEN BEGIN
		I = 0
		GOTO, INSERT
	ENDIF
;
;  In conforming extensions, if the keyword is XTENSION, then it must be at the
;  beginning. 
;
	IF NN EQ 'XTENSION' THEN BEGIN
		I = 0
		GOTO, INSERT
	ENDIF
;
;  If the keyword is BITPIX, then it must follow the either SIMPLE or XTENSION
;  keyword.
;
	IF NN EQ 'BITPIX  ' THEN BEGIN
		IF (KEYWRD(0) NE 'SIMPLE  ') AND		$
			(KEYWRD(0) NE 'XTENSION') THEN MESSAGE,	$
			'Header must start with either SIMPLE or XTENSION'
		I = 1
		GOTO, INSERT
	ENDIF
;
;  If the keyword is NAXIS, then it must follow the BITPIX keyword.
;
	IF NN EQ 'NAXIS   ' THEN BEGIN
		IF KEYWRD(1) NE 'BITPIX  ' THEN MESSAGE,	$
			'Required BITPIX keyword not found'
		I = 2
		GOTO, INSERT
	ENDIF
;
;  If the keyword is NAXIS1, then it must follow the NAXIS keyword.
;
	IF NN EQ 'NAXIS1  ' THEN BEGIN
		IF KEYWRD(2) NE 'NAXIS   ' THEN MESSAGE,	$
			'Required NAXIS keyword not found'
		I = 3
		GOTO, INSERT
	ENDIF
;
;  If the keyword is NAXIS<n>, then it must follow the NAXIS<n-1> keyword.
;
	IF STRMID(NN,0,5) EQ 'NAXIS' THEN BEGIN
		NUM_AXIS = FIX(STRMID(NN,5,3))
		PREV = STRING(REPLICATE(32B,8))		;Format NAXIS<n-1>
		STRPUT,PREV,'NAXIS',0			;Insert NAXIS
		STRPUT,PREV,STRTRIM(NUM_AXIS-1,2),5	;Insert <n-1>
		IF KEYWRD(NUM_AXIS+1) NE PREV THEN MESSAGE,	$
			'Required '+PREV+' keyword not found'
		I = NUM_AXIS + 2
		GOTO, INSERT
	ENDIF
;
;  If the first keyword is XTENSION, and has the value of either 'TABLE' or
;  'BINTABLE', then there are some additional required keywords.
;
	IF KEYWRD(0) EQ 'XTENSION' THEN BEGIN
		XTEN = FXPAR(HEADER,'XTENSION')
		IF (XTEN EQ 'TABLE   ') OR (XTEN EQ 'BINTABLE') THEN BEGIN
;
;  If the keyword is PCOUNT, then it must follow the NAXIS2 keyword.
;
			IF NN EQ 'PCOUNT  ' THEN BEGIN
				IF KEYWRD(4) NE 'NAXIS2  ' THEN MESSAGE, $
					'Required NAXIS2 keyword not found'
				I = 5
				GOTO, INSERT
			ENDIF
;
;  If the keyword is GCOUNT, then it must follow the PCOUNT keyword.
;
			IF NN EQ 'GCOUNT  ' THEN BEGIN
				IF KEYWRD(5) NE 'PCOUNT  ' THEN MESSAGE, $
					'Required PCOUNT keyword not found'
				I = 6
				GOTO, INSERT
			ENDIF
;
;  If the keyword is TFIELDS, then it must follow the GCOUNT keyword.
;
			IF NN EQ 'TFIELDS ' THEN BEGIN
				IF KEYWRD(6) NE 'GCOUNT  ' THEN MESSAGE, $
					'Required GCOUNT keyword not found'
				I = 7
				GOTO, INSERT
			ENDIF
		ENDIF
	ENDIF
;
;  At this point the location has not been determined, so a new line is added
;  at the end of the FITS header, but before any blank, COMMENT, or HISTORY
;  keywords, unless overridden by the BEFORE or AFTER keywords.
;
	I = FXPARPOS(KEYWRD,IEND,AFTER=AFTER,BEFORE=BEFORE)
	IF I EQ IEND THEN I =					  $
	    FXPARPOS(KEYWRD,IEND,AFTER=AFTER,BEFORE='')		< $
	    FXPARPOS(KEYWRD,IEND,AFTER=AFTER,BEFORE='COMMENT')	< $
	    FXPARPOS(KEYWRD,IEND,AFTER=AFTER,BEFORE='HISTORY')
;
;  A new line needs to be added.  First check to see if the length of the
;  header array needs to be extended.  Then insert a blank record at the proper
;  place.
;
INSERT:
	IF IEND EQ (N-1) THEN BEGIN
		HEADER = [HEADER,REPLICATE(BLANK,36)]
		N = N_ELEMENTS(HEADER)
	ENDIF
	HEADER(I+1) = HEADER(I:N-2)
	HEADER(I) = BLANK
;
;  Now put value into keyword at line I.
;
REPLACE: 
	H=BLANK			;80 blanks
	STRPUT,H,NN+'= '	;insert name and =.
	APOST = "'"	        ;quote (apostrophe) character
	TYPE = SIZE(VALUE)	;get type of value parameter
;
;  Store the value depending on the data type.  If a character string, first
;  check to see if it is one of the logical values "T" (true) or "F" (false).
;
	IF TYPE(1) EQ 7 THEN BEGIN		;which type?
		UPVAL = STRUPCASE(VALUE)	;force upper case.
		IF (UPVAL EQ 'T') OR (UPVAL EQ 'F') THEN BEGIN
			STRPUT,H,UPVAL,29	;insert logical value.
;
;  Otherwise, remove any tabs, and check for any apostrophes in the string.
;
		END ELSE BEGIN
			VAL = DETABIFY(VALUE)
			NEXT_CHAR = 0
			REPEAT BEGIN
				AP = STRPOS(VAL,"'",NEXT_CHAR)
				IF AP GE 66 THEN BEGIN
					VAL = STRMID(VAL,0,66)
				END ELSE IF AP GE 0 THEN BEGIN
					VAL = STRMID(VAL,0,AP+1) + APOST +	$
						STRMID(VAL,AP+1,80)
					NEXT_CHAR = AP + 2
				ENDIF
			ENDREP UNTIL AP LT 0
;
;  If a long string, then add the comment as soon as possible.
;
			IF STRLEN(VAL) GT 18 THEN BEGIN
				STRPUT,H,APOST+STRMID(VAL,0,68)+APOST+ $
					' /'+COMMENT,10
				HEADER(I)=H
				RETURN
;
;  If a short string, then pad out to at least eight characters.
;
			END ELSE BEGIN
				STRPUT,H,APOST+VAL,10
				STRPUT,H,APOST,11+(STRLEN(VAL)>8)
			ENDELSE
		ENDELSE
;
;  If complex, then format the real and imaginary parts, and add the comment
;  beginning in column 51.
;
	END ELSE IF TYPE(1) EQ 6 THEN BEGIN
		IF N_ELEMENTS(FORMAT) EQ 1 THEN BEGIN	;use format keyword
			VR = STRING(FLOAT(VALUE),    '('+FORMAT+')')
			VI = STRING(IMAGINARY(VALUE),'('+FORMAT+')')
		END ELSE BEGIN
			VR = STRTRIM(FLOAT(VALUE),2)
			VI = STRTRIM(IMAGINARY(VALUE),2)
		ENDELSE
		SR = STRLEN(VR)  &  STRPUT,H,VR,(30-SR)>10
		SI = STRLEN(VI)	 &  STRPUT,H,VI,(50-SI)>30
		STRPUT,H,' /'+COMMENT,50
		HEADER(I) = H
		RETURN
;
;  If not complex or a string, then format according to either the FORMAT
;  keyword, or the default for that datatype.
;
	END ELSE BEGIN
		IF (N_ELEMENTS(FORMAT) EQ 1) THEN $ ;use format keyword
			V = STRING(VALUE,'('+FORMAT+')' ) ELSE $
			V = STRTRIM(VALUE,2)	;default format
		S = STRLEN(V)                 ;right justify
		STRPUT,H,V,(30-S)>10          ;insert
	ENDELSE
;
;  Add the comment, and store the completed line in the header.
;
	STRPUT,H,' /',30	;add ' /'
	STRPUT,H,COMMENT,32	;add comment
	HEADER(I)=H		;save line
;
	RETURN
	END
