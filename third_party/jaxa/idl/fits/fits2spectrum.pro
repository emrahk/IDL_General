;==============================================================================
;+
; Name: fits2spectrum
;
; Category: HESSI, UTIL, FITS
;
; Purpose: Read spectral rate data from a FITS file, including the ENEBAND
; extension, if any.
;
; Calling sequence:
;
; Inputs:
; file - FITS file to read.
; Extnumber - extension number to find Rate or Flux
;
; Outputs:
;
; Input keywords:
; EXTNAME - keyword passed to rd_fits_ext.  Trapped.
;  The next three keywords control which extension(s) are read.  If
;  none of these are set, then all three of the primary, rate, and
;  eneband data extensions are read.
; READ_PRIMARY - Set to read primary header.
; READ_RATE - Set to read rate extension data.
; READ_ENEBAND - set to read eneband extension data.
; EXTNO - extension number to read.  Trapped.
; SETNO - number of extension with given extension type to read in
;         file.  Set this to 1 if you want the second rate extension
;         and its corresponding eneband extension.
; SILENT - Set this to suppress printing of error messages.
;
; Output keywords:
; PRIMARY_HEADER - primary FITS header
; EXT_HEADER - header for the RATE extension, with any necessary
; 	       keywords.
; EXT_DATA - data from the RATE / Flux extension.
; EXT_STATUS - status from mrdfits call to read rate extension.
; ENEBAND_HEADER - header from the ENEBAND extension, if any.
; ENEBAND_DATA - data from the ENEBAND extension, if any.
; ENEBAND_STATUS - status from mrdfits call to read eneband extension.
; ERR_MSG - error message.  Null if no error occurred.
; ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
; headfits, rd_fits_ext, ssw_pickfile
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 24-May-2001
;
; Modification History:
;   9-aug-2002, Paul BIlodeau - rewrote to use rd_fits_ext, headfits,
;     and ssw_pickfile.  Added SILENT kewyord.
; 19-Feb-2004, Kim Tolbert - added check that file is a rate file by looking for type*rate
; 9-apr-2007, richard.schwartz@gsfc.nasa.gov, now using get_fits_nextend()
;-
;------------------------------------------------------------------------------
PRO fits2spectrum, FILE=file, $
                   EXTNAME=extname, $
                   READ_PRIMARY=read_primary, $
                   READ_RATE=read_rate, $
                   READ_ENEBAND=read_eneband, $
                   SETNO=setno, $
                   EXTNO=extno, $
                   PRIMARY_HEADER=primary_header,$
                   EXT_HEADER=ext_header, $
                   EXT_DATA=ext_data, $
                   EXT_STATUS=ext_status, $
                   ENEBAND_HEADER=eneband_header, $
                   ENEBAND_DATA=eneband_data, $
                   ENEBAND_STATUS=enband_status, $
                   ERR_MSG=err_msg, $
                   ERR_CODE=err_code, $
                   SILENT=silent, $
                   _EXTRA=_extra

err_msg = ''
err_code = 1

loud = 1 - Keyword_Set( silent )

CATCH, err
IF err NE 0 THEN BEGIN
    err_msg = !err_string
    IF loud THEN MESSAGE, err_msg, /CONTINUE
    RETURN
ENDIF

read_primary = Keyword_Set( read_primary )
read_rate = Keyword_Set( read_rate )
read_eneband = Keyword_Set( read_eneband )
IF NOT( read_primary OR read_rate OR read_eneband ) THEN BEGIN
    read_primary = 1
    read_rate = 1
    read_eneband = 1
ENDIF

; if no fitsfile passed in, then popup widget dialog to select file
IF NOT keyword_set(file) THEN BEGIN
    cd, current=dir
    filename = ssw_pickfile( $
                 PATH=dir, $
                 FILTER='*.fits', $
                 TITLE='Select input file', $
                 GET_PATH=path, $
                 ERR_MSG=err_msg, $
                 ERR_CODE=err_code )
    IF filename EQ '' THEN BEGIN
        MESSAGE, err_msg, /CONTINUE
        RETURN
    ENDIF
    file = filename
ENDIF

;fits_info, file, /SILENT, N_EXT=n_ext
n_ext = get_fits_nextend(file)
count = 0
; Check that file has extensions, and that first extension has ...TYPE...RATE... in header
if n_ext gt 0 then begin
	dummy = mrdfits(file, 1, header1, /silent)
	q = where (stregex (header1, 'type.*rate', /boolean, /fold_case), count)
endif
if count eq 0 then begin
	err_msg = 'Aborting.  File is not a spectrum file - ' + file
	return
endif


err_code = 0

IF read_primary THEN BEGIN
    primary_header = headfits( file, ERRMSG=err_msg, SILENT=silent )
    IF err_msg NE '' THEN err_code = 1
    IF err_code THEN RETURN
ENDIF

IF read_rate THEN BEGIN
    rd_fits_ext, FILE=file, $
                 EXTNAME='RATE', $
                 SETNUMBER=setno, $
                 HEADER=ext_header, $
                 DATA=ext_data, $
                 STATUS=ext_status, $
                 ERR_MSG=err_msg, $
                 ERR_CODE=err_code, $
                 SILENT=silent
    IF err_code THEN RETURN
ENDIF

IF read_eneband THEN BEGIN
    rd_fits_ext, FILE=file, $
                 EXTNAME='ENEBAND', $
                 SETNUMBER=setno, $
                 HEADER=eneband_header, $
                 DATA=eneband_data, $
                 STATUS=enband_status, $
                 ERR_MSG=err_msg, $
                 ERR_CODE=err_code, $
                 SILENT=silent
ENDIF

END

