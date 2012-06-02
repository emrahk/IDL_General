	PRO FXBFINISH, UNIT
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FXBFINISH
; Purpose     : 
;	Close a FITS binary table extension file opened for write.
; Explanation : 
;	Closes a FITS binary table extension file that had been opened for
;	write by FXBCREATE.
; Use         : 
;	FXBFINISH, UNIT
; Inputs      : 
;	UNIT	= Logical unit number of the file.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	None.
; Calls       : 
;	None.
; Common      : 
;	Uses common block FXBINTABLE--see "fxbintable.pro" for more
;	information.
; Restrictions: 
;	The file must have been opened with FXBCREATE, and written with
;	FXBWRITE.
; Side effects: 
;	Any bytes needed to pad the file out to an integral multiple of 2880
;	bytes are written out to the file.  Then, the file is closed.
; Category    : 
;	Data Handling, I/O, FITS, Generic.
; Prev. Hist. : 
;	W. Thompson, Jan 1992.
;	W. Thompson, Feb 1992, modified to support variable length arrays.
;	W. Thompson, Feb 1992, removed all references to temporary files.
; Written     : 
;	William Thompson, GSFC, January 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 12 April 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 21 July 1993.
;		Fixed bug with variable length arrays.
; Version     : 
;	Version 2, 21 July 1993.
;-
;
@fxbintable
	ON_ERROR, 2
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, 'Syntax:  FXBFINISH, UNIT'
;
;  Find the index of the file.
;
	ILUN = WHERE(LUN EQ UNIT,NLUN)
	ILUN = ILUN(0)
	IF NLUN EQ 0 THEN MESSAGE,'Unit ' + STRTRIM(UNIT,2) +	$
		' not opened properly'
;
;  Make sure the file was opened for write access.
;
	IF STATE(ILUN) NE 2 THEN MESSAGE,'Unit ' + STRTRIM(UNIT,2) +	$
		' not opened for write access'
;
;  Calculate how many bytes are needed to pad out the file.
;
	OFFSET = NHEADER(ILUN) + HEAP(ILUN) + DHEAP(ILUN)
	NPAD = OFFSET MOD 2880
	IF NPAD NE 0 THEN BEGIN
		NPAD = 2880 - NPAD
		POINT_LUN,UNIT,OFFSET
		WRITEU,UNIT,BYTARR(NPAD)
	ENDIF
;
;  If variable sized arrays were written out to the file, then the PCOUNT value
;  must be updated.  It is taken for granted that PCOUNT is the sixth keyword
;  down, and the value is inserted right justified to column 30.
;
	PCOUNT = HEAP(ILUN) + DHEAP(ILUN) - NAXIS1(ILUN)*NAXIS2(ILUN)
	IF PCOUNT GT 0 THEN BEGIN
		PCOUNT = STRTRIM(PCOUNT,2)
		POINT_LUN,UNIT,MHEADER(ILUN) + 430 - STRLEN(PCOUNT)
		WRITEU,UNIT,PCOUNT
	ENDIF
;	
;  Close the file, mark it as closed, and return.
;
	FREE_LUN,UNIT
	STATE(ILUN) = 0
;
	RETURN
	END
