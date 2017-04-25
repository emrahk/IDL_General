;+
; Name: merge_fits_hdrs
;
; Category: HESSI, UTIL
;
; Purpose: Merge two FITS headers.
;
; Calling sequence:  rm2fits, 'file.fits', photon_edges, matrix, LO_THRES=1e-6
;
; Inputs:
; 	master - header to merge keywords into.
; 	input - header to merge keywords from.
;
; Outputs:
;
; Input keywords:
;
; Output keywords:
; 	ERR_MSG = error message.  Null if no error occurred.
; 	ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
;	fxaddpar
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;-
;------------------------------------------------------------------------------
FUNCTION merge_fits_hdrs, master, input, ERR_MSG=err_msg, ERR_CODE=err_code

err_code = 1
err_msg = ''
CATCH, err
IF err NE 0 THEN BEGIN
	err_msg = !err_string
	RETURN, 0
ENDIF

merged = master

comp_master = Where( Strmid(master,0,1) NE ' ' AND $
	Strmid(master,0,1) NE '' )
comp = Strmid( master[comp_master], 0, 8 )

; Ignore blank lines, comments, history entries, and the 'END' keyword.
comp_input = Where( Strmid(input,0,1) NE ' ' AND $
  Strmid(input,0,1) NE '' AND $
  Strmid(input,0,8) NE 'COMMENT ' AND $
  Strmid(input,0,8) NE 'HISTORY ' AND $
  Strmid(input,0,3) NE 'END', n_comp_input )

input_names = Strmid( input, 0, 8 )

FOR i=0L, n_comp_input-1L DO BEGIN
    match = Where( Strmid(input[comp_input[i]],0,8) EQ comp, n_match )
    IF n_match EQ 0L THEN BEGIN
        value = fxpar( input, input_names[comp_input[i]], comment=comment )
        fxaddpar, merged, input_names[comp_input[i]], value, comment
    ENDIF
ENDFOR

; Add any history and comments to the end of the master header.
comm = Where( Strmid(input,0,8) EQ 'COMMENT ', n_comm )
FOR i=0L, n_comm-1L DO fxaddpar, merged, 'COMMENT', input[comm[i]]

hist = Where( Strmid(input,0,8) EQ 'HISTORY ', n_hist )
FOR i=0L, n_hist-1L DO fxaddpar, merged, 'HISTORY', input[hist[i]]

err_code = 0
RETURN, merged

END
