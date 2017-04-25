;+
; Project     : HESSI
;
; Name        : SPIRIT__DEFINE
;
; Purpose     : Define a SPIRIT data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('spirit')
;
; History     : Written 11 Nov 2005, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function spirit::init,_ref_extra=extra

return,self->fits::init(_extra=extra)

end

;----------------------------------------------------------------------------

pro spirit::cleanup

self->fits::cleanup

return & end

;-----------------------------------------------------------------------------
;-- correct for spacecraft roll

pro spirit::read,file,data,_ref_extra=extra

self->fits::read,file,data,_extra=extra

count=self->get(/count)
if count eq 0 then return
for i=0,count-1 do self->rotate,-self->get(i,/roll_angle),i,full_size=0
self->set,/log

return & end

;----------------------------------------------------------------------------
;-- correct FITS header

function spirit::index2fits,index,no_copy=no_copy,err=err

err=''
if not is_struct(index) then return,-1

index.crval1=0.
index.crval2=0.
index.cdelt1=8.17
index.cdelt2=8.17
index.crpix1=comp_fits_crpix(0.,index.cdelt1,index.naxis1)
index.crpix2=comp_fits_crpix(0.,index.cdelt2,index.naxis2)
if keyword_set(no_copy) then nindex=temporary(index) else nindex=index

return,nindex

end
                                         
;----------------------------------------------------------------------------

pro spirit__define                 

self={spirit, inherits fits}

return & end

