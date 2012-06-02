pro num_read,dim,num,bit_arr
;******************************************************************
; Program converts a given long value(4 bytes) to a bit array
; Varables are:
;           dim...............number of bits in output array
;           num...............number to convert to bit array
;       bit_arr...............the bit array corresponding to above
; 9/1/93 handles unsigned numbers
;******************************************************************
bit_arr = intarr(dim)
if (num eq 0) then return
bit_nums = 2.^(dindgen(dim))
if(num lt 0)then begin
   num = num + max(bit_nums)
   bit_arr(dim - 1) = 1
endif
upper = max(where(bit_nums le num))
bit_arr(upper) = 1 & lon = num mod bit_nums(upper)
if (lon eq 0) then return
for i = upper - 1,0,-1 do begin
 if (bit_nums(i) le lon) then begin
    bit_arr(i) = 1
    lon = lon mod bit_nums(i) 
 endif
endfor
;*******************************************************************
; Thats all ffolks
;*******************************************************************
return
end
