;+
; Project     : RHESSI
;
; Name        : IS_TRUECOLOR
;
; Purpose     : Check if input data is a TrueColor image
;
; Category    : imaging
;
; Syntax      : true=is_truecolor(data)
;
; Inputs      : DATA = TrueColor interleaved data array [3,nx,ny]
;
; Outputs     : TRUE = 1/0 = if TrueColor or not 
;
; Keywords    : TRUE_INDEX = 1, 2, or 3 = index of interleave dimension
;               DIMENSION = data dimensions 
;
; History     : Written 20 April 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_truecolor,data,true_index=true_index,dimensions=dimensions,$
                           _ref_extra=extra

dimensions=get_true_size(data,true_index=true_index,_extra=extra)
return,(true_index gt 0) && is_byte(data)

end

