;+
; Project     : HESSI
;
; Name        : MEUDON__DEFINE
;
; Purpose     : Define a Meudon data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('meudon')
;
; History     : Written 20 Dec 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function meudon::init,_ref_extra=extra

ret=self->mesola::init(_extra=extra) 
if ~ret then return,ret
self->setprop,/halpha,ext='fits'

return,1

end

;---------------------------------------------------------------------------
;-- set method

pro meudon::setprop,halpha=halpha,kline=kline,_ref_extra=extra
          
def_dir='/pub/meudon/Halpha'
if keyword_set(halpha) then topdir=def_dir
if keyword_set(kline) then topdir='/pub/meudon/K1v'

self->mesola::setprop,topdir=topdir,_extra=extra

return & end

;--------------------------------------------------------------------------

function meudon::search,tstart,tend,_ref_extra=extra,count=count,type=type

type=''
files=self->mesola::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('H-alpha/images',count)

return,files
end

;---------------------------------------------------------------
pro meudon::read,file,_ref_extra=extra

self->mesola::read,file,_extra=extra,record=0
count=self->get(/count)
if count gt 0 then begin
 dx=1.5
 dy=1.5
 for i=0,count-1 do self->set,i,dx=dx,dy=dy,/limb,grid=30
endif

return & end

;------------------------------------------------------------------------------
;-- meudon site structure

pro meudon__define                 

temp={meudon,inherits mesola}

return & end


