;+
; PROJECT:
;       SOHO - LASCO
;
; NAME:
;       VALID_PNG()
;
; PURPOSE:
;       To detect if the given file is in PNG format
;
; CATEGORY: Utility Image Display Graphics
;
; EXPLANATION:
;
; SYNTAX:
;       Result = valid_png(filename)
;
; INPUTS:
;       FILENAME - Name of the file to be detected
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT   - 1/0 indicating whether the given file is or is not
;                  a PNG file
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
;       Version 1, 15 Apr 2005 - create from valid_jpeg.pro by D.Zarro
; CONTACT:
;       dzarro@solar.stanford.edu
;       nathan.rich@nrl.navy.mil
;-
;

   function valid_png, filename,dimensions,error=error

   on_error, 1
   error = ''
   dimensions=[0,0]
   if datatype(filename) ne 'STR' then begin
    error = 'syntax: a = valid_png(filename)'
    message, error, /cont
    return, 0
   endif

   chk=loc_file(filename,count=count)
   if count eq 0 then begin
    error = 'file "'+strtrim(filename,2)+'" does not exist!'
    message, error, /cont
    return, 0
   endif

   if have_proc('query_png') then begin
    is_jpeg=call_function('query_png',filename,info)
    if is_jpeg then begin
     dimensions=info.dimensions
     return,1
    endif
   endif
  
;-- check filename as last resort

  temp=trim(strlowcase(filename))
  return,(strpos(temp,'.png') gt -1) 

  end
