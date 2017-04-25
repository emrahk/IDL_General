;+
; Project     : HESSI
;
; Name        : PTR_EXIST
;
; Purpose     : check if a pointer is valid and has data in it
;
; Category    : Pointers
;
; Syntax      : IDL> s=ptr_exist(pointer)
;
; Inputs      : POINTER = Pointer variable
;               INDEX = index of pointer to check (if array)
;
; Outputs     : 1/0 if it has or hasn't                     
;
; History     : 29-Aug-2000, Zarro (EIT/GSFC) 
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function ptr_exist,pointer,index


if size(pointer,/tname) ne 'POINTER' then return,0b

if is_number(index) then index=0 > index < (n_elements(pointer)-1) else index=0

if ~ptr_valid(pointer[index]) then return,0b

return,n_elements(*pointer[index]) gt 0

end
