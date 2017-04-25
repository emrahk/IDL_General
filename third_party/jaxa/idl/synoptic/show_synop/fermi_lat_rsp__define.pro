;+
; Project     : RHESSI
;
; Name        : fermi_lat_rsp__define
;
; Purpose     : Define a FERMI lat RSP (response file) data object.  
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('fermi_lat_rsp')
;
; History     : Written 23-Jun-2010, Kim Tolbert, modified from fermi_lat__define
; 10-Aug-2012 - Kim.  Call site::search with /use_network if IDL > 6.4. Fixes problem
;   with occasional random characters at end of URL. Can remove when DMZ changes sock routines
; 15-Aug-2012 - Kim. Removed use_network because DMZ changed site::search to use /use_network
; 18-Dec-2013, Kim.  Put online
;  29-Sep-2015, Kim. Added check for LAT_PARENT_DIR env var..  If set, use that as parent directory for archive data.
;
;-
;----------------------------------------------------------------
;
function fermi_lat_rsp::init,_ref_extra=extra

if ~self->synop_spex::init() then return,0
rhost='hesperia.gsfc.nasa.gov'

parent = str_replace(chklog('LAT_PARENT_DIR'), '/data', '')
if ~is_string(parent) then parent = '/fermi/lat'

self->setprop,rhost=rhost,ext='rsp',org='day',$
                 topdir=parent,/full, delim='/', suffix='rsp'
return,1

end
;-----------------------------------------------------------------

;-- search method 
; tstart, tend should be in seconds since 1958 (tai) or some absolute time format

function fermi_lat_rsp::search,tstart,tend,count=count,type=type,_ref_extra=extra

type=''
; expand search by a minute since rsp file names don't include seconds
;tstart60 = atime(anytim(tstart, fid='tai') - 60.)
;tend60 = atime(anytim(tend, fid='tai') + 60.)

files=self->site::search(tstart, tend, _extra=extra, count=count)
if count gt 0 then type=replicate('response matrix',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;----------------------------------------------------------------

pro fermi_lat_rsp__define                 
void={fermi_lat_rsp, inherits synop_spex}
return & end

