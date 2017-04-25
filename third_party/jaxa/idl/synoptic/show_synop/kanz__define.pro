;+
; Project     : HESSI
;
; Name        : KANZ__DEFINE
;
; Purpose     : Define a KANZ data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('kanz')
;
; History     : Written 15 March 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function kanz::init,_ref_extra=extra

ret=self->site::init(_extra=extra)
if ~ret then return,ret
ret=self->fits::init(_extra=extra)
if ~ret then return,ret
           
self->setprop,rhost='ftp://ftp.kso.ac.at',ext='fts',$
      username='download',password='9521treffen',org='year',ftype='kanz',$
      topdir='/halpha/FITS/high',/full,delim=''

return,1

end
;------------------------------------------------------------------------
pro kanz::cleanup

self->site::cleanup
self->fits::cleanup

return & end

;-------------------------------------------------------------------------
;-- FTP search method

function kanz::search,tstart,tend,_ref_extra=extra,count=count,type=type

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('H-alpha/images',count) else files=''
return,files

end

;------------------------------------------------------------
pro kanz::read,file,_ref_extra=extra

if is_blank(file) then begin
 pr_syntax,'object_name->read,filename'
 return
endif
file=strtrim(file,2)
self->getfile,file,local_file=ofile,_extra=extra
if is_blank(ofile) then return

self->fits::read,ofile,_extra=extra
count=self->get(/count)
if count gt 0 then begin
 index=self->get(/index)
 index=rep_tag_value(index,file_basename(ofile),'filename')
 self->set,index=index
 roll=0.
 if have_tag(index,'solar_p0') then roll=-index.solar_p0
 self->set,roll_angle=roll,/limb,grid=30
endif

return & end
                                         
;------------------------------------------------------------------------------
;-- KANZ site structure

pro kanz__define                 

self={kanz,inherits site, inherits fits}

return & end

