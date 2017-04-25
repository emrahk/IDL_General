;==============================================================================
;+
;
; NAME: SSW_PICKFILE
;
; CATEGORY: FILE, UTIL
;
; PURPOSE: Wrapper routine for dialog_pickfile that returns a keyword
; indicating whether or not the selected file already exists.
;
; CALLING SEQUENCE: 
;   file = ssw_pickfile( PATH='/my/path', FILTER='*.txt', /FIX_FILTER, $
;     GET_PATH=path )
;
; INPUT KEYWORDS:
;   See dialog_pickfile.
;   _EXTRA - keywords in _extra are passed to dialog_pickfile.
;
; OUTPUTS:
;   See dialog_pickfile.
;
; OUTPUT KEYWORDS: 
;   GET_PATH - keyword for dialog_pickfile.  Included for keyword inheritance.
;   EXISTS - set to [ 0 / 1 ] if the selected file [ does not / does ]
;            exist.
;   ERR_CODE - set to [ 0 / 1 ] if an error [ did not / did ] occur
;              during execution.
;   ERR_MSG - String containing an error message.  Null if no error occurred.
;
; CALLS:
;   dialog_pickfile
;   loc_file
;
; WRITTEN: 11-January-2002, Paul Bilodeau
; Modifications:
;  16-jun-2008, Kim Tolbert.  Use file[0] to check for valid, in case multiple files allowed.
; 
;-
;
FUNCTION SSW_PICKFILE, GET_PATH=get_path, $
                       EXISTS=exists, $
                       QUIET=quiet, $
                       _EXTRA=_extra, $
                       ERR_MSG=err_msg, $
                       ERR_CODE=err_code
err_code = 1
err_msg = ''

loud = 1 - Keyword_Set( quiet )

exists = 0

file = DIALOG_PICKFILE( GET_PATH=get_path, _EXTRA=_extra )

IF file[0] EQ '' THEN BEGIN
    err_msg = 'No valid output filename selected.'
    IF loud THEN MESSAGE, err_msg, /CONTINUE
    RETURN, file
ENDIF

found_file = loc_file(file, PATH=get_path, COUNT=count )

exists = count GT 0

err_code = 0

RETURN, file

END
