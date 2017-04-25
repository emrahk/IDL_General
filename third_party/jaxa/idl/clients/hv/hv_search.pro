;+
; Project     : HELIOVIEWER
;
; Name        : HV_SEARCH
;
; Purpose     : Return metadata for closest JPEG2000 file in time for specified SOURCE ID
;
; Category    : utility system sockets
;
; Example     : IDL> a=hv_search('1-may-10',15,header=header)
;               IDL> help,a
;               ** Structure <78351a8>, 9 tags, length=88, data length=84, refs=1:
;                ID              STRING    '947636'
;                DATE            STRING    '2010-06-02 00:05:30'
;                SCALE           DOUBLE          0.61829595
;                WIDTH           LONG64                      4096
;                HEIGHT          LONG64                      4096
;                REFPIXELX       DOUBLE           2044.0100
;                REFPIXELY       DOUBLE           2054.1800
;                SUNCENTEROFFSETPARAMS
;                OBJREF    <ObjHeapVar563(LIST)>
;                LAYERINGORDER   LONG64                         1
;
; Inputs      : TIME = input time to check
;               SOURCE_ID = data source ID (from HV_SOURCE)
;
; Outputs     : META = metadata record
;
; Keywords    : ERR = error string
;               HEADER = JPEG2000 file header
;
; History     : 1-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function hv_search,time,source_id,_ref_extra=extra,header=header

header='' 

if ~valid_time(time) || ~is_number(source_id) then begin
 pr_syntax,'meta=hv_search(time,source_id)'
 return,''
endif

;-- check for existence of data source

date=anytim2utc(time,/ccsd)+'Z'
request=hv_server(_extra=extra)+'/getClosestImage/?date='+date+'&sourceId='+trim(source_id)
sock_list,request,output,_extra=extra
if is_string(output) then begin
 if ~stregex(output,'error',/bool,/fold) then begin
  meta=json_parse(output,/tostruct)
  if is_struct(meta) then begin
   if arg_present(header) then begin
    if have_tag(meta,'id') then begin
     query=hv_server(_extra=extra)+'/getJP2Header/?id='+trim(meta.id)
     sock_list,query,header,_extra=extra
    endif
   endif
   return,meta
  endif
 endif
endif

mprint,'No data found for time and source ID.'
return,''
end

