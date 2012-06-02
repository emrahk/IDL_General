pro cleanupmatrixn,data,newdata,hkdata,newhkdata,tracer,newtracer,$
    hktracer,newhktracer,matrix=matrix

np=n_elements(hkdata)
selp=intarr(np-n_elements(matrix))

j=0
k=0
for i=0,np-1 do begin
  if i ne matrix[k] then begin
    selp[j]=i
    j=j+1
  endif else if k ne n_elements(matrix)-1 then k=k+1
endfor
print,selp

if selp[0] eq 0 then begin
   ranget=[0L,long(hktracer[0].nel)-1L]
   ranged=[0L,long(hkdata[0].nel)-1L]
endif else begin
   ranget=[long(total(hktracer[0:selp[0]-1].nel)),$
            long(total(hktracer[0:selp[0]].nel))-1L]
   ranged=[long(total(hkdata[0:selp[0]-1].nel)),$
            long(total(hkdata[0:selp[0]].nel))-1L]
endelse
    newdata=data[ranged[0]:ranged[1]]
    newtracer=tracer[ranget[0]:ranget[1]]
    newhkdata=hkdata[selp[0]]
    newhktracer=hktracer[selp[0]]

print,selp(0),ranget,ranged

for i=1,n_elements(selp)-1 do begin
    ranget=[long(total(hktracer[0:selp[i]-1].nel)),$
            long(total(hktracer[0:selp[i]].nel))-1L]
    ranged=[long(total(hkdata[0:selp[i]-1].nel)),$
            long(total(hkdata[0:selp[i]].nel))-1L]

    print,selp(i),ranget,ranged

    newdata=[newdata,data[ranged[0]:ranged[1]]]
    newtracer=[newtracer,tracer[ranget[0]:ranget[1]]]
    newhkdata=[newhkdata,hkdata[selp[i]]]
    newhktracer=[newhktracer,hktracer[selp[i]]]
endfor

end
