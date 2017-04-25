;+
; Project     : HELIOVIEWER
;
; Name        : HV_GET
;
; Purpose     : Download nearest JPEG2000 file for specified SOURCE ID
;
; Category    : utility system sockets
;
; Example     : IDL> hv_get,'1-may-07',14
;
; Inputs      : TIME = time/date to search (UT)
;               SOURCE_ID = data source ID (from HV_SOURCE)
;
; Outputs     : See keywords
;
; Keywords    : LOCAL = name of downloaded file
;               ERR = error string
;
; History     : 1-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro hv_get,time,source_id,_ref_extra=extra

if ~valid_time(time) || ~is_number(source_id) then begin
 pr_syntax,'hv_get,time,source_id'
 return
endif

;-- check for existence of data source

date=anytim2utc(time,/ccsd)+'Z'
request=hv_server(_extra=extra)+'/getJP2Image/?date='+date+'&sourceId='+trim(source_id)
check=request+'&jpip=true'
sock_list,check,output
if stregex(output,'error',/bool,/fold) then begin
 mprint,'No data found for time and source ID.'
 return
endif

dprint,'% request: '+request

;-- now download it

sock_copy,request,_extra=extra

return
end
