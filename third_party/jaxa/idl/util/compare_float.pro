;+
; NAME:
;       COMPARE_FLOAT
; PURPOSE:
;       Routine to compare whether two numeric vectors have same dimensions and same
;       value - if ratio of a to b is within epsilon of 1., then have same value.
;
; CALLING SEQUENCE:
;       compare_float, a, b, epsilon=epsilon
;
; INPUTS:
;       a,b - two vectors to compare
;
; OUTPUTS:
;       Function returns 1 for identity, 0 otherwise.
;
; OPTIONAL INPUT KEYWORD:
;       epsilon - if values are within epsilon, they are considered equal. Used only
;               in non-integer matching.  Default=.005
;
; METHOD:
;       1. Compare dimensions of two vectors.
;       2. Make sure elements with 0 value are in the same location in two vectors.
;       3. For non-zero values, compute ratio and compare to epsilon  
;
; HISTORY: Kim Tolbert, Richard Schwartz, 24-Feb-2009
; Modifications:
;-

function compare_float, a, b, epsilon=epsilon

on_error,2

checkvar, epsilon, .005

if N_params() LT 2 then begin
     print,'Syntax - test = compare_float(a, b, [ epsilon = ])'
     print,'    a,b -- input numeric vectors to compare'
     return, 0
endif

if not same_size(a,b) then return,0    ; not same dimensions

qa = where (a ne 0., na)
qb = where (b ne 0., nb)
if na ne nb then return, 0    ; not same number of 0s

if not array_equal(qa, qb) then return, 0  ; 0s not in same indices


if na gt 0 then begin             ; for non-zero values, compare ratio to epsilon
  ratio = a[qa] / b[qb]
  return, max(abs(ratio - 1.)) lt epsilon
endif else return, 1

end

