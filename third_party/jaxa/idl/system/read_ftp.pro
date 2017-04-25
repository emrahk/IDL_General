;+
; READ_FTP
;
; Syntax:
;   READ_FTP, remote_host [, files] [, directory] [,/FILE] [,DATA=variable]
;              [,USER=string] [,PASS=string] [,/PTR]
;
; Arguments
;   remote_host - Name of the remote host (ftp server) that you want
;                 to connect to, or a complete ftp location such as for example:
;                      ftp://ftp.rsinc.com/pub/gzip/README.GZIP
;
;   directory - Remote directory where the files reside on the ftp
;               server
;
;   files - A single filename or an array of filenames to be
;           retrieved.
;
; Keywords
;   FILE - Set this keyword to make a local copy of the file to be
;          transferred.  The local file will have the same name as the
;          remote file and will be placed in the current working
;          directory.
;
;   DATA - Set this to a named variable that will contain either a
;          byte array or an array of pointers to byte arrays with the
;          transferred data.  If there is more than one file, an array
;          of pointers is returned, one for each file.
;          Note that when downloading large files using /FILE
;          instead will require much less memory since the entire file
;          is not stored in a variable in that case.
;
;   PTR  - Set this keyword to return an array of pointers
;          even when there is only one file.
;
;   USER - Specify user name to connect to server with.  Default is:
;          anonymous.
;
;   PASS - Specify password to use when connecting.  Default is:
;          test@test.com.
;
;   ASCII - return data in ASCII format
;
;   CLOBBER - clobber existing files when downloading
;
;   OUT_DIR - local download directory [def = current]
;
;   RSIZE  - size (bytes) of remote files
;
; HISTORY - 1-Jan-06, Zarro (L-3Com/GSFC)- adapted and modified from: 
;           http://www.rsinc.com/services/techtip.asp?ttid=3537
;           24-Dec-06, Zarro (ADNET/GSFC) - added RSIZE
;
;
; Examples of use.
; 1) Retrieve and print the contents of ftp://ftp.rsinc.com/pub/gzip/README.GZIP:
;   IDL> READ_FTP, 'ftp://ftp.rsinc.com/pub/gzip/README.GZIP', DATA=data
;   IDL> elp, data
;          DATA            BYTE      = Array[2134]
;   IDL> print, string(data)
;     ------------------------------------------------------------------------------
;     README file: Research Systems Anonymous FTP site (ftp.rsinc.com)
;                   pub directory
;                   gzip directory
;   ------------------------------------------------------------------------------
;   ...
;
; 2) Retrieve some files from podaac.jpl.nasa.gov and store the files
;    in the current working directory:
;
;    IDL> files = string(lindgen(10)+50,format='(%"MGB370.%3.3d.gz")')
;    IDL> READ_FTP, 'podaac.jpl.nasa.gov', files,  $
;    IDL>
;    'pub/sea_surface_height/topex_poseidon/mgdrb/data/MGB_370', /FILE
;
;-
pro ftp_post, u, cmd, res, out=out, count=count

;  compile_opt idl2
  if (cmd ne '') then begin
    printf, u, cmd, format='(a)'
;
; comment out the following line to disable debug info
;    print, '>'+cmd
  endif
  if (size(out,/type) eq 0) then out='2?? *'
  catch, err
  if (err ne 0) then return
  line=''
  count=0
  while arg_present(res) do begin
    readf, u, line
    if count eq 0 then res=line else res=[res,line]
    count=count+1
;
; comment out the following line to disable debug info
;    print, '<'+line
    if strmatch(line,out) then break
  endwhile
end

pro ftp_parse_pasv, text, host, port
  t=strtrim(text,2)
  ind=where(strcmp(t,'227',3))
  i=ind[0]
  if (i ne -1) then begin
    sub=stregex(t[i],'\([0-9,]*\)',/extract)
    p=str_sep(strmid(sub,1,strlen(sub)-2),',')
    p=strtrim(p,2)
    host=p[0]+'.'+p[1]+'.'+p[2]+'.'+p[3]
    port=256*long(p[4])+long(p[5])
  endif
end

pro read_ftp, site, files, dir, port, data=data, file=file, user=user, $
              pass=pass, ptr=ptr,ascii=ascii,err=err,verbose=verbose,rsize=rsize,$
              clobber=clobber,out_dir=out_dir,copy_file=copy_file,status=status

;  compile_opt idl2

;-- input/keyword & error checks

  err='' & status=1b
  verbose=keyword_set(verbose)
  clobber=keyword_set(clobber)
  ascii=keyword_set(ascii)
  download=arg_present(file) or arg_present(data)
  get_size=arg_present(rsize)

  if n_elements(port) eq 0 then port='ftp'
  if n_elements(files) eq 0 then begin
    if strcmp(site,'ftp://',6) then host=strmid(site,6) else host=site
    pos=strpos(host,'/')
    dir=strmid(host,pos)
    host=strmid(host,0,pos)
    pos=strpos(dir,'/',/reverse_search)
    files=strmid(dir,pos+1)
    dir=strmid(dir,0,pos)
  endif else host=site

;-- not clobbering, then only copy missing files

  mfiles=files
  if keyword_set(file) then begin
   if not is_dir(out_dir) then out_dir=curdir()
   if not write_dir(out_dir,err=err) then return
   copy_file=concat_dir(out_dir,files)
   if not clobber then begin
    cfiles=have_files(files,out_dir,missing=mfiles,mcount=mcount)
    if mcount eq 0 then begin
     if verbose then message,'Requested file[s] already downloaded.',/cont
     return
    endif
   endif
   ascii=0b
  endif 

  if (size(user,/type) eq 0) then user='anonymous'
  if (size(pass,/type) eq 0) then pass='test@test.com'
  
;-- open FTP socket

  on_ioerror,done
  error=0
  socket, u, host, port, connect_timeout=5, read_timeout=5, /get_lun,error=error
done:on_ioerror,null
  if error ne 0 then begin
   err='Failed connection to '+host
   status=0b
   if verbose then message,err,/cont
   return
endif

;-- login and determine remote file sizes

  ftp_post, u, '', res
  ftp_post, u, 'USER '+user, res, out='3?? *'
  ftp_post, u, 'PASS '+pass, res
  ftp_post, u, 'TYPE I', res
  if (size(dir,/type) ne 0) then ftp_post, u, 'CWD '+dir, res
  n=n_elements(mfiles)
  rsize=lonarr(n)
  if download or get_size then begin
   if download then begin
    bufsize=512
    buffer=bytarr(bufsize)
    if arg_present(data) then dat=ptrarr(n)
    if verbose then message,'Please wait. Downloading...',/cont
   endif
   for i=0, n-1 do begin
    ftp_post, u, 'SIZE '+mfiles[i], res, out='213 *'
    sz=strmid(res[n_elements(res)-1],4)
    if not is_number(sz) then begin
     if verbose then message,'Could not locate '+mfiles[i],/cont
     continue
    endif
    sz=long64(strmid(res[n_elements(res)-1],4))
    rsize[i]=sz
    if ~download and get_size then continue
    if arg_present(data) then dat[i]=ptr_new(bytarr(sz))
    ftp_post, u, 'PASV', res
    ftp_parse_pasv, res, host, port
    ftp_post, u, 'RETR '+mfiles[i], res, out='1?? *'
    dprint,'% PASV port: ',port
    socket, v, host, port, connect_timeout=5, read_timeout=5, $
         /get_lun
    if ascii then begin
     *dat[i]=rd_ascii_buff(v,bufsize)
    endif else begin
     tc=0ll
     if keyword_set(file) then begin
      out_file=concat_dir(out_dir,mfiles[i])
      openw,w,out_file,/get_lun
      if verbose then message,'Downloading '+mfiles[i]+' to '+out_dir,/cont
     endif
     while (tc lt sz) do begin
      if (sz-tc lt bufsize) then begin
       bufsize=sz-tc
       buffer=bytarr(bufsize)
      endif
      readu, v, buffer, transfer_count=dtc
      if arg_present(data) then $
       (*dat[i])[tc]=(dtc eq bufsize)?buffer:buffer[0:dtc-1]
      if keyword_set(file) then $
       writeu,w,(dtc eq bufsize)?buffer:buffer[0:dtc-1]
      tc=tc+dtc
     endwhile
    endelse
    free_lun, v
    if keyword_set(file) then free_lun, w
    ftp_post, u, '', res
   endfor
  
   if arg_present(data) then begin
    if (n gt 1 or keyword_set(ptr)) then data=temporary(dat) $
     else if ptr_exist(dat) then data=temporary(*dat[0])
   endif
   if download and (not exist(data)) and (not keyword_set(file)) then begin
    err='No data transferred'
    status=0b
    message,err,/cont
   endif
  endif
 
  if n eq 1 then rsize=rsize[0]
  ftp_post, u, 'QUIT', res
  free_lun, u

  return & end
