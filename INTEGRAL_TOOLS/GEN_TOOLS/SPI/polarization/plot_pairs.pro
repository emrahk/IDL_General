pro plot_pairs, dataml,histo,histang

nel=n_elements(where((dataml.en[0] ge 20) and (dataml.en[1] ge 20)))
print,nel
histo=lonarr(84)
;histang=lonarr(6)

st=5.196153

coord=[[0.,0.],[6.,0.],[3.,st],[-3.,st],$
       [-6.,0.],[-3.,-st],[3.,-st],[9.,-st],$
       [12.,0.],[9.,st],[6.,2.*st],[0.,2.*st],[-6.,2.*st],$
       [-9.,st],[-12.,0.],[-9.,-st],[-6.,-2.*st],$
       [0.,-2.*st],[6.,-2.*st]]


anga=0.

for i=0L,long(nel)-1L do begin
  j=psdetnum(dataml[i].dete[0],dataml[i].dete[1])-19
  if j ge 0 then begin 
  if (dataml[i].dete[0] gt dataml[i].dete[1]) then j=j+42
  histo(j)=histo(j)+1

  x=coord(0,dataml[i].dete[1])-coord(0,dataml[i].dete[0])
  y=coord(1,dataml[i].dete[1])-coord(1,dataml[i].dete[0])
  if x eq 0 then x=x+1e-8
  ang=atan(y/x)*180./!PI
  angx=ang
  if ((x lt 0) and (y ge 0)) then angx=180+ang
  if ((x le 0) and (y lt 0)) then angx=180+ang
  ;if ((x eq 0) and (y lt 0)) then angx=+ang
  if ((x ge 0) and (y lt 0)) then angx=360+ang
  anga=[anga,angx]
  endif
endfor

anga=anga(1L:n_elements(anga)-1L)
histang=histogram(anga,min=0,binsize=60) 

end
