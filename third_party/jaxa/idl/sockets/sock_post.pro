;+
; Project     : VSO
;
; Name        : SOCK_POST
;
; Purpose     : Wrapper around IDLnetURL object to issue POST request
;
; Category    : utility system sockets
;
; Syntax      : IDL> output=sock_post(url,content)
;
; Inputs      : URL = remote URL file to send content
;               CONTENT = string content to post
;
; Outputs     : OUTPUT = server response
;
; Keywords    : HEADERS = optional string array with headers 
;                         For example: ['Accept: text/xml']
;               FILE = if set, OUTPUT is name of file containing response
;
; History     : 23-November-2011, Zarro (ADNET) - Written
;               2-November-2014, Zarro (ADNET)
;                - allow posting blank content (for probing)
;              
;-

function sock_post,url,content,err=err,file=file,_ref_extra=extra

err='' & output=''

if ~since_version('6.4') then begin
 err='Requires IDL version 6.4 or greater.'
 mprint,err
 return,output
endif

if is_blank(url) then begin
 pr_syntax,'output=sock_post(url,content,headers=headers)'
 return,output
endif

;-- parse out URL

stc=url_parse(url)
if is_blank(stc.host) then begin
 err='Host name missing from URL.'
 mprint,err
 return,output
endif

ourl=obj_new('idlneturl2',url,_extra=extra)

cdir=curdir()
error=0
catch, error
IF (error ne 0) then begin
 catch,/cancel
 mprint,err_state()
 message,/reset
 goto,bail
endif

;-- have to send output to writeable temp directory

tdir=get_temp_dir()
sdir=concat_dir(tdir,'temp'+get_rid())

file_mkdir,sdir
cd,sdir
result=''
if is_string(content) then dcontent=content else dcontent=''
result = ourl->put(dcontent,/buffer,/post)

;-- clean up

bail: cd,cdir
if obj_valid(ourl) then obj_destroy,ourl

sresult=file_search(sdir,'*.*',count=count)
if count eq 1 then result=sresult[0]
if ~file_test(result) then begin
 mprint,'POST request failed.'
 return,''
endif

if keyword_set(file) then return,result 
output=rd_ascii(result)

file_delete,sdir,/quiet,/recursive,/allow_nonexistent

return,output 
end  
