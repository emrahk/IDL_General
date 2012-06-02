pro module,fname,dp
;set_plot,'ps'
z=replicate(' ',6)
plot,[0,50],/nodata,xtickname=z,ytickname=z,ticklen=0,xrange=[0,100]$
     ,yrange=[0,100],title='trajectory'
;obox,0,0,100,100
boxc,0,1,5,0,100
obox,20,0,30,1
boxc,45,0,55,1,100
obox,70,0,80,1
boxc,95,0,100,1,100
rddata,fname,11,aryf,nskip=3
aryi=intarr(2,dp)
for i=0,dp-1 do begin
   aryi(0,i)=floor(aryf(0,i)/2+0.5)
   aryi(1,i)=floor(aryf(2,i)+0.5)-605
endfor

for i=0,dp-2 do oplot,[aryi(1,i),aryi(1,i+1)],[aryi(0,i),aryi(0,i+1)],line=0

;device,/close
end
