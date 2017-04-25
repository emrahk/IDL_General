;+
; Project     : SSW
;
; Name        : MTOTAL
;
; Purpose     : Dimension array support for TOTAL and PRODUCT
;
; Category    : Utility
;
; Explanation : For IDL's TOTAL and PRODUCT, the second argument, Dimension, may not be a vector
;	of dimensions eliminating the need for nesting TOTAL and PRODUCT. It also supports summing or
;	multiplying over all but the dimensions in the Dimension argument
;
; Syntax      : IDL> result = mtotal (array, dimension)
;
; Inputs      : array - array to be summed (or multiplied)
;
; Opt. Inputs : dimension - dimension over which to sum (starting at 1)
;
; Outputs     : Returns sum(product) of elements in array, or sum(product) over dimension if dimension(s) are specified
;
; Keywords    : Any keywords that total takes
;				PRODUCT - Use the function Product instead of Total as it has the same restrictions
;				KEEP_DIM - Sum(Multiply) over all the other dimensions other than those in the Dimension argument
;				FIRST - If the Dimension argument isn't set, this sets it to 1
;				LAST  = If the Dimension argument isn't set, this sets it to the last Dimension
;					LAST has precedence over FIRST
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     :
;				27-aug-2010, richard.schwartz@nasa.gov
;
; Contact     : richard.schwartz@nasa.gov
;-
function mtotal, a, dimlist, KEEP_DIM=KEEP_DIM, LAST=LAST, FIRST=FIRST,$
	 _EXTRA=_EXTRA, PRODUCT=PRODUCT


ndim = n_dimensions(a)
dim = indgen(ndim)+1
if (~keyword_set(dimlist)) && (~keyword_set(last)) && (~keyword_set(first)) then $
	return, ftotal( a,_extra=_extra, product=product)
dimlist = keyword_set(dimlist) ? dimlist: $
	( keyword_set(last)? dim[ndim-1] : (keyword_set(first)? 1: 1))

dimlist = fix(dimlist)
if ~in_range( dimlist, [1,ndim]) then begin
	message,/continue, 'Input out of range. Must lie between 1 and ndim'
	return, a
	endif
if keyword_set(keep_dim) then begin
	temp = dim
	remove, dimlist-1, temp
	dimlist = temp
	endif

ord = sort(dimlist)
dimlist = dimlist[reverse(ord)] ;integration list sorted high to low
nlist = n_elements( dimlist)
out = a
for i=0,nlist-1 do out = ftotal( out, dimlist[i], product=product, _extra=_extra)
return, out
end



