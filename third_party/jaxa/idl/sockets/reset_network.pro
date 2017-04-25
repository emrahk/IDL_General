;+
; Project     : HESSI
;                  
; Name        : RESET_NETWORK
;               
; Purpose     : reset network state by clearing last saved
;               network state.
;                             
; Category    : system utility sockets
;               
; Syntax      : IDL> reset_network
;                   
; History     : 6 May 2002, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro reset_network

common have_network,last_time,last_state,last_server
delvarx,last_time,last_state,last_server
return & end
