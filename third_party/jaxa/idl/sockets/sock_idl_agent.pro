;+
; Project     : VSO
;
; Name        : SOCK_IDL_AGENT
;
; Purpose     : Create USER-AGENT string for IDL HTTP client
;
; Inputs      : None
;
; Outputs     : User-Agent string
;
; Keywords    : None
;
; History     : 28-September-2014, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_idl_agent

agentStr='IDL/'+!version.release+' '+!version.os+'/'+!version.arch

return,agentStr

end
