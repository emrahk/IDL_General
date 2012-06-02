pro getmehk,mdir=mdir,hk,logfile=logfile,scwlist=scwlist

;this program obtains housekeeping and deadtime information


if ((NOT keyword_set(mdir)) AND (NOT keyword_set(scwlist))) THEN begin
  print,'You need to set a mdir=/xxxx/*0.00x/ inside REP/scw or'
  print,'You need to provide a scwlist in REP/scw'
  stop
endif

if (NOT keyword_set(logfile)) THEN logfile='getmehk.log'

openw,5,logfile
printf,5,'Log file for getmehk'
printf,5,'Get  prepared data for observation times'

;Now the same for prp data for times
;first find all the files, and write them into a file

dir_prp='/home/integral/REP/scw'
if keyword_set(mdir) then begin

  openw,1,'findallprp.csh'
  printf,1,'#!/bin/csh'
  ;printf,1,'set mdir = "'+dir_raw+'/002[4-5]/*0.001/"'
  printf,1,'set mdir = "'+dir_prp+mdir+'"'
  printf,1,'set files = `find ${mdir} -name "spi_prp_oper.fits.gz" -print`'
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
endif else prp_files=dir_prp+scwlist+'/spi/prp/spi_prp_oper.fits.gz'

printf,5,'Performing same steps for scientific housekeeping data'

;Now the same for the housekeeping data for times, if asked for
;first find all the files, and write them into a file

dir_schk=dir_prp

if keyword_set(mdir) then begin

  openw,1,'findallschk.csh'
  printf,1,'#!/bin/csh'
  ;printf,1,'set mdir = "'+dir_raw+'/002[4-5]/*0.001/"'
  printf,1,'set mdir = "'+dir_schk+mdir+'"'
  printf,1,'set files = `find ${mdir} -name "spi_raw_schk.fits.gz" -print`'
  printf,1,'echo $files > schk_files.txt'
 close,1

  spawn, 'chmod u+x findallschk.csh'
  spawn, './findallschk.csh'
  ;now read those files

  allf=strarr(1)
  openr,1,'schk_files.txt'
  readf,1,allf
  close,1

  ;now find individual files
  tot_length=strlen(allf(0))+1  ;one to include white space
  s=strpos(allf(0),' ')+1
  if s eq 0 then num_files=1 else num_files=tot_length/s
  schk_files=strarr(num_files)
  for i=0,num_files-1 do schk_files[i]=strmid(allf(0),i*s,s-1)
  if s eq 0 then schk_files[0]=allf(0)
endif else schk_files=dir_schk+scwlist+'/spi/raw/spi_raw_schk.fits.gz'

num_files=n_elements(schk_files)
;;

;create the data structure
printf,5,'Creating the data structures'

m=0L

;for housekeeping
hk1=create_struct('scwname',' ','obtime',0.d,'avgdt',fltarr(19),'avacsd',0.)
hk=replicate(hk1,num_files)

printf,5,'Reading and preparing data for each science windows'

dead=fltarr(num_files)

for j=0,num_files-1 do begin
;for j=0,0 do begin
   print,'schk_files[j]=',schk_files[j]
   printf,5,'schk_files[j]=',schk_files[j]

   hk[j].scwname=schk_files[j]

;first we have to check whether the extension exists,
;remember, this is for multiples

  spawn,'fstruct '+schk_files[j]+' colinfo=N type=1 |'+$
      ' grep "BINTABLE SPI.-SCHK-HRW"',res

  if strlen(res) gt 0 then begin
   obtimes=loadcol(prp_files[j],'OB_TIME',ext=4)
   siz=size(obtimes)
   time_st=timeconvf(obtimes(*,0))
   time_end=timeconvf(obtimes(*,siz(2)-1L))
   hk[j].obtime=time_end-time_st

   ;ACS Dead Time

   acsd=loadcol(schk_files[j],'P__DF__NVTDT__L',ext=1)
   hk[j].avacsd=avg(float(acsd))/(1.0e7)


   dt0=loadcol(schk_files[j],'P__DF__CAFDT__L0',ext=1)

   dt=fltarr(n_elements(dt0),19)
   dt(*,0)=dt0
  dt(*,1)=loadcol(schk_files[j],'P__DF__CAFDT__L1',ext=1)
   dt(*,2)=loadcol(schk_files[j],'P__DF__CAFDT__L2',ext=1)
   dt(*,3)=loadcol(schk_files[j],'P__DF__CAFDT__L3',ext=1)
   dt(*,4)=loadcol(schk_files[j],'P__DF__CAFDT__L4',ext=1)
   dt(*,5)=loadcol(schk_files[j],'P__DF__CAFDT__L5',ext=1)
   dt(*,6)=loadcol(schk_files[j],'P__DF__CAFDT__L6',ext=1)
   dt(*,7)=loadcol(schk_files[j],'P__DF__CAFDT__L7',ext=1)
   dt(*,8)=loadcol(schk_files[j],'P__DF__CAFDT__L8',ext=1)
   dt(*,9)=loadcol(schk_files[j],'P__DF__CAFDT__L9',ext=1)
   dt(*,10)=loadcol(schk_files[j],'P__DF__CAFDT__L10',ext=1)
   dt(*,11)=loadcol(schk_files[j],'P__DF__CAFDT__L11',ext=1)
   dt(*,12)=loadcol(schk_files[j],'P__DF__CAFDT__L12',ext=1)
   dt(*,13)=loadcol(schk_files[j],'P__DF__CAFDT__L13',ext=1)
   dt(*,14)=loadcol(schk_files[j],'P__DF__CAFDT__L14',ext=1)
   dt(*,15)=loadcol(schk_files[j],'P__DF__CAFDT__L15',ext=1)
   dt(*,16)=loadcol(schk_files[j],'P__DF__CAFDT__L16',ext=1)
   dt(*,17)=loadcol(schk_files[j],'P__DF__CAFDT__L17',ext=1)
   dt(*,18)=loadcol(schk_files[j],'P__DF__CAFDT__L18',ext=1)

   dt=dt/(1.0e7)

   printf,5,'Minimum dt=',min(dt)
   printf,5,'Maximum dt=',max(dt)

   dead[j]=avg(dt)
   if (dead[j] ge 0.14) then begin
     print,'Avg deadtime is greater than 0.14'
     printf,5,'WARNING... The avg. deadtime is greater than 0.14 in this scw:'
     printf,5,schk_files[j]
  endif
 
  if ((max(dt) gt (1.2*dead[j])) OR (min(dt) lt (0.8*dead[j]))) then printf,5,'WARNING, too much variation in the deadtime'

  for dnum=0,18 do hk[j].avgdt[dnum]=avg(dt(*,dnum))

endif else printf,5,schk_files[j]+' does not contain valid science data'
;plot,spx(*,19)
endfor

close,5

end

