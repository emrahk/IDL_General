function get_bit_val,num,lbit,ubit,dim=dim
;***********************************************************
; Program extracts the value ofa group of bits from a 
; number. Inspired by G. Huzar (5/30/95). Variables are:
;      num..............number to extract from
;     lbit..............beginning bit
;     ubit..............ending bit
;    value..............value of desired bit range
;      dim..............dimension (for unsigned)
; First do usage:
;***********************************************************
if (n_params() eq 0)then begin
   print,'USAGE:GET_BIT_VAL,NUM,LBIT,UBIT,VALUE'
   return,-1
endif
;***********************************************************
; Set some variables
;***********************************************************
l2 = long(2)
e1 = lbit
nbits = ubit - lbit + 1
n = n_elements(lbit)
len = n_elements(num)
val = lonarr(n,len)
;***********************************************************
; Do the decomm-ing
;***********************************************************
for i = 0,n-1 do begin
 lt0 = where(num lt long(0)) 
 if (lt0(0) ne -1)then begin
    if (ks(dim) eq 0) then begin
       print,'!NEED DIMENSION OF NUMBER FOR UNSIGNED!'
       return,-1
    endif
    num1 = num 
    num1(lt0) = num(lt0) + l2^(dim-1)
    value = num/l2^e1(i) mod l2^nbits(i)
    value(lt0) = num1(lt0)/l2^e1(i) mod l2^nbits(i) + $
                (ubit(i) eq dim-1)*l2^(nbits(i)-1)
    val(i,*) = value
 endif else begin
    val(i,*) = num/l2^e1(i) mod l2^nbits(i)
 endelse
endfor
if (n eq 1)then val = reform(val,len)
;***********************************************************
; Thats all ffolks
;***********************************************************
return,val
end
