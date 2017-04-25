;+
; Project     : SOHO/CDS
;                   
; Name        : VALID_FITS
;               
; Purpose     : check if file is a valid FITS file
;               
; Category    : FITS, utility
;               
; Syntax      : IDL> valid=valid_fits(file)
;    
; Inputs      : FILE = FITS file name
;               
; Opt. Inputs : None
;               
; Outputs     : VALID = 1/0 if valid or not
;  
; Keywords    : STATUS = 1 if file doesn't exist                     
;
; History     : 28-Oct-98, Zarro (SMA/GSFC) - written
;               24-Feb-03, Zarro (EER/GSFC) - vectorized and added
;               support for compressed files
;               10-Jan-10, Zarro (ADNET)
;               - added STATUS
;               12-Sep-10, Zarro (ADNET)
;               - use MRD_HEAD to test for valid FITS file
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-      

function valid_fits,file,header,_ref_extra=extra,status=status

header=''
status=-1
if is_blank(file) then return,0b
np=n_elements(file)
valid=bytarr(np)
status=intarr(np)-1
for i=0,np-1 do begin
 err=''
 mrd_head,file[i],_extra=extra,status=fstatus
 status[i]=fstatus
 if fstatus eq 0 then valid[i]=1 
endfor

if np eq 1 then begin
 valid=valid[0]
 status=status[0]
endif

return,valid & end

