pro coldat_1550o01,ind,fpeak,qpo,rmsiz,rmstz,trmsi,trmst,fit_res


base1='/home/emrahk/DATA_AN/1550/2001_out/'

base2=['P08.0x/an/','P10.00/an/','P13.0x/an/','P16.00/an/',$
'P19.0x/an/','P23.00/an/','P25.0x/an/','P26.00/an/',$
'P27.00/an/','P28.00/an/']

base3_all=['threelor_alln.dat','threelor_alln.dat','threelor_alln.dat',$
'threelor_alln.dat','threelor_alln.dat','threelor_alln.dat',$
'threelor_alln.dat','threelor_alln.dat','threelor_alln.dat',$
'threelor_alln.dat']

files=base1+base2+base3_all

restore,files[ind]

num=n_elements(res)
ele=num/3

fres=fltarr(2,num)
fres(0,*)=res
fres(1,*)=sig
fit_res=fres

rmstoti=0.
rmstott=0.
errix=0.
errtx=0.


q=1
l=1

fpeak=fltarr(2,3)
rmsiz=fltarr(2,3)
rmstz=fltarr(2,3)
qpo=fltarr(2,6)

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
  if a(2)/a(1) ge 2. then begin
;     print,'QPO #',q
;     print,'Freq. :',a(2),er(2)
;     print,'FWHM :',a(1),er(1) 
;     print,'RMS 0 inf :',rmsix*100.,rmsix_er*100.
     qpo[0,(q-1)*3]=a[2]
     qpo[1,(q-1)*3]=er[2]
     qpo[0,((q-1)*3)+1]=a[1]
     qpo[1,((q-1)*3)+1]=er[1]
     qpo[0,((q-1)*3)+2]=rmsix*100.
     qpo[1,((q-1)*3)+2]=rmsix_er*100.
     q=q+1
  endif else begin
     peak,a(2),er(2),a(1),er(1),fp,fper
     fpeak[0,l-1]=fp
     fpeak[1,l-1]=fper
     rmsiz[0,l-1]=rmsix
     rmsiz[1,l-1]=rmsix_er
     rmstz[0,l-1]=rmstx
     rmstz[1,l-1]=rmstx_er  
;     print,'lor #:',l
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
