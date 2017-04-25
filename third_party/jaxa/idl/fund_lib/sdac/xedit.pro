


;+
; NAME:		
;       XEDIT
; PURPOSE:	
;       Call the XEDIT editor to edit a file.
; CALLING SEQUENCE:
;       XEDIT                ;Prompt for filename
;	XEDIT, File
; INPUTS:
;	File = Name of file to edit, scalar string
; OUTPUTS:
;	None.
; COMMON BLOCKS:
;	LASTFILE -- Contains the single variable FILENAME.
;	same common block is used for filename in notepad.pro and edit.pro
; PROCEDURE:
;	spawn is used to call xedit, except under vms where we use
;	vue$library:vue$notepad.com  On ultrix or osf the process is launched.
;
; NOTES:
;
; RESTRICTIONS:
;       
;
; MODIFICATION HISTORY:
;	ras 3-apr-95
;-
;
	PRO XEDIT, FILE	;Call the XEDIT editor to edit a file
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
	  'VMS' : spawnthis='@vue$library:vue$notepad '+filename
          else  : spawnthis='xedit '+filename + ' &'
        endcase
	spawn, spawnthis

	RETURN
	END

