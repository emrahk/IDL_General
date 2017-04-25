FUNCTION sohofile2time, file, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       SOHOFILE2TIME()
;
; PURPOSE: 
;       Return time from a given file name conforming the SOHO standard
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       Result = sohofile2time(file)
;
; INPUTS:
;       FILE - String scalar, name of image file
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - String scalar, time (in UTC format) indicated in
;                filename if no error; null string if there is an error
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       ERROR - A named variable containing possible error message
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, October 21, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, June 8, 1998, Zarro, vectorized
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''
   IF datatype(file) ne 'STR' THEN BEGIN
      error = 'No file name passed in.'
      RETURN, ''
   ENDIF
   nf=n_elements(file)
   out=strarr(nf)
   for i=0,nf-1 do begin
    break_file, file(i), dlog, dir, name, ext, version, node
    name=trim(name)
    IF STRLEN(name) EQ 27 THEN BEGIN
      year = STRMID(name, 14, 4)
      month = STRMID(name, 18, 2)
      day = STRMID(name, 20, 2)
      hour = STRMID(name, 23, 2)
      mini = STRMID(name, 25, 2)
      tstring = year+'/'+month+'/'+day+' '+hour+':'+mini
      err=''
      utc = anytim2utc(tstring, /ecs, /trunc, err=err)
      IF error eq '' then out(i)=utc 
    ENDIF
   endfor
   ok=where(out ne '',count)
   if count eq 0 then begin
    error = 'File name does not conform to SOHO standard.'
    out=''
   endif else out=out(ok)
   if n_elements(out) eq 1 then out=out(0)

   RETURN, out
END

