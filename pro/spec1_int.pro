pro spec1_int
rddata,'/home/ek/r2.dat',10,aryf,nskip=3
print,aryf(4,*)
; set_plot,'ps'
!P.MULTI=[0,2,3]
for i=1,88 do aryf(1,i)=aryf(1,i-1)+aryf(1,i)
; integrate
for i=1,88 do aryf(3,i)=aryf(3,i-1)+aryf(3,i)
for i=1,88 do aryf(4,i)=aryf(4,i-1)+aryf(4,i)
for i=1,88 do aryf(5,i)=aryf(5,i-1)+aryf(5,i)
for i=1,88 do aryf(6,i)=aryf(6,i-1)+aryf(6,i)
for i=1,88 do aryf(8,i)=aryf(8,i-1)+aryf(8,i)
for i=1,88 do aryf(9,i)=aryf(9,i-1)+aryf(9,i)
plot,aryf(1,*),aryf(3,*),title="anode 9"
plot,aryf(1,*),aryf(4,*),title="anode 10"
plot,aryf(1,*),aryf(5,*),title="anode 11"
plot,aryf(1,*),aryf(6,*),title="anode 12"
plot,aryf(1,*),aryf(8,*),title="steering"
plot,aryf(1,*),aryf(9,*),title="cathode"
; device,/close
set_plot,'x'
end
 
    
