;+
; Project     : VSO
;
; Name        : SOCK_CHECK
;
; Purpose     : Check if URL file exists by sending a HEAD request for it
;
; Category    : utility system sockets
;
; Syntax      : IDL> chk=sock_check(url)
;
; Inputs      : URL = remote URL file name to check
;
; Outputs     : CHK = 1 or 0 if exists or not
;
; Keywords    : RESPONSE = server response
;               CODE = response code
;
; History     : 10-March-2010, Zarro (ADNET) - Written
;               19-June-2013, Zarro - Reinstated
;               28-October-2013, Zarro 
;                - more stringent test for return code 2xxx
;               7-October-2014, Zarro
;                - return code in keyword
;-

function sock_check,url,response=response,code=code,_ref_extra=extra,err=err

err=''
response=''
code=404
if ~is_url(url) then return,0b
if n_elements(url) gt 1 then begin
 mprint,'Input URL must be scalar.'
 return,0b
endif
response=sock_head(url,_extra=extra,code=code,err=err)
scode=strtrim(code,2)
nok=stregex(scode,'^(4|5)',/bool)
state=~nok

return,state

end
