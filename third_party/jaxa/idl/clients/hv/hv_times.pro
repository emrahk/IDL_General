;+
; Project     : HELIOVIEWER
;
; Name        : HV_TIMES
;
; Purpose     : Return start/end times of Helioviewer (HV) JPEG2000 files for
;               specified SOURCE ID
;
; Category    : utility system sockets
;
; Example     : IDL> hv_times,source_id,tstart,tend
;
; Inputs      : SOURCE_ID = HV source ID
;
; Outputs     : TSTART, TEND = UT start and end times of JPEG2000 files
;
; Keywords    : VERBOSE = show output results
;
; History     : 5-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro hv_times,source_id,tstart,tend,err=err,verbose=verbose,nickname=nickname,$
                    _ref_extra=extra

err='' & nickname='' & tstart='' & tend=''
common hv_source,results

if ~is_number(source_id) then begin
 pr_syntax,'hv_times,source_id,tstart,tend [,nickname=nickname]'
 return
endif

if ~is_struct(results) then begin
 server=hv_server(_extra=extra)
 sources=server+'/getDataSources/?'
 sock_list,sources,json,err=err
 if is_string(err) then begin
  mprint,err & return
 endif
 results=json_parse(json,/tostruct)
endif

;-- parse JSON output into a structure and drill for times

if ~is_struct(results) then begin 
 err='Helioviewer source file not readable.'
 mprint,err & return
endif

verbose=keyword_set(verbose)
chk=chktag(results,'sourceid',value=source_id,nest=nest,/recurse)
if chk then begin
 tstart=nest.start
 tend=nest._end
 nickname=nest.nickname
 if verbose then help,nest,/st
endif else begin
 err='Source ID not found.'
 mprint,err
endelse

return
end

