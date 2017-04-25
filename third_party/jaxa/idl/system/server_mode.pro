;+
; Project     : HESSI
;
; Name        : SERVER_MODE
;
; Purpose     : Determin if IDL running in server mode by checking
;               $SERVER_MODE
;
; Category    : system utility
;
; Syntax      : IDL> a=server_mode()
;
; Outputs     : 1/0 if yes/no
;
; History     : Written, 13 May 2009, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function server_mode
val=chklog('$SERVER_MODE')
return,val eq '1'
end
