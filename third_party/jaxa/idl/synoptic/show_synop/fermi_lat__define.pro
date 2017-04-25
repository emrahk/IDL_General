;+
; Project     : RHESSI
;
; Name        : FERMI_LAT__DEFINE
;
; Purpose     : Define a FERMI LAT data object.  
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('fermi_lat')
;
; History     : Written 12-Feb-2010, Kim Tolbert, modified from fermi_gbm__define
;
; Written     : Kim tolbert, 6-Dec-2012
; Modifications: 
;  18-Dec-2013, Kim.  Put online
;  29-Sep-2015, Kim. Added check for LAT_PARENT_DIR env var..  If set, use that as parent directory for archive data.

;   
;-
;----------------------------------------------------------------
;
function fermi_lat::init,_ref_extra=extra

if ~self->synop_spex::init() then return,0

;rhost='fermi.gsfc.nasa.gov'
rhost='hesperia.gsfc.nasa.gov'

parent = str_replace(chklog('LAT_PARENT_DIR'), '/data', '')
if ~is_string(parent) then parent = '/fermi/lat'

self->setprop,rhost=rhost,ext='fits',org='day',/round,$
                 topdir=parent,/full, delim='/'
return,1

end
;-----------------------------------------------------------------

;-- search method 

function fermi_lat::search,tstart,tend,count=count,type=type,_ref_extra=extra

type=''

; site::search expects yyyymmdd_hhmmss but we only have yyyymmdd, so give it a modified regular expression
regex = '([^_\\/ ]+)_?_([0-9]{0,2}[0-9]{2})([0-9]{2})([0-9]{2})'
files=self->site::search(tstart,tend,_extra=extra, regex=regex, count=count)
if count gt 0 then type=replicate('hxr/lightcurves',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;----------------------------------------------------------------

pro fermi_lat__define                 
void={fermi_lat, inherits synop_spex}
return & end

