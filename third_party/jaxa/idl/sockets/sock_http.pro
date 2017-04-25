;+
; Project     : VSO
;
; Name        : SOCK_HTTP
;
; Purpose     : Read and process HTTP requests over a socket LUN
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_http,lun
;
; Inputs      : LUN = open socket LUN
;
; Outputs     : VALUE = HTTP header
;
; Keywords    : ERR = error string
;
; History     : 13 February 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_http,lun,value,err=err,_ref_extra=extra

err='' & value='' & success=0b
cr=string(13b)
if is_blank(chklog('HTTP_WRITE')) then mklog,'HTTP_WRITE',get_temp_dir()
if is_blank(chklog('HTTP_READ')) then mklog,'HTTP_READ',get_temp_dir()
on_ioerror,bail

error=0
catch, error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
 goto,bail
endif

if ~is_number(lun) then begin
 pr_syntax,'sock_http,socket_lun,variable_value'
 return
endif

if ~is_socket(lun,rawio=rawio) then begin
 err='Socket unavailable.'
 mprint,err
 return
endif

if rawio then begin
 err='Cannot process HTTP requests over raw I/O socket.'
 mprint,err
 return
endif

;-- read HTTP header

header='' & text='xxx'
while text ne  '' do begin
 readf,lun,text
 header=[header,text]
endwhile
nhead=n_elements(header)
if nhead gt 1 then value=header[1:nhead-1] else value=''
if is_blank(value) then begin
 mprint,'Client not sending valid header request.'
 goto,bail
endif

;-- check request type

req=str2arr(value[0],' ')
print,header
fname=ascii_decode(local_name(req[1]))
sock_content,value,size=bsize,accept=accept

;-- check if requesting PUT 

if req[0] eq 'PUT' then begin
 sock_upload,fname,lun,_extra=extra,bsize=bsize
 return
endif

;-- bail if not GET or HEAD

if (req[0] ne 'GET') && (req[0] ne 'HEAD') then begin
 bail:
 err='Invalid HTTP request.'
 mprint,err
 if exist(req) then mprint,req[0]
 hstatus='HTTP/1.1 400 Bad Request'
 printf,lun,hstatus+cr
 printf,lun,'Connection: close'+cr
 printf,lun,cr
 return
endif

;--check if executing IDL command

proc=url_command(fname)
if is_string(proc) then begin
 head=req[0] eq 'HEAD'
 sock_service,fname,lun,_extra=extra,head=head
 return
endif

;-- check if requesting file

bsize=0l
if fname eq '/' then bsize=1L else begin
 source=chklog('HTTP_READ')
 if is_string(source) then begin
  aname=concat_dir(source,fname)
  if file_test(aname,/read,/regular) then bsize=file_size(aname)
 endif
endelse

if bsize gt 0 then hstatus='HTTP/1.1 200 OK' else $
 hstatus='HTTP/1.1 404 Not Found'
printf,lun,hstatus+cr
printf,lun,systime(/utc)+' GMT'+cr
printf,lun,'Content-Length: '+trim(bsize)+cr
printf,lun,'Connection: close'+cr
printf,lun,cr
if bsize eq 0 then begin
 err='File not found - '+fname
 mprint,err
 return
endif

;-- send requested file

if (req[0] eq 'GET') && (strlowcase(accept) ne 'none') && file_test(aname,/regular) then begin
 bdata=file_stream(aname)
 sock_writeb,lun,bdata,err=err,_extra=extra
 destroy,bdata
endif

return & end
