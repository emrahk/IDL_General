pro get_nai,arr_big
;***********************************************
; Program reads the array of good NaI event
; locations in (PSA,PHA) space for HEXTE.
; Variables are:
;       arr.........(64,256) array (1 = good)
;   arr_big.........same as above + 4 dets
; First do common block:
;***********************************************
common nai,arr,nai_only
;***********************************************
; Make the output array
;***********************************************
arr = intarr(64,256)
arr_big = lonarr(4,64,256)
;***********************************************
; Set the array values. These were gotten from
; a long phapsa accumulation of good event 
; data. 
;***********************************************
arr(10:20,100:255) = 1
for i = 10,100 do begin
 p1 = fix(5.5+sqrt((float(i)-10.)/4.))
 if (i gt 50) then p2 = 20 else $
 p2 = fix(10.5+sqrt(5.*(float(i)-10.)/2.))
 arr(p1:p2,i) = 1
endfor
;***********************************************
; Make big array
;***********************************************
for i = 0,3 do arr_big(i,*,*) = long(arr)
arr = arr_big
;***********************************************
; Thats all, ffolks.
;***********************************************
return
end
