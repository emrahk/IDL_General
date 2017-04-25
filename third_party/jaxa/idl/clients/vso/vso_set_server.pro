;+
; Project     : HESSI
;
; Name        : VSO_SET_SERVER
;
; Purpose     : Set VSO PrepServer
;
; Category    : synoptic sockets VSO
;
; Inputs      : SERVER = server to select (WILCO or HESPERIA)
;
; History     : Written 24-July-2010, Zarro (ADNET)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro vso_set_server,server

if is_blank(server) then return
fserver=strlowcase(strtrim(server,2))
primary='hesperia.gsfc.nasa.gov'
secondary='wilco.gsfc.nasa.gov'
if fserver eq 'wilco' then vserver=secondary
if fserver eq 'hesperia' then vserver=primary

mklog,'vso_prep_server',vserver

return & end
