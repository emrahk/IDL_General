del = fltarr(256)
for i = 1,255 do begin
 del(i) = abs(sqrt(acnts(i)) - sqrt(acnts(i-1)))
endfor
end
