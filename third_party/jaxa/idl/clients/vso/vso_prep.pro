;+
; Project     : VSO
;
; Name        : VSO_PREP
;
; Purpose     : Wrapper around VSO PREP object
;
; Category    : utility sockets
;
; Example     : IDL> vso_prep,file
;
; Inputs      : FILE = input file to process (with optional URL path)
;
; Keywords    : STATUS= 1/0 for success or failure
;               OFILE = prepped output filename
;               ODIR = output directory for prepped file
;               INSTRUMENT = optional instrument [in case can't get from FILE]
;               ERR = error messages
;               OPREP = object with prepped data
;               IMAGE_NO = optional image nos to process [for multiple
;               records]
;               BACKGROUND = run in background (still testing) 
;
; History     : Written 31-March-2009, D.M. Zarro (ADNET)
;               15-Sept-2009, Zarro (ADNET) 
;               - removed INST input (made it optional keyword)
;               - added more error checking and messaging
;               17-Nov-2009, Zarro (ADNET)
;               - added check for write access to output directory
;               23-Dec-2009, Zarro (ADNET)
;               - added check that VSO_PREP server is available
;               25-January-2010, Tolbert (Wyle)
;               - added hooks for selecting prep options
;               10-March-2010, Zarro (ADNET)
;               - added more robust check for file existence (remote
;                 and local)
;               10-July-2010, Zarro (ADNET)
;               - added ODIR
;               24-July-2010, Zarro (ADNET)
;               - added capability to select backup server
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

;--------------------------------------------------------------------------

pro vso_prep_main,file,ofile=ofile,_extra=extra,image_no=image_no,$
            odir=odir,$
            status=status,err=err,instrument=instrument,oprep=oprep,cancel=cancel

status=0b & cancel=0b
error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err=err_state()
 message,err,/cont
 status=0b
 if obj_valid(vsoprep) then obj_destroy,vsoprep
 if obj_valid(request) then obj_destroy,request
 if obj_valid(otemp) then obj_destroy,otemp
 java_debug
 return
endif

;-- no need to enter filename for RHESSI

if is_blank(file) then begin
 derr='vso_prep,file [,instrument=instrument,ofile=ofile]'
 if is_blank(instrument) then err='Missing input file and instrument name.'
 if is_string(instrument) then if ~stregex(instrument,'HESSI',/bool,/fold) then err='Missing input file name.'
 if is_string(err) then begin
  message,err,/cont
  pr_syntax,derr & return
 endif
endif

;-- check if file exists

if is_string(file) then begin
 url=is_url(file,/scheme)
 if url then chk=sock_check(file,err=err) else chk=loc_file(file,err=err)
 if is_string(err) then begin
  message,err,/cont
  return
 endif
endif 

;-- check if VSO Prepserver is available

if ~vso_prep_check(server=server,err=err) then return

;-- determine instrument by checking file header (if not entered)

if is_string(instrument) then instrument=strupcase(strtrim(instrument,2))
if is_string(file) then begin
 inst=get_fits_det(file,prepped=prepped,err=err,/quiet)
 if prepped or stregex(inst,'HESSI',/bool,/fold) then begin
  message,file+' already prepped.',/cont
  message,/reset
  ofile=file
  status=1b
  return
 endif
 if is_blank(inst) and is_string(instrument) then inst=instrument
 if is_string(instrument) then begin
  if instrument ne inst then begin
   message,'Input instrument keyword ('+instrument+') does not match input file ('+inst+').',/cont
   message,'Assuming '+inst,/cont
   message,/reset
  endif
 endif
endif

if is_blank(inst) and is_string(instrument) then inst=instrument
if is_blank(inst) then begin
 err='Could not determine instrument name.'
 message,err,/cont
 return
endif

chk=stregex(inst,'(EIT|TRACE|EUVI|XRT|EIS|HESSI|COR1|COR2)',/bool,/fold)
if ~chk then begin
 err='Prepping not currently supported for '+inst+' data.'
 message,err,/cont
 return
endif

;-- default output prepped file to current directory

out_file='prepped_temp.fits'
if is_string(file) then begin
 out_file='prepped_'+file_basename(file)
 out_file=str_replace(out_file,'.gz','')
endif

if is_string(ofile) then begin
 out_dir=file_dirname(ofile)
 out_file=file_basename(ofile)
endif

if is_dir(odir) then out_dir=odir
if is_blank(out_dir) then out_dir=curdir()
if out_dir eq '.' then out_dir=curdir()
if ~test_dir(out_dir,_extra=extra,err=err) then begin
 message,err,/cont
 return
endif

ofile=concat_dir(out_dir,out_file)

;-- load Java files

vso_startup, status=status
if ~status then begin
 err='Problem loading IDL-Java bridge.'
 message,err,/cont
 return
endif

message,'Prepping '+inst+' data...',/info

;-- check if preselecting image records

otemp=obj_new(inst)
if have_method(otemp,'get_prep_opts') then otemp->get_prep_opts, _extra=extra
if ~exist(image_no) then begin
 if have_method(otemp,'preselect') then begin
  otemp->preselect,file,image_no,cancel=cancel
  if cancel then begin
   message,'Prepping cancelled',/cont
   obj_destroy,otemp
   return
  endif
 endif
endif

;-- create new VSO PREP object

status=0b
vsoprep = OBJ_NEW($
'IDLJavaObject$STATIC$GOV_NASA_GSFC_JIDL_VPS_CLIENT_PREPROCESSORCLIENTREQUEST', $
'gov.nasa.gsfc.jidl.vps.client.PreprocessorClientRequest')

if ~obj_valid(vsoprep) then begin
 err='Error creating VSO PREP object.'
 message,err,/cont
 java_debug
 return
endif

;-- set the server

c=stregex(server,'//([^/\.]+)\.',/ext,/sub)
vserver=c[1]
message,'Selecting PrepServer on '+server,/cont

vsoprep->selectserver,vserver

;-- create request object

request=vsoprep->newrequest(inst)
if is_string(file) then request->addData,file
if exist(image_no) then begin
 request->addparameter,'image_no',image_no
endif

;-- pass command line prep keywords

if is_struct(extra) then begin
 names=tag_names(extra)
 for i=0,n_elements(names)-1 do request->addparameter,names[i],extra.(i)
endif

;-- send to prep server

request->preprocess

;-- download prepped file

file_delete,ofile,/quiet
result=request->getData()
if is_string(result) then begin
 sock_copy,result,ofile,_extra=extra
 chk=file_search(ofile,count=count)
endif else count=0

if count gt 0 then begin
 message,'Prepping completed successfully.',/info
 message,'Wrote prepped data to - '+ofile,/info
 message,/reset
 status=1b 

;-- return prepped object

 if arg_present(oprep) then begin
  if obj_valid(oprep) then obj_destroy,oprep
  oprep=otemp
  oprep->read,ofile
 endif else obj_destroy,otemp
endif else begin
 err='Prepping failed.'
 message,err,/cont
 java_debug
 obj_destroy,otemp
endelse

;-- cleanup

obj_destroy,vsoprep
obj_destroy,request


return & end

;-----------------------------------------------------------------------------

;--- call back routine to notify when thread is complete

pro vso_prep_callback, status, error, oBridge, userdata

inst=obridge->getvar('instrument')
err=obridge->getvar('err')
if is_string(err) then message,err,/cont
ofile=obridge->getvar('ofile')

if status eq 2 then begin
 message,'VSO_PREP completed.',/cont
endif

if is_string(ofile) then message,ofile,/cont
if is_string(error) then message,error,/cont

return & end

;---------------------------------------------------------------------------------

pro vso_prep_thread,file,_extra=extra,instrument=instrument,$
         verbose=verbose,ofile=ofile,odir=odir,reset=reset,err=err

common vso_prep,obridge

if keyword_set(reset) then if obj_valid(obridge) then obj_destroy,obridge
verbose=keyword_set(verbose)

err=''
if ~since_version('6.3') then begin
 err='Requires at least IDL version 6.3.'
 message,err,/cont
 return
endif

;-- create IDL-IDL bridge object
;-- make sure thread object has same SSW IDL environment/path as parent

if verbose then output=''

if ~obj_valid(obridge) then begin
 obridge = Obj_New('IDL_IDLBridge',callback='vso_prep_callback',output=output)
 chk=obridge->getvar("getenv('SSW_GEN')")
 if is_blank(chk) then oBridge->execute, '@' + pref_get('IDL_STARTUP')
endif

if obridge->status() then begin
 message,'Thread busy. Come back again later.',/cont
 return
endif

;-- set input file

if is_string(file) then dfile=full_path(file) else dfile=''
obridge->setvar,"file",dfile

;-- pass in any keywords. Have to manually parse out keywords in extra
;   since the bridge object doesn't honor _extra.

if is_string(ofile) then obridge->setvar,"ofile",ofile else $
 obridge->setvar,"ofile",''

if is_string(odir) then obridge->setvar,"odir",odir else $
 obridge->setvar,"odir",''

if is_string(instrument) then obridge->setvar,"instrument",instrument else $
 obridge->setvar,"instrument",''

obridge->setvar,"err",''

cmd='vso_prep,file,err=err,ofile=ofile,odir=odir,instrument=instrument'
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

obridge->execute,cmd,/nowait

;-- check status

case obridge->status(err=err) of
 1: message,'Request sent to VSO Prepserver...',/cont
 2: message,'Completed.',/cont
 3: message,'Failed - '+err,/cont
 4: message,'Aborted - '+err,/cont
 else: message,'Idle',/cont
endcase

if is_string(err) then message,err,/cont

return & end

;--------------------------------------------------------------------------

pro vso_prep,file,_ref_extra=extra,background=background

if keyword_set(background) and since_version('6.3') then vso_prep_thread,file,_extra=extra else $
 vso_prep_main,file,_extra=extra
 
return & end
