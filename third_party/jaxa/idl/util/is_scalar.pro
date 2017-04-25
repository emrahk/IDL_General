;+
; Project     : HESSI
;                  
; Name        : IS_SCALAR
;               
; Purpose     : return true if input is a true scalar (e.g. 1 instead of [1])
;                             
; Category    : utility
;               
; Syntax      : IDL> a=is_scalar(input)
;    
; Inputs      : INPUT = input variable to check
;                              
; Outputs     : 0/1 if scalar/nonscalar
;             
; History     : 4-Apr-2005, Zarro (L-3Com/GSFC)
;               15-March-2009, Zarro (ADNET)
;                - added check for COMPLEX, OBJ, and PTR
;
; Contact     : dzarro@solar.stanford.edu
;-    

function is_scalar,input

sz=size(input)
type=sz[n_elements(sz)-2]
chk=where(type eq [6,8,9,10,11],count)
return,(sz[0] eq 0) and (n_elements(input) eq 1) and (count eq 0) 

end
