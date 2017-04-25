;+
; Project     : HESSI
;
; Name        : KPNO__DEFINE
;
; Purpose     : Define a KPNO data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('kpno')
;
; History     : Written 17 Feb 2001, D. Zarro, EIT/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function kpno::init,_ref_extra=extra

ret=self->fits::init(_extra=extra)
                     
if not ret then return,ret

return,1

end

;----------------------------------------------------------------------------

pro kpno::cleanup

self->fits::cleanup

return & end


;----------------------------------------------------------------------------
;-- convert KPNO index to FITS standard

function kpno::index2fits,index,no_copy=no_copy,err=err

err=''
if datatype(index) ne 'STC' then return,-1

if keyword_set(no_copy) then nindex=temporary(index) else nindex=index
if have_tag(nindex,'scale') then scale=(nindex.scale)[0] else scale=1.1483
if not have_tag(nindex,'cdelt1') then nindex=add_tag(nindex,scale,'cdelt1')
if not have_tag(nindex,'cdelt2') then nindex=add_tag(nindex,scale,'cdelt2')
nindex=rep_tag_value(nindex,0.,'crval1')
nindex=rep_tag_value(nindex,0.,'crval2')
nindex=rep_tag_value(nindex,nindex.e_xcen,'crpix1') 
nindex=rep_tag_value(nindex,nindex.e_ycen,'crpix2') 

return,nindex

end

;------------------------------------------------------------------------------
;-- KPNO data structure

pro kpno__define                 

self={kpno, inherits fits}

return & end


