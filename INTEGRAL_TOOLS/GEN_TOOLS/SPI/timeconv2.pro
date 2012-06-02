function timeconv2,nums

bin=fltarr(4,16)

for i=0,3 do begin
  num=nums(i)
  j=15
  while num ne 0 do begin
    ch=num-(2.^j)
    if ch ge 0 then begin
      bin(i,j)=1
      num=num-(2.^j)
    endif else bin(i,j)=0
    j=j-1
  endwhile
endfor

bin1=reverse(reform(bin(1,*)))
bin2=reverse(reform(bin(2,*)))
bin3=reverse(reform(bin(3,*)))

;print,bin1
timex=reverse([bin1(4:15),bin2(0:11)])
;print,timex

t=double(0)
for i=0,23 do t=t+timex(i)*(double(2.^(float(i))))

tint=t-double(5631911.)
;tint=t

timex=reverse([bin2(12:15),bin3(0:14)])
;print,timex

t=double(0)
for i=0,18 do t=t+(double(timex(i)*2.^(float(i))))
tdec=t/double(2.^(19.))

;tdx=floor(alog(tdec)/alog(10))
;divf=10^(tdx+1.)
;tdec=tdec/divf
;print,tint,tdec
time=tint+tdec+.21810372103
;time=tint+tdec
return,time

end
