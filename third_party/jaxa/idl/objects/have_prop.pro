;+
; Project     : HESSI
;
; Name        : HAVE_PROP
;
; Purpose     : check object has property
;
; Category    : utility objects
;
; Syntax      : IDL> chk=have_prop(class,property)
;
; Inputs      : CLASS = class name or object variable name
;               PROPERTY = property name
;
; Outputs     : CHK = 1/0 if have/have not
;
; History     : 31-Dec-2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function have_prop,class,property,err=err,_extra=extra
err=''

ok_input=(is_object(class) || is_string(class)) && is_string(property)

if ~ok_input then begin
 pr_syntax,'chk=have_prop(ob_class_name,property_name)'
 err='invalid inputs'
 return,0b
endif

props=obj_props(class,err=err)
if is_string(err) then return,0b
chk=where(strtrim(strupcase(property),2) eq props,count)
return,(count ne 0)

end
