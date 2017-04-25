;+
; Project     : VSO
;
; Name        : SOCK_SEND
;
; Purpose     : Send a socket request
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_send,unit,request
;
; Inputs      : UNIT = socket unit number (must be open)
;               REQUEST = string array to send
;
; Keywords    : None
;
; Outputs     : None
;
; History     : 20-Nov-2012, Zarro (ADNET) - Written
;-

pro sock_send,unit,request

if ~is_number(unit) then return
if is_blank(request) then return

stat=fstat(unit)
if ~stat.open then return
for i=0,n_elements(request)-1 do printf,unit,request[i]

return & end
