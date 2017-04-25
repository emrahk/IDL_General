;+
; Project     : HESSI
;
; Name        : HSI_READ_FLARELIST2
;
; Purpose     : IDL-IDL Bridge wrapper around HSI_READ_FLARELIST
;               to read RHESSI flare catalog in background thread.
;
; Category    : RHESSI utility
;
; Syntax      : IDL> f=hsi_read_flarelist2()
;
; Inputs      : None
;
; Outputs     : F = blank string. 
;               There is no direct output since this function runs
;               asynchronously. Once it is has completed reading the
;               flare catalog, it populates the common block:
;               common hsi_flarelist, flare_data, flare_info
;               with the corresponding catalog data.
;
; Keywords    : FORCE = force reading catalog each time
;
; History     : 27-Oct-2010, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

;--- call back routine to notify when thread is complete

pro hsi_read_flarelist_callback, status, error, oBridge, userdata

@hsi_flarelist_com

err_msg=obridge->getvar('err_msg')
if is_string(err_msg) then message,err_msg,/cont

if status eq 2 then begin
 message,'Completed.',/cont
endif
temp_file=concat_dir(get_temp_dir(),'hsi_flarelist.sav')
if file_test(temp_file,/read) then begin
 delvarx,flare_data, flare_info
 restore,file=temp_file  
endif else message,'Not found - '+temp_file,/cont

if is_string(error) then message,error,/cont

return & end

;-------------------------------------------------------------------------

pro hsi_read_flarelist_thread,_extra=extra,verbose=verbose,err_msg=err_msg

@hsi_flarelist_com

common hsi_read_flarelist_thread,obridge

if keyword_set(reset) then if obj_valid(obridge) then obj_destroy,obridge
verbose=keyword_set(verbose)

;-- create IDL-IDL bridge object
;-- make sure thread object has same SSW IDL environment/path as parent

err_msg=''
if verbose then output=''
if ~obj_valid(obridge) then begin
 obridge = Obj_New('IDL_IDLBridge',callback='hsi_read_flarelist_callback',output=output)
 chk=obridge->getvar("getenv('SSW_GEN')")
 if is_blank(chk) then oBridge->execute, '@' + pref_get('IDL_STARTUP')
endif

if obridge->status() then begin
 message,'Thread busy. Come back again later.',/cont
 return
endif

;-- create command to send to IDL-IDL bridge

cmd='hsi_read_flarelist_wrap,err_msg=err_msg,verbose=verbose'
obridge->setvar,"err_msg",err_msg
obridge->setvar,"verbose",verbose

;-- include additional extra keywords

if is_struct(extra) then begin
 tags=tag_names(extra)
 extra_cmd=''
 ntags=n_elements(tags)
 for i=0,ntags-1 do begin
  obridge->setvar,tags[i],extra.(i)
  extra_cmd=extra_cmd+tags[i]+'='+tags[i]
  if i lt (ntags-1) then extra_cmd=extra_cmd+','
 endfor
 cmd=cmd+','+extra_cmd
endif

;-- send copy command to thread

if verbose then message,'Submitting - '+cmd,/cont

obridge->execute,cmd,/nowait

;-- check status

case obridge->status(err=err_msg) of
 1: message,'Submitted...',/cont
 2: message,'Completed.',/cont
 3: message,'Failed - '+err,/cont
 4: message,'Aborted - '+err,/cont
 else: message,'Idle',/cont
endcase

if is_string(err_msg) then message,err_msg,/cont

return & end

;---------------------------------------------------------------------------

function hsi_read_flarelist2,_ref_extra=extra,force=force

@hsi_flarelist_com

;-- skip bridge if data already read and not forcing

force=keyword_set(force)
if exist(flare_data) and exist(flare_info) and ~force then $
 return,hsi_read_flarelist(_extra=extra)

;-- use bridge if supported
 
if since_version('6.3') then begin
 hsi_read_flarelist_thread,_extra=extra,force=force 
 return,''
endif

;-- default to non-bridge version

return,hsi_read_flarelist(_extra=extra,force=force)

end
