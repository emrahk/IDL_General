;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       VALID_GIF()
;
; PURPOSE:
;       To detect if the given file is in GIF format
;
; CATEGORY:
;       Utility
;
; EXPLANATION:
;
; SYNTAX:
;       Result = valid_gif(filename)
;
; INPUTS:
;       FILENAME - Name of the file to be detected
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT   - 1/0 indicating whether the given file is or is not
;                  a GIF file
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
;       Version 1, November 1, 1995, Liyun Wang, GSFC/ARC. Written
;       Version 2, 30-Jan-1999, Zarro (SM&A) - introduced QUERY_GIF 
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

FUNCTION valid_gif, filename,dimensions,error=error

   ON_ERROR, 1
   error = ''
   dimensions=[0,0]
   IF datatype(filename) NE 'STR' THEN BEGIN
      error = 'Syntax: a = valid_gif(filename)'
      MESSAGE, error, /cont
      RETURN, 0
   ENDIF

   chk=loc_file(filename,count=count)
   if count eq 0 then begin
     error = 'File "'+STRTRIM(filename,2)+'" does not exist!'
     MESSAGE, error, /cont
     RETURN, 0
   ENDIF

;-- new way

   if have_proc('query_gif') then begin
    is_gif=call_function('query_gif',filename,info)
    if is_gif then begin
     dimensions=info.dimensions
     return,1
    endif else return,0
   endif

;-- old way

   h = {magic:BYTARR(6), width_lo:0b, width_hi:0b, $
        height_lo:0b, height_hi:0b, $
        screen_info:0b, background:0b, reserved:0b }

   
   on_ioerror,bad
   OPENR, unit, filename, /GET_LUN, /block,error=err
   if err ne 0 then begin
    error=!err_string
    print,error
    goto,bad
   endif
   
   READU, unit, h
   FREE_LUN, unit

   gif = STRING(h.magic(0:2))
   d1 = STRING(h.magic(3))
   d2 = STRING(h.magic(4))
   a = STRING(h.magic(5))

   a_is_ok = (a GE 'a' AND a LE 'z') OR (a GE 'A' AND a LE 'Z')

   IF gif NE 'GIF' OR d1 LT '0' OR d1 GT '9' OR    $
      d2 LT '0' OR d2 GT '9' OR a_is_ok(0) EQ 0 THEN RETURN, 0 ELSE BEGIN
    if n_params() eq 2 then begin
     read_gif,filename,temp
     dimensions=[data_chk(temp,/nx),data_chk(temp,/ny)]
    endif
    return,1
   endelse

bad: return,0
END

