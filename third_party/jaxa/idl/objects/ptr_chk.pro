;+
; Project     : HESSI
;
; Name        : PTR_CHK
;
; Purpose     : check if a variable is of type POINTER (regardless of
;               whether it's an array or scalar or allocated or not)
;
; Category    : Pointers
;
; Syntax      : IDL> s=ptr_chk(pointer)
;
; Inputs      : POINTER = Variable to check
;
; Outputs     : 1/0 if it is or isn't
;
; History     : Sep-2004, Richard Schwartz
;
; Contact     : richard.schwartz@gsfc.nasa.gov
;-

function ptr_chk, var

return, size(/tname, var) eq 'POINTER'

end