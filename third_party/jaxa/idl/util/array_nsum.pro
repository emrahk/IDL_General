;+
; Name: array_nsum
; 
; Purpose: Return an array with every nsum points of input array averaged. 
; 
; Method: Extra points beyond full groups of nsum points are averaged. If nsum > # points in array, average of full array is returned.
; 
; Input argument: 
;  array - input array to average
;  
; Input keywords:
;  nsum - number of points to average (default=2)
;  
; Written: Kim Tolbert 27-Mar-2015
; Modifications:
; 
;-

function array_nsum, array, nsum=nsum_in

checkvar, nsum, 2
nsum = fix(nsum_in)

na = n_elements(array)
if nsum eq 1 then return, array

new = na / nsum ; integer arithmetic will truncate
nuse = nsum * new

nextra = na - nuse  ; points beyond full groups of nsum points
if nextra gt 0 then alast = total(last_nelem(array,nextra)) / nextra
if nuse eq 0 then return, alast

return, nextra eq 0 ? rebin(array[0:nuse-1], new) :  [rebin(array[0:nuse-1], new), alast]

end 