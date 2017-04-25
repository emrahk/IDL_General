;+
; NAME:
;  rd_fits_ext
;
; PURPOSE:
;  Read a specified extension from a FITS file.  The extension can be
;  specified by its EXTNAME, its EXTNO, and / or the instance of the
;  given EXTNAME.
;
; CATEGORY: FITS, UTIL
; 
; CALLING SEQUENCE:
;  rd_fits_ext, FILE='some_fits_file.fits', setno=2, extname='rate', $
;     /SILENT, HEADER=fits_extension_header, DATA=fits_extension_data
;
; INPUT KEYWORDS:
;  FILE - Name of FITS file to read.
;
; OPTIONAL INPUT KEYWORDS:
;  SILENT - set to deactivate printing error messages.
;  Input Keywords for find_fits_ext.
;
; OUTPUT KEYWORDS:
;  HEADER - header from requested extension of FITS file.
;  DATA - requested extension from FITS file.
;
; OPTIONAL OUTPUT KEYWORDS:
;  STATUS - keyword from mrdfits.
;  ERR_CODE - set to [ 0 / 1 ] if an error [ did not / did ] occur
;  ERR_MSG - string containing error message.  Null string if no
;            errors occurred.
;  Output keywords from find_fits_ext.
;
; CALLS: 
;   find_fits_ext, mrdfits
;
; WRITTEN: Paul Bilodeau, SSAI, paul.bilodeau@gsfc.nasa.gov 9-aug-2002
;
;-
;------------------------------------------------------------------------------
PRO rd_fits_ext, FILE=file, $
                 EXTNUMREAD=extnumread, $
                 HEADER=header, $
                 DATA=data, $
                 STATUS=status, $
                 SILENT=silent, $
                 ERR_MSG=err_msg, $
                 ERR_CODE=err_code, $
                 _REF_EXTRA=_ref_extra

err_msg = ''
err_code = 0

;; Look for the requested extension name in the file.
find_fits_ext, FILE=file, $
               EXTNUMREAD=extnumread, $
               ERR_MSG=err_msg, $
               ERR_CODE=err_code, $
               SILENT=silent, $
               _EXTRA=_ref_extra

IF err_code THEN RETURN

; read the extension at extnumread in the file
data = mrdfits( $
         file, $
         extnumread, $
         header, $
         STATUS=status, $
         SILENT=silent, $
         _EXTRA=_ref_extra )

err_code = status NE 0

IF err_code THEN BEGIN
    err_msg = 'MRDFITS ERROR: ' + !err_string
    IF 1 - Keyword_Set( silent ) THEN MESSAGE, err_msg, /CONTINUE
ENDIF

END
