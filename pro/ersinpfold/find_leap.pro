FUNCTION  FIND_LEAP, mjd_ref, mjd


; Read in table of leap seconds

filename = 'leap_sec.txt'
dir='/home.carbon/integral/IDL_PRO/pro/ersinpfold/'
check_file = FINDFILE(dir + filename )

IF (check_file[0] EQ '') THEN BEGIN
	PRINT, ' '
	PRINT, ' File not found '
	PRINT, ' ' + STRTRIM(filename,2)
	GOTO, quit
ENDIF


text = ''
date_string = ''
time_string = ''


OPENR, lun, dir+filename, /GET_LUN

FOR i = 0, 3 DO READF, lun, text


mjdx = 48988.0d			; 1993 Jan 1

mjd_leap = DBLARR(1) + mjdx


WHILE NOT(EOF(lun)) DO BEGIN

   READF, lun, mjdx

   mjd_leap = [mjd_leap, mjdx]

ENDWHILE


CLOSE, lun

FREE_LUN, lun


; Determine reference point

ref_ind = WHERE( mjd_ref GE mjd_leap )


; Determine epoch

epoch_ind = WHERE( mjd GE mjd_leap )


IF ((epoch_ind[0] EQ -1) OR (ref_ind[0] EQ -1)) THEN BEGIN
   PRINT, ' '
   PRINT, ' * * * ERROR * * * '
   PRINT, ' Time and/or reference given is before 1993 '
   PRINT, ' Out of range '
   PRINT, ' '
   GOTO, quit
ENDIF

IF (mjd_ref GT mjd) THEN BEGIN
   PRINT, ' '
   PRINT, ' * * * ERROR * * * '
   PRINT, ' Reference time given is larger than time ' + $
   	'requested for leap seconds '
   PRINT, ' * Aborting * '
   PRINT, ' '
   GOTO, quit
ENDIF


leap_seconds = DOUBLE(MAX(epoch_ind) - MAX(ref_ind))



RETURN, leap_seconds


quit:


END
