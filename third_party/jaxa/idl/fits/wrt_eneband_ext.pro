;==============================================================================
;+
; Name: wrt_eneband_ext
;
; Category: HESSI, UTIL
;
; Purpose: Write an ENEBAND extension to a FITS file.
;
; Calling sequence:
; wrt_eneband_ext, 'file.fits', NUMBAND=numband, MINCHAN=minchan,
;   MAXCHAN=maxchan, E_MIN=e_min, E_MAX=e_max
;
; Inputs:
; filename - name of FITS file to append to.
;
; Outputs:
;
; Input keywords:
; NUMBAND - number of energy bands to be stored in the extension.
; MINCHAN - Array numband in length, containing minimum detector channel
;       numbers for each band.
; MAXCHAN - Array numband in length, containing maximum detector channel
;           numbers for each band.
; E_MIN - Array numband in length, containing minimum energies for each band.
; E_MAX - Array numband in length, containing maximum energies for each band.
; E_UNIT - energy units for e_min and e_max.
; HEADER - extension header. Should contain any comments, history, and
;          non-mandatory keywords that be in the extension header.
;
; Output keywords:
; ERR_MSG = error message.  Null if no error occurred.
; ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
; fxaddpar, fxbaddcol, fxbcreate, fxbwrite, fxbfinish, fxwrite, mk_rmf_hdr,
; mwrfits,  trim, wrt_ebounds_ext
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;
; Modification History:
;   18-nov-2002, Paul.Bilodeau@gsfc.nasa.gov - changed error handling to
;     use GOTO's for simplification, removed CATCH staement.
;   01-sep-2004, Sandhia Bansal - modified code to write energy bounds as
;                    one element per bin rather than as a vector array in a row.
;   13-sep-2004, Sandhia Bansal - replace min/max channels with only CHANNELS and write this
;                    column as a vector of long integers.
;
;-
;------------------------------------------------------------------------------
PRO wrt_eneband_ext, filename, NUMBAND=numband, MINCHAN=minchan, $
                     MAXCHAN=maxchan, E_MIN=e_min, E_MAX=e_max, $
                     E_UNIT=e_unit, HEADER=header, ERR_MSG=err_msg, $
                     ERR_CODE=err_code

err_msg = ''
err_code = 0

;IF N_Elements( minchan ) NE N_Elements( maxchan ) THEN BEGIN
;    err_msg = 'Number of MINCHAN not equal to number of MAXCHAN.'
;    GOTO, ERROR_EXIT
;ENDIF

IF N_Elements( numband ) EQ 0L THEN numband = N_Elements( minchan )

m_mchan = Max( minchan )

CASE 1L OF
    ; 1 byte integer
    ;m_mchan LE ( 2^8 - 1 ): istr = numband EQ 1L ? '0B' : 'Bytarr(numband)'
    m_mchan LE ( 2^8 - 1 ): istr = '0L'
    ; 2 byte integer
    ;m_mchan LE ( 2L^16 - 1 ): istr = numband EQ 1L ? '0' : 'Intarr(numband)'
    m_mchan LE ( 2L^16 - 1 ): istr = '0'
    ; 4 byte integer
    ;ELSE: istr = numband EQ 1L ? '0L' : 'Lonarr(numband)'
    ELSE: istr = '0L'
ENDCASE

; Make the binary extension header
fxbhmake, hdr, numband, 'ENEBAND', /DATE, ERRMSG=err_msg
err_code = err_msg NE 0
IF err_code THEN GOTO, ERROR_EXIT

; merge any input from the HEADER keyword
IF Size( header, /TYPE ) EQ 7 THEN BEGIN
    hdr = merge_fits_hdrs( header, hdr, ERR_MSG=err_msg, ERR_CODE=err_code )
    IF err_code THEN GOTO, ERROR_EXIT
ENDIF

;struct_def = 'struct = { MINCHAN: ' + istr + ', MAXCHAN: ' + istr
struct_def = 'struct = { CHANNEL: ' + istr

use_e = N_Elements( e_min ) EQ N_Elements( minchan ) AND $
  N_Elements( e_min ) EQ N_Elements( e_max )

IF use_e THEN BEGIN
    IF Size( e_unit, /TYPE ) NE 7 THEN e_unit = 'keV'
    ;e_str = numband EQ 1L ? '0.' : 'Fltarr( numband )'
    e_str = '0.'
    fxaddpar, hdr, 'TUNIT2', e_unit
    fxaddpar, hdr, 'TUNIT3', e_unit
    struct_def = struct_def + ', E_MIN: ' + e_str + ', E_MAX: ' + e_str
ENDIF

struct_def = struct_def + '}'

err = 1 - Execute( struct_def )



; this code writes one element per bin for each field - SB - 09/01/04
; fill structure with values
input = Replicate( struct, n_elements(minchan) )
input.channel = minchan

if use_e then begin
    input.e_min = e_min
    input.e_max = e_max
endif




; this code writes each field as a vector in a row
;struct.minchan = minchan
;struct.maxchan = maxchan

;IF use_e THEN BEGIN
;    struct.e_min = e_min
;    struct.e_max = e_max
;ENDIF

; Write the header and extension to the file
;mwrfits, struct, filename, hdr
mwrfits, input, filename, hdr

ERROR_EXIT:
err_code = err_msg NE ''
IF err_code THEN BEGIN
    MESSAGE, err_msg, /CONTINUE
    err_msg = 'WRT_ENEBAND_EXT: ' + err_msg
ENDIF

END
