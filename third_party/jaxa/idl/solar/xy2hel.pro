;+
; Project     : HESSI
;
; Name        : XY2HEL
;
; Purpose     : convert heliocentric to heliographic coords 
;
; Category    : synoptic
;
; Syntax      : IDL> coords=xy2hel(value,date=date)
;
; Inputs      : XCEN,YCEN (arcsecs)
;
; Outputs     : COORDS, e.g. S21, W21
;
; Keywords    : DATE = pertinent date
;
; History     : 19-Apr-2003, D.M. Zarro (EER/GSFC),  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function xy2hel,xcen,ycen,date=date

nx=n_elements(xcen)
ny=n_elements(ycen)
if (nx ne ny) or (nx*ny eq 0) then return,''

coord=arcmin2hel(xcen/60.,ycen/60.,date=date)

lat=coord[0,*]
slat=replicate('N',nx)
chk=where(lat lt 0,count)
if count gt 0 then slat[chk]='S'

lon=coord[1,*]
slon=replicate('W',ny)
chk=where(lon lt 0,count)
if count gt 0 then slon[chk]='E'

lat=strtrim(string(abs(lat),'(i2.2)'),2)
lon=strtrim(string(abs(lon),'(i2.2)'),2)

out=slat+lat+', '+slon+lon
if nx eq 1 then out=out[0]

return,out

end

