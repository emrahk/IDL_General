pro findgaps,time,gaps

gaps=fltarr(2,n_elements(time))
j=0

for i=1L, long(n_elements(time))-1L do begin
  if time(i)-time(i-1) ge 0.1 then begin
     gaps(0,j)=i
     gaps(1,j)=time(i)-time(i-1)
     j=j+1
  endif
endfor
gaps=gaps(*,0:j-1)
end
