;+
; Name: add_kw2hdr
;
; Category: UTIL
;
; Purpose: Add keywords set in _EXTRA to a FITS header.  The mapping of _extra
; 	keywords to header keywords is controlled via the keywords kw_list and
; 	hdr_list
;
; Calling sequence:  new_hdr = add_kw2hdr( header, KW_LIST=kws, HDT_LIST=hdrs )
;
; Input:
; 	hdr - FITS header for modification.
;
; Output:
;	Modified FITS header.
;
; Input keywords:
; 	KW_LIST - list of keywords to search for in _extra
; 	HDR_LIST - names keyword parameters will be given in FITS header.
; 	HDR_COMMENTS - string array containing comments for added parameters.
;
; Output keywords:
; 	ERR_MSG - string containing error message.  Null if no errors occurred during
; 		execution.
;	ERR_CODE - 0/1 if no error/ an error occurred during execution.
;
; Calls:
; 	fxaddpar, fxpar, wc_where
;
; Written: Paul Bilodeau, RITSS/ NASA-GSFC 18-May-2001
;-
;-------------------------------------------------------------------------------
FUNCTION add_kw2hdr, hdr, KW_LIST=kw_list, HDR_LIST=hdr_list, $
	HDR_COMMENTS=hdr_comments, _EXTRA=_extra, ERR_MSG=err_msg, ERR_CODE=err_code

err_msg = ''
err_code = 1

CATCH, err
IF err NE 0 THEN BEGIN
	err_msg = !err_string
	RETURN, 0
ENDIF

IF Size( hdr, /TYPE ) NE 7 THEN BEGIN
	err_msg = 'Parameter HDR must be a FITS header.'
	RETURN, 0
ENDIF

CASE 1 OF
	Size( kw_list, /TYPE ) NE 7: BEGIN
		err_msg = 'Keyword KW_LIST must be a string array.'
		RETURN, 0
	END
	Size( hdr_list, /TYPE ) NE 7: BEGIN
		err_msg = 'Keyword HDR_LIST must be a string array.'
		RETURN, 0
	END
	N_Elements( kw_list ) NE N_Elements( hdr_list ): BEGIN
		err_msg = 'Keywords KW_LIST and HDR_LIST must be string arrays ' + $
			'of the same size.'
		RETURN, 0
	END
	ELSE:
ENDCASE

out_hdr = hdr

use_comments = Size( hdr_comments, /TYPE ) EQ 7 AND $
	N_Elements( hdr_comments ) EQ N_Elements( hdr_list )

; index of _extra structure tags corresponding to proper header keywords
hdr2ex_idx = Make_Array( N_Elements( hdr_list ), /LONG, VALUE=-1 )

IF Size( _extra, /TYPE ) EQ 8 THEN BEGIN
	ex_tags = Tag_Names( _extra )
	n_ex = N_Tags( _extra )
	FOR i=0L, n_ex-1L DO BEGIN
		match = ( WC_Where( kw_list, ex_tags[ i ]+'*' ) )[ 0 ]
		IF match GT -1L AND N_Elements( _extra.( i ) ) EQ 1L THEN $
			hdr2ex_idx[ match ] = i
	ENDFOR
ENDIF

; set/insert any proper keywords into the header
matched = Where( hdr2ex_idx GT -1, n_matched )
FOR i=0L, n_matched-1L DO BEGIN
	idx = matched[ i ]
	ex_idx = hdr2ex_idx[ idx ]
	IF use_comments THEN $
		fxaddpar, out_hdr, hdr_list[ idx ], _extra.( ex_idx ), $
			hdr_comments[ idx ] $
	ELSE $
		fxaddpar, out_hdr, hdr_list[ idx ], _extra.( ex_idx )
ENDFOR

; If necessary, add a default null string to any proper keywords that weren't
; set in the _extra structure.
failed = Where( hdr2ex_idx EQ -1, n_failed )
FOR i=0L, n_failed-1L DO BEGIN
	result = fxpar( out_hdr, hdr_list[ failed[ i ] ], COUNT=count )
	IF count EQ 0L THEN fxaddpar, out_hdr, hdr_list[ failed[ i ] ], ''
ENDFOR

err_code = 0

RETURN, out_hdr

END