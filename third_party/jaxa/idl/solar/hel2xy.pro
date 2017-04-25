;+
; Project     : HESSI
;
; Name        : HEL2XY
;
; Purpose     : convert heliographic coords to heliocentric
;
; Category    : synoptic
;
; Syntax      : IDL> coords=hel2xy(value,date=date)
;
; Inputs      : VALUE = coordinates, e.g., 'N23 W34'
;
; Outputs     : COORDS = [-100,200] arcsecs
;
; Keywords    : DATE = pertinent date
;               PANGLE = position angle (angle CCW from Solar N)
;
; History     : 6-Nov-2000, D.M. Zarro (EIT/GSFC),  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function hel2xy,value,pangle=pangle,_extra=extra

xy=[0.,0.]
if is_blank(value) then return,xy
reg='( *[a-z] *)([0-9]{1,2})( *\,? *)([a-z] *)([0-9]{1,2})'

coord=strtrim(stregex(value,reg,/fold,/extr,/sube),2)
coord=coord[1:*]
if not is_blank(coord) then begin
 chk=where(stregex(coord,'N|S',/fold) gt -1,count)
 if count gt 0 then begin
  ns=coord[chk[0]]+coord[chk[0]+1]
  chk=where(stregex(coord,'E|W',/fold) gt -1,count)
  if count gt 0 then begin
   ew=coord[chk[0]]+coord[chk[0]+1]
   xy=hel2arcmin(ns,ew,_extra=extra)
  endif
 endif
endif

pangle=270.+atan(xy[1],xy[0])*180./!pi

return,xy*60. & end


