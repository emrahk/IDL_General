;+
; Project     : VSO
;
; Name        : JAVA_DEBUG
;
; Purpose     : Check for error debug messages from IDL-Java bridge serever
;
; Category    : utility sockets
;
; Example     : IDL> java_debug
;
; Inputs      : None
;
; Keywords    : None
;
; Restrictions: Only run this after a problem has occurred with the IDL-Java bridge 
;
; History     : Written 31-March-2009, D.M. Zarro (ADNET)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;
;-

pro java_debug

oJSession = OBJ_NEW('IDLJavaObject$IDLJAVABRIDGESESSION')
if ~obj_valid(oJSession) then return
oJExc = oJSession->GetException()
if ~obj_valid(oJExc) then begin
 obj_destroy,ojsession & return
endif
oJExc->PrintStackTrace
obj_destroy,[ojsession,ojexc]

return & end
