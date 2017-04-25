;+
; Project     : SOHO-CDS
;
; Name        : ADD_PROP
;
; Purpose     : Add a property to a map object
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : add_prop,map,property=value
;
; Examples    : add_prop,map,units='arcsecs'
;
; Inputs      : MAP = map structure
;               PROPERTY = property name
;               VALUE = property value
;               REPLACE = set to replace with new value if property exists
;
; Opt. Inputs : None
;
;
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
; History     : Written 18 March 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro add_prop,map,_extra=extra,err=err,replace=replace

on_error,1
err=''

if datatype(extra) ne 'STC' then return

if not valid_map(map,err=err) then begin
 pr_syntax,'add_prop,map,property=value'
 return
endif

if keyword_set(replace) then rep_prop,map,_extra=extra,err=err,extra=extra


map=join_struct(map,extra)
return

end
