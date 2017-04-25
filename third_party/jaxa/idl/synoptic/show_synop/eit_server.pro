;+
; Project     : eit
;
; Name        : eit_server
;
; Purpose     : return first available eit data server
;
; Category    : synoptic sockets
;                   
; Inputs      : None
;
; Outputs     : SERVER = eit data server name
;
; Keywords    : NETWORK = 1 if network is up
;               PATH = top data path
;               NO_CHECK= skip network check
;               FULL = include HTTP in server name
;
; History     : 15-Jan-2003,  D.M. Zarro (EER/GSFC)  Written
;               09-Jun-2004,  P.T. Gallagher (L-3 Com/GSFC) 
;                             Converted sxi_server to eit_server
;               6-July-2007, Zarro (ADNET/GSFC) 
;                             - changed backup server to sohowwww
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function eit_server,_ref_extra=extra,network=network,path=path,$
                    no_check=no_check,full=full

;-- primary server

  path='/sdb/soho/eit/last_links/'
  server='umbra.nascom.nasa.gov'

  if keyword_set(no_check) then network=1b else $
  network=have_network(server,_extra=extra)

;-- if primary server is down, try secondary 

  if not network then begin
   server='sohowww.nascom.nasa.gov'
   network=have_network(server,_extra=extra)
  endif

  if keyword_set(full) then server='http://'+server

  return,server
  
end


