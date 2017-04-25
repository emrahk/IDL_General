;+
; Project     : SOHO-CDS
;
; Name        : FITS2MAP
;
; Purpose     : Make an image map from a FITS file
;
; Category    : imaging
;
; Syntax      : fits2map,file,map
;
; Inputs      : FILE = FITS file name (or FITS data + HEADER)
;
; Outputs     : MAP = map structure
;
; Keywords    : HEADER = FITS header (output of last file read)
;               OBJECT = return map as an object
;
; History     : Written 22 January 1998, D. Zarro, SAC/GSFC
;               Modified, 22 April 2000, Zarro (SM&A/GSFC)
;               Modified, 1 April 2005, Zarro (L-3Com/GSFC) 
;                - accounted for 180 degree roll
;               14-Sept-2008, Zarro (ADNET) 
;                - fixed typo with 180 roll-correction not being
;                  applied to map
;                - move roll-correction to INDEX2MAP
;               3-Nov-2008, Zarro (ADNET)
;               - added /object for object output
;               9-May-2014, Zarro (ADNET)
;               - added check for RTIME
;
; Contact     : dzarro@solar.stanford.edu
;-

pro fits2map,file,map,err=err,object=object,$
                  _extra=extra,header=header,$
                  extension=extension,index=index

err=''

;-- check inputs

if is_blank(file) then begin
 err='Invalid filename input'
 pr_syntax,'fits2map,file,map'
 return
endif

delvarx,map
if keyword_set(object) then begin
 map=obj_new('fits')
 map->read,file,extension=extension,_extra=extra,err=err
 if is_string(err) then return
 count=map->get(/count)
 if count eq 0 then return
 if arg_present(header) then header=map->get(count-1,/header)
 return
endif

f=obj_new('fits')
f->read,file,err=err
if is_string(err) then message,err,/cont else begin
 count=f->get(/count)
 for i=0,count-1 do begin
  imap=f->get(/map,i)
  if i eq 0 then map=temporary(imap) else map=[temporary(map),temporary(imap)]
 endfor
endelse 
obj_destroy,f

return & end
