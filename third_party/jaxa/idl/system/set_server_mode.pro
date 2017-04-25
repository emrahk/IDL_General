;+
; Project     : HESSI
;
; Name        : SET_SERVER_MODE
;
; Purpose     : Set $SERVER_MODE=1
;
; Category    : system utility
;
; Syntax      : IDL> set_server_mode
;
; Outputs     : None
;
; Keywords    : UNSET = unset $SERVER_MODE
;
; History     : Written, 13 May 2009, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro set_server_mode,unset=unset

if keyword_set(unset) then mklog,'$SERVER_MODE=""' else mklog,'$SERVER_MODE=1'


return
end
