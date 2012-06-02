	PRO FXBCREATE, UNIT, FILENAME, HEADER
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FXBCREATE
; Purpose     : 
;	Open a new binary table at the end of a FITS file.
; Explanation : 
;	Write a binary table extension header to the end of a disk FITS file,
;	and leave it open to receive the data.
;
;	The FITS file is opened, and the pointer is positioned just after the
;	last 2880 byte record.  Then the binary header is appended.  Calls to
;	FXBWRITE will append the binary data to this file, and then FXBFINISH
;	will close the file.
;
; Use         : 
;	FXBCREATE, UNIT, FILENAME, HEADER
; Inputs      : 
;	FILENAME = Name of FITS file to be opened.
;	HEADER	 = String array containing the FITS binary table extension
;		   header.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	UNIT	 = Logical unit number of the opened file.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	None.
; Calls       : 
;	FXADDPAR, FXBFINDLUN, FXBPARSE, FXFINDEND
; Common      : 
;	Uses common block FXBINTABLE--see "fxbintable.pro" for more
;	information.
; Restrictions: 
;	The primary FITS data unit must already be written to a file.  The
;	binary table extension header must already be defined (FXBHMAKE), and
;	must match the data that will be written to the file.
; Side effects: 
;	None.
; Category    : 
;	Data Handling, I/O, FITS, Generic.
; Prev. Hist. : 
;	W. Thompson, Jan 1992, based on WRITEFITS by J. Woffard and W. Landsman.
;	W. Thompson, Feb 1992, changed from function to procedure.
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
	IF N_PARAMS() NE 3 THEN MESSAGE, $
		'Syntax:  FXBCREATE, UNIT, FILENAME, HEADER'
;
;  Get a logical unit number, open the file, and find the end.
;
	GET_LUN,UNIT
       	OPENU, UNIT, FILENAME, /BLOCK
	FXFINDEND, UNIT
;
;  Store the UNIT number in the common block, and leave space for the other
;  parameters.  Initialize the common block if need be.  ILUN is an index into
;  the arrays.
;
	ILUN = FXBFINDLUN(UNIT)
;
;  Store the current position as the start of the header.  Mark the file as
;  open for write.
;
	POINT_LUN,-UNIT,POINTER
	MHEADER(ILUN) = POINTER
	STATE(ILUN) = 2
;
;  Determine if an END line occurs, and add one if necessary
;
	ENDLINE = WHERE(STRMID(HEADER,0,8) EQ 'END     ', NEND)
	ENDLINE = ENDLINE(0)
	IF NEND EQ 0 THEN BEGIN
		MESSAGE,/INF,'WARNING - An END statement has been appended ' +$
			'to the FITS header'
		HEADER = [HEADER, 'END' + STRING(REPLICATE(32B,77))]
		ENDLINE = N_ELEMENTS(HEADER) - 1 
	ENDIF
	NMAX = ENDLINE + 1		;Number of 80 byte records
	NHEAD = FIX((NMAX+35)/36)	;Number of 2880 byte records
;
;  Convert the header to byte and force into 80 character lines.
;
WRITE_HEADER:
	BHDR = REPLICATE(32B, 80, 36*NHEAD)
	FOR N = 0,ENDLINE DO BHDR(0,N) = BYTE( STRMID(HEADER(N),0,80) )
	WRITEU, UNIT, BHDR
;
;  Get the rest of the information, and store it in the common block.
;
	FXBPARSE,ILUN,HEADER
;
;  Check the size of the heap offset.  If the heap offset is smaller than the
;  table, then reset it to the size of the table.
;
	DDHEAP = HEAP(ILUN) - NAXIS1(ILUN)*NAXIS2(ILUN)
	IF DDHEAP LT 0 THEN BEGIN
		MESSAGE,'Heap offset smaller than table size--resetting', $
			/CONTINUE
		HEAP(ILUN) = NAXIS1(ILUN)*NAXIS2(ILUN)
		FXADDPAR,HEADER,'THEAP',HEAP(ILUN)
		POINT_LUN, UNIT, MHEADER(ILUN)
		GOTO, WRITE_HEADER
	ENDIF
;
;  Fill out the file to size it properly.
;
	BUFFER = BYTARR(NAXIS1(ILUN))
	FOR I = 1,NAXIS2(ILUN) DO WRITEU,UNIT,BUFFER
;
;  If there's any extra space before the start of the heap, then write that out
;  as well.
;
	IF DDHEAP GT 0 THEN BEGIN
		BUFFER = BYTARR(DDHEAP)
		WRITEU,UNIT,BUFFER
	ENDIF
;
;  Initialize DHEAP, and return.
;
	DHEAP(ILUN) = 0
;
	RETURN
	END
