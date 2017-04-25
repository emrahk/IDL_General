;+
; Project     : VSO
;
; Name        : SOCK_LIST
;
; Purpose     : Wrapper around IDLnetURL object to list URL.
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_list,url,output
;
; Inputs      : URL = URL to list
;
; Outputs     : OUTPUT = string or byte array (if /buffer) 
;
; Keywords    : BUFFER = return output as byte array
;
; History     : 20-July-2011, Zarro (ADNET) - written
;               7-November-2013, Zarro (ADNET) 
;               - renamed from SOCK_CAT to SOCK_LIST
;               31-December-2013, Zarro (ADNET)
;               - added /BUFFER keyword
;               10-Feb-2015, Zarro (ADNET)
;               - pass input URL directly to IDLnetURL2 to parse
;                 PROXY keyword properties in one place
;-

pro sock_list,url,output,_ref_extra=extra,err=err,buffer=buffer,debug=debug

err=''
output=''

if ~since_version('6.4') then begin
 err='Requires IDL version 6.4 or greater.'
 mprint,err
 return
endif

if ~is_url(url) then begin
 pr_syntax,'sock_list,url,[output]'
 return
endif

if is_ftp(url) then begin
 err='FTP listing not supported.'
 mprint,err
 return
endif

error=0
CATCH, error
IF (error NE 0) THEN BEGIN  
 CATCH, /CANCEL
 if keyword_set(debug) then  mprint,err_state()  
 err='Remote listing failed for '+url 
 mprint,err
 message,/reset
 if obj_valid(ourl) then obj_destroy,ourl
 return
ENDIF  
  
ourl=obj_new('idlneturl2',url,_extra=extra,debug=debug)

;-- read URL 

buffer=keyword_set(buffer)
output = oUrl->Get(string_array=~buffer,buffer=buffer)

;ourl->GetProperty,_extra=extra
  
obj_destroy,oUrl

if n_params() eq 1 then print,output
 
return & end  
