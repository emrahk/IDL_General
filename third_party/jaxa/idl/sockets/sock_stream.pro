;+
; Project     : VSO
;
; Name        : SOCK_STREAM
;
; Purpose     : Stream a file from a URL into a buffer
;
; Category    : utility system sockets
;
; Syntax      : IDL> buffer=sock_stream(url)
;
; Inputs      : URL = remote URL file name to stream
;
; Outputs     : BUFFER = byte array
;
; Keywords    : COMPRESS = compress buffer
;               CODE = HTTP status code
;
; History     : 13-Jan-20016, Zarro (ADNET) - Written
;-

function sock_stream,url,compress=compress,err=err,_ref_extra=extra,$
                     no_check=no_check,code=code

err=''
code=404
if ~is_url(url,/scheme) then begin
 err='File URL not entered.'
 pr_syntax,'buffer=sock_stream,url [,/compress]'
 return,0b
endif

error=0
catch,error
if (error ne 0) then begin
 err=err_state()
 mprint,err
 goto,bail
endif
  
stc=url_parse(url)
if is_blank(stc.path) then begin
 err='Path name not included in URL.'
 mprint,err
 return,0b
endif

check=~keyword_set(no_check)
if check then begin
 ok=sock_check(url,_extra=extra,code=code)
 if ~ok then begin
  err='File not accessible. Status code = '+trim(code)
  mprint,err
  return,0b
 endif
endif

;-- initialize object 

ourl=obj_new('idlneturl2',url,_extra=extra)
buffer = ourl->Get(/buffer)  

bail:
ourl->getproperty,response_code=code,_extra=extra
obj_destroy,ourl

if is_byte(buffer) && n_elements(buffer) gt 1 then begin
 if keyword_set(compress) then buffer=zlib_compress(temporary(buffer),/gzip)
 return,buffer
endif

;-- problems if we got here.

err='Read failed. Status code = '+trim(code)
mprint,err

return,0b & end  




