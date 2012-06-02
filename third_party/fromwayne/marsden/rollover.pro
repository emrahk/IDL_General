pro rollover,cnts,sigma
;********************************************************************
; Program detects rollover in the archive data due to
; data compression.
; Variables are:
;         cnts.................counts array
;        sigma.................sigma variation for rollover
; 6/10/94 Current version
; 8/26/94 Print statements
;********************************************************************
nbns = n_elements(cnts)
cnts_add = lonarr(nbns)
scnts = shift(cnts,-1)
del = scnts - cnts
del(0) = 0 & del(nbns-1) = 0
sig = sqrt(cnts - (cnts - scnts)*(scnts lt cnts))
nz = where(sig ne 0.)
z = where(sig eq 0.)
if (z(0) ne -1)then del(z) = 0.
if (nz(0) ne -1)then del(nz) = del(nz)/sig(nz)
;********************************************************************
; Find the instances of rollover. Calculate the compression which is
; 256/width. The widths are:
;      0 - 31.................2 pha
;     32 - 63.................4 pha
;     64 - 255................8 pha
; Add the necessary amount/chn.
;********************************************************************
rolled = where(abs(del) ge sigma,num)
if (rolled(0) eq -1 or num eq 1)then begin
   return
endif
dell = del(rolled)
if (num mod 2 ne 0)then nums = num + 1 else nums = num
low = intarr(nums/2) & high = low
roll = intarr(nums)
if (nums eq num)then begin
   roll = rolled 
endif else begin
   roll(0:num-1) = rolled
   roll(num) = nbns-1
endelse
add = 0
for i = 0,nums-2 do begin
 ndx = roll(i) & ndxx = roll(i+1)
 if (ndx le 31)then fac = 2
 if (ndx gt 31 and ndx le 63)then fac = 4
 if (ndx gt 63)then fac = 8
 if (del(ndx) gt 0)then begin
    cnts_add(ndx+1:ndxx) = add + 256/fac
    add = add + 256/fac
 endif else begin
    add = 0
 endelse
endfor
cnts = cnts + cnts_add    
;********************************************************************
; Thats all folks
;********************************************************************
return
end
