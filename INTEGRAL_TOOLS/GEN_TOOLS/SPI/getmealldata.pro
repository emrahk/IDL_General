pro getmealldata,data,spx,hk,scwlist=scwlist,mdir=mdir,gainn=gainn,logfile=logfile

;this program obtains ME spectrum from the raw data for the given dir.
;gainn is the coef gain file number, default is 13

if ((NOT keyword_set(mdir)) AND (NOT keyword_set(scwlist))) THEN begin
  print,'You need to set either an mdir=/xxxx/*0.00x/ inside REP/scw or'
  print,'You need to provide a scwlist in REP/scw'
  stop
endif

if (NOT keyword_set(gainn)) THEN gainn='0013'

if (NOT keyword_set(dead)) THEN dead=0

if (NOT keyword_set(logfile)) THEN logfile='getmedata.log'


openw,5,logfile
printf,5,'Log file for getmedata'
printf,5,'Performing gain correction'

;for gain correction
dir_gain='/raid/data/integral/REP/ic/spi/cal/'
fil_gain='spi_coef_cal_'+gainn+'.fits'

printf,5,'Using spi_coef_cal_'+gainn+'.fits'

gain=loadcol(dir_gain+fil_gain,'CHAN_KEV')

;gain is 5 by 38 array
poa = reform(gain(0,0:18))
pob = reform(gain(1,0:18))
poc = reform(gain(2,0:18))
pod = reform(gain(3,0:18))


;raw spi
;first find all the files, and write them into a file
 
printf,5,'Finding all raw science files'

dir_raw='/raid/data/integral/GRB041219/scw'


raw_files = findfileu(dir_raw+mdir, 'spi_raw_oper.fits.gz')

printf,5,'Performing the same step for prepared data'

;Now the same for prp data for times
;first find all the files, and write them into a file

dir_prp='/raid/data/integral/GRB041219/scw'

prp_files = findfileu(dir_prp+mdir, 'spi_prp_oper.fits.gz')

printf,5,'Performing same step for scientific housekeeping data'

;Now the same for the housekeeping data for times, if asked for
;first find all the files, and write them into a file

dir_schk='/raid/data/integral/GRB041219/scw'

schk_files= findfileu(dir_schk+mdir, 'spi_raw_schk.fits.gz')

;;
spx=fltarr(16384,61)
dechn=1./8.

;create the data structure
printf,5,'Creating the data structures'

num_files = n_elements(raw_files)
data1=create_struct('dete',intarr(2),'en',fltarr(2),'time',0.d)
data=replicate(data1,250000L*num_files)
m=0L

;for housekeeping
hk1=create_struct('scwname',' ','obtime',0.d,'nel',0L,'avgdt',fltarr(19),'avacsd',0.)
hk=replicate(hk1,num_files)

printf,5,'Reading and preparing data for each science windows'

dead=fltarr(num_files)

for j=0,num_files-1 do begin
;for j=0,0 do begin
   print,'raw_files[j]=',raw_files[j]   

   hk[j].scwname=raw_files[j]

;first we have to check whether the extension exists,
;remember, this is for multiples

  spawn,'fstruct '+raw_files[j]+' colinfo=N type=1 |'+$
      ' grep "BINTABLE SPI.-OME2-RAW"',res, /sh

  if strlen(res) gt 0 then begin
    pha=loadcol(raw_files[j],'PHA',ext=4)
    det=loadcol(raw_files[j],'DETE',ext=4)
    obtimes=loadcol(prp_files[j],'OB_TIME',ext=4)

pha=pha-16384L
ts=m
siz=size(pha)
   for k=0L,long(siz(2))-1L do begin
      psnum=psdetnum(det(0,k),det(1,k))
;      if psnum ne 0 then begin
        ch1 = float(pha(0, k))
        dt1 = det(0, k)
        ch2 = float(pha(1, k))
        dt2 = det(1, k)
        en1 = poa(dt1)/ch1 + pob(dt1) + poc(dt1)*ch1 + pod(dt1)*ch1^2
        en2 = poa(dt2)/ch2 + pob(dt2) + poc(dt2)*ch2 + pod(dt2)*ch2^2
        ephot = en1+en2
        ichn=fix((ephot/dechn)+randomu(seed,1)-0.5)
        if ((ichn lt 16384) and (ichn ge 0)) then spx(ichn,psnum)=spx(ichn,psnum)+1.
        if en1 le en2 then begin
         data[m].en=[en1,en2]
         data[m].dete=[det(0,k),det(1,k)]
     endif else begin
         data[m].en=[en2,en1]
         data[m].dete=[det(1,k),det(0,k)]
     endelse
         data[m].time=timeconvf2(obtimes(*,k))
         m=m+1L
 ;     endif
   endfor

   hk[j].obtime=data[m-1].time-data[ts].time
   hk[j].nel=long(m-ts)

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
   dead[j]=avg(dt)
   if dead[j] ge 0.14 then begin
     print,'Avg deadtime is greater than 0.14'
     printf,5,'WARNING... The avg. deadtime is greater than 0.14 in this scw:'
     printf,5,raw_files[j]
  endif

  if ((max(dt) gt (1.2*dead[j])) OR (min(dt) lt (0.8*dead[j]))) then printf,5,'WARNING,'+raw_files[j]+': too much variation in the deadtime' 

  for dnum=0,18 do hk[j].avgdt[dnum]=avg(dt(*,dnum))

endif else printf,5,raw_files[j]+' does not contain valid science data'
;plot,spx(*,19)
endfor

data=data[0:m-1]
close,5

end
