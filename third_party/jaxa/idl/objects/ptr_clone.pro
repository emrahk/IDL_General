;+
; Project     : HESSI
;
; Name        : PTR_CLONE
;
; Purpose     : Clone a pointer by saving it to an IDL save file
;               and then restoring it into a new pointer
;
; Category    : utility pointers
;
; Syntax      : IDL> clone=ptr_clone(pointer)
;
; Inputs      : pointer = pointer to clone (array or scalar)
;
; Outputs     : CLONE = cloned pointer
;
; History     : Written 29 Nov 2002, D. Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;
;-

function ptr_clone,pointer,err=err,_extra=extra

err='Invalid pointer entered'
if ~exist(pointer) then begin
 message,err,/cont
 return,-1
endif

if size(pointer,/tname) ne 'POINTER' then begin
 message,err,/cont
 return,pointer
endif

return,clone_var(pointer,_extra=extra)

end
