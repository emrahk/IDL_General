	PRO FXBPARSE, ILUN, HEADER, NO_TDIM=NO_TDIM
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FXBPARSE
; Purpose     : 
;	Parse the binary table extension header.
; Explanation : 
;	Parses the binary table extension header, and store the information
;	about the format of the binary table in the FXBINTABLE common
;	block--called from FXBCREATE and FXBOPEN.
; Use         : 
;	FXBPARSE, ILUN, UNIT, HEADER
; Inputs      : 
;	ILUN	= Index into the arrays in the FXBINTABLE common block.
;	HEADER	= FITS binary table extension header.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	NO_TDIM	  = If set, then any TDIMn keywords found in the header are
;		    ignored.
; Calls       : 
;	FXBFIND, FXBTDIM, FXBTFORM, FXPAR
; Common      : 
;	Uses common block FXBINTABLE--see "fxbintable.pro" for more
;	information.
; Restrictions: 
;	None.
; Side effects: 
;	Any TDIMn keywords found for bit arrays (format 'X') are ignored, since
;	the dimensions would refer to bits, not bytes.
; Category    : 
;	Data Handling, I/O, FITS, Generic.
; Prev. Hist. : 
;	William Thompson, Feb. 1992.
;	William Thompson, Jan. 1993, modified for renamed FXBTFORM and FXBTDIM.
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
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  FXBPARSE, ILUN, HEADER'
;
;  Gather the necessary information, and store it in the common block.
;
	FXBTFORM,HEADER,BYTOFF0,IDLTYPE0,FORMAT0,N_ELEM0,MAXVAL0
	FXBFIND,HEADER,'TTYPE',COLUMNS,TTYPE0,N_FOUND,''
	FXBFIND,HEADER,'TSCAL',COLUMNS,TSCAL0,N_FOUND,1.
	FXBFIND,HEADER,'TZERO',COLUMNS,TZERO0,N_FOUND,0.
	POINT_LUN,-LUN(ILUN),NHEAD0
;
;  Get the information from the required keywords.
;
	STORE_ARRAY,HEAD,HEADER,ILUN
	NHEADER(ILUN) = NHEAD0
	NAXIS1(ILUN)  = FXPAR(HEADER,'NAXIS1')
	NAXIS2(ILUN)  = FXPAR(HEADER,'NAXIS2')
	TFIELDS(ILUN) = FXPAR(HEADER,'TFIELDS')
;
;  If THEAP is not present, then set it equal to the size of the table.
;
	THEAP = FXPAR(HEADER,'THEAP')
	IF !ERR LT 0 THEN THEAP = NAXIS1(ILUN)*NAXIS2(ILUN)
	HEAP(ILUN) = THEAP
;
;  Store the information about the columns.
;
	STORE_ARRAY,BYTOFF,BYTOFF0,ILUN
	STORE_ARRAY,TTYPE,STRUPCASE(STRTRIM(TTYPE0,2)),ILUN
	STORE_ARRAY,IDLTYPE,IDLTYPE0,ILUN
	STORE_ARRAY,FORMAT,FORMAT0,ILUN
	STORE_ARRAY,N_ELEM,N_ELEM0,ILUN
	STORE_ARRAY,TSCAL,TSCAL0,ILUN
	STORE_ARRAY,TZERO,TZERO0,ILUN
	STORE_ARRAY,MAXVAL,MAXVAL0,ILUN
	STORE_ARRAY,N_DIMS,INTARR(9,N_ELEMENTS(N_ELEM0)),ILUN
;
;  If not a variable length array, then get the dimensions associated with each
;  column from the TDIMn keywords.  If not found, then assume to be the number
;  of elements.
;
	FOR ICOL = 0,TFIELDS(ILUN)-1 DO IF MAXVAL(ICOL,ILUN) EQ 0 THEN BEGIN
		TDIM = FXPAR(HEADER,'TDIM'+STRTRIM(ICOL+1,2))
		TDIM_USED = (!ERR GE 0) AND (NOT KEYWORD_SET(NO_TDIM))
		IF TDIM_USED THEN DIMS = FIX(FXBTDIM(TDIM))	$
			     ELSE DIMS = N_ELEM(ICOL,ILUN)
		DIMS = [N_ELEMENTS(DIMS),DIMS]
;
;  If the datatype is a double complex array, then the array is treated as a
;  double precision array with an extra dimension of two.
;
		IF FORMAT(ICOL,ILUN) EQ 'M' THEN IF TDIM_USED THEN	$
			DIMS = [DIMS(0)+1,2,DIMS(1:*)]	  ELSE		$
			DIMS = [2,2,N_ELEM(ICOL,ILUN)/2]
;
;  If the datatype is a bit array, then no dimensions are applied to the data.
;
		IF FORMAT(ICOL,ILUN) EQ 'X' THEN DIMS = [1,N_ELEM(ICOL,ILUN)]
		N_DIMS(0,ICOL,ILUN) = DIMS
;
;  For those columns which are character strings, then the number of
;  characters, N_CHAR, is the first dimension, and the number of elements is
;  actually N_ELEM/N_CHAR.
;
		IF IDLTYPE(ICOL,ILUN) EQ 7 THEN		$
			N_ELEM(ICOL,ILUN) = N_ELEM(ICOL,ILUN) / DIMS(1)
	ENDIF
;
	RETURN
	END
