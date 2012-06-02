

restore,'/boris/ek/bckg/pk0528_03_01_00_c229.dat'
tncs=(idfr(1)-idfr(0)+1)*16l*1024l
cont=size(cts)
if cont(4) NE tncs then begin
   print,'warning, size does not match'
   tncs=cont(4)
endif

cocts=lonarr(tncs,4)
for j=0,3 do begin
    for i=0l,tncs-1 do cocts(i,j)=total(cts(*,j,0,i))
endfor
coctsn=cocts
for i=230,246 do begin
filen=strcompress('/boris/ek/bckg/pk0528_03_01_00_c'+string(i)+'.dat',$
/remove_all)
restore,filen
print,i,idfr
tncs=(idfr(1)-idfr(0)+1)*16l*1024l
cont=size(cts)
if cont(4) NE tncs then begin
   print,'warning, size does not match'
   tncs=cont(4)
endif
cocts_sub=lonarr(tncs,4)
for j=0,3 do begin
    for k=0l,tncs-1 do cocts_sub(k,j)=total(cts(*,j,0,k))
endfor
coctsn=[coctsn,cocts_sub]
;plot,cocts(*,0)
endfor

end
