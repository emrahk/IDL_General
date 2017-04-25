;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       VALID_JPEG()
;
; PURPOSE:
;       To detect if the given file is in JEPG format
;
; CATEGORY:
;       Utility
;
; EXPLANATION:
;
; SYNTAX:
;       Result = valid_jpeg(filename)
;
; INPUTS:
;       FILENAME - Name of the file to be detected
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT   - 1/0 indicating whether the given file is or is not
;                  a JPEG file
;       DIMENSIONS - image dimensions
;;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       ERROR - A named variable containing any error message. If no
;               error occurs, a null string is returned.
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
;       Version 1, 30-Jan-1999, Zarro (SM&A) 
; CONTACT:
;       dzarro@solar.stanford.edu
;-
;

   function valid_jpeg, filename,dimensions,error=error

   on_error, 1
   error = ''
   dimensions=[0,0]
   if datatype(filename) ne 'STR' then begin
    error = 'syntax: a = valid_jpeg(filename)'
    message, error, /cont
    return, 0
   endif

   chk=loc_file(filename,count=count)
   if count eq 0 then begin
    error = 'file "'+strtrim(filename,2)+'" does not exist!'
    message, error, /cont
    return, 0
   endif

   if have_proc('query_jpeg') then begin
    is_jpeg=call_function('query_jpeg',filename,info)
    if is_jpeg then begin
     dimensions=info.dimensions
     return,1
    endif
   endif
  
;-- check filename as last resort

  temp=trim(strlowcase(filename))
  return,(strpos(temp,'.jpg') gt -1) or (strpos(temp,'.jpeg') gt -1)

  end
