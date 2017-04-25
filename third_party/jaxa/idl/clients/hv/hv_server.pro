;+
; Project     : HELIOVIEWER
;
; Name        : HV_SERVER
;
; Purpose     : Return HTTP address of Helioviewer (HV) API server
;
; Category    : utility system sockets
;
; Inputs      : None
;
; Outputs     : URL of HV server
;
; Keywords    : V1 = set for version 1
;
; History     : 1-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function hv_server,v1=v1

version='v2'
if keyword_set(v1) then version='v1' 
return,'http://api.helioviewer.org/'+version

end
