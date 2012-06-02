; this program plots the detectors and writes down the potentials if <> 0
pro fstrip,i,fn,num
; i file number for strip file fn with num number of detectors
openr,i,fn
st=fltarr(3,num)
readf,i,st
print,st
for j=0,num-1 do begin
oplot,[14+st(0,j),14+st(1,j)],[182,182], line=0
;if st(2,j) ne 0 then xyouts,st(0,j),177,st(2,j),charsize=0.5
endfor
close,i
end
