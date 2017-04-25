;+
; Project     : HESSI
;
; Name        : PTR_EXIST_ARR
;
; Purpose     : check if elements of a pointer array are valid and have data in them
;
; Category    : Pointers
;
; Syntax      : IDL> s=ptr_exist_arr(pointer)
;
; Inputs      : POINTER = Pointer variable
;
; Outputs     : array of 1/0 if pointers are valid with data or not                     
;
; History     : 04-Jan-2010, Kim Tolbert 
;
; Contact     : kim.tolbert@nasa.gov
;-

function ptr_exist_arr,pointer

if size(pointer,/tname) ne 'POINTER' then return,0b

np = n_elements(pointer)

if np eq 1 then return, ptr_exist(pointer)

ret = bytarr(np)
for i = 0,np-1 do ret[i] = ptr_exist(pointer[i])
  
return, ret

end
