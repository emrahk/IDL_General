;+
; Project     : HESSI
;
; Name        : SOCK_PING
;
; Purpose     : ping a remote Web server
;
; Category    : utility system sockets
;                   
; Inputs      : SERVER = server name
;
; Outputs     : STATUS = 1/0 if up/down
;
; Opt. Outputs: PAGE= server output [deprecated]
;
; Keywords    : TIME = response time (seconds)
;
; History     : 7-Jan-2002,  D.M. Zarro (EITI/GSFC) - Written
;               20-Jan-2013, Zarro (ADNET) 
;               - Removed deprecated RETRY keyword
;               21-Feb-2013 (ADNET)
;               - Added call to HAVE_NETWORK
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_ping,server,status,page,time=time,_ref_extra=extra

page=''
t1=systime(/seconds)
status=have_network(server,/use_network,_extra=extra)
t2=systime(/seconds)
if status then time=t2-t1 else time=-1

return

end
