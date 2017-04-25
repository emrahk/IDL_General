;+
; Project     : VSO
;
; Name        : HAVE_PROXY
;
; Purpose     : Check whether a proxy server is defined in $HTTP_PROXY
;
; Category    : utility system sockets
;
; Inputs      : None
;
; Outputs     : 1/0 if defined or not
;
; History     : 15-December-2011, Zarro (ADNET) - Written
;               7-February-2013, Zarro (ADNET) - changed name to HAVE_PROXY
;-

function have_proxy

;-- check if $http_proxy environment variable defined

 proxy=''
 proxy1=getenv('http_proxy')
 proxy2=getenv('HTTP_PROXY')
 if is_string(proxy2) then proxy=proxy2 else if is_string(proxy1) then proxy=proxy1

 ptc=url_parse(proxy)
 return,is_string(ptc.host)

 end
