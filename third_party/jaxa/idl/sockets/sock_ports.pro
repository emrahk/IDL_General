;+
; Project     : VSO
;
; Name        : SOCK_PORTS
;
; Purpose     : Return assigned ports
;
; Category    : system utility sockets
;
; Syntax      : IDL> ports=sock_ports()
;
; Inputs      : None
;
; Outputs     : PORTS = assigned ports
;
; Keywords    : COUNT = number of ports
;
; History     : 28 December 2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function sock_ports,count=count

count=0
help,/files,out=out
reg='\.([0-9]+)'
for i=0,n_elements(out)-1 do begin
 chk=stregex(out[i],'([0-9]+) +',/ext,/sub)
 if is_number(chk[1]) then begin
  slun=long(chk[1])
  stat=(fstat(slun)).name
  sport=stregex(stat,reg,/ext,/sub)
  if is_number(sport[1]) then begin
   port=long(sport[1])
   if exist(ports) then begin
    chk=where(port eq ports,pcount) 
    if pcount eq 0 then ports=[ports,port] 
   endif else ports=port
  endif
 endif
endfor

count=n_elements(ports)
if count eq 0 then ports=-1

return,ports
end
