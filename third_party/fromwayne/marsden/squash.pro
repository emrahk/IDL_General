pro squash,a_counts,a_cts,low,high

; Takes a_counts(4,4,64,256) and squash it down it a_cts(4,4,256)
; by adding over the "64" dimension starting from "low" and going
; to "high", inclusive. 

a_cts=lonarr(4,4,256)
mask=intarr(64)
for i=low,high do mask(i)=1.0
for i=0,3 do begin
  for j=0,3 do begin
    arr=reform(a_counts(i,j,*,*),64,256)
    a_cts(i,j,*)=mask#arr
  endfor
endfor

return
end
