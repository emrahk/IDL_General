pro decomp,comp_arr,fact,arr
;*****************************************************************
; Program decompresses an integer array into another array
; Variables are:
;       comp_arr..................compressed array
;            arr..................decompressed array
;           fact..................compression factor
; 6/10/94 Current version
;*****************************************************************
fac = 1./fact
c_arr = float(comp_arr)
decom = long(c_arr*fac + .5)
nbns = n_elements(comp_arr)
arr = lonarr(fact*nbns)
for i = 0,fact-1 do begin
 arr(indgen(nbns)*(fact)+i) = decom
endfor
;*****************************************************************
; Thats all ffolks
;*****************************************************************
return
end
