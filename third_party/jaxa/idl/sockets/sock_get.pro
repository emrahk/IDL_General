;+
; Project     : VSO
;
; Name        : SOCK_GET
;
; Purpose     : Wrapper around IDLnetURL object to download
;               files via HTTP and FTP
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_get,url,out_name,out_dir=out_dir
;
; Inputs      : URL = remote URL file name to download
;               OUT_NAME = optional output name for downloaded file
;
; Outputs     : See keywords
;
; Keywords    : LOCAL_FILE = Full name of copied file
;               OUT_DIR = Output directory to download file
;               CLOBBER = Clobber existing file
;               STATUS = 0/1/2 fail/success/file exists
;               CANCELLED = 1 if download cancelled
;               PROGRESS = Show download progress
;               NO_CHECK = don't check remote server for valid URL.
;                          Use when sure that remote file is
;                          available.
;
; History     : 27-Dec-2009, Zarro (ADNET) - Written
;                8-Oct-2010, Zarro (ADNET) - Dropped support for
;                COPY_FILE. Use LOCAL_FILE.
;               28-Sep-2011, Zarro (ADNET) - ensured that URL_SCHEME
;               property is set to that of input URL   
;               19-Dec-2011, Zarro (ADNET) 
;                - made http the default scheme
;               7-Sep-2012, Zarro (ADNET)
;                - added more stringent check for valid HTTP status code
;                  200
;               27-Sep-2012, Zarro (ADNET)
;                - added check for FTP status code
;               27-Dec-2012, Zarro (ADNET)
;                 - added /NO_CHECK
;               12-Mar-2012, Zarro (ADNET)
;                 - replaced SOCK_RESPONSE by SOCK_HEAD
;               25-May-2014, Zarro (ADNET)
;                 - vectorized
;                 - use FILE_MOVE,/OVERWRITE instead of FILE_DELETE
;               20-Oct-2014, Zarro (ADNET)
;                 - added more header error checking
;               3-Nov-2014, Zarro (ADNET)
;                 - relaxed some error checking
;               8-Nov-2014, Zarro (ADNET)
;                 - improved FTP support
;               18-Nov-2014, Zarro (ADNET)
;                 - added check for local vs remote timestamps
;                 - sped up progress bar by reducing plot updates
;               25-Nov-2014, Zarro (ADNET)
;                 - can now set PROGRESS to value between 1 and 100%
;                   (e.g. PROGRESS=20 to update every 20%)
;                 - check timestamp of remote file for newer version
;                   (requires making CHECK the default)
;               5-Feb-2015, Zarro (ADNET)
;                 - added additional checks for failed downloads
;               10-Feb-2015, Zarro (ADNET)
;               - pass input URL directly to IDLnetURL2 to parse
;                 PROXY keyword properties in one place
;               28-Nov-2015, Zarro (ADNET)
;               - check for blank file name in queries
;-

;-----------------------------------------------------------------  
function sock_get_callback, status, progress, data  

if (progress[0] eq 1) && (progress[1] gt 0) then begin
 if ptr_valid(data) then begin
  (*data).completed=progress[1] eq progress[2]
  val = float(progress[2])/float(progress[1])
  pval=100.*val
  if ~(*data).completed && ~(*data).cancelled then begin
   if ~widget_valid( (*data).pid) then begin
    bsize=progress[1]
    bmess=trim(str_format(bsize,"(i10)"))
    cmess=['Please wait. Downloading...','File: '+(*data).file,$
           'Size: '+bmess+' bytes',$
           'From: '+(*data).server,$
           'To: '+(*data).ofile]
    (*data).pid=progmeter(/init,button='Cancel',_extra=extra,input=cmess)
   endif
  endif 
 
  if (pval ge (*data).bar) then begin
   if widget_valid((*data).pid) then begin
    if (progmeter((*data).pid,val) eq 'Cancel') then begin
     xkill,(*data).pid
     (*data).cancelled=1b
     return,0
    endif else (*data).bar=(*data).bar+(*data).init
   endif
  endif 
 endif
endif

if ~exist(bsize) then bsize=0l
if ptr_valid(data) then begin
 (*data).bsize=bsize
 if ((*data).completed || (*data).cancelled) then xkill,(*data).pid
endif
 
return, 1
end

;-----------------------------------------------------------------------------

pro sock_get_main,url,out_name,clobber=clobber,local_file=local_file,no_check=no_check,$
  progress=progress,err=err,status=status,cancelled=cancelled,$
  out_dir=out_dir,_ref_extra=extra,verbose=verbose,$
  response=response,debug=debug

err='' & status=0

verbose=keyword_set(verbose)
error=0
catch,error
if (error ne 0) then begin
 if keyword_set(debug) then mprint,err_state()
 catch, /cancel
 message,/reset  
 goto,bail  
endif
  
cancelled=0b
local_file=''
clobber=keyword_set(clobber)

stc=url_parse(url)
file=file_break(stc.path)
path=file_break(stc.path,/path)+'/'
if is_blank(file) && is_blank(path) then begin
 err='File name not included in URL path.'
 mprint,err
 return
endif

;-- default copying file with same name to current directory
 
odir=curdir()
ofile=file
if n_elements(out_name) gt 1 then begin
 err='Output filename must be scalar string.'
 mprint,err
 return
endif

if is_string(out_name) then begin
 tdir=file_break(out_name,/path)
 if is_string(tdir) then odir=tdir 
 ofile=file_break(out_name)
endif
if is_string(out_dir) then odir=out_dir
if ~test_dir(odir,/verbose,err=err) then return

check=~keyword_set(no_check)
bsize=0l & chunked=0b & ok=1b & rdate=''
if check then begin
 ok=sock_check(url,response=response,chunked=chunked,disposition=disposition,size=bsize,$
               _extra=extra,date=rdate,code=code,debug=debug)
 if ~ok then begin
  err='URL not accessible. Status code = '+trim(code)
  mprint,err
  return
 endif
 if keyword_set(debug) then begin
  print,'% RDATE: '+rdate
  print,'% BSIZE: '+trim(bsize)
 endif
 if is_string(disposition) then ofile=disposition
endif

;-- if file exists, download a new one if /clobber or local size or time
;   differs from remote

ofile=local_name(concat_dir(odir,ofile))
chk=file_info(ofile)
if chk.directory then begin
 err='Could not determine download file name - check query string.'
 mprint,err
 return
endif

have_file=chk.exists
osize=chk.size

;-- check if remote file is newer

newer_file=0b
if valid_time(rdate) && have_file then begin
 local_time=anytim(file_time(ofile))
 remote_time=anytim(rdate)+ut_diff(/sec)
 dprint,'% Remote file time: ',anytim(remote_time,/vms)
 dprint,'% Local file time: ',anytim(local_time,/vms)
 newer_file=remote_time gt local_time
 if verbose then if newer_file then mprint,'Remote file is newer than local file.'
endif

size_change=0b
if (bsize gt 0) && (osize gt 0) then if (bsize ne osize) then size_change=1b

download=~have_file || clobber || size_change || newer_file

if ~download && ok then begin
 if verbose then mprint,'Identical local file '+ofile+' already exists (not downloaded). Use /clobber to re-download.'
 local_file=ofile
 status=2
 return
endif

;-- initialize object 

ourl=obj_new('idlneturl2',url,_extra=extra,debug=debug)

;-- show progress bar?

if keyword_set(progress) then begin
 if ~chunked && (bsize ne 0) then begin
  bar= 100. <  float(progress) > 10.
  if allow_windows() && (bar lt 100.) then begin
   callback_function='sock_get_callback'
   init=bar
   callback_data=ptr_new({file:file_basename(ofile),server:stc.host,ofile:ofile,pid:0l,bsize:bsize,init:init,$
    bar:bar,cancelled:0b,completed:0b})
   ourl->setproperty,callback_data=callback_data,callback_function=callback_function
  endif
 endif
endif

;-- download into temporary file and then rename to output file 

if verbose then t1=systime(/seconds)
t_ofile=ofile+'_temp'

result = oUrl->Get(file=t_ofile)  

;-- check what happened

bail: 

merr='Download failed - Zero size or partially downloaded file.'
if is_string(result) then begin
 chk=file_info(t_ofile)
 have_file=chk.exists
 tsize=chk.size
 if ((bsize gt 0) && (tsize gt 0)) then if (tsize ne bsize) then have_file=0b
 if have_file then begin
  bsize=tsize
  if verbose then begin
   t2=systime(/seconds)
   tdiff=t2-t1
   m1=trim(string(bsize,'(i10)'))+' bytes of '+file_basename(ofile)
   m2=' copied in '+strtrim(str_format(tdiff,'(f8.2)'),2)+' seconds.'
   mprint,m1+m2
  endif
  file_move,t_ofile,ofile,/overwrite,/allow_same
  local_file=ofile
  status=1
  file_chmod,ofile,/a_read,/a_write 

;-- update timestamp of downloaded file to local time

  if ~valid_time(rdate) then begin
   ourl->getproperty,response_header=response
   sock_content,response,date=rdate
  endif
  if valid_time(rdate) then begin
   local_time=anytim(anytim(rdate)+ut_diff(/sec),/vms)
   file_touch,ofile,local_time
  endif
 endif else begin
  err=merr
  mprint,err
 endelse
endif else begin 
 if ptr_valid(callback_data) then begin
  if (*callback_data).cancelled then begin
   err='Download cancelled.' 
   cancelled=1b
  endif else err=merr
 endif else err=merr
 mprint,err
endelse

;-- clean up

if is_string(t_ofile) then file_delete,t_ofile,/quiet,/noexpand_path,/allow_nonexistent
;if ~cancelled && is_string(err) && is_string(ofile) then file_delete,ofile,/quiet,/noexpand_path,/allow_nonexistent

obj_destroy,ourl
if ptr_valid(callback_data) then heap_free,callback_data

return & end  

;-----------------------------------------------------------------------
  
pro sock_get,url,out_name,local_file=local_file,_ref_extra=extra,$
                     status=status,err=err,cancelled=cancelled

if ~since_version('6.4') then begin
 err='Requires IDL version 6.4 or greater.'
 mprint,err
 return
endif

if ~is_url(url) then begin
 pr_syntax,'sock_get,url,out_dir=out_dir'
 return
endif

np=n_elements(url)
if is_string(out_name) then begin
 if (n_elements(out_name) ne np) then begin
  err='Number of elements of output file name and input URL must match.'
  mprint,err
  return
 endif
endif else out_name=strarr(np)
 
local_file=strarr(np)

for i=0,np-1 do begin
 sock_get_main,url[i],out_name[i],local_file=lfile,err=err,status=status,$
               cancelled=cancelled,_extra=extra
 if is_string(err) || (status eq 0) || cancelled then continue
 local_file[i]=lfile
endfor

if np eq 1 then local_file=local_file[0]

return & end

