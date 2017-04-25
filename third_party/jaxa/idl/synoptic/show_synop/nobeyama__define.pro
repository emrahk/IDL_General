;+
; Project     : HESSI
;
; Name        : NOBEYAMA__DEFINE
;
; Purpose     : Define a NOBE data object for Nobeyama Radio Obs.
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('nobe')
;
; History     : Written 22 Aug 2000, D. Zarro (EIT/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function nobeyama::init,_ref_extra=extra

ret=self->site::init(_extra=extra)
                     
if ~ret then return,ret

ret=self->fits::init(_extra=extra)

if ~ret then return,ret
           
self->setprop,rhost='ftp://solar.nro.nao.ac.jp',dtype='daily',org='month',$
              ftype='if',/full,delim='/'

return,1

end

;----------------------------------------------------------------------------

pro nobeyama::cleanup

self->site::cleanup
self->fits::cleanup

return & end

;------------------------------------------------------------------------------
;-- SET method

pro nobeyama::setprop,dtype=dtype,err=err,_extra=extra

;-- set file type and location to download

root='/pub/nsro/norh/images/'
valid_dtype=['daily','10min'] 
if is_string(dtype) then begin
 chk=where(strlowcase(trim(dtype)) eq valid_dtype,count)
 if count gt 0 then begin
  topdir=root+valid_dtype[chk[0]]
  self->site::setprop,topdir=topdir
 endif
endif

self->site::setprop,_extra=extra,err=err

return & end
                                      
;---------------------------------------------------------------------------

function nobeyama::parse_time,file,_ref_extra=extra

dd='([0-9]{2})'
regex='([a-z]{3})'+dd+dd+dd+'_'+dd+dd+dd

return,parse_time(file,_extra=extra,regex=regex)

end

;---------------------------------------------------------
pro nobeyama::read,file,_ref_extra=extra

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
 id='Nobeyama'+' '+index.OBS_D$FREQ
 self->set,id=id,roll_angle=index.solp,/limb,grid=30
endif

return & end

;--------------------------------------------------------------------------

function nobeyama::search,tstart,tend,_ref_extra=extra,count=count,type=type

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('radio/images',count)
if count eq 0 then mprint,'No files found.'

return,files
end
                                         
;------------------------------------------------------------------------------
;-- Nobeyama site structure

; DTYPE = 'daily' or 'ten_minute'

pro nobeyama__define                 

self={nobeyama,dtype:'',inherits site, inherits fits}

return & end

