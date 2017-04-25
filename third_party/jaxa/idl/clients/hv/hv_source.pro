;+
; Project     : HELIOVIEWER
;
; Name        : HV_SOURCE
;
; Purpose     : Return Helioviewer (HV) SOURCE ID
;
; Category    : utility system sockets
;
; Example     : IDL> source_id=hv_source(obs='SOHO',inst='EIT',meas='304')
;               IDL> print,source_id
;
; Inputs      : See keywords
;
; Outputs     : SOURCE_ID = matching source ID
;
; Keywords    : Observatory = observatory (e.g. 'STEREO_A')
;               Instrument = instrument (e.g. 'SECCHI')
;               Detector = detector (e.g. 'EUVI')
;               Measurement = measurement (e.g. 171)
;
; History     : 1-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function hv_source,detector=detector,instrument=instrument,observatory=observatory,$
                   measurement=measurement,err=err,_ref_extra=extra
err=''
common hv_source,results

if ~is_struct(results) then begin
 server=hv_server(_extra=extra)
 sources=server+'/getDataSources/?'
 sock_list,sources,json,err=err
 if is_string(err) then begin
  mprint,err & return,-1
 endif
 results=json_parse(json,/tostruct)
endif

;-- parse JSON output into a structure and drill for source ID

if ~is_struct(results) then begin 
 err='Helioviewer source file not readable.'
 mprint,err & return,-1
endif

req='results'
if is_string(observatory) then req=req+'.'+observatory
if is_string(instrument) then req=req+'.'+instrument
if is_string(detector) then req=req+'.'+detector
if exist(measurement) then begin
 if is_number(measurement) then dmess='_'+trim(measurement) else $
  if string(measurement) then dmess=measurement
 if is_string(dmess) then req=req+'.'+dmess
endif

state='source_id='+req+'.sourceid'
status=execute(state,1,1)
if status eq 1 then return,source_id

err='Failed to determine SOURCE ID.'
mprint,err
return,-1

end

