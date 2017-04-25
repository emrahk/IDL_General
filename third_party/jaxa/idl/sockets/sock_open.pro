;+
; Project     : HESSI
;                  
; Name        : SOCK_OPEN
;               
; Purpose     : Open a socket with some error checking
;                             
; Category    : system utility sockets
;               
; Syntax      : IDL> sock_open,lun,host,port,err=err
;
; Inputs      : HOST = address of host
;
; Outputs     : LUN = unit number of open socket
;
; Keywords    : ERR = error string (if any)
;               PORT = host port [def=80]
;                   
; History     : 14 April 2002, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro sock_open,lun,host,port=port,err=err,_extra=extra,force=force

err=''

if is_blank(host) then return
if ~is_number(port) then port=80
if keyword_set(force) then close_lun,lun

get_lun=1b
if is_number(lun) then begin
 if lun gt 0 then begin
  if (fstat(lun)).open then begin
   err=' LUN already opened - '+trim(lun)
   message,err,/info
   return
  endif
  if lun lt 100 then begin
   err='LUN must be > 99 for sockets.'
   message,err,/info
   return
  endif
  get_lun=0b
 endif
endif 

error=1
on_ioerror,done
socket,lun,host,port,error=error,get_lun=get_lun,$
           _extra=extra
done: on_ioerror,null
 
if error ne 0 then begin
 close_lun,lun
 err='Could not open network connection to '+host
 message,err,/info
endif

return & end
