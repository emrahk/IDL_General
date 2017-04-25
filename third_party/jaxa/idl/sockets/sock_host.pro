;+
; Project     : HESSI
;
; Name        : SOCK_HOST
;
; Purpose     : return host name of nearest server by shortest ping time
;
; Category    : sockets
;
; Inputs      : SERVERS = string array of server names to ping           
;               
; Outputs     : SERVER = server name
;
; Opt. Output : INDEX = index of server in SERVERS
;
; Keywords    : ERR = error string
;
; History     : 22-Oct-2002, Zarro (EER/GSFC) - written
;               11-Nov-2015, Zarro (ADNET) - renamed
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_host,servers,err=err,index=index,_extra=extra,verbose=verbose,$
                     network=network

err=''
index=-1
network=1b

if is_blank(servers) then return,''

;-- return first server in list if network is down

index=0 
if not have_network(_extra=extra) then begin
 network=0b
 return,servers[index]
endif

nservers=n_elements(servers)
times=fltarr(nservers)

;-- ping servers for round-trip times

for i=0,nservers-1 do begin
 sock_ping,servers[i],err=err,time=time
 times[i]=time
 if keyword_set(verbose) then message,servers[i]+' ping time(s): '+trim(time),/cont
endfor

;-- find closest in time

ok=where((times ge 0),count)
if count eq 0 then return,servers[index]

tmin=min(times[ok])
index=where(tmin eq times)

index=index[0]
server=servers[index]

if keyword_set(verbose) then message,'using '+server,/cont

return,server

end
