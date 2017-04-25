;+
; Project     : EIS
;
; Name        : STRUCT2STR
;
; Purpose     : convert structure tag elements into a string
;
; Category    : structures
;
; Syntax      : IDL> str=struct2str(struct)
;
; Inputs      : STRUCT = input structure to convert
;               (e.g. struct={a:1,b:2,c:3})
;
; Outputs     : STR = output string
;               (e.g. str='a=1,b=2,c=3')
;
; Keywords    : None
;
; Restrictions: Only scalar elements are converted.
;
; History     : 15-Mar-2009 Zarro (ADNET)- Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
;----------------------------------------------------------------------------

function struct2str,struct

str=''
if ~is_struct(struct) then return,str

tags=tag_names(struct)
for i=0,n_elements(tags)-1 do begin
 if is_scalar(struct.(i)) then begin
  item=tags[i]+'='+strtrim(struct.(i),2)
  if is_string(isearch) then isearch=isearch+','+item else isearch=item
 endif
endfor

if is_string(isearch) then str=isearch
return,str
end
