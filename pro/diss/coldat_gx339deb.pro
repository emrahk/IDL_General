pro coldat_gx339deb,ind,eb,fpeak,qpo,rmsiz,rmstz,trmsi,trmst

root1='/raid1/ekalemci/DATA239/gx339/'

root2=['P01.01/an/','P01.02/an/','P01.03/an/','P01.04/an/',$
'P02.01/an/','P02.02/an/']

base3_1=['twolor_e1n.dat','threelor_e1n.dat','threelor_e1n.dat',$
'threelor_e1n.dat','threelor_e1n.dat','threelor_e1n.dat']

base3_2=['twolor_e2n.dat','threelor_e2n.dat','threelor_e2n.dat',$
'threelor_e2n.dat','threelor_e2n.dat','threelor_e2n.dat']


base3_3=['twolor_e2n.dat','threelor_e2n.dat','threelor_e3n.dat',$
'threelor_e3n.dat','threelor_e3n.dat','threelor_e3n.dat']


if eb eq 1 then files=root1+root2+base3_1
if eb eq 2 then files=root1+root2+base3_2
if eb eq 3 then files=root1+root2+base3_3

restore,files[ind]

num=n_elements(res)
ele=num/3

rmstoti=0.
rmstott=0.
errix=0.
errtx=0.


q=1
l=1

fpeak=fltarr(2,3)
rmsiz=fltarr(2,3)
rmstz=fltarr(2,3)
qpo=fltarr(2,3)

for j=0,ele-1 do begin
  a=res(j*3:j*3+2)
  er=sig(j*3:j*3+2)
  rmsix=rmsi(j*2)
  rmsix_er=rmsi(j*2+1)
  rmstx=rmst(j*2)
  rmstx_er=rmst(j*2+1)
  rmstoti=rmstoti+rmsix^2
  rmstott=rmstott+rmstx^2
  errix=errix+(rmsix+rmsix_er)^2
  errtx=errtx+(rmstx+rmstx_er)^2
  if a(2)/a(1) ge 1.5 then begin
;     print,'QPO #',q
;     print,'Freq. :',a(2),er(2)
;     print,'FWHM :',a(1),er(1) 
;     print,'RMS 0 inf :',rmsix*100.,rmsix_er*100.
     q=q+1
     qpo[0,0]=a[2]
     qpo[1,0]=er[2]
     qpo[0,1]=a[1]
     qpo[1,1]=er[1]
     qpo[0,2]=rmsix*100.
     qpo[1,2]=rmsix_er*100.
  endif else begin
     peak,a(2),er(2),a(1),er(1),fp,fper
     fpeak[0,l-1]=fp
     fpeak[1,l-1]=fper
     rmsiz[0,l-1]=rmsix
     rmsiz[1,l-1]=rmsix_er
     rmstz[0,l-1]=rmstx
     rmstz[1,l-1]=rmstx_er  
 ;    print,'lor #:',l
;     print,'Peak f :',fp,fper
;     print,'rms 0 inf :',rmsix*100.,rmsix_er*100.
;     print,'rms 0 20 :',rmstx*100.,rmstx_er*100.
     l=l+1
  endelse
endfor

trmsi=[sqrt(rmstoti),sqrt(errix)-sqrt(rmstoti)]
trmst=[sqrt(rmstott),sqrt(errtx)-sqrt(rmstott)] 
  
;print,'Total rms, 0 inf :',trmsi[0],trmsi[1]
;print,'Total rms, 0 20 :',trmst[0],trmst[1]

trmsi=[sqrt(rmstoti),sqrt(errix)-sqrt(rmstoti)]
trmst=[sqrt(rmstott),sqrt(errtx)-sqrt(rmstott)]
end
