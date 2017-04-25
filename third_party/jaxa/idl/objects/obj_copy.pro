;+
; Project     : HESSI
;
; Name        : OBJ_COPY
;
; Purpose     : Copy an object variable into new object variable
;
; Category    : utility objects
;
; Syntax      : IDL> obj_copy,object,copy
;
; Inputs      : OBJECT = object to copy (array or scalar)
;
; Outputs     : COPY = copied object
;
; History     : Written 18 March 2004, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;
;-

pro obj_copy,object,copy,_ref_extra=extra

if not obj_valid(object) then begin
 pr_syntax,'obj_copy,object,copy'
 return
endif

if obj_valid(copy) then obj_destroy,copy

copy=obj_clone(object,_extra=extra)

return

end
