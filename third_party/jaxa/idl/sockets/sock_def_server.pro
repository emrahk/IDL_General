;+
; Name        : SOCK_DEF_SERVER
;
; Purpose     : Return default server and port for sock client-server
;
; Category    : utility analysis sockets
;
; Inputs      : PFILE = file to prep (can be URL)
;
; Outputs     : SERVER = default server (localhost)
;               PORT = default port (21068)
;
; History     : 19-March-2016, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFO
;-

pro sock_def_server,server,port

if is_blank(server) then server='localhost'
if ~is_number(port) then port = 21068

return
end
