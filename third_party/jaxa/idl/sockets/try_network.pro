;+
; Project     : VSO
;                  
; Name        : TRY_NETWORK
;               
; Purpose     : Call to test if !use_network is set to use 
;               IDLnetURL object instead of direct socket calls.
;                             
; Category    : system utility sockets
;               
; Syntax      : IDL> try_network
;
; History     : 26 December 2014 (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function try_network

defsysv,'!use_network',exists=exists
if ~exists then defsysv,'!use_network',0b
return,!use_network

end

