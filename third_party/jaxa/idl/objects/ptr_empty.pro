;+
; Project     : HESSI
;
; Name        : PTR_EMPTY
;
; Purpose     : Empty a pointer of its data, but don't deallocate its memory
;
; Category    : Pointers
;
; Syntax      : IDL> ptr_empty,pointer
;
; Inputs      : POINTER = Pointer variable (scalar or array)
;
; Outputs     : POINTER minus its data
;
; History     : 22-Apr-2004, Zarro (L-3Com/GSFC) 
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro ptr_empty,pointer

if size(pointer,/tname) ne 'POINTER' then return
np=n_elements(pointer)
for i=0,np-1 do begin
 if ptr_valid(pointer[i]) then delvarx,*(pointer[i])
endfor

return
end
