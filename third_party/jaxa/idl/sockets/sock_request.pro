;+
; Project     : VSO
;
; Name        : SOCK_REQUEST
;
; Purpose     : Create a socket request
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_request,url,request
;
; Inputs      : URL = remote URL to send request to
;
; Keywords    : See HTTP::MAKE
;
; Outputs     : REQUEST = string array of request commands
;
; History     : 14-Nov-2012, Zarro (ADNET) - Written
;-

pro sock_request,url,request,_ref_extra=extra,verbose=verbose

http=obj_new('http',_extra=extra)
http->send_request,url,request=request,/no_open,/no_send,_extra=extra
if keyword_set(verbose) then print,request
obj_destroy,http

return & end
