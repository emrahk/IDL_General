pro z2_range,tme,frange,n,z2arr,low,high,binsize=binsize,$
             pdot=pdot,ppdot=ppdot,fdot=fdot,ffdot=ffdot,$
             silent=silent
;************************************************************
; Program calculates the Z^2 statistic for a range of
; frequencies given an array of event times.
; Variables are:
;       times...........array of event times (s)
;      frange...........frequency range for z^2
;           n...........number of harmonics parameter
;       z2arr...........array of z^2 values
;    low,high...........upper,lower bin edges (1/s)
;        pdot...........period derivitive
;       ppdot...........2nd period derivative
;        fdot...........first frequency derivative
;       ffdot...........second frequency derivative
;      silent...........no printouts
; Needs routine z_2.pro
; First do usage:
;************************************************************
if (n_params() eq 0)then begin
   print,'USAGE:Z2_RANGE,TIMES,FRANGE,N,Z2ARR,LOW,HIGH,' + $
         '[BINSIZE=],[PDOT=],[PPDOT=],[FDOT=],[FFDOT=],' + $
         '[SILENT=(no)]'
   return
endif
;************************************************************
; Set some default variables and get the frequency array.
;************************************************************
if (ks(pdot) eq 0)then pdot = 0d
if (ks(ppdot) eq 0)then ppdot = 0d
if (ks(fdot) eq 0)then fdot = 0d
if (ks(ffdot) eq 0)then ffdot = 0d
range = double(max(frange) - min(frange))
if (ks(binsize) eq 0)then binsize = range/10d
binsize = double(binsize)
nbns = range/binsize + .5
if (nbns lt 1.)then begin
   print,'BAD BINSIZE OR FREQUENCY RANGE'
   return
endif
z2arr = fltarr(nbns)
low = min(frange) + binsize*dindgen(nbns) 
freq = low + binsize/2d
high = low + binsize
;************************************************************
; Loop through the frequencies and print message at 
; intervals of .1*length
;************************************************************
ndx = long(nbns/10.)
print,'Z2_RANGE:' 
print,'PDOT=',pdot
print,'FDOT=',fdot
print,'PPDOT=',ppdot
print,'FFDOT=',ffdot
for i = long(0),long(nbns)-long(1) do begin
 z_2,tme,n,freq(i),temp_z2,pd=pdot,pp=ppdot,fd=fdot,ff=ffdot
 if (n_elements(silent) eq 0)then $
 print,long(i)+1l,' DONE,',' FREQ. = ',freq(i)
 z2arr(i) = temp_z2
endfor
;************************************************************
; Thats all ffolks
;************************************************************
return
end







