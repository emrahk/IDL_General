pro prep_comp,en,dete1,dete2,mult,sct1,delt,sct2,dest,pos,datamul,datasin

;This program reads variables, and prepares a nicely organized
;structure "data" to hold information variables

data1=create_struct('dete',intarr(2),'en',fltarr(2),'pos',fltarr(2,2),'ang',0.,'flag','')
data2=create_struct('dete',0,'en',0.,'pos',fltarr(2),'flag','')

;Singles
xx=where((mult eq 1) and (dete1 lt 16))
num=n_elements(xx)
datasin=replicate(data2,num)
datasin.dete=dete1(xx)
datasin.en=en(xx)
datasin[where(datasin.dete lt 8)].flag='isgr'
datasin[where(datasin.dete ge 8)].flag='picsit'
for i=0L,long(num)-1L do begin
  cal_posan,dete1(xx(i)),0,pos(xx(i),*),pos(xx(i),*),rpos1,rpos2,anx
  datasin[i].pos=rpos1
endfor

;Multiples
xx=where(mult eq 2)  ; Only choose multiples
num=n_elements(xx)/2
datamul=replicate(data1,num)

for i=0L,long(num)-1L do begin

  ind1=2*i
  ind2=2*i+1

  yy=where(sct2 eq sct1(xx(ind1)))
  dety1=where(dete2(yy) eq dete1(xx(ind1)))
  dety2=where(dete2(yy) eq dete1(xx(ind2)))
  
  datamul[i].flag='comp'
  if ((dete1(xx(ind1)) lt 8) and (dete1(xx(ind2)) lt 8)) then datamul[i].flag='is_is'
  if ((dete1(xx(ind1)) ge 8) and (dete1(xx(ind2)) ge 8)) then datamul[i].flag='pic_pic'

  if delt(xx[ind1]) lt delt(xx[ind2]) then begin
    datamul[i].dete=[dete1[xx[ind1]],dete1[xx[ind2]]]
    datamul[i].en=[en[xx[ind1]],en[xx[ind2]]]
    cal_posan,dete1[xx[ind1]],dete1[xx[ind2]],$
             pos[yy[dety1[0]],*],pos[yy[dety2[0]],*],pos1,pos2,ang
    datamul[i].pos=[pos1,pos2]
    datamul[i].ang=ang  
  endif else begin
    temp=ind1
    ind1=ind2
    ind2=temp
    datamul[i].dete=[dete1[xx[ind1]],dete1[xx[ind2]]]
    datamul[i].en=[en[xx[ind1]],en[xx[ind2]]]
    cal_posan,dete1[xx[ind1]],dete1[xx[ind2]],$
              pos[yy[dety1[0]],*],pos[yy[dety2[0]],*],pos1,pos2,ang
    datamul[i].pos=[pos1,pos2]
    datamul[i].ang=ang  
  endelse

endfor
end
