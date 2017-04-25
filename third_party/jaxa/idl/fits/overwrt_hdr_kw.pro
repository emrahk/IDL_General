;+
; Name: overwrt_hdr_kw
;
; Category: HESSI, UTIL
;
; Purpose: Update FITS header by overwriting with keyword values from second
; 	input header.  Only keywords found in the first header are looked for in
; 	the second, so any keywords found in the second but not the first will
; 	not be integrated into the first.
;
; Calling sequence: new_hdr = overwrt_fits_hdr( my_hdr, hdr2merge )
;
; Inputs:
; 	master - FITS header for updating / merging.
; 	input - FITS header with keyword values to overwrite those found in master
;
; Outputs:
; 	merged header
;
; Input keywords:
;
; Output keywords:
; 	ERR_MSG = error message.  Null if no error occurred.
; 	ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
;	fxaddpar, fxpar
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC
;-
;-------------------------------------------------------------------------------
FUNCTION overwrt_hdr_kw, master, input, ERR_MSG=err_msg, ERR_CODE=err_code

err_msg = ''
err_code = 1

CATCH, err
IF err NE 0 THEN BEGIN
	err_msg = !err_string
	err_code = 1
	RETURN, 0
ENDIF

merged = master

comp_master = Where( Strmid(master,0,1) NE ' ' AND $
	Strmid(master,0,1) NE '' )
comp = Strmid( master[comp_master], 0, 8 )

; Ignore blank lines, comments, and history entries.
comp_input = Where( Strmid(input,0,1) NE ' ' AND Strmid(input,0,1) NE '' $
	AND Strmid(input,0,8) NE 'COMMENT ' AND Strmid(input,0,8) NE 'HISTORY ', $
	n_comp_input )

input_names = Strupcase( Strmid( input, 0, 8 ) )

FOR i=0L, n_comp_input-1L DO BEGIN
	match = Where( Strmid(input[comp_input[i]],0,8) EQ comp, n_match )
	IF n_match GT 0L THEN BEGIN
		value = fxpar( input, input_names[comp_input[i]], comment=comment )
		fxaddpar, merged, input_names[comp_input[i]], value, comment
	ENDIF
ENDFOR

err_code = 0
RETURN, merged

END