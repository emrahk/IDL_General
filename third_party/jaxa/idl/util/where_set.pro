;+
; ROUTINE: Where_Set
;
; PURPOSE: The procedure is the vector equivalent of "if( test) then a = value"
;
; USEAGE: where_set, test, arr, setvalue, arr1, setvalue1, arr2, setvalue2
;
; INPUT:
;	Test - Conditional test for each array element
;   For each pair of Arr and SetValue inputs,
;	Arr  and Setvalue, arr[where(test)] = setvalue[where(test)]
;
;	Arr1 and Setvalue1 - arr1[where(test)] = setvalue1[where(test)]
;	Arr2 and Setvalue2 - arr2[where(test)] = setvalue2[where(test)]
;   If Test isn't true anywhere, no values are changed
;	The Arr may be an array or scalar, test should have the same number of elements as Arr (not checked)
;	Setvalue may either be an array the same n_elements as Arr or a scalar.
;	There is no checking of the inputs, the caller is responsible for that

; OUTPUT:
;	Arr, Arr1, Arr2 are modified where test is true
;
; History
;	March 2012, richard.schwartz@nasa.gov
;-
pro where_set, test, arr, setvalue, arr1, setvalue1, arr2, setvalue2

sel = where(test, count)
if count gt 0 then begin
	arr[sel] = setvalue[sel]
	if exist(arr1) then arr1[sel] = setvalue1[sel]
	if exist(arr2) then arr2[sel] = setvalue2[sel]
	endif


end