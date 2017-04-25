;+
; Project     : VSO
;
; Name        : SESSION_ID
;
; Purpose     : Return unique session ID
;
; Category    : utility system sockets 
;
; Syntax      : IDL> id=session_id()
;
; Inputs      : None
;
; Outputs     : ID = string with time and random number appended
;
; Keywords    : None
;
; History     : 30-Oct-2015, Zarro (ADNET) - Written
;
; Contact:    : dzarro@stanford.edu
;-

function session_id

return,get_rid(/time)

end

