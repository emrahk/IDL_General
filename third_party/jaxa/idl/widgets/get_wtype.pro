;+
; NAME:
;	get_wtype
; PURPOSE:
;       get widget type
; CALLING SEQUENCE:
;	wtype=get_wtype(event)
; INPUTS:
;       event = widget event number
; OUTPUTS:
;       wtype=type of widget (base, button, slider, etc)
; PROCEDURE
;       examines tag names in event and widget_id structures
; HISTORY:
;       Zarro (ARC) - written Oct'93
;-

function get_wtype,event

@wbsc_com_blk

wtype=widg_type(event.id)

if wtype eq 'ERROR' then wtype=''

if wtype eq 'BASE' then begin
 wids=tag_names(widget_id) & nwids=n_elements(wids)
 widl=lonarr(n_elements(wids))
 for i=0,nwids-1 do begin
   wid_id=widget_id.(i)
   if n_elements(wid_id) eq 1 then widl(i)=widget_id.(i)
 endfor
 chk=where(event.id eq widl,count)
 if count gt 0 then wtype=(wids(chk))(0) 
endif

return,wtype & end

