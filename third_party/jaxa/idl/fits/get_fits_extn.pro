;+
; Project     : VSO
;
; Name        : GET_FITS_EXTN
;
; Purpose     : Empirically determine number of extensions in a FITS file 
;               by sequentially reading headers until end of file
;
; Category    : FITS
;
; Syntax      : IDL> next=get_fits_extn(file)
;
; Inputs      : FILE = FITS file name
;
; Outputs     : N_EXT = number of valid extensions in file
;
; Keywords    : VERBOSE = set for noisy output
;
; History     : 10 Oct 2009, Zarro (ADNET) - written
;               31-Dec-2015, Zarro (ADNET) - improved error handling
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_fits_extn,file,err=err,_extra=extra

err=''
i=0
repeat begin
 terr=''
 mrd_head,file,ext=i,err=terr,_extra=extra
 if is_blank(terr) then i=i+1
endrep until is_string(terr)

if i eq 0 then err='Invalid FITS file.'
 
return,i

end
