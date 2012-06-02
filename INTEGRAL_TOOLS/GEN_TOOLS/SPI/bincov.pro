pro binconv,num,bin

bin=fltarr(16)
j=15
while num ne 0 do begin
  ch=num-(2.^j)
  if ch ge 0 then begin
    bin(j)=1
    num=num-(2.^j)
  endif else bin(j)=0
  j=j-1
endwhile
print,bin

end
