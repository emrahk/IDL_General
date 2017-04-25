;+
; Project     : VSO
;
; Name        : SOCK_DIR_FTP
;
; Purpose     : Wrapper around IDLnetURL object to perform
;               directory listing via FTP
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_dir_ftp,url,out_list
;
; Inputs      : URL = remote URL directory name to list
;
; Outputs     : OUT_LIST = optional output variable to store list
;
; History     : 27-Dec-2009, Zarro (ADNET) - written
;               12-Feb=2015, Zarro (ADNET) - scrubbed 
;-

function sock_dir_ftp_callback, status, progress, data

xstatus,'Searching',wbase=wbase,cancelled=cancelled
if cancelled then xkill,wbase

print,status,progress

return,1 & end

;-------------------------------------------------------------------------

pro sock_dir_ftp,url,out_list,err=err,progress=progress,_ref_extra=extra,$
                     debug=debug

err='' 
out_list=''

if ~since_version('6.4') then begin
 err='Requires IDL version 6.4 or greater.'
 mprint,err
 return
endif

if ~is_url(url) then begin
 pr_syntax,'sock_dir_ftp,url'
 return
endif
durl=url
if ~is_ftp(url) then durl='ftp://'+url 

error=0
CATCH, error
IF (error NE 0) THEN BEGIN  
 CATCH, /CANCEL
 if keyword_set(debug) then mprint,err_state()
 err='Remote listing failed.'
 message,/reset
 if obj_valid(ourl) then obj_destroy,ourl
 return
endif
 
ourl=obj_new('idlneturl2',durl,_extra=extra,debug=debug)
callback_function=''
if keyword_set(progress) then callback_function='sock_dir_ftp_callback' 

;-- start listing 

out_list = ourl->getftpdirlist(/short)

obj_destroy,ourl

;-- reconstruct full URL

stc=url_parse(url)
server=stc.host
if is_string(stc.username) && is_string(stc.password) && (stc.username ne 'anonymous') then $
 server=stc.username+':'+stc.password+'@'+stc.host 

;--override with keyword values

if is_string(extra) then begin
 chk1=where(stregex(extra,'^(URL_)?USER(NAME)?',/bool,/fold),count1)
 chk2=where(stregex(extra,'^(URL_)?PASS(WORD)?',/bool,/fold),count2)
 if (count1 eq 1) && (count2 eq 1) then begin
  username=scope_varfetch(extra[chk1],/ref)
  password=scope_varfetch(extra[chk2],/ref)
  if is_string(username) && is_string(password) && (username ne 'anonymous') then $
   server=username+':'+password+'@'+stc.host
 endif
endif

out_list='ftp://'+server+'/'+stc.path+out_list
if n_elements(out_list) eq 1 then out_list=out_list[0]

if n_params() eq 1 then print,out_list

return & end  
