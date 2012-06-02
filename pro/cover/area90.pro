pro area90

openr,1,'/home/ek/coverage/con90'
ar90=fltarr(2,450)
readf,1,ar90
lo90=fltarr(450)
la90=fltarr(450)
for i=0,449 do lo90(i)=ar90(0,i)
for i=0,449 do la90(i)=ar90(1,i)
close,1
side1lon=[reverse(360-lo90),lo90]
side1lat=[reverse(la90),la90]
side2lon=side1lon+90
side2lat=side1lat
side3lon=side1lon+180
side3lat=side1lat
side4lon=side1lon+270
side4lat=side1lat

lo90n=rotlo(side3lon,side1lat)
la90n=rotla(side3lon,side1lat)
 

; discretisize longitude
dis=intarr(37)
for j=0,36 do for i=1,899 do begin
if (lo90n(i-1) GE float(j) AND lo90n(i) LT float(j)) THEN dis(j)=i
endfor
print,la90n(dis)
;now find the area of small circular portion
area=0.0
for i=0,35 do area=area+fix(la90n(dis(i))+0.5)-59
print,area
print,'take into account cos effect'
print,'area = ',area*0.46
area=area*0.46
;total cap area
tot=0.0
for j=60,90 do tot=tot+360*cos(j*!pi/180)
print,tot

print,tot-area*10
;print,area2
;small part

lo90n=rotlo(side2lon,side1lat)
la90n=rotla(side2lon,side1lat)
dis2=intarr(17)
lo90n=lo90n+144
area3=0.0;
for j=0,16 do for i=1,899 do begin
if (la90n(i-1) LT float(j) AND la90n(i) GE float(j)) THEN begin
dis2(j)=i
area3=area3+(181-lo90n(dis2(j)))*cos(la90n(dis2(j))*!pi/180)
print,area3
endif
endfor
;print,la90n(dis2)

total=area3*20+(tot-area*10)
print,'covered',41612-360-total
print,'uncovered',total

end

