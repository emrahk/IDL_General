;==============================================================================
;+
; Name: spectrum2fits
;
; Category: FITS, UTIL
;
; Purpose: Write spectral rate data to a FITS file.
;
; Calling sequence:
;     spectrum2fits, filename, WRITE_PRIMARY_HEADER=1,
;       PRIMARY_HEADER=primary_header, EXTENSION_HEADER=extension_header,
;       DATA=rate_data, ERROR=rate_error, TSTART=start_times, TSTOP=stop_times,
;       MINCHAN=1, MAXCHAN=number_of_channels,
;       E_MIN=min_channel_energies, E_MAX=max_channel_energies, E_UNIT='keV',
;       ERR_CODE=had_err, ERR_MSG=err_msg
;
; Inputs:
; filename - name of FITS file to write.
;
; Outputs:
;
; Input keywords:
; WRITE_PRIMARY_HEADER - set this keyword to write a primary header to
;                        the file.
; PRIMARY_HEADER - primary header for the file.  This contains any information
;       that should be in the primary header in addition to
;       the mandatory keywords.  Only used if
;       WRITE_PRIMARY_HEADER is set.
; EXTENSION_HEADER - header for the RATE extension, with any necessary
;         keywords.
; EVENT_LIST - set this keyword if a list of events is being written
;              to the file.
; _EXTRA - Any keywords set in _EXTRA will be integrated into the extension
;      structure array based on the number of elements.  If an entry has
;      n_channel entries, it will be duplicated n_input spectra
;      times and will be stored as a vector in the structure
;      array.  If it has n_input spectra entries, each entry will
;      be a scalar in the corresponding structure array element.
;      The spectral data are passed in via the DATA keyword.
;
; The following keywords control writing data into the RATE
; extension and are processed in wrt_rate_ext:
; DATA - a [n_channel x n_input spectra / n_channel x n_detector x $
;    n_input_spectra] array containing the the
;    counts/s or counts for each spectrum in each channel.
; ERROR - an array containing the uncertainties on DATA.  Deafults to the
;     square root of DATA.
; COUNTS - set if the column name for the data entry should be COUNTS
;          instead of the default RATE.
; UNITS - units for DATA
;  - a [ n_channel x n_input spectra / n_input spectra ] array
;            containing the livetime for each [ spectrum channel / spectrum ]
; TIMECEN - Full time or time from TIMEZERO for each input spectrum or
;           event.  Stored as TIME column within RATE extension.
; SPECNUM - Index to each spectrum.
; TIMEDEL - The integration time for each channel of each spectrum or
;           each spectrum.
; DEADC - Dead Time Correction for each channel of each spectra, each
;     spectrum, or each channel.  One of DEADC / LIVETIME should
;     be set.  If n_chan elements, this will be set in the header
;     for this extension.
; BACKV - background counts for each channel of each spectrum - OPTIONAL.
; BACKE - error on background counts for each channel of each spectrum.
;         OPTIONAL.  Defaults to the square root of the BACKV if BACKV is set.
;
; The following keywords control the data that are written in the ENEBAND
; extension are passed to wrt_eneband_ext:
; NUMBAND - number of energy bands.
; MINCHAN - a numband element array containing the minimum channel number in
;       each band.
; MAXCHAN - a numband element array containing the maximum channel number in
;       each band.
; E_MIN - a numband element array containing the minimum energy in each band.
; E_MAX - a numband element array containing the maximum energy in each band.
;
; Output keywords:
; ERR_MSG = error message.  Null if no error occurred.
; ERR_CODE - 0/1 if [ no error / an error ] occurred during execution.
;
; Calls:
; arr2str, str2arr, str2chars
;
; Written: Paul Bilodeau, RITSS / NASA-GSFC
;
; Modification History:
;   18-nov-2002, Paul.Bilodeau@gsfc.nasa.gov - changed error handling to
;     use GOTO's for simplification, removed CATCH staement.
;   23-Aug-2004, Sandhia Bansal - Added SPEC_NUM and CHANNEL to ext_kw_list
;     so that these two fields can be added to the columns in spectrum.
;   03-Sep-2004, Sandhia Bansal, Added exposure to the argument list for this procedure.
;                         Pass number of channels and exposure to the call for wrt_rate_ext..
;                   Set prim_kw_list and prim_st_list only if the primary header is
;                       to be created by this function.  Deleted TIME-OBS and
;                       TIME-END from prim_kw_list - these values are already
;                       included in DATE-OBS and DATE-END.
;                   Replaced RA--NOM and DEC--NOM with RA_NOM and DEC_NOM.
;                   Added SPEC_NUM and CHANNEL to the keyword list for rate extension (ext_kw_list,
;                       and ext_st_list).
;   06-Dec-2004, Sandhia Bansal - Deleted EXPOSURE keyword from the argument list.  Deleted
;                                 EXPOSURE and NCHAN from call to wrt_rate_fits.
;-
;------------------------------------------------------------------------------
PRO spectrum2fits, filename, $
                   WRITE_PRIMARY_HEADER=write_primary_header, $
                   PRIMARY_HEADER=prim_header, $
                   EXTENSION_HEADER=ext_header, $
                   NUMBAND=numband, $
                   MINCHAN=minchan, $
                   MAXCHAN=maxchan, $
                   E_MIN=e_min, $
                   E_MAX=e_max, $
                   E_UNIT=e_unit, $
                   EVENT_LIST=event_list, $
                   _EXTRA=_extra, $
                   ERR_MSG=err_msg, $
                   ERR_CODE=err_code

err_msg = ''
err_code = 0

IF Size( filename, /TYPE ) NE 7 THEN BEGIN
    err_msg = 'Need filename as first input.'
    GOTO, ERROR_EXIT
ENDIF

;; default mappings for _extra keywords into the primary header
;prim_kw_list = [ 'TELESCOP', 'INSTRUME', 'FILTER', 'OBJECT', 'RADEG', $
;  'DECDEG', 'NOMRA', 'NOMDEC', 'EQUINOX', 'RADECSYS', 'DATE_OBS', $
;  'DATE_END', 'ORIGIN', 'TIMVERSN', 'AUTHOR' ]

;prim_st_list = prim_kw_list
;;The ST_LIST are the mappings into the FITS standard Labels.
;prim_st_list[4:7] = ['RA', 'DEC', 'RA_NOM', 'DEC_NOM' ]
;prim_st_list[10:11] = [ 'DATE-OBS', 'DATE-END' ]

IF Keyword_Set( write_primary_header ) THEN BEGIN
    ; default mappings for _extra keywords into the primary header
    ;prim_kw_list = [ 'TELESCOP', 'INSTRUME', 'FILTER', 'OBJECT', 'RADEG', $
    ;    'DECDEG', 'NOMRA', 'NOMDEC', 'EQUINOX', 'RADECSYS', 'DATE_OBS', $
    ;    'DATE_END', 'ORIGIN', 'TIMVERSN', 'AUTHOR' ]

    ;prim_st_list = prim_kw_list
    ;The ST_LIST are the mappings into the FITS standard Labels.
    ;prim_st_list[4:7] = ['RA', 'DEC', 'RA_NOM', 'DEC_NOM' ]
    ;prim_st_list[10:11] = [ 'DATE-OBS', 'DATE-END' ]



    ; Create the primary header if necessary.
    IF Size( prim_header, /TYPE ) NE 7 THEN $
      fxhmake, prim_header, /EXTEND, /DATE

    ; add keywords to the primary header
    ;phdr = add_kw2hdr( prim_header, _EXTRA=_extra, KW_LIST=prim_kw_list, $
    ;  HDR_LIST=prim_st_list, $
    ;  ;HDR_COMMENTS=hdr_comments, ERR_MSG=err_msg, $
    ;  ERR_CODE=err_code )
    ;IF err_code THEN GOTO, ERROR_EXIT

    ;fxaddpar, phdr, 'AUTHOR', 'SPECTRUM2FITS'

    ;fxwrite, filename, phdr, ERRMSG=err_msg

    fxaddpar, prim_header, 'AUTHOR', 'SPECTRUM2FITS'
    fxaddpar, prim_header, 'RA', 0.0, 'Source right ascension in degrees'
    fxaddpar, prim_header, 'DEC', 0.0, 'Source declination in degrees'
    fxaddpar, prim_header, 'RA_NOM', 0.0, 'r.a. nominal pointing in degrees'
    fxaddpar, prim_header, 'DEC_NOM', 0.0, 'dec. nominal pointing in degrees'
    fxaddpar, prim_header, 'EQUINOX', 2000.0, 'Equinox of celestial coordinate system'
    fxaddpar, prim_header, 'RADECSYS', 'FK5', 'Coordinate frame used for equinox'
    fxaddpar, prim_header, 'TIMVERSN', 'OGIP/93-003', 'OGIP memo number where the convention used'
    fxaddpar, prim_header, 'VERSION', '1.0', 'File format version number'

    fxwrite, filename, prim_header, ERRMSG=err_msg

    IF err_msg NE '' THEN BEGIN
        MESSAGE, 'ERROR writing primary header to ' + filename, /CONTINUE
        RETURN
    ENDIF
ENDIF

ext_kw_list = [  'SPEC_NUM', 'CHANNEL', 'TIMECEN', 'TIMEDEL', 'LIVETIME', 'DEADC', $
  'BACKV', 'BACKE', 'TIMEZERO', 'TSTART', 'TSTOP' ]

ext_st_list = [ 'SPEC_NUM', 'CHANNEL', 'TIME', 'TIMEDEL', 'LIVETIME', 'DEADC', $
  'BACKV', 'BACKE', 'TIMEZERO', 'TSTART', 'TSTOP' ]

wrt_rate_ext, filename, HEADER=ext_header, _EXTRA=_extra, $
              KW_LIST=ext_kw_list, ST_LIST=ext_st_list, $
              EVENT_LIST=event_list, ERR_MSG=err_msg, ERR_CODE=err_code

IF err_code THEN BEGIN
    MESSAGE, 'ERROR writing RATE extension to ' + filename, /CONTINUE
    RETURN
ENDIF

wrt_eneband_ext, filename, HEADER=ext_header, NUMBAND=numband, $
                 MINCHAN=minchan, MAXCHAN=maxchan, E_MIN=e_min, E_MAX=e_max, $
                 E_UNIT=e_unit, ERR_MSG=err_msg, ERR_CODE=err_code

IF err_code THEN BEGIN
    MESSAGE, 'ERROR writing ENEBAND extension to ' + filename, /CONTINUE
    RETURN
ENDIF

ERROR_EXIT:
err_code = err_msg NE ''
IF err_code THEN BEGIN
    MESSAGE, err_msg, /CONTINUE
    err_msg = 'SPECTRUM2FITS: ' + err_msg
ENDIF

END
