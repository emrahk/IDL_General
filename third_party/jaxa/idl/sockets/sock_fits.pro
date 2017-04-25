;+
; Project     : HESSI
;
; Name        : SOCK_FITS
;
; Purpose     : read a FITS file via HTTP sockets
;
; Category    : utility sockets fits
;
; Syntax      : IDL> sock_fits,file,data,header=header,extension=extension
;                   
; Inputs      : FILE = remote file name with URL path attached
;
; Outputs     : DATA = FITS data
;
; Keywords    : ERR   = string error message
;               HEADER = FITS header
;
; History     : 27-Dec-2001,  D.M. Zarro (EITI/GSFC)  Written
;               23-Dec-2005, Zarro (L-3Com/GSFC) - removed COMMON
;               14-Oct-2009, Zarro (ADNET) - made HEADER a keyword
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_fits,file,data,_ref_extra=extra

err=''
hfits=obj_new('hfits',_extra=extra)
if ~obj_valid(hfits) then return
delvarx,data
hfits->read,file,data,_extra=extra
obj_destroy,hfits

return

end


