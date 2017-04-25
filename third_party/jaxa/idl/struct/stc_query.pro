;+
; Project     : VSO
;
; Name        : STC_QUERY
;
; Purpose     : Convert structure to query string for URL. Only
;               scalars are converted.
;
; Category    : utility analysis
;
; Inputs      : STC = structure (e.g. {a:1,b:2,c:3})
;
; Outputs     : QUERY = string (e.g. 'a=1&b=2&c=3')
;
; History     : 30-March-2016, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function stc_query,stc

query=''
if ~is_struct(stc) then return,query
tags=tag_names(stc)
quote='%22'
bad_types=[6,8,10,11]
for i=0,n_elements(tags)-1 do begin
 val=stc.(i)
 if n_elements(val) ne 1 then continue
 type=size(val,/type)
 chk=where(type eq bad_types,count)
 if count gt 0 then continue
 if is_string(val,/blank) then val=quote+val+quote else val=trim(val)
 piece=tags[i]+'='+val 
 if i eq 0 then query=piece else query=query+'&'+piece
endfor

return,query
end
