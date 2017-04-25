;+
; Project     : RHESSI
;
; Name        : FITS_KEYWORD_VALUE
;
; Purpose     : Return keyword value from FITS header
;
; Category    : FITS utility 
;
; Inputs      : HEADER = FITS header string
;               KEYWORD = string keyword to find value for
;
; Outputs     : VALUE = matching string value
;
; Keywords    : None
;
; History     : 17-Feb-2010, Zarro (ADNET) - Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function fits_keyword_value,header,keyword

if size(header,/tname) ne 'STRING' or size(keyword,/tname) ne 'STRING' then return,''

;-- use fast and robust STREGEX

strg=" *"+strtrim(keyword[0],2)+" *= *'?([^'\/]+)'?.*"
chk=where(stregex(header,strg,/fold,/bool),count)
if count eq 0 then return,''
ext=stregex(header[chk[0]],strg,/ext,/fold,/sub)
return,ext[1]
end
