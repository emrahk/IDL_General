;pro tombala

;s=1077L

nums=intarr(15)
!p.multi=[0,1,2]

cont=bytarr(100)


i=0
for j=0,99 do cont(j)=0
plot,[0,0],[0,0],xrange=[0,100],yrange=[0,30],posit=[0.08,0.03,0.95,0.50],$
xticklen=0.0001,xtickname=replicate(' ',50),yticklen=0.0001,$
ytickname=replicate(' ',50)
oplot,[10,10],[0,30],line=0
oplot,[20,20],[0,30],line=0
oplot,[30,30],[0,30],line=0
oplot,[40,40],[0,30],line=0
oplot,[50,50],[0,30],line=0
oplot,[60,60],[0,30],line=0
oplot,[70,70],[0,30],line=0
oplot,[80,80],[0,30],line=0
oplot,[90,90],[0,30],line=0
oplot,[0,100],[10,10],line=0
oplot,[0,100],[20,20],line=0

nums(0)=floor(randomu(s,1)*100+0.5)
cont(nums(0))=1

for j=1,14 do begin    
   ctr=1
   while (ctr eq 1) do begin
      nums(j)=floor(randomu(s,1)*100+0.5)
      if cont(nums(j)) eq 0 then ctr=0
   endwhile
   cont(nums(j))=1
endfor
for j=0,99 do cont(j)=0





xyouts,1,14,'E.K.',size=2.0
xyouts,91,27,'iYi',size=1.5
xyouts,90,23,'YILLAR',size=1.3

xyouts,1,4,strcompress(nums(i+0)),size=2.0
xyouts,20,4,strcompress(nums(i+1)),size=2.0
xyouts,40,4,strcompress(nums(i+2)),size=2.0
xyouts,60,4,strcompress(nums(i+3)),size=2.0
xyouts,80,4,strcompress(nums(i+4)),size=2.0
xyouts,10,14,strcompress(nums(i+5)),size=2.0
xyouts,30,14,strcompress(nums(i+6)),size=2.0
xyouts,50,14,strcompress(nums(i+7)),size=2.0
xyouts,70,14,strcompress(nums(i+8)),size=2.0
xyouts,90,14,strcompress(nums(i+9)),size=2.0
xyouts,0,24,strcompress(nums(i+10)),size=2.0
xyouts,20,24,strcompress(nums(i+11)),size=2.0
xyouts,40,24,strcompress(nums(i+12)),size=2.0
xyouts,60,24,strcompress(nums(i+13)),size=2.0
xyouts,80,24,strcompress(nums(i+14)),size=2.0    

i=0
plot,[0,0],[0,0],xrange=[0,100],yrange=[0,30],posit=[0.08,0.51,0.95,1.10],$
xticklen=0.0001,xtickname=replicate(' ',50),yticklen=0.0001,$
ytickname=replicate(' ',50)

oplot,[10,10],[0,30],line=0
oplot,[20,20],[0,30],line=0
oplot,[30,30],[0,30],line=0
oplot,[40,40],[0,30],line=0
oplot,[50,50],[0,30],line=0
oplot,[60,60],[0,30],line=0
oplot,[70,70],[0,30],line=0
oplot,[80,80],[0,30],line=0
oplot,[90,90],[0,30],line=0
oplot,[0,100],[10,10],line=0
oplot,[0,100],[20,20],line=0

nums(0)=floor(randomu(s,1)*100+0.5)
cont(nums(0))=1

for j=1,14 do begin    
   ctr=1
   while (ctr eq 1) do begin
      nums(j)=floor(randomu(s,1)*100+0.5)
      if cont(nums(j)) eq 0 then ctr=0
   endwhile
   cont(nums(j))=1
endfor

xyouts,1,14,'E.K.',size=2.0
xyouts,91,27,'iYi',size=1.5
xyouts,90,23,'YILLAR',size=1.3




xyouts,1,4,strcompress(nums(i+0)),size=2.0
xyouts,21,4,strcompress(nums(i+1)),size=2.0
xyouts,41,4,strcompress(nums(i+2)),size=2.0
xyouts,61,5,strcompress(nums(i+3)),size=2.0
xyouts,81,4,strcompress(nums(i+4)),size=2.0
xyouts,11,14,strcompress(nums(i+5)),size=2.0
xyouts,31,14,strcompress(nums(i+6)),size=2.0
xyouts,51,14,strcompress(nums(i+7)),size=2.0
xyouts,71,14,strcompress(nums(i+8)),size=2.0
xyouts,91,14,strcompress(nums(i+9)),size=2.0
xyouts,1,24,strcompress(nums(i+10)),size=2.0
xyouts,21,24,strcompress(nums(i+11)),size=2.0
xyouts,41,24,strcompress(nums(i+12)),size=2.0
xyouts,61,24,strcompress(nums(i+13)),size=2.0
xyouts,81,24,strcompress(nums(i+14)),size=2.0    

end
