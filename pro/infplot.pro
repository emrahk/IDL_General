pro infplot,i,num,levels,fn
print,'this program will plot the file #',i,' as contour plot with ',levels,$
' levels, also saves as idl.ps'
arr=fltarr(num,num)
str=string(40)
readf,i,str
readf,i,arr
close,i
contour,arr,nlevels=levels,/follow
if num ne 159 then begin
var=(num-159)/2.
oplot,[var,var],[var,num+1-var],line=1
oplot,[var,num+1-var],[var,var],line=1
oplot,[num+1-var,num+1-var],[var,num+1-var],line=1
oplot,[var,num+1-var],[num+1-var,num+1-var],line=1
endif
xyouts,30,num-10,str
set_plot,'ps'
device,filename=fn
contour,arr,nlevels=levels
if num ne 159 then begin
var=(num-159)/2.
oplot,[var,var],[var,num+1-var],line=1
oplot,[var,num+1-var],[var,var],line=1
oplot,[num+1-var,num+1-var],[var,num+1-var],line=1
oplot,[var,num+1-var],[num+1-var,num+1-var],line=1
endif
xyouts,30,num-10,str
device,/close
set_plot,'x'
end
