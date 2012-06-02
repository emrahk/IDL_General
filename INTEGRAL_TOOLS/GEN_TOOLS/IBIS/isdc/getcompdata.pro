pro getcompdata,mdir=mdir,datacomp,time,tottime

;this program obtains comp data from the raw data for the given dir.
;gainn is the coef gain file number, default is 13. I will use osim,
; not the final rise time correction for now, will be fixed later.

if (NOT keyword_set(mdir)) THEN begin
  print,'You need to set a mdir=/xxxx/*0.00x/ inside REP/scw'
  exit
endif

;corrected ibis
;first find all the files, and write them into a file
 
dir='/raid/data/integral/REP/scw'

openw,1,'findallcor.csh'
printf,1,'#!/bin/csh'
;printf,1,'set mdir = "'+dir_raw+'/002[4-5]/*0.001/"'
printf,1,'set mdir = "'+dir+mdir+'"'
printf,1,'set files = `find ${mdir} -name "compton_cor_events.fits.gz" -print`'
printf,1,'echo $files > cor_files.txt'
close,1

spawn, 'chmod u+x findallcor.csh'
spawn, './findallcor.csh'

;now read those files

allf=strarr(1)
openr,1,'cor_files.txt'
readf,1,allf
close,1

;now find individual files
tot_length=strlen(allf(0))+1  ;one to include white space
s=strpos(allf(0),' ')+1 
if s eq 0 then num_files=1 else num_files=tot_length/s
cor_files=strarr(num_files)
for i=0,num_files-1 do cor_files[i]=strmid(allf(0),i*s,s-1)
if s eq 0 then cor_files[0]=allf(0)

;same with the raw data to get detectors and positions

openw,1,'findallraw.csh'
printf,1,'#!/bin/csh'
;printf,1,'set mdir = "'+dir_raw+'/002[4-5]/*0.001/"'
printf,1,'set mdir = "'+dir+mdir+'"'
printf,1,'set files = `find ${mdir} -name "compton_raw_events.fits.gz" -print`'
printf,1,'echo $files > raw_files.txt'
close,1

spawn, 'chmod u+x findallraw.csh'
spawn, './findallraw.csh'

;now read those files

allf=strarr(1)
openr,1,'raw_files.txt'
readf,1,allf
close,1

;now find individual files
tot_length=strlen(allf(0))+1  ;one to include white space
s=strpos(allf(0),' ')+1 
if s eq 0 then num_files=1 else num_files=tot_length/s
raw_files=strarr(num_files)
for i=0,num_files-1 do raw_files[i]=strmid(allf(0),i*s,s-1)
if s eq 0 then raw_files[0]=allf(0)

;same with the prp data to get time

openw,1,'findallprp.csh'
printf,1,'#!/bin/csh'
;printf,1,'set mdir = "'+dir_raw+'/002[4-5]/*0.001/"'
printf,1,'set mdir = "'+dir+mdir+'"'
printf,1,'set files = `find ${mdir} -name "compton_prp_events.fits.gz" -print`'
printf,1,'echo $files > prp_files.txt'
close,1

spawn, 'chmod u+x findallprp.csh'
spawn, './findallprp.csh'

;now read those files

allf=strarr(1)
openr,1,'prp_files.txt'
readf,1,allf
close,1

;now find individual files
tot_length=strlen(allf(0))+1  ;one to include white space
s=strpos(allf(0),' ')+1 
if s eq 0 then num_files=1 else num_files=tot_length/s
prp_files=strarr(num_files)
for i=0,num_files-1 do prp_files[i]=strmid(allf(0),i*s,s-1)
if s eq 0 then prp_files[0]=allf(0)

datacomp=create_struct('dete',intarr(2),'en',fltarr(2),'pos',fltarr(2,2),'ang',0.,'time',0.d,'flag','')  

time=fltarr(num_files)
tottime=0.

for j=0,num_files-1 do begin
;for j=0,0 do begin
   print,j    

;first we have to check whether the extension exists,
;remember, this is for multiples

  spawn,'fstruct '+cor_files[j]+' colinfo=N type=1 |'+$
      ' grep "BINTABLE COMP-SGLE-COR"',res


  if strlen(res) gt 0 then begin
    isgrpha=loadcol(cor_files[j],'ISGRI_ENERGY',ext=1)
    picspha=loadcol(cor_files[j],'PICSIT_ENERGY',ext=1)
    isgry=loadcol(raw_files[j],'ISGRI_Y',ext=2)
    isgrz=loadcol(raw_files[j],'ISGRI_Z',ext=2)
    picsity=loadcol(raw_files[j],'PICSIT_Y',ext=2)
    picsitz=loadcol(raw_files[j],'PICSIT_Z',ext=2)
    obtimes=loadcol(prp_files[j],'OB_TIME',ext=1)    
;create temporary structures
    datact1=create_struct('dete',intarr(2),'en',fltarr(2),'pos',fltarr(2,2),'ang',0.,'time',0.d,'flag','')  
    nel=n_elements(isgrpha)
    datact=replicate(datact1,nel) 

;arrange detectors like mgeant
    dete=intarr(2,nel)
;isgr 
    dete(0,where((isgry lt 64) and (isgrz ge 96)))=0
    dete(0,where((isgry lt 64) and ((isgrz lt 96) and (isgrz ge 64))))=1
    dete(0,where((isgry lt 64) and ((isgrz lt 64) and (isgrz ge 32))))=2
    dete(0,where((isgry lt 64) and (isgrz lt 32)))=3
    dete(0,where((isgry ge 64) and (isgrz ge 96)))=4
    dete(0,where((isgry ge 64) and ((isgrz lt 96) and (isgrz ge 64))))=5
    dete(0,where((isgry ge 64) and ((isgrz lt 64) and (isgrz ge 32))))=6
    dete(0,where((isgry ge 64) and (isgrz lt 32)))=7
;picsit
    dete(1,where((picsity lt 32) and (picsitz ge 48)))=8
    dete(1,where((picsity lt 32) and ((picsitz lt 48) and (isgrz ge 32))))=9
    dete(1,where((picsity lt 32) and ((picsitz lt 32) and (isgrz ge 16))))=10
    dete(1,where((picsity lt 32) and (picsitz lt 16)))=11
    dete(1,where((picsity ge 32) and (picsitz ge 48)))=12
    dete(1,where((picsity ge 32) and ((picsitz lt 48) and (isgrz ge 32))))=13
    dete(1,where((picsity ge 32) and ((picsitz lt 32) and (isgrz ge 16))))=14
    dete(1,where((picsity ge 32) and (picsitz lt 16)))=15

;positions
    xlis=30.36/64.
    ylis=15.64/32.
    xlpic=30.36/32.
    ylpic=15.64/16.
    posis=fltarr(nel,2)
    pospic=fltarr(nel,2)
    posis(*,0)=(isgry*xlis)+(xlis/2.)-30.36
    posis(*,1)=(isgrz*ylis)+(ylis/2.)-31.28
    pospic(*,0)=(picsity*xlpic)+(xlpic/2.)-30.36
    pospic(*,1)=(picsitz*ylpic)+(ylpic/2.)-31.28


endif

nel=n_elements(isgrpha)
   for i=0L,nel-1L do begin
      

      if (isgrpha[i] lt picspha[i]) then begin
         datact[i].en=[isgrpha[i],picspha[i]]
         datact[i].dete=dete(*,i)
         datact[i].pos=[posis[i,*],pospic[i,*]]
         datact[i].flag='isg_pic'
         x=(pospic[i,0]-posis[i,0])
         y=(pospic[i,1]-posis[i,1])
         if x eq 0 then x=x+1e-8
         ang=atan(y/x)*180./!PI
         if ((x lt 0) and (y ge 0)) then ang=180+ang
         if ((x le 0) and (y lt 0)) then ang=180+ang
         if ((x ge 0) and (y lt 0)) then ang=360+ang
         datact[i].ang=ang 
    endif else begin
         datact[i].en=[picspha[i],isgrpha[i]]
         datact[i].dete=reverse(dete(*,i))
         datact[i].pos=[pospic[i,*],posis[i,*]]
         datact[i].flag='pic_isg'
         x=(posis[i,0]-pospic[i,0])
         y=(posis[i,1]-pospic[i,1])
         if x eq 0 then x=x+1e-8
         ang=atan(y/x)*180./!PI
         if ((x lt 0) and (y ge 0)) then ang=180+ang
         if ((x le 0) and (y lt 0)) then ang=180+ang
         if ((x ge 0) and (y lt 0)) then ang=360+ang
         datact[i].ang=ang
     endelse

     datact[i].time=timeconvf(obtimes(*,i))
  
   endfor

time[j] = max(datact.time)-min(datact.time)
tottime=tottime+time[j]
datacomp=[datacomp,datact]

endfor

datacomp=datacomp[1:n_elements(datacomp)-1L]

end
