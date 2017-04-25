;+
; Project     : HESSI
;
; Name        : LIST_MONTHS
;
; Purpose     : list month names
;
; Category    : utility date time 
;
; Syntax      : months=list_months()
;
; Inputs      : None
;
; Outputs     : MONTHS = string array of month names
;
; Keywords    : LOWER = convert to lower case
;             : TRUNCATE = truncate to three letters
;
; History     : Written 28 March 2002, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function list_months,lower=lower,truncate=truncate

months=['January','February','March','April','May','June','July','August',$
         'September','October','November','December']

if keyword_set(truncate) then months=strmid(months,0,3)
if keyword_set(lower) then months=strlowcase(months)

return,months

end
