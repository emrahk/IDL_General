pro getmetracer,mdir=mdir,data,hk,logfile=logfile,scwlist=scwlist

;this program is to get different tracers

if (NOT keyword_set(logfile)) THEN logfile='getmetracer.log'
;if NOT keyword_set(scwlist) THEN scwlist = 0

if ((NOT keyword_set(mdir)) AND (NOT keyword_set(scwlist))) THEN begin
  print,'You need to set a mdir=/xxxx/*0.00x/ inside REP/scw or'
  print,'You need to provide a scwlist in REP/scw'
  stop
endif

openw,5,logfile
printf,5,'Log file for getmetracer'
printf,5,'Find scientific housekeeping data'

;first find all the files, and write them into a file

 dir_schk='/raid2/integral/REP/osa_ic-5.1/scw/'

if NOT keyword_set(scwlist) then begin

 schk_files= findfileu(dir_schk+mdir, 'spi_science_hk.fits.gz')


;;
;printf,5,'Performing the same steps for prepared data'

;Now the same for prp data for times

;  dir_prp=dir_schk

;  prp_files = findfileu(dir_prp+mdir, 'spi_prp_schk.fits.gz')
endif else begin 
  
   ;first obtain the word count
   spawn,'wc '+scwlist,wc
   numrow=long(strmid(wc,0,4))
     

   scwarr=strarr(numrow)
   openr,1,scwlist
   readf,1,scwarr
   close,1

   schk_files=dir_schk+strmid(scwarr,3,23)+'spi_science_hk.fits.gz'

endelse
   
;;
;create the data structure
printf,5,'Creating the data structures'

data1=create_struct('geds',fltarr(19),'acs_ab',0.,'acs_bw',0.,'dt',fltarr(19),'acsd',0.,'time',0.d)
data=replicate(data1,1000000L)
m=0L

;for housekeeping

num_files = n_elements(schk_files)
hk1=create_struct('scwname',' ','obtime',0.d,'nel',0L)
hk=replicate(hk1,num_files)

printf,5,'Reading and preparing data for each science windows'


for j=0,num_files-1 do begin
;for j=0,0 do begin
   print,'schk_file=',schk_files[j]

   hk[j].scwname=schk_files[j]

;first we have to check whether the extension exists,
;remember, this is for multiples
  spawn,'fstruct '+schk_files[j]+' colinfo=N type=1 |'+$
      ' grep "BINTABLE SPI.-SCHK-HRW"',res, /sh

  if strlen(res) gt 0 then begin
    obtimes=loadcol(schk_files[j],'LOCAL_OBT',ext=1)
    gedst0=loadcol(schk_files[j],'P__DF__CAFTS__L0',ext=1)
    geds=fltarr(n_elements(gedst0),19)
    geds(*,0)=gedst0
    geds(*,1)=loadcol(schk_files[j],'P__DF__CAFTS__L1',ext=1)
    geds(*,2)=loadcol(schk_files[j],'P__DF__CAFTS__L2',ext=1)
    geds(*,3)=loadcol(schk_files[j],'P__DF__CAFTS__L3',ext=1)
    geds(*,4)=loadcol(schk_files[j],'P__DF__CAFTS__L4',ext=1)
    geds(*,5)=loadcol(schk_files[j],'P__DF__CAFTS__L5',ext=1)
    geds(*,6)=loadcol(schk_files[j],'P__DF__CAFTS__L6',ext=1)
    geds(*,7)=loadcol(schk_files[j],'P__DF__CAFTS__L7',ext=1)
    geds(*,8)=loadcol(schk_files[j],'P__DF__CAFTS__L8',ext=1)
    geds(*,9)=loadcol(schk_files[j],'P__DF__CAFTS__L9',ext=1)
    geds(*,10)=loadcol(schk_files[j],'P__DF__CAFTS__L10',ext=1)
    geds(*,11)=loadcol(schk_files[j],'P__DF__CAFTS__L11',ext=1)
    geds(*,12)=loadcol(schk_files[j],'P__DF__CAFTS__L12',ext=1)
    geds(*,13)=loadcol(schk_files[j],'P__DF__CAFTS__L13',ext=1)
    geds(*,14)=loadcol(schk_files[j],'P__DF__CAFTS__L14',ext=1)
    geds(*,15)=loadcol(schk_files[j],'P__DF__CAFTS__L15',ext=1)
    geds(*,16)=loadcol(schk_files[j],'P__DF__CAFTS__L16',ext=1)
    geds(*,17)=loadcol(schk_files[j],'P__DF__CAFTS__L17',ext=1)
    geds(*,18)=loadcol(schk_files[j],'P__DF__CAFTS__L18',ext=1)

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
 

    acs_ab=loadcol(schk_files[j],'P__DF__CNVT_MAB__L',ext=1)
    acs_bw=loadcol(schk_files[j],'P__DF__CNVT_MBW__L',ext=1)
    acsd=loadcol(schk_files[j],'P__DF__NVTDT__L',ext=1)/(1.0e7)

    ts=m

    for k=0L,n_elements(gedst0)-1L do begin

       data[m].geds=geds[k,*]
       data[m].dt=dt[k,*]
       data[m].acs_ab=acs_ab[k]
       data[m].acs_bw=acs_bw[k]
       data[m].acsd=acsd[k]
       data[m].time=timeconvf2(obtimes(*,k))
       m=m+1L


   endfor
   hk[j].obtime=data[m-1].time-data[ts].time
   hk[j].nel=n_elements(gedst0)

endif else printf,5,schk_files[j]+' does not contain valid science data'
;plot,spx(*,19)
endfor

data=data[0:m-1]
close,5

end

