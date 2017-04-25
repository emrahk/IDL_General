;+
; Project     : HESSI
;
; Name        : SOCK_FITS_HEAD
;
; Purpose     : read a FITS header file via HTTP sockets end extract a
;               keyword value
;
; Category    : utility sockets fits
;
; Syntax      : IDL> value=sock_fits_head(file,key)
;                   
; Inputs      : FILE = remote file name 
;               KEY = keyword to extract
;
; Outputs     : VALUE = keyword value
;
; Keywords    : ERR   = string error message
;
; History     : 26-April-2009, Zarro (ADNET) - written
;               24-Feb-2012, Zarro (ADNET) - renamed from SOCK_HEAD
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_fits_head,file,key,err=err,_ref_extra=extra,header=header

if is_blank(file) then begin
 pr_syntax,'value=sock_fits_head(file,key)'
 return,''
endif

sock_fits,file,data,header=header,/nodata,err=err
if is_string(err) then return,''

if is_string(key) then begin
 out=stregex(header,key+" *= *'?([^']+)'?.*",/extra,/fold,/sub)
 value=''
 chk=where(out[1,*] ne '',count)
 if count gt 0 then value=out[1,chk[0]]
 return,value[0]
endif else return,header

end


