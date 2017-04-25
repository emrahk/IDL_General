;+
; Project     : VSO
;
; Name        : HAS_URL_SCHEME
;
; Purpose     : check if URL has valid scheme (ftp or http)
;
; Category    : utility system sockets
;
; Inputs      : URL = URL to check
;
; Outputs     : 1/0 if valid URL
;
; Keywords    : None
;
; History     : Written 24-August-2011, Zarro (ADNET/GSFC)
;               4-February-2015, Zarro (ADNET) 
;               - fixed check for optional secure protocol 
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function has_url_scheme,url

if is_blank(url) then return,0b

return,stregex(url,'(ftp[s]?\:\/\/)|(http[s]?\:\/\/)',/bool,/fold)

end
