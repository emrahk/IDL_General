;+
; Project     : VSO
;
; Name        : SOCK_READ
;
; Purpose     : Read bytes from an open socket
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_read,unit,data
;
; Inputs      : UNIT = socket unit number (must be open)
;               DATA = named variable to receive data
;               
; Outputs     : DATA = data 
;
; History     : 20-Nov-2012, Zarro (ADNET) - Written
;-

pro sock_read,unit,data,err=err,_extra=extra
on_ioerror, done

err=''
if ~is_number(unit) then return
stat=fstat(unit)

if ~stat.open then begin
 err='Socket unit closed.'
 message,err,/info
 return
endif

if n_elements(data) eq 0 then return
nbytes=n_bytes(data)
dimensions=size(data,/dimension)
type=size(data,/tname)
if type eq 'INT' then type='FIX'
buff=bytarr(nbytes,/nozero)
sock_readu,unit,buff,maxsize=nbytes,_extra=extra,/slurp
data=call_function(type,temporary(buff),0,dimensions)
return

done:on_ioerror,null
err='Error reading socket.'
message,err,/info

return & end
