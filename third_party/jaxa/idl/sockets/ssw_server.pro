;+
; Project     : HESSI
;
; Name        : SSW_SERVER
;
; Purpose     : return SSW software server URL 
;
; Category    : synoptic
;                   
; Inputs      : None
;
; Outputs     : SERVER = SSW software server name
;
; Keywords    : NETWORK = 1 if network is up
;
; History     : 10-Feb-2004,  D.M. Zarro (L-3Com/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function ssw_server,_ref_extra=extra


server='sohowww.nascom.nasa.gov'
chk=have_network(server,_extra=extra)

return,'http://'+server

end
