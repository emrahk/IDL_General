;+
; Project     : VSO
;
; Name        : SOCK_PUT
;
; Purpose     : Wrapper around IDLnetURL object to issue PUT request
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_put,url,file
;
; Inputs      : URL = remote URL file where upload file
;               FILE = filename to upload
;
; Outputs     :
;
; Keywords    : ERR = error string
;
; History     : 24-March-2016, Zarro (ADNET) - Written
;              
;-

pro sock_put,file,url,err=err,_ref_extra=extra,header=header

err=''

if ~since_version('6.4') then begin
 err='Requires IDL version 6.4 or greater.'
 mprint,err
 return
endif

if ~is_url(url) || is_blank(file) then begin
 pr_syntax,'sock_put,url,file'
 return
endif

if ~file_test(file,/read,/regular) then begin
 mprint,'Missing or invalid input file - '+file
 return
endif

;-- parse out URL

stc=url_parse(url)
if is_blank(stc.host) then begin
 err='Host name missing from URL.'
 mprint,err
 return
endif

error=0
catch, error
if (error ne 0) then begin
 catch,/cancel
 err=err_state()
 mprint,err
 goto,bail
endif

ourl=obj_new('idlneturl2',_extra=extra)
url_out=stc.scheme+'://'+stc.host+':'+stc.port+'/'+file_dirname(stc.path)+'/'+file_basename(file)

result = ourl->put(file, url=url_out)

;-- clean up

bail: 
ourl->getproperty,_extra=extra,response_header=header
;response_code=code,response_header=header,response_filename=rfile
obj_destroy,ourl

return 
end  
