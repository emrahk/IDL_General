;+
; Project     : VSO
;
; Name        : SOCK_SENDCMD
;
; Purpose     : Send command to an open socket
;
; Category    : sockets
;
; Inputs      : LUN = socket logical unit number
;               CMD = command string
;
; History     : 22-Nov-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_sendcmd,lun,cmd,_ref_extra=extra,err=err

if ~is_socket(lun) then begin
 err='Socket unit number not entered.'
 mprint,err
 return
endif

if is_blank(cmd) then begin
 pr_syntax,'sock_sendcmd,lun,command'
 return
endif

sock_sendvar,lun,cmd,/command,_extra=extra,err=err

return & end
