;+
; Project     : VSO
;
; Name        : SYNOP__DEFINE
;
; Purpose     : Wrapper object to read prepped synoptic images
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('synop')
;
; History     : Written 1-Jan-09 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function synop::init,_ref_extra=extra

if ~self->site::init(_extra=extra) then return,0

rhost='hesperia.gsfc.nasa.gov'
self->setprop,rhost=rhost,ext='fts',org='day',$
                 topdir='/ancillary/images',delim='',_extra=extra

return,1 & end

;-----------------------------------------------------------------------
function synop::search,tstart,tend,_ref_extra=extra,count=count,type=type

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('euv/images',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;------------------------------------------------------------------------------

pro synop__define,void                 

void={synop,inherits site}

return & end
