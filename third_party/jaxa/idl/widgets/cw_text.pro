;+
; Project     : SOHO - CDS     
;                   
; Name        : CW_TEXT
;               
; Purpose     : compound text widget that switches itself to a label when non-editable
;               
; Category    : Widgets
;               
; Explanation : Used for making TEXT widgets appear as LABELS when
;               not editable.
;               
; Syntax      : IDL> id=cw_text(parent,value=value)
;    
; Examples    : To initially create an editable text widget,
;               IDL> id=cw_text(parent,value='test message')
;               
;               Then, to convert it to a label,
;               IDL> widget_control,id,set_value='noedit'
;
;               Then, to convert it back,
;               IDL> widget_control,id,set_value='edit'
;
; Inputs      : parent = parent widget id
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : All keywords inherited from WIDGET_TEXT. VALUE keyword is special.
;               To make TEXT widget editable, use value='EDIT'. This
;               is the default.
;               To make widget non-editable and appear as a LABEL, 
;               use value='NOEDIT'.
;
; Common      : None
;               
; Restrictions: Although this is a self-contained widget such as WIDGET_TEXT,
;               it still needs a parent base.
;               
; Side effects: None.
;               
; History     : Version 1,  26-Jun-1995,  D M Zarro.  Written
;
; Contact     : DMZARRO
;-            
;==============================================================================

function cw_text_get,id               ;-- Get value from TEXT widget
child=widget_info(id,/child)
widget_control,child,get_uvalue=state,/no_copy
widget_control,state.textid,get_value=field_text
widget_control,child,set_uvalue=state,/no_copy
return,field_text
end

;=============================================================================

pro cw_text_set,id,value        ;set value for TEXT and LABEL widget

;-- note that VALUE= 'EDIT' or 'NOEDIT' are special
;   and control the mapping and unmapping of the TEXT and LABEL widgets.

child=widget_info(id,/child)
widget_control,child,get_uvalue=state,/no_copy
on=(strupcase(value) eq 'EDIT')
off=(strupcase(value) eq 'NOEDIT')
label=state.labelid
if (on or off) then begin
 if on and not state.edit then begin
  widget_control,state.tbase,map=1
  widget_control,state.lbase,map=0
  if widget_info(label,/type) eq 3 then widget_control,label,sensitive=1
  state.edit=1
 endif
 if off and state.edit then begin
  widget_control,state.tbase,map=0
  widget_control,state.lbase,map=1
  if widget_info(label,/type) eq 3 then widget_control,label,sensitive=1
  state.edit=0
 endif
endif else begin
 widget_control,state.textid,set_value=value 
 widget_control,state.labelid,set_value=value 
endelse
widget_control,child,set_uvalue=state,/no_copy

return & end 

;====================================================

function cw_text_event,event             ;-- get value for TEXT widget

child=widget_info(event.handler,/child)
widget_control,child,get_uvalue=state,/no_copy
widget_control,state.textid,get_value=currenttext
widget_control,child,set_uvalue=state,/no_copy
return,{id:event.handler,top:event.top,handler:0l}
end

;====================================================

function cw_text,parent,_extra=extra,value=value,uvalue=uvalue,$
                 edit=edit,xsize=xsize,font=font,text=text,label=label

on_error,1
if n_elements(parent) eq 0 then message,'enter a parent base'
if n_elements(value) eq 0 then value=''
if n_elements(uvalue) eq 0 then uvalue='INPUT'

cw_base=widget_base(parent,event_fun='cw_text_event',$
                   pro_set_value='cw_text_set',$
                   func_get_value='cw_text_get',uvalue=uvalue)

;-- TEXT and WIDGET bases occupy same base locations
;   Note use of _EXTRA to pass extra EDIT keywords to TEXT widget

edit=keyword_set(edit)
tbase=widget_base(cw_base,row=1,map=0)
if n_elements(xsize) eq 0 then xsize=10
if n_elements(font) eq 0 then font=''
text=widget_text(tbase,_extra=extra,value=value,edit=edit,xsize=xsize,font=font)

;-- add some blank space to fill out LABEL widget

lbase=widget_base(cw_base,row=1,map=0)
blank=' '
if n_elements(xsize) ne 0 then begin
 if xsize gt 1 then for i=0,xsize-1 do blank=blank+' '
endif
lvalue=blank
if n_elements(value) ne 0 then begin
 if strtrim(value,2) ne '' then lvalue=value
endif

do_it=strtrim(!version.release,2) eq '4.0.1a'
do_it=0
if do_it then begin
 label=widget_text(lbase,value=value,xsize=xsize,edit=0,/frame,font=font) 
endif else label=widget_label(lbase,value=lvalue,/frame,font=font)

;-- initially make TEXT appear first

if edit then begin
 widget_control,tbase,/map 
 if widget_info(label,/type) eq 3 then widget_control,label,/sensitive
endif else begin
 widget_control,lbase,/map
 if widget_info(label,/type) eq 3 then widget_control,label,sensitive=1
endelse

;-- save STATE structure in TBASE which is first child of CW_BASE
 
state={labelid:label,textid:text,tbase:tbase,lbase:lbase,edit:edit}
widget_control,tbase,set_uvalue=state,/no_copy

return,cw_base

end

