;+
; Project     : VSO
;
; Name        : SOCK_PREP
;
; Purpose     : PREP a file using SOCK_CLIENT
;               Before calling, type:
;               IDL> sock_client
;
; Category    : utility analysis sockets
;
; Inputs      : FILE = string file name or URL to prep
;
; Outputs     : PFILE = prepped file name (def = 'prepped_'+file)
;
; Keywords    : EXTRA = prep keywords to pass to prep routine
;               ERR = error string
;               LUN = unit number of SOCK_SERVER (determined from port)
;
; History     : 30-Dec-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_prep,ifile,pfile,err=err,lun=lun,_extra=extra,out_dir=out_dir,$
                          verbose=verbose

pfile=''
return_err=arg_present(err)
return_err=1b
err=''
verbose=keyword_set(verbose)
session=session_id()

if ~is_number(lun) then begin
 ports=sock_ports(count=count)
 if count eq 0 then begin
  err='Socket client not running or connected to server.'
  mprint,err
  mprint,'To start client, enter: "IDL> sock_client"'
  return
 endif
 lun=sock_luns(ports[0],count=count)
 if count eq 0 then begin
  mprint,'Socket client not connected.'
  return
 endif
endif

if is_blank(ifile) then begin
 err='Missing input file.'
 pr_syntax,'sock_prep,file'
 return
endif

if n_elements(ifile) ne 1 then begin
 err='Can only handle one file at a time.'
 mprint,err
 return
endif

if is_string(out_dir) then begin
 if ~file_test(out_dir,/dir,/write) then begin
  err='Inaccessible output directory '+out_dir
  mprint,err
  return
 endif
endif

if is_url(ifile,/scheme) then idata=ifile else begin
 if ~file_test(ifile,/regular,/read) then begin
  err='Unreadable or missing file - '+ifile
  mprint,err
  return
 endif
 mprint,'Uploading file to Prep Server...'
 idata=file_stream(ifile,/compress,err=err)
 if is_string(err) then return
endelse

idata_name='idata_'+session
pdata_name='pdata_'+session

sock_sendvar,lun,idata_name,idata,session=session,$
 _extra=extra,err=err,verbose=verbose
if is_string(err) then return

err_name='err_'+session
ofile_name='ofile_'+session
ifile_name='ifile_'+session
sock_sendvar,lun,ifile_name,ifile,session=session,_extra=extra,err=err,verbose=verbose
prep_cmd='prep_data,idata_'+session+',pdata_'+session+',err='+err_name+$
          ',ofile='+ofile_name+',ifile='+ifile_name
if is_struct(extra) then begin
 extra_name='extra_'+session
 sock_sendvar,lun,extra_name,extra,session=session,_extra=extra,err=err,verbose=verbose
 if is_string(err) then return
 prep_cmd=prep_cmd+',_extra='+extra_name
endif

mprint,'Waiting for Prep Server...'
sock_sendcmd,lun,prep_cmd,session=session,_extra=extra,err=err,verbose=verbose
if is_string(err) then return

ready=0b
repeat begin
 status=sock_getvar(lun,/status,timeout=timeout,_extra=extra,verbose=verbose)
 if is_struct(status) then ready=status.status ne 1
endrep until (ready || timeout)

if timeout || ~ready then begin
 mprint,'Prep Server busy. Try again later.'
 return
endif

ofile=''
pdata=sock_getvar(lun,pdata_name,_extra=extra,verbose=verbose)
if exist(pdata) then ofile=sock_getvar(lun,ofile_name,_extra=extra,verbose=verbose)
if is_string(ofile) then begin
 mprint,'Prep Server completed successfully.'
 if is_url(ifile,/scheme) then odir=curdir() else odir=file_dirname(def_file(ifile))
 ofile=concat_dir(odir,ofile)
 write_stream,ofile,pdata,err=err,/uncompress,out_dir=out_dir,local_file=pfile,verbose=verbose
 if is_string(err) then return
 mprint,'Prepped file written to => '+pfile
endif else begin
 if return_err then err=sock_getvar(lun,err_name,_extra=extra,timeout=timeout,verbose=verbose) else $
  err='Prep Server unsuccessful.'
endelse

if is_string(err) then mprint,err

return & end
