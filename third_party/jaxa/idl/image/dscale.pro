;+
; Project     : SOHO - CDS     
;                   
; Name        : DSCALE
;               
; Purpose     : scale data
;               
; Category    : display
;               
; Syntax      : IDL> a=dscale(b)
;
; Inputs      : ARRAY = input array to scale
;               
; Outputs     : DARRAY = scaled data
;
; Keywords    :
;               MIN = min data to scale [def=min(array)]
;               MAX = max data to scale [def=max(array)]
;               MISSING = data to exclude [i.e., set to dmin]
;               NO_COPY = destroy input array
;               LOG     = use log10 scale
;               CRANGE  = actual data range used
;               
; History     : Version 1,  17-Jan-1998,  D M Zarro.  Written
;               Modified  24-Nov-1999, Zarro (SM&A/GSFC) - added check
;               for unnecessary call to filt_data
;               Modified  14-March-2000, Zarro (SM&A/GSFC) - fixed
;               bug in use of nmin/nmax
;               Modified  30-Oct-2003, Zarro (L-3/GSFC) - fixed
;               bug in which values between 0 and 1 were being ignored under
;               log scaling
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            


function dscale,array,min=dmin,max=dmax,missing=missing,$
                log=log,err=err,no_copy=no_copy,nan=nan,nok=nok,$
                count=count,outer=outer,drange=drange,$
                crange=crange,acount=acount,above=above
               
;-- defaults

nok=-1
count=0
outer=0
acount=0
above=-1

err=''
if not exist(array) then begin
 pr_syntax,'data=dscale(data,[/log,missing=missing]'
 err='invalid input'
 return,0
endif

;-- set data limits

amax=max(array,min=amin,nan=nan)
if exist(dmin) then cmin=dmin else cmin=amin
if exist(dmax) then cmax=dmax else cmax=amax
if valid_range(drange) then begin
 cmin=min(drange[0]) & cmax=max(drange[1])
endif
temp=float([cmin,cmax])
cmin=min(temp,max=cmax)

sz=size(array)
nx=sz[1]
ny=sz[2]

err_mess='No data in specified range'
if (amax eq amin) and (amax eq 0) then begin
 err=err_mess
; message,err,/cont
 return,bytarr(nx,ny)
endif

if exist(log) then log=(0b > log <  1b) else log=0b

;-- flag missing or negative/zero data values for log case

if cmax ne amax then above=where(array gt cmax,acount)

np=n_elements(array)
do_filt=exist(missing) or log or (cmin ne amin) or (cmax ne amax) or keyword_set(nan)

if do_filt then begin
 nok=filt_data(array,miss=missing,positive=log,min=cmin,$
              max=cmax,count=count,nan=nan,/inverse)
 if count eq np then begin
  err=err_mess
  message,err,/cont
  return,bytarr(nx,ny)
 endif
              
endif

;-- create output array
              
if keyword_set(no_copy) then darray=temporary(array) else darray=array

if count gt 0 then darray[nok]=abs(amax)+1

if log then begin
 darray=alog10(temporary(darray))
 if cmin gt 0 then cmin=alog10(cmin) else cmin=min(darray,nan=nan)
 if cmax gt 0 then cmax=alog10(cmax) else cmax=max(darray,nan=nan)
endif

dprint,'% DSCALE: cmin, cmax: ',cmin,cmax

crange=[cmin,cmax]

if cmax eq cmin then begin
 err=err_mess
 message,err,/cont
 return,bytarr(nx,ny)
endif

return,darray

end

