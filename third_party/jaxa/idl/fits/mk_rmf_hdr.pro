;==============================================================================
;+
; Name: mk_rmf_hdr
;
; Category: HESSI, UTIL
;
; Purpose: Make an header for a response matrix FITS extension.
;
; Calling sequence:
; rmf_hdr = mk_rmf_hdr( HEADER=basic_header, N_HDR_ROWS=12, $
;   EXTNAME='SPECRESP MATRIX' )
;
; Inputs:
;
; Input keywords:
; HEADER - primary header for the file.  This contains any information
;          that should be in the header in addition to the mandatory
;          keywords.
; _EXTRA - included to capture any keywords that should be added to
;          the header.
;
; Output keywords:
; ERR_MSG = error message.  Null if no error occurred.
; ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
; arr2str, str2arr, str2chars
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;-
;------------------------------------------------------------------------------
FUNCTION mk_rmf_hdr, HEADER=hdr, N_HDR_ROWS=n_hdr_rows, EXTNAME=extname, $
                     _EXTRA=_extra, ERR_MSG=err_msg, ERR_CODE=err_code

err_code = 1
err_msg = ''

CATCH, err
IF err NE 0 THEN BEGIN
    err_msg = !err_string
    RETURN, ''
ENDIF

fxbhmake, rmf_hdr, n_hdr_rows, ' SPECTRAL RESPONSE RMF EXTENSION', /DATE, $
          /INITIALIZE

IF Size( hdr, /TYPE ) EQ 7 THEN BEGIN
    rmf_hdr = merge_fits_hdrs( hdr, rmf_hdr, ERR_MSG=err_msg, $
      ERR_CODE=err_code )
    IF err_code THEN RETURN, ''
ENDIF

IF N_Elements( extname ) EQ 0L THEN extname = 'SPECRESP MATRIX'

;Add keywords to the header
hdr_list = [ 'EXTNAME', 'TELESCOP', 'INSTRUME', 'FILTER', 'CHANTYPE', $
  'DETCHANS', 'HDUCLASS', 'HDUCLAS1', 'HDUCLAS2', 'HDUCLAS3', 'HDUVERS', $
  'TLMIN4', 'TLMAX4', 'NUMGRP', 'NUMELT', 'PHAFILE', 'LO_THRES' ]

kw_list = hdr_list
rmf_hdr = add_kw2hdr( rmf_hdr, HDR_LIST=hdr_list, $
  KW_LIST=kw_list, EXTNAME=extname, HDUCLASS='OGIP', HDUCLAS1='RESPONSE', $
  HDUCLAS2='RSP_MATRIX', HDUVERS='1.3.0', _EXTRA=_extra, ERR_MSG=err_msg, $
  ERR_CODE=err_code )

RETURN, rmf_hdr

END
