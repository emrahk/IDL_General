;+
; Project     : RHESSI
;
; Name        : smm_hxrbs__DEFINE
;
; Purpose     : Define an SMM HXRBS data object.  
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('smm_hxrbs')
;
; History     : Written 18-Mar-2013, Kim Tolbert
; 
; Modifications:
;  14-Jul-2015, Kim.  Changed org from 'none' to 'year' after reorganizing files into yearly directories
;
;
;-
;----------------------------------------------------------------

function smm_hxrbs::init,_ref_extra=extra

if ~self->synop_spex::init() then return,0
rhost='hesperia.gsfc.nasa.gov'
self->setprop,rhost=rhost,ext='.fits',org='year',$
                 topdir='/smm/hxrbs',/full,/round

return,1
end

;----------------------------------------------------------------
;-- search method 

function smm_hxrbs::search,tstart,tend,count=count,type=type,_ref_extra=extra

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('hxr/lightcurves',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;----------------------------------------------------------------

pro smm_hxrbs__define                 
void={smm_hxrbs, inherits synop_spex}
return & end

