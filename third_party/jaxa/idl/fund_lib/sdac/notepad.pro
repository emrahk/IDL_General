


;+
; NAME:		
;       NOTEPAD
; PURPOSE:	
;       Call the NOTEPAD editor to edit a file.
; CATEGORY:
;	GEN
; CALLING SEQUENCE:
;       NOTEPAD                ;Prompt for filename
;	NOTEPAD, File
; INPUTS:
;	File = Name of file to edit, scalar string
; OUTPUTS:
;	None.
; COMMON BLOCKS:
;	LASTFILE -- Contains the single variable FILENAME.
; PROCEDURE:
;	spawn is used to call the notepad editor, dxnotepad, or
;	vue$library:vue$notepad.com  On ultrix or osf the process is launched.
;
; NOTES:
;
; RESTRICTIONS:
;       Only DEC supports the notepad, on other X library machines, xedit is launched.
;
; MODIFICATION HISTORY:
;	ras 3-apr-95
;	ras, 13-july-1996, spawn with /nowait under VMS
;-
;
	PRO NOTEPAD, FILE	;Call the NOTEPAD editor to edit a file
	ON_ERROR,1
	COMMON LASTFILE,FILENAME
;
;  Check to make sure that the variable FILENAME is defined.
;
	IF N_ELEMENTS(FILENAME) EQ 0 THEN FILENAME = ''
;
;  If the filename was not passed, then ask once for a valid file is 
;  selected.  The default is the name of the previously edited file.
;
	IF FILENAME EQ '' THEN OLD = '' ELSE OLD = ' (' + FILENAME + ')'
	IF N_PARAMS(0) EQ 0 THEN FILE = ''
	IF FILE EQ '' THEN BEGIN
		READ,'Enter file name' + OLD+': ', FILE
		IF FILE EQ '' THEN FILE = FILENAME
	ENDIF
;
;  Save the name of the file for the next time the procedure is called.  Edit 
;  the file.
;
	FILENAME = CHKLOG(FILE)
        if filename eq '' then filename=file
        break_file,FILENAME,DSK,DIREC,NAME,EXT
	file = findfile(filename, count=countfile)
        if countfile ne 1 then $
		IF EXT EQ '' THEN FILENAME=FILENAME+'.pro'
        case strupcase(!version.os ) of
	  'VMS' : spawn,/nowait,'@vue$library:vue$notepad '+filename
          'OSF'  : spawn,'dxnotepad '+filename + ' &'
          'ULTRIX'  : spawn,'dxnotepad '+filename + ' &'
          else  : spawn,'xedit '+filename + ' &'
        endcase

	END

