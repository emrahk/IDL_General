pro num_read_arr,dim,nm,bit_arr
;******************************************************************
; Program converts an array of given longword values to an array
; of bit values. Variables are:
;        dim................number of bits in output array
;    num_arr................array of longword numbers
;    bit_arr................bit array corresponding to the above
;******************************************************************
num_arr = double(nm)
len = n_elements(num_arr)
bit_arr = intarr(dim,len) 
bit_nums = (2d)^dindgen(dim)
lt0 = where(num_arr lt 0)
if (lt0(0) ne -1)then begin
   num_arr(lt0) = num_arr(lt0) + max(bit_nums)
   bit_arr(dim-1,lt0) = 1
endif
for i = dim-1,0,-1 do begin
 in = where(num_arr ge bit_nums(i))
 if (in(0) ne -1)then begin
    bit_arr(i,in) = 1
    rem = num_arr(in) mod bit_nums(i)
    num_arr(in) = rem
 endif
endfor
;******************************************************************
; Thats all ffolks
;******************************************************************
return
end
