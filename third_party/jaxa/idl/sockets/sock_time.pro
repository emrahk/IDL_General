;+
; Project     : VSO
;
; Name        : SOCK_TIME
;
; Purpose     : Get local time of remote file
;
; Category    : utility system sockets
;
; Syntax      : IDL> time=sock_time(url)
;
; Inputs      : URL = remote URL file name 
;
; Outputs     : See keywords
;
; Keywords    : ERR = error string
;
; History     : 6-Jan-2015, Zarro (ADNET) - Written
;-

function sock_time,url,_ref_extra=extra,err=err

case 1 of
 n_elements(url) ne 1: err='Input URL must be scalar string.'
 ~is_url(url,/scheme): err='Input file must be URL.'
 else: err=''
endcase

if is_string(err) then begin
 message,err,/info
 return,''
endif

if ~sock_check(url,date=date,err=err,_extra=extra) then return,''
if ~valid_time(date,err=err) then return,''
time=anytim(date)+ut_diff(/sec)
return,anytim(time,/vms)

end

