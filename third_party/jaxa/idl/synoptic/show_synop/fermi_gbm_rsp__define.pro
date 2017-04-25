;+
; Project     : RHESSI
;
; Name        : fermi_gbm_rsp__define
;
; Purpose     : Define a FERMI GBM RSP (response file) data object.  
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('fermi_gbm_rsp')
;
; History     : Written 23-Jun-2010, Kim Tolbert, modified from fermi_gbm__define
; 10-Aug-2012 - Kim.  Call site::search with /use_network if IDL > 6.4. Fixes problem
;   with occasional random characters at end of URL. Can remove when DMZ changes sock routines
; 15-Aug-2012 - Kim. Removed use_network because DMZ changed site::search to use /use_network
;
;-
;----------------------------------------------------------------
;
function fermi_gbm_rsp::init,_ref_extra=extra

if ~self->synop_spex::init() then return,0
rhost='hesperia.gsfc.nasa.gov'
self->setprop,rhost=rhost,ext='rsp|rsp2',org='day',$
                 topdir='/fermi/gbm/rsp',/full, delim=''
return,1

end
;-----------------------------------------------------------------

;-- search method 
; tstart, tend should be in seconds since 1958 (tai) or some absolute time format

function fermi_gbm_rsp::search,tstart,tend,count=count,type=type,_ref_extra=extra

type=''
; expand search by a minute since rsp file names don't include seconds
tstart60 = atime(anytim(tstart, fid='tai') - 60.)
tend60 = atime(anytim(tend, fid='tai') + 60.)

files=self->site::search(tstart60, tend60, _extra=extra, count=count)
if count gt 0 then type=replicate('response matrix',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;----------------------------------------------------------------

pro fermi_gbm_rsp__define                 
void={fermi_gbm_rsp, inherits synop_spex}
return & end

