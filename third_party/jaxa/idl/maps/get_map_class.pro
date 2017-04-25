;+
; Project     : VSO
;
; Name        : GET_MAP_CLASS
;
; Purpose     : Get object class name from FITS detector or instrument name
;
; Category    : imaging, FITS
;
; Syntax      : obj=get_map_obj(file)
;
; Inputs      : FILE = FITS file name or header
;
; Outputs     : CLASS = map object class name for corresponding detector or instrument
;
; Keywords    : 
;
; History     : 11 February 2016 Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_class,file,_ref_extra=extra,err=err

err=''

if is_blank(file) then begin
 err='Input filename not entered.'
 mprint,err
 return,''
endif

if n_elements(file) gt 1 then begin
 err='Input filename must be scalar.'
 mprint,err
 return,''
endif

if stregex(file_basename(file),'^tri',/bool) then return,'TRACE'
instrument=0b
for i=0,1 do begin
 det=get_fits_det(file,err=err,_extra=extra,instrument=instrument)
 if is_string(err) then begin
  mprint,err
  return,''
 endif
 if det eq 'XRT' then det='XRT2'
 if stregex(det,'^AIA',/bool,/fold) then det='AIA'
 if stregex(det,'^HMI',/bool,/fold) then det='HMI'
 if stregex(det,'^SXI',/bool,/fold) then det='SXI'
 if stregex(det,'^SOT',/bool,/fold) then det='SOT'
 if valid_class(det) then return,strlowcase(det)
 instrument=1b
endfor

return,''
end
