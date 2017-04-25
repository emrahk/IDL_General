;+
; Project     : SDO
;
; Name        : WHERE_ON_DISK
;
; Purpose     : find indicies of points on solar disk
;
; Category    : imaging
;
; Syntax      : on_disk=where_on_disk(xr,yr,date)
;
; Inputs      : XR, YR = arcsec coordinates
;
; Optional    : DATE = observation date
;
; Outputs     : ON_DISK = indices of points on disk
;
; Keywords    : COUNT = # of points found
;               ON_DISK = indicies of points on disk
;               INNER_, OUTER_RADIUS = inner,outer radius limits
;               (arcsecs)
;               PERCENT = limits in % of solar radius [def=100]
;               RADIUS = solar radius (arcsec) [def = radius for DATA]
; 
; Examples    : Points on disk between 10% and 90% of solar radius
;               IDL> on_disk=where_on_disk(xr,yr,inner=10,outer=90,/perc)
;
;               Points within 900 arcsecs
;               IDL> on_disk=where_on_disk(xr,yr,outer=900)
;               
; History     : Written 24 October 2007, Kirk & Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function where_on_disk,xr,yr,date,count=count,percent=percent,$
                  radius=radius, _ref_extra=extra,debug=debug,$
		  inner_radius=inner_radius,outer_radius=outer_radius 

if (not_exist(xr)) or (not_exist(yr)) then begin
 pr_syntax,'on_disk=where_on_disk(xr,yr)'
 return,-1
endif

percent=keyword_set(percent)
need_radius = not_exist(radius) and $
              (not_exist(inner_radius) or not_exist(outer_radius) or percent)

;-- default to current date for radius

err=''
if need_radius then begin
 tdate=anytim2utc(date,err=err)
 if err ne '' then get_utc,tdate
 pr=pb0r(tdate,_extra=extra,/arcsec)
 radius=float(pr[2])
endif

;-- default to 100% of whole disk

rot_pos=sqrt(float(xr)^2+float(yr)^2)
if percent then fac=radius/100. else fac=1.
if exist(inner_radius) then inner=float(inner_radius)*fac else inner=0.
if exist(outer_radius) then outer=float(outer_radius)*fac else outer=float(radius)

if keyword_set(debug) then help,inner,outer

on_disk=where2( (rot_pos gt inner) and $
                (rot_pos lt outer),count, _extra=extra)

return,on_disk
end
