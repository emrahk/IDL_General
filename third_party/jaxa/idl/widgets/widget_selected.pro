;+
; Project     : HESSI
;
; Name        : WIDGET_SELECTED
;
; Purpose     : get currently highlighted selections from list widget
;
; Category    : utility widgets
;
; Syntax      : IDL> selected=widget_selected(list)
;
; Inputs      : LIST = list widget ID
;
; Outputs     : SELECTED = selected uvalues 
;
; Keywords    : INDEX = set to return index of selection instead of UVALUEs
;
; History     : Written 23 May 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function widget_selected,list,index=index
selected='' 
ret_index=keyword_set(index)
if ret_index then selected=-1

if not exist(list) then return,selected
if not widget_info(list,/valid) then return,selected
if widget_info(list,/name) ne 'LIST' then return,selected
selections=widget_info(list,/list_select)
ok=where(selections gt -1,count)
if count eq 0 then return,selected
selections=selections(ok)

if ret_index then return,selections
widget_control,list,get_uvalue=uvalue
ok=where(selections gt -1,count)
if count gt 0 then selected=uvalue(selections)

return,selected & end
