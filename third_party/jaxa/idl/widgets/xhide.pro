;+
; Project     :	SDAC
;
; Name        :	XHIDE
;
; Purpose     :	To hide (map) an X widget
;
; Explanation :	So obvious, that explaining it will take more
;               lines than the code.
;
; Use         :	XHIDE,ID
;              
; Inputs      :	ID = widget id to hide
;
; Category    :	Useful stuff
;
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 18 September 1993
;-

pro xhide,id

nid=n_elements(id)
if nid gt 0 then begin
 for i=0,n_elements(id)-1 do begin
  if xalive(id(i)) then widget_control,id(i),map=0
 endfor
endif

return & end
