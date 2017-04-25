
function moment2d, a, i, j, order, mask=mask

;+
; NAME:
;       moment2d
; PURPOSE:
;	Calculate the generalized moment of an array relative to
;	a specified coordinate pair (i,j) (not necessarily located
;	within the array).
; CALL:
;       moment = moment2d(input_array, i, j [,order])
; INPUTS:
;       A     - Input array
;       i,j   - xy indices of pixel relative to which moment is calculated
; OPTIONAL INPUT:
;	order - The exponent applied to distance array when weighting
;		each element's contribution to the moment
;	mask  - Optional mask in which valid pixels are set to 1 and
;	        invalid pixels are set to 0.
; OUTPUTS:
;       Scalar moment of array relative to specified coordinate pair.
; OPTIONAL OUTPUT:
; METHOD:
;       Calculate the array of distances of each element in the input
;	array relative to the specified center coordinates.  Then multiply
;	this distance array by the input array.  Total the resulting array,
;	normalize the total by the number of points in the array, baste
;	in Hollandaise sauce, chill overnight, and serve with garnishes.
;	Serves 6-8 hungry scientists. 
; HISTORY:
;       10-Aug-2001 - Written by GLS.
;-

if n_elements(order) eq 0 then order = 1

d = dij(a,i,j)

if abs(order) lt 0 then d = d > 1
case order of
   1   : m = a*d
  -1   : m = a/d
   2   : m = a*(d*d)
   else: m = a* d^order
endcase

if exist(mask) then m = total(m)/total(mask) else $
  m = total(m)/n_elements(a)

return, m
end
