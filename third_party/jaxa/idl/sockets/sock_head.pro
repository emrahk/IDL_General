;+
; Project     : VSO
;
; Name        : SOCK_HEAD
;
; Purpose     : Wrapper around IDLnetURL object to send HEAD request
;
; Category    : utility system sockets
;
; Syntax      : IDL> header=sock_head(url)
;
; Inputs      : URL = remote URL file name to check
;
; Outputs     : HEADER = response header 
;
; Keywords    : CODE = response code
;             : HOST_ONLY = only check host (not full path)
;             : SIZE = number of bytes in return content
;             : PATH = input URL is a path
;
; History     : 24-Aug-2011, Zarro (ADNET) - Written
;                6-Feb-2013, Zarro (ADNET)
;               - added call to new HTTP_CONTENT function
;               19-Jun-2013, Zarro (ADNET) - renamed to sock_head
;               23-Sep-2014, Zarro (ADNET) - stripped down
;               2-Nov-2014, Zarro (ADNET) - skip callback if no path
;               4-Feb-2015, Zarro (ADNET) 
;               - added check for FTP success code
;               10-Feb-2015, Zarro (ADNET) 
;               - pass input URL directly to IDLnetURL2 to parse
;                 PROXY keyword properties in one place
;               21-Feb-2015, Zarro (ADNET)
;               - added separate check for FTP response headers
;               28-March-2106, Zarro (ADNET)
;               - added "Accept: none" keyword to inhibit download
;-

function sock_head_callback, status, progress, data  

;-- since we only need the response header, we just read
;   the first set of bytes until a non-zero response code is reached

if exist(data) then begin
 print,status
 mprint,'progress[0] '+trim(progress[0])
 mprint,'progress[2] '+trim(progress[2])
endif

if (progress[0] eq 1) && (progress[2] gt 0) then return,0

return,1

end

;-----------------------------------------------------------------------------
  
function sock_head,url,err=err,$
                       _ref_extra=extra,host_only=host_only,code=code,$
                       path=path,debug=debug,size=bsize
err='' 

bsize=0l & code=404

case 1 of
 ~since_version('6.4') : begin
  err='Requires IDL version 6.4 or greater.'
  mprint,err
  return,''
 end
 n_elements(url) ne 1: begin
  err='Input URL must be scalar'
  mprint,err
  return,''
 end
  ~is_url(url): begin
  pr_syntax,'header=sock_head(url)'
  return,''
 end
 else: continue=1
endcase

stc=url_parse(url)
url_path=stc.path
if is_blank(stc.path) || keyword_set(host_only) then url_path='/' 
if keyword_set(path) then if ~stregex(url_path,'\/$',/bool) then url_path=url_path+'/'

;-- initialize object 

ourl=obj_new('idlneturl2',url,_extra=extra,debug=debug,$
          headers='Accept: none')

if url_path ne '/' then begin
 ourl->setproperty,callback_data=data,callback_function='sock_head_callback'
endif

;-- have to use a catch since canceling the callback triggers it

error=0
catch, error
if (error ne 0) then begin
 catch,/cancel
 if keyword_set(debug) then mprint,err_state()
 message,/reset
 goto, bail
endif

result=oUrl->Get(/string)  

bail: 
ourl->closeconnections

ourl->GetProperty,RESPONSE_HEADER=rsphdr,response_code=response_code

resp=''
if is_string(rsphdr) then begin
 http_resp=stregex(rsphdr,'^HTTP',/bool,/fold)
 if http_resp then $
  sock_content,rsphdr,_extra=extra,size=bsize,code=code,resp_array=resp else $
   sock_content_ftp,rsphdr,size=bsize,code=code,resp_arr=resp
endif

obj_destroy,ourl

return,resp & end  
