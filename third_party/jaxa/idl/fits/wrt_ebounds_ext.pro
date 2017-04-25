;==============================================================================
;+
; Name: wrt_ebounds_ext
;
; Category: HESSI, UTIL
;
; Purpose: Write an EBOUNDS binary extension to a FITS file.
;
; Calling sequence:  wrt_ebounds_ext, 'file.fits', header=hdr, rate=rate, error
;
; Inputs:
; file - name of FITS file to write to.
; channels - index of detector channels
; edges - energy edges of channels
; hdr - header for this extension
;
; Input keywords:
; _EXTRA - any keywords in _extra will be integrated into the header for this
;          extension.
;
; Output keywords:
; ERR_MSG = error message.  Null if no error occurred.
; ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
; add_kw2hdr, fxbaddcol, fxbhmake, mwrfits, overwrt_hdr_kw
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;
; Modification History:
;   7-December-2001, Paul Bilodeau - changed definition of e_min and e_max
;     such that vectors are returned from the file, not 1 x n matrices.
;   18-non-2002, Paul.Bilodeau@gsfc.nasa.gov - changed error handling.
;     Use CATCH for mwrfits call only, otherwise use GOTO's to handle display
;     and format of any error messages.
;   13-Sep-2004, Sandhia Bansal - write channels as LONG integers.  Also
;     write channels, emin and emax one element per bin rather than as a
;     vector array in one bin.
;-
;------------------------------------------------------------------------------
PRO wrt_ebounds_ext, file, channels, edges, hdr, _EXTRA=_extra, $
                     ERR_MSG=err_msg, ERR_CODE=err_code

err_msg = ''
err_code = 1

n_channels = N_Elements( channels )

;Write the EBOUNDS extension
fxbhmake, head_e, 1, 'EBOUNDS', ERRMSG=err_msg
IF err_msg NE '' THEN GOTO, ERROR_EXIT

IF Size( hdr, /TYPE ) EQ 7 THEN BEGIN
    head_e = merge_fits_hdrs( head_e, hdr, ERR_MSG=err_msg, ERR_CODE=err_code )
    IF err_code THEN GOTO, ERROR_EXIT
ENDIF

;Add keywords to the header
hdr_list = [ 'EXTNAME', 'TELESCOP', 'INSTRUME', 'FILTER', 'CHANTYPE', $
  'DETCHANS', 'HDUCLASS', 'HDUCLAS1', 'HDUCLAS2', 'HDUVERS' ]

kw_list = hdr_list

head_e = add_kw2hdr( head_e, HDR_LIST=hdr_list, KW_LIST=kw_list, $
  EXTNAME='EBOUNDS', DETCHANS=n_channels, HDUCLASS='OGIP', $
  HDUCLAS1='RESPONSE', HDUCLAS2='EBOUNDS', HDUVERS='1.2.0', _EXTRA=_extra, $
  ERR_MSG=err_msg, ERR_CODE=err_code )

IF err_code THEN GOTO, ERROR_EXIT

fxbaddcol, 1, head_e, 1, 'CHANNEL', ERRMSG=err_msg
IF err_msg NE '' THEN GOTO, ERROR_EXIT

e_min = Reform(edges[0,*])
fxbaddcol, 2, head_e, e_min, 'E_MIN', tunit = 'keV', ERRMSG=err_msg
IF err_msg NE '' THEN GOTO, ERROR_EXIT

e_max = Reform(edges[1,*])
fxbaddcol, 3, head_e, e_max, 'E_MAX', tunit = 'keV', ERRMSG=err_msg
IF err_msg NE '' THEN GOTO, ERROR_EXIT

;struct = { channel: channels, e_min: e_min, e_max: e_max }
struct = { channel: 0L, e_min: 0.0, e_max: 0.0 }



input = Replicate( struct, n_channels )

input.channel = channels
input.e_min   = e_min
input.e_max   = e_max




;; Catch any mwrfits errors
CATCH, err
IF err NE 0 THEN BEGIN
    err_msg = !err_string
    GOTO, ERROR_EXIT
ENDIF
;mwrfits, struct, file, head_e
mwrfits, input, file, head_e


ERROR_EXIT:
err_code = err_msg NE ''
IF err_code THEN BEGIN
    MESSAGE, err_msg, /CONTINUE
    err_msg = 'WRT_EBOUNDS_EXT: ' + err_msg
ENDIF

END
