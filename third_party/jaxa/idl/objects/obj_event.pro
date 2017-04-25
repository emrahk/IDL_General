;+
; Project     : HESSI
;
; Name        : OBJ_EVENT
;
; Purpose     : General object widget event handler
;
; Category    : utility objects widgets
;
; Syntax      : IDL>obj_event,event
;
; Inputs      : EVENT = widget event 
;
; History     : Written 16 April 2000, D. Zarro, EIT/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

 pro obj_event, event

 if not have_tag(event,'top') then return
 widget_control,event.top,get_uvalue=object
 widget_control,event.id,get_uvalue=method
 if is_string(method) and obj_valid(object) then begin
  if have_method(object,method) then call_method,method,object,event
 endif

; if obj_valid(object) then object->event,event

 return & end
