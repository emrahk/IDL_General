;+
; Project     : SOHO-CDS
;
; Name        : REP_PROP
;
; Purpose     : replace a property value in a map object
;
; Category    : imaging, objects, maps
;
; Explanation : 
;
; Syntax      : rep_prop,map,property=value
;
; Examples    : rep_prop,map,units='arcsecs'
;
; Inputs      : MAP = map structure
;               PROPERTY = property name
;               VALUE = property value
;
; Opt. Inputs : None
;;
; Outputs     : MAP = new map with property added
;
; Opt. Outputs: 
;
; Keywords    : See inputs
;
; Common      : None
;
; Restrictions: Cannot have two properties with same name
;
; Side effects: None
;
; History     : Written 22 April 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro rep_prop,map,_extra=extra,err=err,extra=extra2

on_error,1
err=''

if datatype(extra) ne 'STC' then return
if not valid_map(map,err=err) then begin
 pr_syntax,'rep_prop,map,name=value'
 return
endif

tags=tag_names(extra)
extra2=extra
for i=0,n_elements(tags)-1 do begin
 chk=get_map_prop(map,tags(i),found=found,/quiet)
 if found then begin
  map=rep_tag_value(map,extra.(i),tags(i),/no_copy)
  extra2=rem_tag(extra2,tags(i))
 endif
endfor

return  & end
