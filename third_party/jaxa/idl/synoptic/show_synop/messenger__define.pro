;+
; Project     : RHESSI
;
; Name        : MESSENGER__DEFINE
;
; Purpose     : Define a messenger data object.  
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('messenger')
;
; History     : Written 8-Feb-2010, Zarro (ADNET)
;               Modified 31-July-2013, Zarro (ADNET)
;                - added paren around file ext for stregex to work
;
; Contact     : dzarro@standford.edu
;-
;----------------------------------------------------------------

function messenger::init,_ref_extra=extra

if ~self->synop_spex::init() then return,0
rhost='hesperia.gsfc.nasa.gov'
self->setprop,rhost=rhost,ext='(dat|lbl)',org='year',$
                 topdir='/messenger',/full,/round

return,1
end

;----------------------------------------------------------------
;-- search method 

function messenger::search,tstart,tend,count=count,type=type,_ref_extra=extra

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('sxr/lightcurves',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;----------------------------------------------------------------

function messenger::parse_time,file,_ref_extra=extra

fil = file_break(file)
year = strmid(fil, 3, 4)
doy = strmid(fil, 7, 3)
return, anytim(doy2utc(doy, year),/tai)
;return, anytim2tai(file_break(file,/no_ext))

end

;----------------------------------------------------------------

pro messenger__define                 
void={messenger, inherits synop_spex}
return & end

