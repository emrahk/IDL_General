;+
; Project     : HESSI
;
; Name        : SOCK_LUNS
;
; Purpose     : Return socket LUN's assigned to a port
;
; Category    : system utility sockets
;
; Syntax      : IDL> luns=sock_luns(port)
;
; Inputs      : PORT = port number
;
; Outputs     : LUNS = unit numbers associated with a port
;
; Keywords    : SERVER = set if seeking a LUN assigned to a SERVER socket.
;               LISTENER = set if seeking a LUN assigned to a LISTENER
;               socket.
;               COUNT = number of associated LUN's.
;
; History     : 20 October 2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function sock_luns,port,server=server,listener=listener,count=count,err=err

err=''
count=0
if n_elements(port) ne 1 then begin
 err='Input port must be scalar.'
 return,-1
endif

if ~is_number(port) then return,-1
reg='\.'
if keyword_set(listener) then reg='\<listener\>\.' else $
 if keyword_set(server) then reg='\<server\>\.'

help,/files,out=out
reg=reg+trim(port)
for i=0,n_elements(out)-1 do begin
 chk=stregex(out[i],'([0-9]+) +',/ext,/sub)
 if is_number(chk[1]) then begin
  lun=long(chk[1])
  stat=(fstat(lun)).name
  check=stregex(stat,reg,/bool,/fold)
  if check then if exist(luns) then luns=[luns,lun] else luns=lun
 endif
endfor

count=n_elements(luns)
if count eq 0 then luns=-1
return,luns

end
