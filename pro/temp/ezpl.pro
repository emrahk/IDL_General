pro ezpl,i,num,levels
print,'this program will plot the file #',i,' as contour plot with ',levels,$
' levels, also saves as idl.ps'
arr=fltarr(num,num)
readf,i,arr
contour,arr,nlevels=levels
set_plot,'ps'
contour,arr,nlevels=levels
device,/close
set_plot,'x'
end
