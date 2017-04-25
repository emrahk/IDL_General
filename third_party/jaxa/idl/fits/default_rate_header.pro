;==============================================================================
;+
; Name: default_rate_header
;
; Category: HESSI, UTIL
;
; Purpose: Creates a header specific to a RATE FITS file and fills it up with default values.
;
; Calling sequence:  default_rate_header, rate_struct
;
; Inputs:
;
; Outputs:
;   rate_struct  - Structure containing RATE header related information
;
; Calls:
;
; Written: Sandhia Bansal - 06-Dec-2004
;
; Modification History:
;-
;------------------------------------------------------------------------------
;PRO default_rate_header, rate_struct
function default_rate_header



rate_struct = {rate_header}

rate_struct.telescope = 'Unknown'
rate_struct.instrument = 'Unknown'
rate_struct.origin = 'Unknown'
rate_struct.timeunit = "d"
rate_struct.timeref = "LOCAL"
rate_struct.tassign = "SATELLITE"
rate_struct.object = 'Unknown'
rate_struct.detchans = 0
rate_struct.chantype = "PI"
rate_struct.areascal = 1.0
rate_struct.backscal = 1.0
rate_struct.corrscal = 1.0
rate_struct.grouping = 0
rate_struct.quality = 0
rate_struct.exposure = 0.
rate_struct.equinox = 2000.0
rate_struct.radecsys = 'FK5'
rate_struct.hduclas2 = 'TOTAL'   ; Extension contains a spectrum.
mjdref = anytim('00:00 1-Jan-79', /MJD)
rate_struct.mjdref = float(mjdref.mjd)
rate_struct.timesys = strmid(anytim('00:00 1-Jan-79', /ccsds), 0, 19)
rate_struct.timezero = 0
rate_struct.tstarti = 0
rate_struct.tstartf = 0.0
rate_struct.tstopi = 0
rate_struct.tstopf = 0.0
rate_struct.clockcor = 'T'
rate_struct.telapse = 0.0
rate_struct.poisserr = 'F'
rate_struct.version = '1.0'
rate_struct.author = 'Unknown'
rate_struct.backapp = 'F'
rate_struct.deadapp = 'T'
rate_struct.vignapp = 'F'
rate_struct.observer = 'Unknown'

rate_struct.timversn = 'OGIP/93-003'

return, rate_struct

END
