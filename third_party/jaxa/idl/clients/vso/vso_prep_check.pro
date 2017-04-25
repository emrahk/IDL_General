;+
; Project     : HESSI
;
; Name        : VSO_PREP_CHECK
;
; Purpose     : Check availability of VSO Prepserver and Java libraries
;
; Category    : synoptic sockets VSO
;
; Inputs      : None
;
; Outputs     : 1/0 if available/unavailable
;
; Keywords    : SERVER = selected server
;
; History     : Written 14-Dec-2009, Zarro (ADNET)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU

function vso_prep_check,server=server,err=err

;-- check if VSO Prepserver is available

server=vso_prep_server(err=err)
if is_string(err) then begin
 err='VSO Prepserver currently unavailable.'
 message,err,/cont
 return,0b
endif

if ~vso_java_check(err=err) then begin
 err='Could not load Prepserver Java libraries.'
 message,err,/cont
 return,0b
endif

return,1b & end
