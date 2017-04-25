;+
; Project     : HESSI
;
; Name        : NANCAY__DEFINE
;
; Purpose     : Define a Nancay data site object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('nancay')
;
; History     : Written 3 March 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

;-----------------------------------------------------------------------------
;-- init

function nancay::init,_ref_extra=extra

ret=self->mesola::init(_extra=extra)
if ~ret then return,ret
self->setprop,ext='fits'

return,1
end

;---------------------------------------------------------------------------
;-- set method

pro nancay::setprop,mhz=mhz,_ref_extra=extra
          
def_dir='/pub/nancay/164MHz'
if exist(mhz) then begin 
 if fix(mhz) eq 164 then topdir=def_dir
 if fix(mhz) eq 327 then topdir='/pub/nancay/327MHz'
endif
self->mesola::setprop,topdir=topdir,_extra=extra

return & end

;--------------------------------------------------------------------------

function nancay::search,tstart,tend,times=times,_ref_extra=extra,count=count,type=type

type=''
self->setprop,mhz=164
files1=self->mesola::search(tstart,tend,times=times1,_extra=extra,count=count1)
self->setprop,mhz=327
files2=self->mesola::search(tstart,tend,times=times2,_extra=extra,count=count2)
if (count1 eq 0) and (count2 gt 0) then begin
 type=replicate('327 MHz radio/images',count2)
 files=temporary(files2)
 times=temporary(times2)
endif
if (count1 gt 0) and (count1 gt 0) then begin
 files=[temporary(files1),temporary(files2)]
 times=[temporary(times1),temporary(times2)]
 type=[replicate('164 MHz radio/images',count1),replicate('327 MHz radio/images',count2)]
endif

if (count1 gt 0) and (count2 eq 0) then begin
 files=temporary(files1)
 times=temporary(times1)
 type=replicate('164 MHz radio/images',count1)
endif

count=n_elements(files)
if count eq 0 then begin
 files='' & times=-1 & type=''
 mprint,'No files found.'
endif

return,files
end

;----------------------------------------------------------------------------
pro nancay::read,file,_ref_extra=extra

self->mesola::read,file,_extra=extra
count=self->get(/count)
if count gt 0 then begin
 index=self->get(/index)
 p=pb0r(index.date_obs,/arc)
 rad=p[2]
 dx=index.cdelt1*rad
 dy=index.cdelt2*rad
 index=rep_tag_value(index,file,'filename')
 type=trim(fix(index.freq))+' MHz'
 self->set,id='Nancay '+type,dx=dx,dy=dy,grid=30,/limb,index=index
endif

return & end

;------------------------------------------------------------------------------
;-- Nancay site structure

pro nancay__define                 

temp={nancay,inherits mesola}

return & end


