;+
; Project     :	SDAC
;
; Name        :	XSHOW
;
; Purpose     :	To show (unmap) an X widget
;
; Explanation :	So obvious, that explaining it will take more
;               lines than the code.
;
; Category    : widgets
;
; Use         :	XSHOW,ID
;              
; Inputs      :	ID = widget ids to show
;
; Opt. Inputs : None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	NAME = set if input ID is a an event handler name
;               ALL  = set to show all instances of NAME
;                              
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 18 September 1993
;               Version 2.0, 17 November 1999 -- added /all, /name
;                
;-


pro xshow,id,sensitive=sensitive,name=name,all=all

if not exist(id) then return
if keyword_set(name) and (datatype(id) eq 'STR') then $ 
  ids=get_handler_id(id,all=all) else ids=id

nid=n_elements(ids)
if nid gt 0 then begin
 for i=0,nid-1 do begin
  if xalive(ids(i)) then begin
   realized=widget_info(ids(i),/realized)
   widget_control,ids(i),/map,/show,realize=(not realized),iconify=0
   if keyword_set(sensitive) then widget_control,ids(i),/sensitive
  endif
 endfor
endif

return & end
