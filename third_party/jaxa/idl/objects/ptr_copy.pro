;+
; Project     : HESSI
;
; Name        : PTR_COPY
;
; Purpose     : Copy a pointer variable into new pointer variable
;
; Category    : utility objects pointers
;
; Syntax      : IDL> ptr_copy,ptr,copy
;
; Inputs      : PTR = pointer to copy (array or scalar)
;
; Outputs     : COPY = copied pointer
;
; History     : Written 18 May 2004, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;
;-

pro ptr_copy,ptr,copy,_ref_extra=extra

if not ptr_valid(ptr) then begin
 pr_syntax,'ptr_copy,ptr,copy'
 return
endif

if ptr_valid(copy) then ptr_free,copy

copy=ptr_clone(ptr,_extra=extra)

return

end
