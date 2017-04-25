;+
; NAME:
;  find_fits_ext
;
; PURPOSE:
;  Find extension numbers of FITS files with given EXTNAME parameter
;
; CATEGORY: FITS, UTIL
;
; CALLING SEQUENCE:
;  ; Find the second 'rate' extension in the file 'some_fits_file.fits.'
;  find_fits_ext, file='some_fits_file.fits', setno=2, extname='rate'
;
; INPUTS:
;  FILE - name of FITS file to search in.
;  EXTNAME - name of extension to search for in FILE.
;
; OPTIONAL INPUT KEYWORDS:
;  EXTNO - number of extension to read.  Useful to see if extension N
;          has extname NAME.
;  SETNO - Set this to number of the extensions with EXTNAME to
;          read; i.e., read the third 'RATE' extension in FILE
;  SILENT - set to deactivate printing error messages.
;
; OPTIONAL OUTPUT KEYWORDS:
;  EXTNUMREAD - actual extension to read
;  SETNUMREAD - actual number of extension read within subset of
;               extensions with EXTNAME. 
;  ERR_CODE - set to [ 0 / 1 ] if an error [ did not / did ] occur
;  ERR_MSG - string containing error message.  Null string if no
;            errors occurred.
;
; CALLS:
;  fits_open, wc_where
;
; WRITTEN: Paul Bilodeau, SSAI, paul.bilodeau@gsfc.nasa.gov 9-aug-2002
;
;-
;------------------------------------------------------------------------------
PRO find_fits_ext, FILE=file, $
                   EXTNAME=extname, $
                   SETNO=setno, $
                   SETNUMREAD=setnumread, $
                   EXTNO=extno, $
                   EXTNUMREAD=extnumread, $
                   ERR_MSG=err_msg, $
                   ERR_CODE=err_code, $
                   SILENT=silent, $
                   _REF_EXTRA=_ref_extra

err_code = 1
err_msg = ''

setnumread = -1
extnumread = -1

loud = 1 - Keyword_Set( silent )

CATCH, err
IF err NE 0 THEN BEGIN
    err_msg = !err_string
    IF loud THEN MESSAGE, err_msg, /CONTINUE
    RETURN
ENDIF

;; Look for the requested extension name in the file.
fits_open, file, fcb
free_lun, fcb.unit

ext_match = wc_where( $
              fcb.extname, $
              extname+'*', $
              n_ext_match, $
              /CASE_IGNORE )

IF n_ext_match EQ 0 THEN BEGIN
    err_msg ='No extensions with name: ' + extname + ' found in file: ' + file
    IF loud THEN MESSAGE, err_msg, /CONTINUE
    RETURN
ENDIF

IF N_Elements( setno ) GT 0 THEN BEGIN 
    IF setno[0] GT n_ext_match-1 THEN BEGIN
        err_msg = 'SETNO is greater than the number of ' + extname + $
                  ' extensions.'
        IF loud THEN MESSAGE, err_msg, /CONTINUE
        RETURN
    ENDIF ELSE setnumread = setno[0]
ENDIF ELSE setnumread = 0

IF N_Elements( extno ) GT 0 THEN BEGIN
    IF extno[0] GT fcb.nextend THEN BEGIN
        err_msg ='EXTNO = ' + trim(extno) + $
                 ', Number of extensions = ' + trim(fcb.nextend )
        IF loud THEN MESSAGE, err_msg, /CONTINUE
        RETURN
    ENDIF
    set_match = Where( ext_match EQ extno, n_set_match )
    IF n_set_match EQ 0 THEN BEGIN
        err_msg ='EXTNO corresponds to a non-' + extname + ' extension.'
        IF loud THEN MESSAGE, err_msg, /CONTINUE
        RETURN
    ENDIF
    extnumread = ext_match[ set_match[ setnumread ] ]
ENDIF ELSE extnumread = ext_match[ setnumread ]

err_code = 0

END
