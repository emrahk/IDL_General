;+
; Project     : VSO
;                  
; Name        : USE_NETWORK
;               
; Purpose     : Set !use_network system variable to enable/disable
;               using IDL network objects
;                             
; Category    : system utility sockets
;               
; Syntax      : IDL> use_network
;
; Outputs     : None
;
; Keywords    : OFF = switch off using IDL network objects
;                   
; History     : 22 November 2013 (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro use_network,off=off

ver=since_version('6.4')

if ~ver then begin
 message,'IDL network objects not supported for this IDL version.',/info
 defsysv,'!use_network',0b
 return
endif

on=~keyword_set(off)
defsysv,'!use_network',on

return

end

