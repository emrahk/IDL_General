;+
; Project     : SOHO-CDS
;
; Name        : WHERE_OFF_LIMB
;
; Purpose     : find indicies of points off solar limb
;
; Category    : imaging
;
; Syntax      : off_limb=where_off_limb(xr,yr,date)
;
; Inputs      : XR, YR = arcsec coordinates
;               DATE = observation date
;
; Outputs     : OFF_LIMB = indices of points off limb
;
; Keywords    : COUNT = # of off limb points
;               RADIUS = solar radius (arcsecs) 
;               ON_DISK = indicies of points on disk
;
; History     : Written 4 March 1999, D. Zarro, SM&A/GSFC
;               Modified, 6 October 2007, Zarro (ADNET)
;                - check if RADIUS is input
;
; Contact     : dzarro@solar.stanford.edu
;-

function where_off_limb,xr,yr,date,count=count,$
                  on_disk=on_disk,_extra=extra,radius=radius

if (not exist(xr)) or (not exist(yr)) then begin
 pr_syntax,'off_limb=where_off_limb(xr,yr,date)'
 return,-1
endif

;-- default to current date for radius

err=''
if not_exist(radius) then begin
 tdate=anytim2utc(date,err=err)
 if err ne '' then get_utc,tdate
 pr=pb0r(tdate,_extra=extra,/arcsec)
 radius=float(pr[2])
endif

rot_pos=sqrt(float(xr)^2+float(yr)^2)

off_limb=where2( rot_pos gt radius,count,complement=on_disk)
dprint,'% WHERE_OFF_LIMB: # of points off limb = ',num2str(count)

return,off_limb
end


