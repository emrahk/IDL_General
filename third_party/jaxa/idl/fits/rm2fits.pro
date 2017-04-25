;==============================================================================
;+
; Name: rm2fits
;
; Category: FITS, UTIL
;
; Purpose: Write a response matrix to a FITS file.  Aims for OGIP
; CAL-GEN-92-002 compliance.
;
; Calling sequence:  rm2fits, 'file.fits', photon_edges, matrix, LO_THRES=1e-6
;
; Inputs:
; file - name of FITS file to write.
; e_bins - Energy boundaries for photon side of response matrix,
;          2 x n_photon bins
; rm - response matrix, dimensioned n_detector channels x n_photon bins
;
; Outputs:
;
; Input keywords:
; WRITE_PRIMARY_HEADER - set this keyword to write a primary header to
;                        file.  This will overwrite any existing file.
; PRIMARY_HEADER - primary header for the FITS file.  Only used if
;                  WRITE_PRIMARY_HEADER is set.
; DET_CHANNELS - energy boundaries for detector channels - 2xn_channels
; LO_THRES - cutoff value below which rm elements will not be stored
; MINCHANNEL - Minimum channel number - defaults to 1
; MAXCHANNEL - Maximum channel number - defaults to n_channels
; PRIMARY_HEADER - primary header for the FITS file.  If this is set,
;                  a new file with name = file will be written.  This
;                  will overwrite any files.  If not set and file
;                  already exists, the extension will be appended to
;                  the file.
; EXTENSION_HEADER - extension header for the FITS file.
; MULTIDETECTOR - Set this if the rm is 2-D, but is an array of the diagonal
;                 responses from multiple detectors.
;
; Output keywords:
; RMF_HEADER - Response Matrix extension header written
; ERR_MSG = error message.  Null if no error occurred.
; ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
; fxaddpar, fxbaddcol, fxbcreate, fxbwrite, fxbfinish, fxwrite, mk_rmf_hdr,
; mwrfits,  trim, wrt_ebounds_ext
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;
; MODIFICATION HISTORY:
; 12-December-2001, Paul BIlodeau - made lo_thres keyword inactive due
;   to bug in reading some FITS files written with it.
; 11-January-2002, Paul Bilodeau - added capability to store diagonal
;   (vector) response matrices.
; 8-aug-2002, Paul Bilodeau - added capability to store 3
;    dimensional matrices, but not with the LO_THRES keyword.
; 18-nov-2002, Paul Bilodeau - changed error message handling:  rely
;   on subroutines to print their own error messages, use GOTO's, and
;   removed CATCH statement.
; 4-Mar-2003, Paul Bilodeau - add MULTIDETECTOR keyword to resolve
;   ambiguity when storing diagonal responses from multiple
;   detectors.
; 25-Jun-2004, Kim Tolbert - added rmf_header keyword to return rm ext header
; 11-Sep-2004, Sandhia Bansal - The array "channels" should be offset by
;                first element of tlmin4 before calling wrt_ebounds_ext.
;              Now storing f_chan and n_chan in long variables.
;-
;-----------------------------------------------------------------------------
PRO rm2fits, file, e_bins, rm, $
             WRITE_PRIMARY_HEADER=write_primary_header, $
             PRIMARY_HEADER=pheader, $
             EXTENSION_HEADER=eheader, $
             DET_CHANNELS=det_channels, $
             LO_THRES=lo_thres, $
             MINCHANNEL=minchannel, $
             MAXCHANNEL=maxchannel, $
             MULTIDETECTOR=multidetector, $
             RMF_HEADER=rmf_header, $
             _EXTRA=_extra, $
             ERR_MSG=err_msg, $
             ERR_CODE=err_code

err_msg = ''
err_code = 0

multidetector = Keyword_Set( multidetector )

rm_dimen = n_dimensions( rm )

; Paul Bilodeau, 12-December-2001 - don't use the lo_thres keyword.
use_thres = 0

;; Only 2-D matrices containing the response from a single detector /
;; instrument can be stored with the LO_THRES keyword.
;use_thres = N_Elements( lo_thres ) GT 0 AND $
;            ( 1 - multidetector ) AND $
;            rm_dimen LT 3

IF use_thres THEN BEGIN
    lo_thres=lo_thres[ 0 ]
    elem2store = Where( rm GE lo_thres, n_elem2store )
ENDIF ELSE BEGIN
    n_elem2store = N_Elements( rm )
    IF n_elem2store GT 0 THEN elem2store = Lindgen( n_elem2store )
ENDELSE

err_code = n_elem2store LE 0
IF err_code THEN BEGIN
    IF use_thres THEN $
      err_msg = 'Response Matrix contains no elements above: ' + $
        trim( lo_thres ) $
    ELSE err_msg = 'Response Matrix is undefined.'
    GOTO, ERROR_EXIT
ENDIF

IF Keyword_Set( write_primary_header ) THEN BEGIN
    fxhmake, phdr, /EXTEND, /DATE, ERRMSG=err_msg

    err_code = err_msg NE ''

    IF err_code THEN GOTO, HEADER_ERROR

    IF Size( pheader, /TYPE ) EQ 7 THEN BEGIN
        phdr = merge_fits_hdrs( pheader, phdr, ERR_MSG=err_msg, $
                 ERR_CODE=err_code )
        IF err_code THEN GOTO, HEADER_ERROR
    ENDIF

    fxwrite, file, phdr, ERRMSG=err_msg
    err_code = err_msg NE ''

    HEADER_ERROR:
    IF err_code THEN BEGIN
        MESSAGE, 'ERROR writing primary header to ' + file, /CONTINUE
        RETURN
    ENDIF
ENDIF


rm_sz = Size( rm )

add_scalar = 0
add_vector = 0
add_matrix = 0

n_rows = rm_sz[ rm_sz[0] ]
n_channels = rm_sz[ 1 ]
n_detectors = 1

CASE rm_dimen OF
    2: BEGIN
        add_vector = 1
        IF multidetector THEN BEGIN
            n_rows = rm_sz[1]
            n_detectors = rm_sz[2]
        ENDIF
    END
    1: BEGIN
        add_scalar = 1
        n_channels = 1
    END
    3: BEGIN
        add_matrix = 1
        n_rows = rm_sz[ 2 ]
        n_detectors = rm_sz[ 3 ]
    END
    0: BEGIN
        add_scalar = 1
        n_rows = 1
        n_channels = 1
    END
    ELSE: BEGIN
        err_code = 1
        err_msg = 'Cannot store matrix with ' + trim( rm_dimen ) + $
                  ' dimensions.'
        GOTO, ERROR_EXIT
    END
ENDCASE

tlmin4 = N_Elements( minchannel ) EQ 0L ? 1 : minchannel[0]
tlmin4 = Fix( tlmin4 )

tlmax4 = N_Elements( maxchannel ) EQ 0L ? n_channels : maxchannel[0]
tlmax4 = Fix( tlmax4 )

IF n_channels EQ 1L THEN BEGIN
    tlmin4 = Indgen( n_rows ) + tlmin4
    tlmax4 = tlmin4
ENDIF

energ_lo = Reform( e_bins[0,*] )
energ_hi = Reform( e_bins[1,*] )

;; 04-Mar-2003, Paul Bilodeau - quick consistency-check on the number
;; of rows and number of energy bins.  If they are not equal, exit
;; with an error message.
IF n_rows NE N_Elements( energ_lo ) THEN BEGIN
    err_code = 1
    err_msg = 'Number of rows: ' + trim( n_rows ) + $
              ', Number of E_BINS: ' + trim( N_Elements( energ_lo ) )
    GOTO, ERROR_EXIT
ENDIF

;head_rmf = mk_rmf_hdr( HEADER=eheader, N_HDR_ROWS=n_rows, $
;  DETCHANS=n_channels, LO_THRES=lo_thres, TLMIN4=tlmin4, TLMAX4=tlmax4, $
;  _EXTRA=_extra, ERR_MSG=err_msg, ERR_CODE=err_code )
;
; Don't store the lo_thres keyword since it isn't used.
detchans = n_channels EQ 1L ? n_rows : n_channels
head_rmf = mk_rmf_hdr( HEADER=eheader, N_HDR_ROWS=n_rows, $
  DETCHANS=detchans, TLMIN4=min( tlmin4 ), TLMAX4=max( tlmax4 ), $
  _EXTRA=_extra, ERR_MSG=err_msg, ERR_CODE=err_code )

IF err_code THEN RETURN

; add columns to the header
tunit = Size( e_unit, /TYPE ) EQ 7 ? e_unit[0] : 'keV'
fxbaddcol, 1, head_rmf, energ_lo[0], 'ENERG_LO', tunit = tunit
fxbaddcol, 2, head_rmf, energ_hi[0], 'ENERG_HI', tunit = tunit
fxbaddcol, 3, head_rmf, 1, 'N_GRP'

IF use_thres THEN BEGIN
    ;; Make an integer array of the maximum possible size for the variable
    ;; length columns.  This is the worst-case scenario, where there
    ;; are no blocks of contiguous channels, and every other channel
    ;; is above lo_thres.
    n_variable = ( n_channels/2 + n_channels MOD 2 ) > 1
    ;variable = Intarr( n_variable )
    variable = Lindarr( n_variable )

    ;; Add the variable length columns to the header.
    fxbaddcol, 4, head_rmf, variable, 'F_CHAN', /VARIABLE
    fxbaddcol, 5, head_rmf, variable, 'N_CHAN', /VARIABLE
    fxbaddcol, 6, head_rmf, Reform( rm[*,0] ), 'MATRIX', /VARIABLE

    ;; Count the number of elements to be stored and the column and
    ;; row indices of the stored elements.
    numelt = n_elem2store
    cols = elem2store MOD n_channels
    rows = elem2store / n_channels

    ;; Determine the number of subgroups of channels.
    delta_cols = shift(cols,-1) - cols
    tmp = Where( delta_cols NE 1, numgrp )

    ;; Now write the extension.
    fxaddpar, head_rmf, 'NUMELT', numelt
    fxaddpar, head_rmf, 'NUMGRP', numgrp

    ;; Create the extension.
    fxbcreate, file_unit, file, head_rmf

    ;; Write the extension, row by row.
    FOR i=0L, n_rows-1L DO BEGIN
        ;; Based on previous calculations, determine which matrix
        ;; elements to store.
        used_in_this_row = Where( rows EQ i, n_used_in_this_row )
        IF n_used_in_this_row GT 0L THEN BEGIN
            mat = rm[ elem2store[ used_in_this_row ] ]
            subcols = cols[ used_in_this_row ]
            ;; Calculate n_grp, f_chan, and n_chan.
            delta = shift(subcols,-1) - subcols
            index = ( Where( delta NE 1, n_grp ) )
            n_grp = Fix( n_grp )
            f_index = index + 1
            IF f_index[ n_grp-1 ] EQ n_used_in_this_row THEN BEGIN
                f_index[ n_grp-1 ] = 0
                f_index = shift(f_index, 1)
            ENDIF
            IF index[0] LT 0 THEN BEGIN
                index[0] = n_used_in_this_row - 1
                index = shift(index,-1)
            ENDIF
            ;f_chan = Fix( subcols[ f_index ] )
            ;n_chan = Fix( subcols[index] - f_chan + 1 )
            f_chan = Long( subcols[ f_index ] )
            n_chan = Long( subcols[index] - f_chan + 1 )
            f_chan = f_chan + tlmin4
        ENDIF ELSE BEGIN
            mat = 0.
            n_grp = 0
            f_chan = 0L
            n_chan = 0L
        ENDELSE
        ;; Write the information to the file.
        fxbwrite, file_unit, energ_lo[i], 1, i+1
        fxbwrite, file_unit, energ_hi[i], 2, i+1
        fxbwrite, file_unit, n_grp, 3, i+1
        fxbwrite, file_unit, f_chan, 4, i+1
        fxbwrite, file_unit, n_chan, 5, i+1
        fxbwrite, file_unit, mat, 6, i+1
    ENDFOR
    ;; Finish the extension
    fxbfinish, file_unit

ENDIF ELSE BEGIN
    numgrp = n_rows
    numelt = n_rows * n_channels
    nchan = Make_Array( n_rows, /INT, VALUE=n_channels )

    ; What matrix elements do we add to each row?
    IF add_scalar THEN mat_elem = rm[0]
    IF add_vector THEN BEGIN
        mat_elem = multidetector ? $
                   Reform( rm[0,*] ) : $
                   Reform( rm[*,0] )
    ENDIF
    IF add_matrix THEN mat_elem = Reform( rm[*,0,*] )

    ;; Add columns to the header.
    fxbaddcol, 4, head_rmf, 0L, 'F_CHAN'
    fxbaddcol, 5, head_rmf, 0L, 'N_CHAN'
    fxbaddcol, 6, head_rmf, mat_elem, 'MATRIX'

    fxaddpar, head_rmf, 'NUMELT', numelt
    fxaddpar, head_rmf, 'NUMGRP', numgrp



    struct = { $
              energ_lo: energ_lo[0], $
              energ_hi: energ_hi[0], $
              n_grp: 0, $
              f_chan: 0L, $
              n_chan: 0L, $
              matrix: mat_elem }

    input = Replicate( struct, n_rows )

    input.energ_lo = energ_lo
    input.energ_hi = energ_hi
    input[*].n_grp = 1
    input[*].f_chan = tlmin4
    input[*].n_chan = n_channels

    IF add_scalar THEN input.matrix = rm

    IF add_vector THEN BEGIN
        IF multidetector THEN $
          input.matrix = Transpose( rm ) $
        ELSE $
          input.matrix = rm
    ENDIF

    IF add_matrix THEN $
      FOR i=0, n_channels-1 DO input[i].matrix = Reform( rm[*,i,*] )

    rmf_header = head_rmf

    mwrfits, input, file, head_rmf
ENDELSE

n_det_channels = N_Elements( det_channels )
IF n_det_channels GT 0L THEN BEGIN
    IF n_channels EQ 1L THEN n_channels = n_det_channels / 2L
    ;channels = Lindgen( n_channels ) + tlmin4
    channels = Lindgen( n_channels ) + tlmin4[0]   ; offset the array by first element in tlmin4
    wrt_ebounds_ext, file, channels, det_channels, eheader, $
                     _EXTRA=_extra, ERR_MSG=err_msg, ERR_CODE=err_code, $
                     /NO_COMMENTS, /NO_HISTORY
ENDIF

ERROR_EXIT:
IF err_code THEN BEGIN
    MESSAGE, err_msg, /CONTINUE
    err_msg = 'RM2FITS: ' + err_msg
ENDIF

END
