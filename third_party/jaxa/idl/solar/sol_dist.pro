;+
; Project     : HESSI
;
; Name        : SOL_DIST
;
; Purpose     : comput solar distance from solar radius
;
; Category    : utility
;
; Syntax      : IDL> rsun=sol_rad(rsun)
;
; Inputs      : RSUN = solar radius in arcecs
;
; Outputs     : DSUN = distance to Sun in km
;
; History     : 10-Oct-2007, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function sol_dist,rsun

if not_exist(rsun) then return,0
if rsun le 0 then return,0

c=sin(rsun*!dpi/3600./180.)
return,6.95508E5/c

end
