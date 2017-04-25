;+
; Project     : VSO
;
; Name        : SOCK_CONTENT_FTP
;
; Purpose     : Parse FTP response content
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_content_ftp,content
;
; Inputs      : CONTENT = FTP response string (scalar or vector)
;
; Outputs     : See keywords
;
; Keywords    : CODE = response status code
;             : SIZE = number of bytes in return content
;             : RESP_ARRAY = response header in string array format   
;
; History     : 21-Feb-2015, Zarro (ADNET) - Written
;-

pro sock_content_ftp,response,size=bsize,code=code,resp_array=resp,_ref_extra=extra

resp='' & bsize=0l &  code=404
if is_blank(response) then return
resp=response
if n_elements(resp) eq 1 then resp=byte2str(byte(resp),newline=13,skip=2)

regex=' *213 +([0-9]+).*'
chk=stregex(resp,regex,/ext,/sub)
found=where(chk[1,*] ne '',count)
if count eq 1 then bsize=long(chk[1,found[0]])

regex='(150 )'
chk=where(stregex(resp,regex,/bool),count)
if count gt 0 then code=200

return & end
