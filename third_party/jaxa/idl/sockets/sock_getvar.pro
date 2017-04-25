;+
; Project     : VSO
;
; Name        : SOCK_GETVAR
;
; Purpose     : Get variable from an open socket
;
; Category    : sockets
;
; Inputs      : LUN = socket logical unit number
;               NAME = string name of variable
;
; Outputs     : VALUE = value of variable
;
; Keywords    : ERR = error string
;               WAIT_TIME = seconds to wait before giving up [def=100]
;
; History     : 8-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_getvar,lun,name,err=err,wait_time=wait_time,_extra=extra,timeout=timeout,$
                     status=status

err=''
value=!null
timeout=0b

if ~is_number(lun) then begin
 pr_syntax,'variable_value=sock_getvar(socket_lun,variable_name)'
 return,value
endif

if ~is_socket(lun) then begin
 err='Socket unavailable.'
 mprint,err
 return,value
endif

if keyword_set(status) then name='status'
if is_blank(name) then begin
 err='Variable name not entered.'
 mprint,err
 return,value
endif

if ~is_number(wait_time) then wait_time=100.

sock_sendvar,lun,name,/get,session=session,_extra=extra,status=status
save_session=session

if exist(SCOPE_VARFETCH(name, /enter, LEVEL=1)) then $
 destroy,SCOPE_VARFETCH(name, /enter, LEVEL=1)
if exist(SCOPE_VARFETCH('session', /enter, LEVEL=1)) then $
 destroy,SCOPE_VARFETCH('session', /enter, LEVEL=1)

err=''
t1=systim(/sec)
repeat begin
 success=0b & undefined=0b

 if exist(SCOPE_VARFETCH('session', /enter, LEVEL=1)) then begin
  session=SCOPE_VARFETCH('session', /enter, LEVEL=1)
  success=session eq save_session
 endif

 if success then begin
  if exist(SCOPE_VARFETCH(name, /enter, LEVEL=1)) then $
   value=temporary(SCOPE_VARFETCH(name, /enter, LEVEL=1)) else undefined=1b
 endif

 t2=systim(/sec)
 tdiff=t2-t1
endrep until (success || (tdiff gt wait_time) || undefined)

timeout=(tdiff gt wait_time)
if timeout then mprint,'Server timeout.'

if ~success then begin
 err='Could not retrieve variable - '+name 
 value=!null
 mprint,err
endif

return,value & end
