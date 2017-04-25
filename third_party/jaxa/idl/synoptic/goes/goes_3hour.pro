;+
;
; NAME:
;	GOES_3HOUR
;
; PURPOSE:
;	Read the GOES 3-hour files copied from SEL and return the
;	header record, and the data records.
;
; CATEGORY:
;	GOES
;
; CALLING SEQUENCE:
;       GOES_3HOUR, File, Header, Data
;
; CALLS:
;       IEEE_TO_HOST
;
; INPUTS:
;       File:	GOES 3-hour file.
;
; OUTPUTS:
;       Header:	Array containing year, day of the year and satellite number.
;	Data:   Array containing time in sec from start of observation day
;		in 2-3 sec interval, ?, ?, flux (watts/m^2) for range 
;		1. - 8. angstroms, and flux (watts/m^2) for range 
;		.5 - 4. angstroms. Flux value of -99999.0 means no data.
;
; PROCEDURE:
;       Read data from goes_3hour file, perform a longword swap using
;	'byteorder', convert data array from IEEE to host representation,
;	and return header and remaining data arrays.
;
; MODIFICATION HISTORY:
;	Kim Tolbert 7/93
;       Mod. 08/07/96 by RCJ. Use IEEE_TO_HOST instead of CONV_UNIX_VAX.
;
;-
pro goes_3hour, file, header, data

openr, lun, file, /get_lun

fstat = fstat(lun)
nrec = fstat.size / 20

data = fltarr(5, nrec)

readu, lun, data
close, lun
free_lun, lun

byteorder, data, /lswap
;conv_unix_vax, data     ; machine dependent
ieee_to_host, data       ; machine independent

header = data(*,0)
data = data(*,1:*)

return & end
