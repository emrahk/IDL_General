;+
; Project     : SOHO-CDS
;
; Name        : LTC_MAP
;
; Purpose     : Plot time history of mean values in vicinity of pixels
;
; Category    : imaging
;
; Explanation : Points nearest input coordinates are averaged
;
; Syntax      : ltc_map,map,xc,yc
;
; Examples    :
;
; Inputs      : MAP = map structure 
;               XC,YC = coordinate arrays of pixels
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: 
;
; Keywords    : TIME, DATA = output time and data arrays
;               OVER = set for overplots
;               TAG_ID = tag name or index to use
;               AREA = if set, average over total area bounded by (xc,yc)
;               TROTATE = rotate map coords to reference time before
;                         averaging
;               SHIFT = [x,y] offsets to apply to coordinates (after rotation)
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 Jan 1997, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro ltc_map,map,xc,yc,_extra=extra,tag_id=tag_id,area=area,shift=shift_val,$
             over=over,time=time,data=data,trotate=trotate,centroid=centroid

on_error,1

;-- interrogate inputs

if (not valid_map(map)) or (not exist(xc)) or (not exist(yc)) then begin
 pr_syntax,'ltc_map,map,xc,yc'
 return
endif

np=n_elements(map)
data=fltarr(np)
for i=0,np-1 do data(i)=mean_map(map(i),xc,yc,area=area,tag_id=tag_id,$
                     trotate=trotate,centroid=centroid,shift=shift_val)

time=map.time
s='utplot,time,data,_extra=extra'
if keyword_set(over) then s='o'+s
s=execute(s)
if !d.name eq 'X' then wshow

return & end


