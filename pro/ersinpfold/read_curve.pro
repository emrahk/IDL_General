; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;
;	READ_CURVE.PRO	
;
; PURPOSE:
;
;	Read in fits files for XTE, SAX, ASCA, XMM, CHANDRA data.	
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
;	READ_FITS_XTE_SAX, filename, data	
;
; INPUTS:
;
;	filename	:  Input filename of fits file       
;
; KEYWORD PARAMETERS:
;
;
;       
; OUTPUTS:
;
;	data		:  STRUCTURE containing all data
;		   	   header - 
;		   	   thresholds - 
;		   	   livetime - 
;		   	   times - 
;		   	   barytimes - 
;		   	   trig_time - 
;		   	   spectra - 
;		   	   errors -        
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;      
;
; RESTRICTIONS:
;
;	This only works for fits files created by XSELECT.	
;
; DEPENDENCIES:
;
;	Astronomy users library (FXB programs)
;
; PROCEDURE:
;        
;
; EXAMPLES:
;       
;
;
; MODIFICATION HISTORY:
;
;	Written, Peter.Woods@msfc.nasa.gov
;		(205) 544-1803
;-
;*******************************************************************************


PRO READ_CURVE, filename, data, header, info


have_file = FINDFILE(filename) NE ''
IF have_file[0] THEN BEGIN
   filename = filename
ENDIF ELSE BEGIN
   PRINT, '***************************'
   PRINT, '      No file found        '
   PRINT, '      Exit program         '
   PRINT, '***************************'
   GOTO, quit
ENDELSE


; Open fits file

data0 = MRDFITS(filename, 0 , head0, /SILENT)


; Determine type of data in fits file

mission = STRTRIM(SXPAR( head0, 'TELESCOP'), 2)
instrument = STRTRIM(SXPAR( head0, 'INSTRUME' ), 2)

PRINT, ' '
PRINT, ' Reading in ' + mission + ' ' + instrument + ' data'
PRINT, filename
PRINT, ' '


; Read in data

data = MRDFITS(filename, 1, header, /SILENT)


; Read in clock time and mjd

CASE mission OF

   'XTE' : BEGIN

	tcorr_int = SXPAR( header, 'TIMEZERI' )
	tcorr_fra = SXPAR( header, 'TIMEZERF' )
	time_corr = DOUBLE( tcorr_int ) + tcorr_fra

	clock_time_int = SXPAR( header, 'TSTARTI' )
	clock_time_fra = SXPAR( header, 'TSTARTF' )
	clock_time = DOUBLE( clock_time_int + clock_time_fra )

	mjd_int = SXPAR( header, 'MJDREFI' )
;	mjd_fra = DOUBLE(PARSE_HEADER( header, 'MJDREFF' ))
        mjd_fra = DOUBLE(fxpar(header,'MJDREFF'))
	mjd_ref = DOUBLE( mjd_int ) + mjd_fra

	mjd_tt = mjd_ref + ((clock_time + time_corr)/86400.0d)

    END
    'SAX' : BEGIN
    	
	time_corr = 0.0d
	
	header0 = HEADFITS( filename, ext = 0 )
	clock_time = SXPAR( header0, 'TSTART' )
	
	mjd_ref = SXPAR( header, 'MJDREF' )
	
	mjd_tt = mjd_ref + ((clock_time + time_corr)/86400.0d)

    END
    'ASCA' : BEGIN
    	
	time_corr = 0.0d
	
	clock_time = SXPAR( header, 'TSTART' )

	mjd_ref = SXPAR( header, 'MJDREF' )

	mjd_tt = mjd_ref + ((clock_time + time_corr)/86400.0d)
	
    END
    'XMM' : BEGIN
    	
	time_corr = 0.0d
	
	clock_time = SXPAR( header, 'TSTART' )

	mjd_ref = SXPAR( header, 'MJDREF' )

	mjd_tt = mjd_ref + ((clock_time + time_corr)/86400.0d)
    END
    'CHANDRA' : BEGIN
    	
	time_corr = 0.0d
	
	clock_time = SXPAR( header, 'TSTART' )

	mjd_ref = SXPAR( header, 'MJDREF' )

	mjd_tt = mjd_ref + ((clock_time + time_corr)/86400.0d)
	
    END
    ELSE : BEGIN
    	
	PRINT, ' '
	PRINT, ' The ' + mission + ' mission is not supported'
	GOTO, quit
    	
    END

ENDCASE

leap_sec = FIND_LEAP( mjd_ref, mjd_tt )

mjd_ut = DOUBLE(LONG( mjd_ref )) + $
	((clock_time + time_corr - leap_sec)/86400.0d)
tjd_tot = mjd_ut - 40000.0d

tjd = LONG( tjd_tot )
sod = (tjd_tot - tjd) * 86400.0d



; Read in time resolution

time_res = SXPAR( header, 'TIMEDEL' )


; Read in absolute energy channel range

CASE mission OF

   'XTE' : BEGIN
   
	comments = SXPAR( header, 'COMMENT' )

	chmin_ind = WHERE( STRPOS( comments, 'CHMIN' ) NE -1 )
	chmin_comm = comments[chmin_ind[0]]
	chmin_comm_offset = STRPOS( chmin_comm, 'was' )
	chmin = LONG( STRTRIM( STRMID( chmin_comm, chmin_comm_offset + 3, $
		99 ) ) )

	chmax_ind = WHERE( STRPOS( comments, 'CHMAX' ) NE -1 )
	chmax_comm = comments[chmax_ind[0]]
	chmax_comm_offset = STRPOS( chmax_comm, 'was' )
	chmax = LONG( STRTRIM( STRMID( chmax_comm, chmax_comm_offset + 3, $
		99 ) ) )

	; Determine energy thresholds

	chan_range = [chmin,chmax]
	thresholds = [2.0,60.0]
;	thresholds = XTE_CHAN2ENERGY( tjd_tot, chan_range )
	
   END
   
   'SAX' : BEGIN
   
	chmin = SXPAR( header, 'TPE1LO' )
	chmax = SXPAR( header, 'TPE1HI' )
	
   	chan_range = [chmin, chmax]

   	; Thresholds not yet determined for SAX data
   	
	thresholds = [2.0, 10.0]
	
   END
   
   'ASCA' : BEGIN
   
	chmin = SXPAR( header, 'PHALCUT' )
	chmax = SXPAR( header, 'PHAHCUT' )
	
   	chan_range = [chmin, chmax]

   	; Thresholds not yet determined for ASCA data
   	
	thresholds = [0.1, 10.0]
	
   END
   
   'XMM' : BEGIN
   
	chmin = SXPAR( header, 'PHALCUT' )
	chmax = SXPAR( header, 'PHAHCUT' )
	
   	chan_range = [chmin, chmax]
   	
	thresholds = [0.1, 10.0]
	
   END
   
   'CHANDRA' : BEGIN
   
	chmin = SXPAR( header, 'PHALCUT' )
	chmax = SXPAR( header, 'PHAHCUT' )
	
   	chan_range = [chmin, chmax]
   	
	thresholds = [0.1, 10.0]
	
   END
   
ENDCASE



; Fill the info structure

info = {   clock_time : clock_time,     $
	   sod : sod,                   $
	   tjd : tjd,                   $
	   mjd_tt : mjd_tt,             $
	   time_res : time_res,         $
	   chan_range : chan_range,     $
	   thresholds : thresholds	}


quit:


END
