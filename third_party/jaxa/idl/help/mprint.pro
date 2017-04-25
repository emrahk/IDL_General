;+
; Project     : VSO
;
; Name        : MPRINT
;
; Purpose     : Print message. Similar to MESSAGE but without setting 
;               !error_state.msg or !err_string
;
; Category    : utility help
;
; Syntax      : IDL> mprint,mess
;
; Inputs      : MESS = string message to print.
;
; Outputs     : Terminal output
;
; Keywords    : None
;
; History     : 19 February 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mprint,mess,_extra=extra,noname=noname

if is_blank(mess) then return
np=n_elements(mess)
if keyword_set(noname) then prefix='% ' else begin
 caller=get_caller()
 prefix='% '+caller+': '
endelse
pad='%'+strpad('',strlen(prefix)-1)
k=-1
for i=0,np-1 do begin
 if is_blank(mess[i]) then continue
 k=k+1
 if k eq 0 then print,prefix+mess[i] else print,pad+mess[i]
endfor
return & end


