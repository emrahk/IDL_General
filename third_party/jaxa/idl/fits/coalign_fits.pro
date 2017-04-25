;+
; Project     : Hinode/EIS
;
; Name        : COALIGN_FITS
;
; Purpose     : coalign image arrays from two FITS files
;
; Category    : imaging
;
; Syntax      : IDL> coalign_fits,fits1,fits2,data1,data2
;
; Inputs      : FITS1, FITS2 = FITS file names
;
; Outputs     : DATA1 = image array from first file
;               DATA2 = coaligned image array from second file
;
; History     : Written 23 September 2006, D. Zarro (ADNET/GSFC)
;               First IDL program post-Hinode launch.
;
; Contact     : dzarro@solar.stanford.edu
;-


pro coalign_fits,fits1,fits2,data1,data2,_extra=extra,map1=map1,map2=map3

;-- make maps first

fits2map,fits1,map1,err=err
if is_string(err) then begin
 message,err,/cont
 return
endif

fits2map,fits2,map2,err=err
if is_string(err) then begin
 message,err,/cont
 return
endif

;-- coalign them

map3=coreg_map(map2,map1,_extra=extra)

;-- extract image arrays

data1=map1.data
data2=map3.data

return & end

