pro spec1
rddata,'/home/ek/r90h.dat',11,aryh,nskip=3
rddata,'/home/ek/r90e.dat',11,arye,nskip=3
; set_plot,'ps'

!P.MULTI=[0,2,2]
for i=1,109 do aryh(1,i)=aryh(1,i-1)+aryh(1,i)
for i=1,88 do arye(1,i)=arye(1,i-1)+arye(1,i)

;interpolate

snew=fltarr(250)
tnew=fltarr(250)
for i=1,87 do begin
    t=arye(1,i)
    j=0
    if (i EQ 0) then print,arye(4,i)+aryh(4,i) 
    while (t GT aryh(1,j)) do begin
         ;print,j,t,aryh(1,j)
         j=j+1
    endwhile
    snew(i)=arye(4,i)+aryh(4,i)+$
((t-aryh(1,j))/(aryh(1,j+1)-aryh(1,j)))*(aryh(4,j+1)-aryh(4,j))
endfor
print,snew(86),snew(87),j
for i=j+1,109 do snew(87-j+i)=aryh(4,i)+arye(4,87)
for i=j+1,109 do tnew(87-j+i)=aryh(1,i)
for i=0,87 do tnew(i)=arye(1,i)

a=fltarr(87-j+110)
b=fltarr(87-j+110)
a=tnew(0:87-j+109)
b=snew(0:87-j+109)
plot,arye(1,*),arye(4,*)
plot,aryh(1,*),aryh(4,*)
plot,a,b

print,a





;plot,aryf(1,*),aryf(3,*),title="anode 9",yrange=[-180,300]
;oplot,arye(1,*),arye(4,*)
;plot,aryf(1,*),aryf(4,*),title="anode 10"
;plot,aryf(1,*),aryf(5,*),title="anode 11"
;plot,aryf(1,*),aryf(6,*),title="anode 12"
;plot,aryf(1,*),aryf(8,*),title="steering"
;plot,aryf(1,*),aryf(9,*),title="cathode"
; device,/close
end
 
    
