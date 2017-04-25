;+
; Project     :	VSO
;
; Name        :	is_object
;
; Purpose     :	returns, 1/0 if valid/invalid object 
;
; Category    :	Objects
;
; Syntax      : IDL> output=is_object(input)
;
; Inputs      :	INPUT = input structure array
;
; Outputs     :	OUTPUT = 1/0
;
; Written     : 27-Oct-2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_object,input

sz=size(input)
return,sz[n_elements(sz)-2] eq 11

end
