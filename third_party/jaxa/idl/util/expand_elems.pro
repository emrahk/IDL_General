;-
; Name: expand_elems
;
; Purpose: Expand groups of contiguous elements by a number of elements in front and at end of each group.
;
; Calling sequence: arr = expand_elems(indicies, nexpand_in, min, max)
;
; Calling arguments:
;  indices - array of indices, 1-D, monotonically increasing
;  nexpand_in - number of elements to expand each group of contiguous elements by. [2] but if scalar uses same value for 
;    start and end. Default=[0,0]
;  min - when expanding, don't allow values to go below min. Default=0
;  max - when expanding, don't allow values to go above max. Default=max(indices)
;  
; Example:
;   indices = [2,3,4,18,19,20]
;   print,expand_elems(indices,nexpand=2,max=25)
;       0       1       2       3       4       5       6      16      17      18      19      20      21      22
;   print,expand_elems(indices,nexpand=[0,2],max=25)
;       2       3       4       5       6      18      19      20      21      22
; Written: Kim Tolbert, 7-Feb-2014
; Modifications:
; 
;+


function expand_elems, indices, nexpand=nexpand_in, min=min, max=max

checkvar, nexpand_in, 0
checkvar, min, 0
checkvar, max, max(indices)

nexpand = nexpand_in
if n_elements(nexpand) eq 1 then nexpand = [nexpand, nexpand]

ind = find_contig(indices, dum, ss)  ; ss will be nx2 array of start/end pairs for each group
ss = reform(transpose(ss))  ; make into a 2xn array, so if there's only one pair the following code still works
ind = indices[ss]
ind[0,*] = (ind[0,*] - nexpand[0]) > min
ind[1,*] = (ind[1,*] + nexpand[1]) < max
for i=0,n_elements(ss[0,*])-1 do new = append_arr(new, ind[0,i]+indgen(ind[1,i]-ind[0,i]+1))

return, get_uniq(new)
end