pro area80

openr,1,'/home/ek/coverage/con80'

ar80=fltarr(2,450)
readf,1,ar80
lo80=fltarr(450)
la80=fltarr(450)
for i=0,449 do lo80(i)=ar80(0,i)
for i=0,449 do la80(i)=ar80(1,i)
close,1
side1lon=[reverse(360-lo80),lo80]
side1lat=[reverse(la80),la80]
side2lon=side1lon+90
side2lat=side1lat
side3lon=side1lon+180
side3lat=side1lat
side4lon=side1lon+270
side4lat=side1lat


lo80n=rotlo(side3lon,side1lat)
la80n=rotla(side3lon,side1lat)

finar=fltarr(360)
;print,lo80n
s1=fltarr(2,105)
for j=-52,52 do for i=1,899 do begin
if (lo80n(i-1) GE float(j) AND lo80n(i) LT float(j)) THEN begin
s1(0,j+52)=float(j)
s1(1,j+52)=la80n(i)
endif
endfor
lo80n=lo80n+72

s2=fltarr(2,105)
for j=-52+72,52+72 do for i=1,899 do begin
if (lo80n(i-1) GE float(j) AND lo80n(i) LT float(j)) THEN begin
s2(0,j-20)=float(j)
s2(1,j-20)=la80n(i)
endif
endfor
;print,s2


lo80n=lo80n+72

s3=fltarr(2,105)
for j=92,196 do for i=1,899 do begin
if (lo80n(i-1) GE float(j) AND lo80n(i) LT float(j)) THEN begin
s3(0,j-92)=float(j)
s3(1,j-92)=la80n(i)
endif
endfor
;print,s3

lo80n=lo80n+72

s4=fltarr(2,105)
for j=164,268 do for i=1,899 do begin
if (lo80n(i-1) GE float(j) AND lo80n(i) LT float(j)) THEN begin
s4(0,j-164)=float(j)
s4(1,j-164)=la80n(i)
endif
endfor
;print,s4

lo80n=lo80n+72

s5=fltarr(2,105)
for j=236,340 do for i=1,899 do begin
if (lo80n(i-1) GE float(j) AND lo80n(i) LT float(j)) THEN begin
s5(0,j-236)=float(j)
s5(1,j-236)=la80n(i)
endif
endfor

for m=0,359 do begin
case 1 of
((m GE 0) and (m LT 36)):finar(m)=s1(1,52+m)
(m GE 36) and (m LT 108) : finar(m)=s2(1,m-20)
(m GE 108) and (m LT 180) : finar(m)=s3(1,m-92)
(m GE 180) and (m LT 252) : finar(m)=s4(1,m-164)
(m GE 252) and (m LT 324) : finar(m)=s5(1,m-236)
(m GE 324) and (m LE 359) : finar(m)=s1(1,m-308)
endcase
endfor
print,finar
area=0.0
for lo=0,359 do for la=64,90 do begin
if la GE finar(lo) then area=area+cos(la*!pi/180)
endfor
print,area



end
