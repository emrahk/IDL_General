;+
; Project     : HESSI
;
; Name        : TRACE__DEFINE
;
; Purpose     : Define a TRACE data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('trace')
;
; History     : Written 30 Dec 2007, D. Zarro (ADNET)
;               Modified 8 Sep 2013, Zarro (ADNET) - added CATCH in ::READ
;
; Contact     : dzarro@solar.stanford.edu
;-

function trace::init,_ref_extra=extra

if ~self->fits::init(_extra=extra) then return,0

;-- setup environment

self->setenv,_extra=extra

return,1 & end

;------------------------------------------------------------------------
;-- setup TRACE environment variables

pro trace::setenv,_extra=extra

if is_string(chklog('TRACE_RESPONSE')) then return
file_env=local_name('$SSW/trace/setup/setup.trace_env')
file_setenv,file_env,_extra=extra
return & end

;-------------------------------------------------------------------------
;-- check that TRACE Databases are loaded  

function trace::have_dbase,err=err,verbose=verbose

err=''
chk=is_dir(local_name('$SSW/trace/dbase')) 
if ~chk then begin
 err='TRACE lookup dbase ($SSW/trace/dbase) not found. Cannot read file.'
 if keyword_set(verbose) then message,err,/info
 return,chk
endif

return,1b
end

;----------------------------------------------------------------------
function trace::have_cal,err=err,verbose=verbose

err=''
have_cal=is_dir('$tdb')
if ~have_cal then err='TRACE calibration directory ($SSWDB/tdb) not found. Returned data will not be prepped.'
if keyword_set(verbose) then message,err,/info
return,have_cal
end

;-------------------------------------------------------------------------
;-- check for trace_decode_idl shareable object

function trace::have_decoder,err=err,verbose=verbose,_extra=extra

err=''
verbose=keyword_set(verbose)
wdir=!version.OS + '_' + !version.ARCH 
decomp='trace_decode_idl.so'
if os_family() eq 'Windows' then decomp='trace_decode_idl.dll'

share=local_name('$SSW_TRACE/binaries/'+wdir+'/'+decomp)
chk=file_search(share,count=count)
if count eq 0 then begin
 share=local_name('$CALL_EXTERNAL_USER/'+decomp)
 chk=file_search(share,count=count)
endif


;-- download a copy to temporary directory

if count eq 0 then begin
 warn='IDL shareable object "trace_decode_idl" not found. Cannot read file.'
 if verbose then message,warn+' Downloading from server...',/info
 sdir=get_temp_dir()
 udir=concat_dir(sdir,wdir)
 mk_dir,udir
 mklog,'CALL_EXTERNAL_USER',udir
 sloc=ssw_server(/full)
 sfile=sloc+'/solarsoft/trace/binaries/'+wdir+'/'+decomp
 sock_copy,sfile,out_dir=udir,_extra=extra,/no_check
 chk=file_search(share,count=count)
endif

if count eq 0 then err=warn
if keyword_set(verbose) then message,err,/info

return,count ne 0

end

;--------------------------------------------------------------------------
;-- VSO search wrapper

function trace::search,tstart,tend,_ref_extra=extra,type=type
f=vso_files(tstart,tend,inst='trace',_extra=extra,window=3600.)
type=replicate('euv/images',n_elements(f))
return,f
end

;---------------------------------------------------------------------------
;-- check for TRACE branch in !path

function trace::have_path,err=err,verbose=verbose

err=''
if ~have_proc('read_trace') then begin
 epath=local_name('$SSW/trace/idl')
 if is_dir(epath) then ssw_path,/trace,/quiet
 if ~have_proc('read_trace') then begin
  err='TRACE branch of $SSW not installed. Cannot Prep image.'
  if keyword_set(verbose) then message,err,/info
  return,0b
 endif
endif

return,1b

end

;-------------------------------------------------------------------------
;-- Preselect records from level 0 file

pro trace::preselect,file,image_no,records=records,_ref_extra=extra

image_no=0
if is_blank(file) then return
records=self->read_records(file,_extra=extra)
if is_blank(records) then return
nsub=n_elements(records)
if nsub eq 1 then return
image_no=xsel_list_multi(records,/index,_extra=extra,$
 label=file_break(file)+' - Select image numbers from list below:')

return & end

;--------------------------------------------------------------------------
;-- FITS reader

pro trace::read,file,_ref_extra=extra,image_no=image_no,err=err

err=''
            
;-- download if URL

if is_blank(file) then begin
 pr_syntax,'object_name->read,filename'
 return
endif
self->getfile,file,local_file=ofile,_extra=extra,err=err
if is_blank(ofile) then return

;-- check what is loaded

have_path=self->have_path(err=path_err)
have_cal=self->have_cal(err=cal_err)
have_decoder=self->have_decoder(err=decoder_err)
have_dbase=self->have_dbase(err=dbase_err)

;-- read files

nfiles=n_elements(ofile)
j=0
img_input=exist(image_no)
if img_input then img_input=is_number(image_no[0])
if img_input then begin
 ok=where(image_no ge 0,count)
 if count eq 0 then img_input=0b else image_no=get_uniq(image_no[ok])
endif

cd,cur=cdir
nsub=1
for i=0,nfiles-1 do begin

 error=0
 catch,error
 if error ne 0 then begin
  err=err_state()
  message,err,/info
  catch,/cancel
  error=0
  cd,cdir
  continue
 endif

 valid=self->is_valid(ofile[i],level=level,_extra=extra,err=err)
 if ~valid then continue

 if level eq 1 then begin
  self->fits::read,ofile[i],_extra=extra,/all,/append,err=err
  j=self->get(/count)
  continue
 endif

 if ~have_decoder then begin
  xack,decoder_err
  continue
 endif

 if ~have_dbase then begin
  xack,dbase_err
  continue
 endif

 if ~have_cal then xack,cal_err,/suppress
 if ~have_path then xack,path_err,/suppress

 dfile=ofile[i]
 if is_compressed(dfile) then begin
  dfile=find_uncompressed(dfile,err=err)
  if is_string(err) then continue
 endif
 if ~img_input then begin
  self->preselect,dfile,image_no,records=records,/no_check,cancel=cancel
  if cancel then continue
 endif else records=self->read_records(dfile,/no_check)
 nsub=n_elements(records)
 nimg=n_elements(image_no)

 for k=0,nimg-1 do begin
  if (image_no[k] le -1) or (image_no[k] ge nsub) then begin
   message,'No such image record '+trim(image_no[k]),/info
   continue
  endif
  case 1 of
   have_cal and have_path: begin
    message,'Prepping image '+trim(image_no[k]),/info
    trace_prep,dfile,image_no[k],index,data,/norm,/wave2point,/float,_extra=extra
   end
   have_path: read_trace,dfile,image_no[k],index,data
   else: continue=1
  endcase
  sz=size(data)
  if (sz[0] lt 2) or ~is_struct(index) then continue
  index=rep_tag_value(index,file_basename(ofile[i]),'filename')
  index2map,index,data,map,/no_copy,_extra=extra
  index=rep_tag_value(index,2l,'naxis')
  self->set,j,map=map,index=index,/no_copy
  j=j+1
 endfor
endfor

count=self->get(/count)
if count eq 0 then message,'No maps created.',/info else begin
 for i=0,count-1 do begin
  map=self->get(i,/map,/no_copy)
  index=self->get(i,/index)
  map.id='TRACE '+trim(index.wave_len)+' ('+trim(index.naxis1)+'x'+trim(index.naxis2)+')'  
  self->set,i,map=map,/log_scale,grid=30,/limb,/no_copy
 endfor
endelse


return & end

;-----------------------------------------------------------------------------
;--- read raw records in a TRACE level 0 file

function trace::read_raw,file
 if is_blank(file) then return,''
 if is_url(file) then sock_fits,file,data,extension=1 else data=mrdfits(file,1)
 if ~is_struct(data) then return,''
 count=n_elements(data)
 index={naxis1:0l,naxis2:0l,date_obs:0d,wave_len:''}
 index=replicate(index,count)
 index.naxis1=data.nx_out
 index.naxis2=data.ny_out
 index.wave_len='???'
 index.date_obs=anytim(data,/tai)
 return,index
end
 
;-------------------------------------------------------------------------
;-- read TRACE level 0 records

function trace::read_records,file,count=count,no_check=no_check

count=0
records=''
check=~keyword_set(no_check)
if check then begin
 valid=self->is_valid(file,level=level)
 if level ne 0 then message,file+' is not a level 0 file',/info
 if ~valid or (level ne 0) then return,''
endif

if self->have_path() and ~is_url(file) then read_trace,file,-1,index,/nodata else index=self->read_raw(file)
if ~is_struct(index) then return,''
count=n_elements(index)
records=trim(sindgen(count))+') TIME: '+trim(anytim2utc(index.date_obs,/vms))+ $
        ' WAVELENGTH: '+strpad(trim(index.wave_len),4,/after)+ $
        ' NAXIS1: '+strpad(trim(index.naxis1),4,/after)+ $
        ' NAXIS2: '+strpad(trim(index.naxis2),4,/after)
return,records
end

;------------------------------------------------------------------------------
;-- check if valid TRACE file

function trace::is_valid,file,err=err,level=level,verbose=verbose

valid=0b & level=0 & err=''
verbose=keyword_set(verbose)
if is_url(file) then sock_fits,file,header=header,/nodata,err=err else $
 mrd_head,file,header,err=err
if is_string(err) then begin
 message,'Could not read header - '+file,/info
 return,valid
endif

chk1=where(stregex(header,'MPROGNAM.+TR_REFORMAT',/bool,/fold),count1)
chk2=where(stregex(header,'(INST|TEL|DET|ORIG).+TRAC',/bool,/fold),count2)

valid=(count1 ne 0) or (count2 ne 0)

if ~valid then begin
 message,'Not a valid TRACE file - '+file,/info
 return,valid
endif

if count1 ne 0 then level=0 else if count2 ne 0 then level=1

chk=where(stregex(header,'trace_prep',/bool,/fold),count)
if count gt 0 then level=1
if verbose and (level eq 1) then message,'TRACE image is already prepped.',/info

return,valid
end

;------------------------------------------------------------------------------
;-- TRACE structure definition

pro trace__define,void                 

void={trace,inherits fits, inherits prep}

return & end
