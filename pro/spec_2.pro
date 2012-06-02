pro spec_2,en,x,z,num

fname=strcompress('se'+string(en)+'x'+string(x)+'z'+string(z),/remove_all)
rddata,fname+'h.dat',11,aryh,nskip=3
rddata,fname+'e.dat',11,arye,nskip=3
rddata,fname+'t.dat',9,aryt,nskip=3
; set_plot,'ps'

!P.MULTI=[0,2,2]
for i=1,200-z do aryh(1,i)=aryh(1,i-1)+aryh(1,i)
for i=1,z do arye(1,i)=arye(1,i-1)+arye(1,i)

;print,aryh(10,*)
;for i=1,200-z do print,aryh(1,i),aryh(10,i)
in=where(arye(1,*) GT 0)
plot_oi,arye(1,in),arye(num,in),/xstyle,xrange=[arye(1,1),arye(1,z)*2]$
       ,title="electron signal"
in=where(aryh(1,*) GT 0)
plot_oi,aryh(1,in),aryh(num,in),/xstyle,xrange=[aryh(1,1),aryh(1,200-z)*2]$
       ,title="hole signal"
plot_oi,aryt(1,*),aryt(num-1,*),/xstyle,xrange=[aryt(1,1),aryh(1,200-z)*2],$
        title='total signal'
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
 
    
