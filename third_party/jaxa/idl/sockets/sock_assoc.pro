;+
; Project     : VSO
;
; Name        : SOCK_ASSOC
;
; Purpose     : socket version of ASSOC function
;
; Category    : utility system sockets
;
; Syntax      : IDL> a=sock_assoc(url,data,offset)
;               IDL> b->read(0)
;                   
; Inputs      : URL = URL path to file
;               DATA = An expression of the data type and structure to
;               be associated with the file
;               OFFSET (optional) = offset in the file to the start of the
;               data in the file (bytes).
;
; Outputs     : A = object with read method
;
; History     : 8-November-2013, Zarro (ADNET) - Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_assoc,url,data,offset,_extra=extra

return,obj_new('sock_assoc',file=url,data=data,offset=offset)

end
