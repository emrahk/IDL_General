;+
; Project     : VSO
;
; Name        : IS_FTP
;
; Purpose     : check if URL resource isusing FTP
;
; Category    : sockets
;
; Inputs      : URL = string URL to check
;
; Outputs     : 1 if ftp resource
;
; Keywords    : None
;
; History     : Written 27-July-2013, Zarro (ADNET)
;               4-February-2015, Zarro (ADNET)
;               - fixed check for optional secure protocol
;-

function is_ftp,url

if is_blank(url) then return,0b
return,stregex(url,'ftps?://',/bool,/fold)

end
