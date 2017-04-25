;+
; Project     : VSO
;
; Name        : DESTROY
;
; Purpose     : Destroy a variable and free all memory associated with it
;
; Example     : IDL> destroy,a
;
; Inputs      : A = any variable
;
; Outputs     : None
;
; History     : 16-June-2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

 pro destroy,var
 if n_elements(var) eq 0 then return
 heap_free,ptr_new(var,/no_copy)
 return
 end
