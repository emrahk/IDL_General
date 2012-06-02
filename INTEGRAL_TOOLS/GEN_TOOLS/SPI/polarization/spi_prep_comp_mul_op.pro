pro spi_prep_comp_mul,en,dete1,dete2,mult,sct1,delt,sct2,dest,pos,ipart,datamul

;This program reads variables, and prepares a nicely organized
;structure "data" to hold information variables, to spped up this
;version on ly works on multiples

;data structure for multiple events
data1=create_struct('dete',intarr(2),'en',fltarr(2),'pos',fltarr(2,2),'ang',0.,'flag','comp','dir','true')
;data structure for single events
;data2=create_struct('dete',0,'en',0.,'pos',fltarr(2),'flag','SPI')

;Singles
;xx=where((mult eq 1) and (dete1 lt 19))
;num=n_elements(xx)
;datasin=replicate(data2,num)
;datasin.dete=dete1(xx)
;datasin.en=en(xx)
;for i=0L,long(num)-1L do begin
  ;convert detector coordiates into general coordinates
;  det_defmg,dete1(xx(i)),0,pos(xx(i),*),pos(xx(i),*),rpos1,rpos2,anx
;  datasin[i].pos=rpos1
;endfor

;Multiples
xx=where(mult eq 2)  ; Only choose multiples
num=n_elements(xx)/2
;first spend some time to optimize thhe process. 
;do things in smaller chunks
if num gt 10000L then begin
    chunksize=10000L
    numchunk=floor(num/chunksize)+1
    

;this is fucked up

datamul=replicate(data1,num)
;some cleaning
sct1xx=sct1(xx)
dete1xx=dete1(xx)
dete2xx=dete2(xx)
deltxx=delt(xx)
enxx=en(xx)

print,'number of multiples= ',num

for i=0L,long(num)-1L do begin
;for i=0L,10 do begin

if ((i mod 100) eq 0) then print,i

  ind1=2*i
  ind2=2*i+1

  ;connection between psd data and regular data
  yy=where(sct2 eq sct1xx(ind1))
  dety1=where(dete2(yy) eq dete1xx(ind1))
  dety2=where(dete2(yy) eq dete1xx(ind2))
  iprt=ipart(yy)  

  if (deltxx[ind1] lt deltxx[ind2]) then begin
    ;check if there is more than one scattering in the first detector
    if (n_elements(where(iprt(dety1) eq 1)) gt 1) then datamul[i].flag='msfd'
    datamul[i].dete=[dete1xx[ind1],dete1xx[ind2]]
    datamul[i].en=[enxx[ind1],enxx[ind2]]
    det_defmg,dete1xx[ind1],dete1xx[ind2],$
             pos[yy[dety1[0]],*],pos[yy[dety2[0]],*],pos1,pos2,ang
    datamul[i].pos=[pos1,pos2]
    datamul[i].ang=ang  
    ;check the direction
    if datamul[i].en[0] ge datamul[i].en[1] then datamul[i].dir='false'
  endif else begin 
    if (n_elements(where(iprt(dety2) eq 1)) gt 1) then datamul[i].flag='msfd'
    ;replace indices to have the correct direction
    temp = ind1
    ind1=ind2
    ind2=temp
    datamul[i].dete=[dete1xx[ind1],dete1xx[ind2]]
    datamul[i].en=[enxx[ind1],enxx[ind2]]
    det_defmg,dete1xx[ind1],dete1xx[ind2],$
              pos[yy[dety1[0]],*],pos[yy[dety2[0]],*],pos1,pos2,ang
    datamul[i].pos=[pos1,pos2]
    datamul[i].ang=ang  
    if datamul[i].en[0] ge datamul[i].en[1] then datamul[i].dir='false'
  endelse

endfor
end
