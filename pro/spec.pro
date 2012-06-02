pro spec,en,x,z,num

fname=strcompress('se'+string(en)+'x'+string(x)+'z'+string(z),/remove_all)
rddata,fname+'h.dat',11,aryh,nskip=3
rddata,fname+'e.dat',11,arye,nskip=3
; set_plot,'ps'

!P.MULTI=[0,2,2]
for i=1,200-z do aryh(1,i)=aryh(1,i-1)+aryh(1,i)
for i=1,z do arye(1,i)=arye(1,i-1)+arye(1,i)

;interpolate

snew=fltarr(250)
tnew=fltarr(250)
for i=1,z do begin
    t=arye(1,i)
    j=0 
    while (t GT aryh(1,j)) do begin
         ;print,j,t,aryh(1,j)
         j=j+1
    endwhile
    snew(i)=arye(num,i)+aryh(num,j-1)+$
((t-aryh(1,j-1))/(aryh(1,j)-aryh(1,j-1)))*(aryh(num,j)-aryh(num,j-1))
endfor

for i=j+1,200-z do snew(z-j+i)=aryh(num,i)+arye(num,z)
if (num EQ 9) then begin
   for i=j+1,200-z do snew(z-j+i)=aryh(num,i)
endif
for i=j+1,200-z do tnew(z-j+i)=aryh(1,i)
for i=0,z do tnew(i)=arye(1,i)

a=fltarr(z-j+199-z)
b=fltarr(z-j+199-z)
a=tnew(0:z-j+199-z)
b=snew(0:z-j+199-z)
in=where(arye(1,*) GT 0)
plot_oi,arye(1,in),arye(num,in),/xstyle,xrange=[arye(1,1),arye(1,z)*2]$
       ,title="electron signal"
plot_oi,aryh(1,in),aryh(num,in),/xstyle,xrange=[aryh(1,1),aryh(1,200-z)*2]$
       ,title="hole signal"
plot_oi,a,b,/xstyle,xrange=[a(1),a(198-j)],title='total signal'
module,fname+'e.dat',z
omodule,fname+'h.dat',z
if (num LT 8) then xyouts,-35,110,$
   strcompress('E'+string(en)+'x'+string(x)+'z'+string(z)+'#'$
              +string(num-3),/remove_all)
if (num EQ 8) then xyouts,-35,110,$
   strcompress('E'+string(en)+'x'+string(x)+'z'+string(z)+'st',/remove_all)
if (num EQ 9) then xyouts,-35,110,$
   strcompress('E'+string(en)+'x'+string(x)+'z'+string(z)+'ca',/remove_all)

; device,/close
end
 
    
