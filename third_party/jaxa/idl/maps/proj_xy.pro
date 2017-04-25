;+
; Project     : STEREO
;
; Name        : PROJ_XY
;
; Purpose     : Project map center helocentric coordinates to
;               heliocentric coordinates in reference map.
;
; Category    : imaging
;
; Syntax      : pcor=proj_xy(map,rmap)
;
; Inputs      : MAP = map with helocentric coordinates to project
;               RMAP = reference map to project to
;
; Outputs     : PCOR = [xc,yc] = projected coordinates
;
; Keywords    : DROTATE = correct for differential rotation
;               ON_DISK = 1/0 if projected coordinates ON or OFF disk
;
; History     : 12 December 2014, Zarro (ADNET) - written
;               Modified 24 November 2015, Zarro (ADNET)
;               - changed CENTER to RCENTER to avoid clash with image center
;
; Contact     : dzarro@solar.stanford.edu
;-

function proj_xy,map,rmap,drotate=drotate,on_disk=on_disk

on_disk=0b
if ~valid_map(map) and ~valid_map(rmap) then begin
 pr_syntax,'pcor=proj_xy(map,rmap,/drotate)'
 return,[-999.,-999.]
endif

xc=map.xc
yc=map.yc

vstart=get_map_angles(map)
vend=get_map_angles(rmap)
tstart=get_map_time(map)
tend=get_map_time(rmap)

;-- if not on disk then bail

on_disk=sqrt(xc^2+yc^2) lt vstart.rsun
if ~on_disk then return,[xc,yc]

;-- project

if ~keyword_set(drotate) then tend=tstart

roll_xy,xc,yc,-map.roll_angle,rcenter=map.roll_center,xc,yc
rcor=rot_xy(xc,yc,tstart=tstart,tend=tend,vstart=vstart,vend=vend,/sphere)
rcor=reform(rcor)
xc=rcor[0] & yc=rcor[1]

on_disk=sqrt(xc^2+yc^2) lt vend.rsun
if ~on_disk then return,[-999.,-999.]

roll_xy,xc,yc,rmap.roll_angle,rcenter=rmap.roll_center,xc,yc

return,[xc,yc]

end
