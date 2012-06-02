pro getmesperaw,mdir=mdir,gainn=gainn,spx

;this program obtains ME spectrum from the raw data for the given dir.
;gainn is the coef gain file number, default is 13

if (NOT keyword_set(mdir)) THEN begin
  print,'You need to set a mdir=/xxxx/*0.00x/ inside REP/scw'
  exit
endif

if (NOT keyword_set(gainn)) THEN gainn='0013'

;for gain correction
dir_gain='/home/integral/INTEGRALTOOLS/ic/spi/cal/'
fil_gain='spi_coef_cal_'+gainn+'.fits'

gain=loadcol(dir_gain+fil_gain,'CHAN_KEV')

;gain is 5 by 38 array, but I need first two columns (gain and
; offset and first 19 rows for each detector)
offsetd=reform(gain(0,0:18))
gaind=reform(gain(1,0:18))

;raw spi
;first find all the files, and write them into a file
 
dir_raw='/home/integral/REP/scw'

openw,1,'findallraw.csh'
printf,1,'#!/bin/csh'
;printf,1,'set mdir = "'+dir_raw+'/002[4-5]/*0.001/"'
printf,1,'set mdir = "'+dir_raw+mdir+'"'
printf,1,'set files = `find ${mdir} -name "spi_raw_oper.fits.gz" -print`'
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
num_files=tot_length/s
raw_files=strarr(num_files)
for i=0,num_files-1 do raw_files[i]=strmid(allf(0),i*s,s-1)

spx=fltarr(16384,61)
dechn=1./8.

for j=0,num_files-1 do begin
;for j=0,0 do begin
   print,j    

;first we have to check whether the extension exists,
;remember, this is for multiples

  spawn,'fstruct '+raw_files[j]+' colinfo=N type=1 |'+$
      ' grep "BINTABLE SPI.-OME2-RAW"',res


  if strlen(res) gt 0 then begin
    pha=loadcol(raw_files[j],'PHA',ext=4)
    det=loadcol(raw_files[j],'DETE',ext=4)
  endif

pha=pha-16384L

siz=size(pha)
   for k=0L,long(siz(2))-1L do begin
      psnum=psdetnum(det(0,k),det(1,k))
      if psnum ne 0 then begin
        ephot=(float(pha(0,k))*gaind(det(0,k))+offsetd(det(0,k)))+(float(pha(1,k))*gaind(det(1,k))+offsetd(det(1,k)))
        ichn=fix((ephot/dechn)+randomu(seed,1)-0.5)
        if ((ichn lt 16384) and (ichn ge 0)) then spx(ichn,psnum)=spx(ichn,psnum)+1.
      endif
   endfor

plot,spx(*,19)

endfor

end
