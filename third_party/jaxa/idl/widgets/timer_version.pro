;+
; Project     : SOHO - CDS     
;                   
; Name        : TIMER_VERSION
;               
; Purpose     : check IDL version that supports timer events
;               
; Category    : system
;               
; Explanation : 
;               
; Syntax      : IDL> a=timer_version()
;    
; Examples    :
;
; Inputs      : None
;               
; Opt. Inputs : 
;               
; Outputs     : 1/0 if timers are supported or not
;
; Opt. Outputs: None
;               
; Keywords    : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None.
;               
; History     : Version 1,  27-Feb-1997,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            


function timer_version

return,idl_release(lower=3.5)

end


