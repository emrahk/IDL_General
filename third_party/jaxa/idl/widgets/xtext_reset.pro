;+
; Name        : XTEXT_RESET
;
; Purpose     : Reset widget text fields
;
; Category    : widgets
;
; Explanation : initializes cursor position in a text widget
;
; Syntax      : IDL> xtext_reset,info
;
; Inputs      : INFO = text widget ID or structure with ID as tags
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  12 Feb 1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro xtext_reset,info

if datatype(info) eq 'STC' then begin
 tags=tag_names(info)
 for k=0,n_elements(tags)-1 do xtext_reset_id,info.(k)
endif else xtext_reset_id,info

return & end

