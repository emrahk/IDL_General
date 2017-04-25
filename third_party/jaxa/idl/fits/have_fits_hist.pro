;+
; Project     : HESSI
;
; Name        : HAVE_FITS_HIST
;
; Purpose     : Check for string in FITS HISTORY
;
; Category    : FITS, Utility
;
; Syntax      : IDL> chk=have_fits_hist(header,value)
;
; Inputs      : HEADER = FITS header (string or index structure
;                         format)
;               VALUE = string to check for
;
; Outputs     : CHK = 1/0 if value present or not
;
; History     : Written, 23-April-2009 (Zarro/ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function have_fits_hist,header,value

if (~is_string(header) and ~is_struct(header)) or is_blank(value) then return,0b
value=strtrim(value,2)

;-- handle structure case

if is_struct(header) then begin
 if ~have_tag(header,'history') then return,0b
 history=header.history
 chk=where(stregex(history,value,/bool,/fold),count)
 return,count gt 0
endif

;-- handle string case

if is_string(header) then begin
 chk=where(stregex(header,'History '+value,/bool,/fold),count)
 return,count gt 0
endif

return,0b

end
