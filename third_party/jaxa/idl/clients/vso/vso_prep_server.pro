;+
; Project     : HESSI
;
; Name        : VSO_PREP_SERVER
;
; Purpose     : return available VSO_PREP server
;
; Category    : synoptic sockets VSO
;
; Inputs      : None
;
; Outputs     : SERVER =  server name
;
; Keywords    : NETWORK = returns 1 if server network connection is available
;
; History     : Written 22-Dec-2009, Zarro (ADNET)
;               Modified 24-July-2010, Zarro (ADNET)
;               - changed primary to HESPERIA and port to 80
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function vso_prep_server,_ref_extra=extra,network=network

secondary='http://wilco.gsfc.nasa.gov'
primary='http://hesperia.gsfc.nasa.gov'
servers=[primary,secondary]

chk=chklog('vso_prep_server')
if is_string(chk) then begin
 server=chk
 if ~stregex(server,'http://',/bool,/fold) then server='http://'+server
 servers=[server,servers]
endif

network=have_network(_extra=extra) 
if ~network then return,server

for i=0,n_elements(servers)-1 do begin
 chk=sock_check(servers[i]+'/prepserver/preprocessor?wsdl',_extra=extra)
 if chk then return,servers[i]
endfor

return,servers[0]

end
