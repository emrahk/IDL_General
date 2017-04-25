;+
; Project     : SOHO - CDS
;
; Name        : XTEXT_RESET_ID
;
; Purpose     : Reset widget text fields
;
; Category    : widgets
;
; Explanation : initializes cursor position in a text widget
;
; Syntax      : IDL> xtext_reset_id,id
;
; Inputs      : ID = text widget id 
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

pro xtext_reset_id,id

if not exist(id) then return
if datatype(id) ne 'LON' then return

for i=0,n_elements(id)-1 do begin
 if xalive(id(i)) then begin
  if widg_type(id(i)) eq 'TEXT' then begin
   widget_control,id(i),set_text_select=0,bad_id=bad_id 
;   widget_control,id(i),set_text_top_line=0,bad_id=bad_id 
  endif
 endif
endfor

return & end
