;+
; Project     : RHESSI
;
; Name        : SOXS__DEFINE
;
; Purpose     : Define a SOXS data object.  
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('soxs')
;
; History     : Written 8-Feb-2010, Zarro(ADNET)
;
; Contact     : dzarro@standford.edu
;-
;----------------------------------------------------------------

function soxs::init,_ref_extra=extra

if ~self->synop_spex::init() then return,0
rhost='hesperia.gsfc.nasa.gov'
self->setprop,rhost=rhost,ext='les',org='year',$
                 topdir='/soxs',/full,/round

return,1
end

;----------------------------------------------------------------
;-- search method 

function soxs::search,tstart,tend,count=count,type=type,_ref_extra=extra

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('sxr/lightcurves',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;----------------------------------------------------------------

function soxs::parse_time,file,_ref_extra=extra

return, anytim2tai(file_break(file,/no_ext))

end

;----------------------------------------------------------------

pro soxs__define                 
void={soxs, inherits synop_spex}
return & end

