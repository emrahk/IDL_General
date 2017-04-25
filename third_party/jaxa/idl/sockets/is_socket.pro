;+
; Project     : VSO
;
; Name        : IS_SOCKET
;
; Purpose     : Check if unit number is an open socket.

; Inputs      : UNIT = number to check
;
; Outputs     : 1/0 if yes/no
;
; Keywords    : HOST = host socket is attached to
;               PORT = opened port
;               RAWIO = true if using RAWIO
;               
; History     : 25-October-2013, Zarro (ADNET) - written
;               6-Dec-2015, Zarro (ADNET) -  added RAWIO
;               19-Feb-2016, Zarro (ADNET) - added ON_IOERROR
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function is_socket,unit,host=host,port=port,rawio=rawio

host='' & port=-1 & rawio=0b

on_ioerror,bail

if ~is_number(unit) then return,0b

stc=fstat(unit)
if ~stc.open then return,0b

chk=stregex(stc.name,'([^ ]+)\.([0-9]+$)',/extra,/sub)

host=chk[1]
port=fix(chk[2])

sopen=is_string(host) && is_number(port)

if arg_present(rawio) && sopen then begin
 rawio=0b
 help,/files,out=out
 for i=0,n_elements(out)-1 do begin
  reg=trim(unit)+'.+rawio.+'
  chk=stregex(out[i],reg,/bool,/fold)
  if chk then begin
   rawio=1b & break
  endif
 endfor
endif

return,sopen

bail: return,0b

end
