;+
; Project     : VSO
;
; Name        : SOCK_UPLOAD
;
; Purpose     : Upload file to server requested by PUT command
;               File written to directory pointed to by $HTTP_WRITE
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_upload,fname,lun
;
; Inputs      : FNAME = filename to upload
;               LUN = socket LUN 
;
; Outputs     : None
;
; Keywords    : ERR = error string
;
; History     : 27 March 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_upload,fname,lun,_extra=extra,server=server,port=port,err=err

err=''
cr=string(13b)
target=chklog('HTTP_WRITE')
if ~file_test(target,/dir,/write) then begin
 err='Write access denied.'
 mprint,err
endif

;-- upload to unique directory under HTTP_WRITE

if is_blank(err) then begin
 session=session_id()
 odir=concat_dir(target,session)
 file_mkdir,odir
 aname=concat_dir(odir,file_basename(fname))
 lname=concat_dir('/'+session,file_basename(fname))
 sock_readb,lun,buffer,err=err,_extra=extra
 if is_blank(err) then write_stream,aname,buffer,err=err
 destroy,buffer
endif

;-- return location in response header

if is_blank(err) then begin
 prefix=''
 if is_string(server) then begin
  prefix='http://'+trim(server)
  if is_number(port) then prefix=prefix+':'+trim(port)
 endif
 hstatus='HTTP/1.1 201 Created'
 printf,lun,hstatus+cr
 printf,lun,systime(/utc)+' GMT'+cr
 printf,lun,'Content-Type: text/plain'+cr
 printf,lun,'Location: '+prefix+lname+cr
 printf,lun,'Connection: close'+cr
 printf,lun,cr
endif else begin
 bail: hstatus='HTTP/1.1 400 Bad Request'
 printf,lun,hstatus+cr
 printf,lun,'Connection: close'+cr
 printf,lun,cr
endelse
return
end
