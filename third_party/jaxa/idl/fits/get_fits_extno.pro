;+
; NAME:
;       get_fits_extno
;
; PURPOSE:
;       To retrieve extension number(s) for extensions with given name(s).
;
; CATEGORY:
;       I/O, FITS
;
; CALLING SEQUENCE:
;       get_fits_extno, file_or_fcb, extname [, message=message]
;
; INPUTS:
;       file_or_fcb - this parameter can be the FITS Control Block (FCB)
;               returned by FITS_OPEN or the file name of the FITS file.
;       extname - name of extension (string scalar or array)
;
; KEYWORD PARAMETERS:
;		message = output error message
;
; History:
;	Written: Kim Tolbert 1-jun-2002
;
;-


function get_fits_extno, file_or_fcb, extname, message=message

s = size(file_or_fcb) & fcbtype = s[s[0]+1]
fcbsize = n_elements(file_or_fcb)
if (fcbsize ne 1) or ((fcbtype ne 7) and (fcbtype ne 8)) then begin
    message = 'Invalid Filename or FCB supplied'
    return, -1
end

if fcbtype eq 7 then begin
    fits_open, file_or_fcb, fcb, /no_abort, message=message
    if n_elements(fcb) gt 0 then fits_close, fcb, /no_abort
    if message NE '' then return, -1
endif else fcb = file_or_fcb


q = where_arr (strlowcase(fcb.extname), strlowcase(extname), count)

if count eq 1 then return, q[0]
if count gt 1 then return, q
return, -1

end