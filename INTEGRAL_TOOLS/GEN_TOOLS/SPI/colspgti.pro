pro colspgti, sp, gti, dir=dir

;;This program is to read a bunch of spectra, livetimes to do detector 
;;statistics

if (NOT keyword_set(dir)) THEN begin
  print,'You need to set a dir=dir of evts_det_spec,fits'
  exit
endif


numdet=142  ;; number of detectors

pha=fltarr(16364,numdet)   ;; spectra 
gti=dblarr(numdet)         ;; livetimes
sp=fltarr(16364,numdet)

;; first find all directories that contain a spectrum

;dir='/home/integral/detst/obs/'

openw,1,'findall.csh'
printf,1,'#!/bin/csh'
printf,1,'set mdir = "'+dir+'"'
printf,1,'set files = `find ${mdir} -name "evts_det_spec.fits" -print`'
printf,1,'echo $files > files.txt'
close,1

spawn, 'chmod u+x findall.csh'
spawn, './findall.csh'

;now read those files

allf=strarr(1)
openr,1,'files.txt'
readf,1,allf
close,1

;now find individual files
tot_length=strlen(allf(0))+1 ;one to include white space, required to read the
                             ;last item

pos=0
j=0
s=strpos(allf(0),' ',pos)+1  ;;get the position for the first file

while (s NE 0) do begin


evts_files=strmid(allf(0),pos,s-pos-1)
tmp=strpos(evts_files,'evts_det_spec.fits')
spidir=strmid(evts_files,0,tmp) ;;get the spi directory
gtifile=spidir+'dead_time.fits' 
print,evts_files
print,gtifile

pos=s

   print,j    
   phax=loadcol(evts_files,'COUNTS',ext=1)
   pha=pha+phax

   gtix=loadcol(gtifile,'livetime')
   gti=gti+gtix

j=j+1
s=strpos(allf(0),' ',pos)+1 

plot,pha(*,19)

endwhile

evts_files=strmid(allf(0),pos,tot_length-pos-1)
print,evts_files

print,j    
phax=loadcol(evts_files[0],'COUNTS',ext=1)
pha=pha+phax
gtix=loadcol(gtifile,'livetime')
gti=gti+gtix

;; now convert everything to counts/s and eliminate dead time
;; dependence

for i=0,numdet-1 do sp(*,i)=pha(*,i)/gti(i)

;save,sp,gti,filename='staringspegt_idl.dat'

end
