;+
; Name        : SOCK_DEBUG
;
; Purpose     : Debugger for IDLneURL object
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_debug,url_obj
;
; Inputs      : URL_OBJ = IDLnetURL object
;
; Outputs     : None, except to print selected properties
;
; Keywords    : None
;
; History     : 10-Feb-2015, Zarro (ADNET) - written
;
;-

pro sock_debug,url_obj

if ~obj_valid(url_obj) then return

if ~stregex(obj_class(url_obj),'^idlneturl',/bool,/fold) then return

props=['authentication','ftp_connection_mode','proxy_hostname','proxy_username','proxy_port','proxy_authentication']

print,''
mprint,'Properties:'
props=[obj_props(url_obj),strupcase(props)]
for i=0,n_elements(props)-1 do begin
 s=execute('url_obj->getproperty,'+props[i]+'=prop',1,1)
 if s then  print,'% '+props[i]+': '+trim(prop)
endfor
url_obj->getproperty,headers=headers

print,''
mprint,'Headers:'
mprint,headers,/noname
print,''

return & end
