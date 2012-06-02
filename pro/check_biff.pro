;first fft first 50
; modifying for idf2_

t=findgen(28672.)/1024.
offset0=2l*1024l
p=fltarr(28672,4)
p_tot=fltarr(14336,4)
p_t=fltarr(14336,4)
tot_idfs=0
for q=4,7 do begin
 fname=strcompress('biff'+string(q)+'.dat',/remove_all)
 ;sname=strcompress('ffted'+string(q)+'.dat',/remove_all)
 t_cts=lonarr(4)
 t_cts=[0l,0l,0l,0l]
 restore,fname
 case q of
   1:coctsn=coctsn1
   2:coctsn=coctsn2
   3:coctsn=coctsn3
   4:coctsn=coctsn4
   5:coctsn=coctsn5
   6:coctsn=coctsn6
   7:coctsn=coctsn7
   8:coctsn=coctsn8
   9:coctsn=coctsn9
   10:coctsn=coctsn10
   11:coctsn=coctsn11
   12:coctsn=coctsn12
   13:coctsn=coctsn13
   14:coctsn=coctsn14
   15:coctsn=coctsn15
   16:coctsn=coctsn16
   17:coctsn=coctsn17
  endcase
  sz=size(coctsn)
  idfs=(sz(1)/(32l*1024l))-1
  ;print,q,idfs+1,sname
  dum=0l
  tot_cts=lonarr(idfs+1,4)
  for i=0,14335 do for j=0,3 do p_tot(i,j)=0
  for i=0,idfs do for j=0,3 do tot_cts(i,j)=0
  for j=0,3 do begin
    for i=0,idfs do begin
        offset=offset0+i*(32l*1024l)
        plot,coctsn(offset:offset+28l*1024l-1,j)
        for s=0l,200000l do dum=dum+1
        ;fft_f,t,coctsn(offset:offset+28l*1024l-1,j),f,p,frange=[0.02,512]
        ;for k=0,14335 do p_tot(k,j)=p_tot(k,j)+(p(k)/(idfs+1))
        ;for k=0,14335 do p_t(k,j)=p_t(k,j)+p(k)
        ;tot_cts(i,j)=total(coctsn(offset:offset+28671l,j))
        ;t_cts(j)=t_cts(j)+total(coctsn(offset:offset+28671l,j))
        ;print,offset
    endfor
  endfor
;tot_idfs=tot_idfs+idfs+1
;print,tot_idfs
;save,f,p_tot,tot_cts,filename=sname
;if q EQ 7 then delvar,coctsn1,coctsn2,coctsn3,coctsn4,coctsn5,coctsn6,coctsn7
endfor
end
