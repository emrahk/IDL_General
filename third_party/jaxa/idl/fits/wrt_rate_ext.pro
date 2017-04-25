;==============================================================================
;+
; Name: wrt_rate_ext
;
; Category: HESSI, UTIL
;
; Purpose: Write a RATE binary extension to a FITS file.
;
; Calling sequence:  wrt_rate_ext, 'file.fits', header=hdr, rate=rate, error
;
; Inputs:
;   filename - name of FITS file to write.
;
; Outputs:
;
; Input keywords:
; DATA - a [n_channel x n_input spectra / n_channel x n_detector x $
;    n_input_spectra] array containing the the counts/s or counts
;    for each spectrum in each channel
; ERROR - an array containing the uncertainties on DATA.  Deafults to the
;         square root of DATA.
; COUNTS - set if the column name for the data entry should be COUNT,
;        instead of the default RATE.
; UNITS - units for DATA

; KW_LIST - list of keywords to search for as fields(tags) in _extra.
; ST_LIST - names fields set in _extra will be given in the structure
;           given to mwrfits.
; Keywords searched for in _EXTRA:
; These are set in the keyword KW_LIST.  Their names in the structure fed to
; mwrfits are set in the keyword ST_LIST.
; LIVETIME - a [ n_channel x n_input spectra / n_input spectra ] array
;        containing the livetime for each [ spectrum channel / spectrum ]
; TIMEZERO - the reference time for each bin in each spectrum.  This
;        should be a n_input spectra vector.  Defaults to 0.  TIMEZERO
;            can also be specified as a keyword in the rate extension header.
; TSTART - the start time for each accumulation.  A n_input spectra vector.
; TSTOP - the stop time for each accumulation.  A n_input spectra vector.
; TIMECEN - Full time or time from TIMEZERO for each input spectrum or event.
;           Stored as TIME column within file.
; TIMEDEL - The integration time for each channel of each spectrum or each
;           spectrum.
; Either TIMEZERO, TSTART, or TIMEDEL are required
; DEADC - Dead Time Correction for each channel of each spectra, each
;         spectrum, or each channel.  Only one of DEADC / LIVETIME should be set.
;         If n_chan elements, this will be set in the header for this
;         extension.
; BACKV - background counts for each channel of each spectrum - OPTIONAL.
; BACKE - error on background counts for each channel of each spectrum.
;    OPTIONAL.  Defaults to the square root of the BACKV if BACKV is set.
; _EXTRA - Any keywords set in _EXTRA will be integrated into the extension
;          structure array if they are listed in kw_list and have a
;          corresponding st_lst entry.
;
; NOTES on the TIMECEN, etc. keywords:
; For event lists, the TIMECEN keyword is required.  Any other
; event-specific information is stored in _extra.
; For rates, there are two possibilities: equispaced binned data and non-
; equispaced binned data.  For equispaced binned data, TIMEDEL can be a
; keyword in the rate header, and TIMECEN is not needed.  For
; non-equispaced binned data, TIMECEN and TIMEDEL are required for
; every event/spectrum.
;
; Output keywords:
; ERR_MSG = error message.  Null if no error occurred.
; ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
;   add_tag, arr2str, mk_rate_hdr, mwrfits, str_subset, trim, wc_where
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC, 18-May-2001
;
; Modification History:
; 28-June-2001 Paul Bilodeau - documentation updates.  Added RATE and DATA
;   keywords.  Data of interest in passed in via DATA, and the column name
;   defaults to COUNT unless RATE is set.
; 11-mar-2002, richard.schwartz@gsfc, simplified structure building
; 15-nov-2002, richard.schwartz@gsfc.nasa.gov, fixes the case for a single row
;     in the spectrum.
; 17-nov-2002, richard.schwartz@gsfc.nasa.gov, fix the fixes of 15-nov-2002
; 18-nov-2002, Paul.Bilodeau@gsfc.nasa.gov, changed error handling to
;   use GOTO's for simplification, removed CATCH statement.
; 25-feb-2003, Paul.Bilodeau@gsfc.nasa.gov, fixed crash when scalars
;   are added to rate extension row structure.
; 03-Sep-2004, Sandhia Bansal, Added NCHAN and ESPOSURE to the argument list.
;                 Use RATE_STRUCT to set up values for some of the
;                   required keywords for RATE extension.  Pass this structure to
;                   mk_rate_hdr that will actually add these keywords to the table.
;                 Write STAT_ERR instead of ERROR to the new fits files.
;                 Use fitswrite object to write the header and data.
; 24-Sep-2004, Sandhia Bansal, Filled origin and chantype fields of rate_struct.
; 18-Nov-2004, Sandhia Bansal, Change CHANTYPE value from PHA to PI for HESSI data.
;                              Deleted code to retrieve and set response matrix name,
;                              and DATE_OBS, DATE_END fields.
; 07-Dec-2004, Sandhia Bansal, Deleted code that created and initialized rate_struct.
;                              This structure will be passed to this
;                              procedure.
; 16-aug-2005 - Andre, added create = 0 to the fitswrite object to adapt to
;               the new writer. Also, commented out the stuff with the
;               extensions which is not needed any more in the newer version
;               fo the fits writer. (see acs comment below)
; 10-Aug-2009, Kim. Destroy fitswrite object (fptr) before exiting.  Memory leak.
;-
;------------------------------------------------------------------------------
PRO wrt_rate_ext, filename, RATE_STRUCT=rate_struct, HEADER=header, DATA=data, $
                  COUNTS=counts, ERROR=error, UNITS=units, _EXTRA=_extra, $
                  KW_LIST=kw_list, ST_LIST=st_list, COL_NAMES=col_names,  $
                  NROWS = nrows, PRIM_kw_list=PRIM_kw_list, $
                  PRIM_st_list = prim_st_list, EVENT_LIST=event_list, $
                  ERR_MSG=err_msg, ERR_CODE=err_code


err_msg = ''
err_code = 0

data_str = Keyword_Set( counts ) ? 'COUNTS' : 'RATE'

use_err = N_Elements( error ) NE N_Elements( data ) ? Sqrt( data ) : error

rate_flag = Size( use_err, /TYPE ) EQ 4 OR Size( use_err, /TYPE ) EQ 5

s = Size( data, /STRUCTURE )


n_det = 0L
n_chan = 1L
n_rows = fcheck( nrows, s.n_elements)
;Check n_rows vs _extra.timecen
ndim     = s.n_dimensions
if n_rows eq 1 then begin ;one degenerate dimension for time, make corrections
    s.dimensions[ndim] = 1

    ndim = ndim+1
    endif

CASE 1 OF
    ndim eq 0L:
    ndim eq 1L: BEGIN
        IF 1 - Keyword_Set( event_list ) THEN BEGIN
            n_chan = n_rows
            n_rows = 1L
    ENDIF
    END
    ndim eq 2L or ndim eq 3L: BEGIN
    n_rows = s.dimensions[ ndim-1]
    n_chan = s.dimensions[0]
    n_det    = ndim eq 3 ? s.dimensions[1] : 0L
    END
    ELSE: BEGIN
        err_msg = 'Input ' + data_str + ' may have at most 3 dimensions.'
        GOTO, ERROR_EXIT
    END
ENDCASE

use_double = Size( data, /TYPE ) EQ 5

use_cnames = Size( col_names, /TYPE ) EQ 7 AND N_Elements( col_names ) EQ n_det

CASE 1 OF
;    n_chan EQ 1: BEGIN
;        CASE 1 OF
;            rate_flag AND use_double: data_typ = '0.d0'
;            rate_flag: data_typ = '0.'
;            ELSE: data_typ = '0L'
;        ENDCASE
;    END
    n_det GT 0L: BEGIN
        CASE 1 OF
            rate_flag AND use_double: data_typ = 'Dblarr(n_chan,n_det)'
            rate_flag: data_typ = 'Fltarr(n_chan,n_det)'
            ELSE: data_typ = 'Lonarr(n_chan,n_det)'
    ENDCASE
    END
    use_double: data_typ = 'Dblarr(n_chan)'
    ELSE: data_typ = 'Fltarr(n_chan)'
ENDCASE

; Required fields for the rate extension to be written
reqd_tags = [ data_str, 'STAT_ERR'  ]
reqd_types = [ data_typ, data_typ ]
IF use_cnames THEN BEGIN
    reqd_tags = Strarr( n_det*2L )
    reqd_types = reqd_tags
    reqd_types[ * ] = data_typ
    reqd_tags[ Lindgen(n_det)*2L ] = data_str + '_' + col_names
    reqd_tags[ Lindgen(n_det)*2L + 1L ] = 'STAT_ERR' + '_' + col_names
ENDIF


; concatenate the structure arrays into a single structure definition statement
struct_fields = reqd_tags + ':' + reqd_types
struct_def = arr2str( struct_fields, ',' )
struct_def = 'struct = {' + struct_def + '}'
ex_val = Execute( struct_def )
IF NOT( ex_val ) THEN BEGIN
    err_msg = 'Could not define structure: ' + !err_string
    GOTO, ERROR_EXIT
ENDIF


;Don't expand to N_rows yet, fill in at the end

curr_tag_index = N_Elements( reqd_tags )

;Here we match up fields in _EXTRA to primary header keywords or optional
;extension column names

if keyword_set( _Extra ) then BEGIN
    ;out = { itag:0,  kw:'', st:'', nelem: 0LL, n_dim:0, dim:lonarr(8)}
    tags = tag_names( _extra )
    ntag = n_elements( tags )
    ;out = replicate( out, ntag )
    nelem = lonarr( ntag )
    for i=0,ntag-1 do begin
        temp = _extra.(i)
        s = size(/str, temp )

        ;; 25-feb-2003, pb, work with correct size of scalars
        ;; converted to arrays.
        if s.n_dimensions eq 0 then begin
            temp = make_array(value=temp,1)
            s = size(/str, temp )
        endif

        itag = i + curr_tag_index
        n_dim = s.n_dimensions
        dim = s.dimensions
        nelem[i] = s.n_elements
        wkw= where( tags[i] eq kw_list, nkw)
        if nkw eq 0 then begin
            err_msg= tags[i] +' is non-standard keyword'
            GOTO, ERROR_EXIT
        endif
        kw = kw_list[wkw[0]]
        stndrd = st_list[wkw[0]]
        ;Does last non-zero element of dim have n_rows?
;        if dim[n_dim-1] ne N_ROWS and nelem[i] ne 1 then begin
;            err_msg= tags[i] + ' does not have N_ROWS, ' + $
;                     'cannot be placed into the rate structure'
;            GOTO, ERROR_EXIT
;        endif

        if nelem[i] eq 1 and n_rows gt 1 then begin
            fxaddpar, header, stndrd, temp[0]
        endif else BEGIN
            if n_dim eq 1 and nelem[i]/n_rows eq 1 then value = temp[0] else begin
              this_dim = dim[0:n_dim-(2<n_rows)]

              value = make_array( dim = this_dim,  value=temp[0] )
              endelse
            struct = add_tag( struct, value, stndrd )

        endelse
    endfor
endif

input = n_rows GT 1L ? Replicate( struct, n_rows ) : struct

Next_field = 0
IF use_cnames THEN BEGIN
    FOR i=0L, N_Elements( reqd_tags )/2L-1L DO BEGIN
        input.( i*2L ) = input.( i*2L )+Reform( data[*,i,*] )
        input.( i*2L+1L ) = input.( i*2L+1L )+Reform( use_err[*,i,*] )
    ENDFOR
    Next_field = i
ENDIF ELSE BEGIN
    input.( 0L ) = input.( 0L ) +data
    input.( 1L ) = input.( 1L ) +use_err
    next_field = 2
ENDELSE

;Fill in FITS column elements from _EXTRA tags
select = where( nelem gt 1, nsel )
For i=0, nsel-1 do $
  input.(Next_field+i) = _extra.(select[i])

fptr = fitswrite()
; acs 2005-08-16 create=0 is now needed to avoid the file to be rewritten (as
; it was before)
fptr->set, create = 0
; Set filename for fptr object
fptr->Set, filename=filename

; If rate_struct is not define, define it and get the default values.
IF (NOT keyword_set( RATE_STRUCT )) THEN BEGIN
   message, 'Structure containing rate keywords is not defined, ' + $
      ' Getting default values', /info
   rate_struct = default_rate_header()
ENDIF

rate_hdr = mk_rate_hdr( header, rate_struct, N_ROWS=n_rows, EVENT_LIST=event_list, $
    fptr=fptr, ERR_MSG=err_msg, ERR_CODE=err_code )

IF err_code THEN GOTO, ERROR_EXIT

; acs 2005-08-16 this is not needed any more, the writer writes the extensions
; one after the other.
;extension=fptr->get(/extension)
;fptr->Set, extension=extension+1
fptr->setheader, rate_hdr

IF Size( units, /TYPE ) EQ 7 THEN BEGIN
    FOR i=0L, N_Elements( units )-1L DO $
      fptr->Addpar, 'TUNIT'+trim(i+1L), units[i]
ENDIF

fptr->write, input
;mwrfits, input, filename, rate_hdr

ERROR_EXIT:
err_code = err_msg NE ''
IF err_code THEN BEGIN
    MESSAGE, err_msg, /CONTINUE
    err_msg = 'WRT_RATE_EXT: ' + err_msg
ENDIF

destroy, fptr

END
