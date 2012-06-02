;pro sacmalik

lon=findgen(900)
lat=findgen(1800)
k=0l
x=fltarr(1800l*900l)
for i=0l,1799l do for j=0l,899l do begin
    x(k)=abs(sin(lon(j)*!pi/180.)*cos(lat(i)*!pi/180.))
    k=k+1
endfor
end
