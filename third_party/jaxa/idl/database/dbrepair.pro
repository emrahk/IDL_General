	PRO DBREPAIR, DBNAME
;+
; Project     :	SOHO - CDS
;
; Name        :	DBREPAIR
;
; Purpose     :	Repairs problem with IEEE format databases.
;
; Category    :	Utilities, database
;
; Explanation : Version 1 of DB_ENT2EXT contained a bug where only the first
;		element in an array was converted from IEEE to host format.
;		DB_ENT2EXT contained the same bug, so that the problem only
;		manifested itself when one tried to read data on one machine
;		that was written on another one with a different native format.
;
;		This procedure reads in a database which had been written
;		incorrectly, and repairs it.  The following conditions must be
;		met for a database file to require repair:
;
;		1.  The database must have been created with the /EXTERNAL
;		    switch set in the call to DBCREATE.
;
;		2.  The database must have been written on a machine who's
;		    native format is either not IEEE or uses a different byte
;		    order.  For example, the native format on Sun workstations
;		    is the same as the external format, so databases created on
;		    Sun's are okay.  However, DEC Alpha/OSF workstations use
;		    IEEE format, but the bytes are reversed, so data files
;		    written on Alphas need to be repaired.
;
;		3.  At least one of the items in the database must be an array.
;		    The problem only manifests itself with arrays.  For
;		    example, a line in the .dbd file like
;
;			WIN_DEF(4)	I*2	Window definition
;
;		    is an array, because of the (4).  Byte and string arrays
;		    are not affected, and do not exhibit this problem.
;
; Syntax      :	DBREPAIR, DBNAME
;
; Examples    :	!PRIV = 4
;		DBREPAIR, 'datawin2'
;
; Inputs      :	DBNAME = Name of the data base file to repair.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	DB_ENT2HOST, DB_ENT2EXT
;
; Common      :	DB_COM
;
; Restrictions:	This routine must only be applied to databases requiring
;		repair.  Using it on a correctly formatted database will damage
;		it.  To work properly, this routine must be used on the same
;		kind of computer that was used to originally write the data.
;
;		Because of the dangers of corrupting a database, it is strongly
;		suggested that this routine be run against a copy of the
;		database, rather than the original.  Change to the directory
;		containing the copy, and run IDL from there.
;
;		!PRIV must be 4 or greater to repair a file.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 15-Sep-1995, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR, 2
	COMMON DB_COM,QDB,QITEMS,QDBREC
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, 'Syntax:  DBREPAIR, DBNAME'
;
;  Check the privilege.
;
	IF !PRIV LT 4 THEN MESSAGE,	$
		'!PRIV must be 4 or greater to repair a database'
;
;  Open the database.
;
	DBOPEN, DBNAME, 1, UNAVAIL=UNAVAIL
	IF UNAVAIL EQ 1 THEN MESSAGE, 'Unable to open database '+DBNAME
;
;  Make sure the database is in external format.
;
	IF NOT DB_INFO('external', DBNAME) THEN BEGIN
		MESSAGE, /CONTINUE, 'Not in external format'
		MESSAGE, /CONTINUE, 'Database ' + DBNAME +	$
			' does not need to be repaired'
		GOTO, FINISH
	ENDIF
;
;  Find out if any of the items are arrays.
;
	NVALUES = DB_ITEM_INFO('nvalues')
	IF MAX(NVALUES) EQ 1 THEN BEGIN
		MESSAGE, /CONTINUE, 'No arrays'
		MESSAGE, /CONTINUE, 'Database ' + DBNAME +	$
			' does not need to be repaired'
		GOTO, FINISH
	ENDIF
;
;  Find out if the database is empty.
;
	IF DB_INFO('entries', DBNAME) EQ 0 THEN BEGIN
		MESSAGE, /CONTINUE, 'Database ' + DBNAME + ' is empty'
		MESSAGE, /CONTINUE, 'Database ' + DBNAME +	$
			' does not need to be repaired'
		GOTO, FINISH
	ENDIF
;
;  Make sure that the user really wants to repair the file.
;
	PRINT,'Printing out first 5 values of each multidimensional array'
	W = WHERE(NVALUES GT 1)
	NVALUES = NVALUES(W)
	NAMES = DB_ITEM_INFO('name', W)
	FOR I_NAME = 0,N_ELEMENTS(NAMES)-1 DO BEGIN
		DBEXT,1,NAMES(I_NAME),TEMP
		PRINT, NAMES(I_NAME) + ':', TEMP(0:4<(NVALUES(I_NAME)-1))
	ENDFOR
	ANSWER = ''
	READ,'Are you sure you want to repair this database? (Y/N): ',ANSWER
	IF STRUPCASE(STRMID(ANSWER,0,1)) NE 'Y' THEN GOTO, FINISH
;
;  Step through each record, and repair it.
;
	N_ENTRIES = DB_INFO('entries', DBNAME)
	FOR I=0,N_ENTRIES-1 DO BEGIN
		ENTRY = QDBREC(I)
		DB_ENT2HOST, ENTRY, 0, /REPAIR_MODE
		DB_ENT2EXT, ENTRY
		QDBREC(I) = ENTRY
	ENDFOR
;
	MESSAGE, /INFORMATION, 'Database ' + DBNAME + ' repaired'
;
;  Exit point.
;
FINISH:
	DBCLOSE
;
	RETURN
	END
