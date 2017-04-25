;+
; Project     : SOHO-CDS
;
; Name        : GT_VMAP
;
; Purpose     : Compute a velocity map from a fitted map structure that
;               contains centroid information
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : vmap=gt_vmap(map,centroid,offset=offset,vrange=vrange)
;
; Examples    :
;
; Inputs      : MAP = map structure created by MK_MAP
;               CENTROID = rest centroid value
;
; Opt. Inputs : None
;
;
; Outputs     : VMAP = velocity data map (in km/s)
;
; Opt. Outputs: 
;
; Keywords    : VRANGE = [min,max]; values outside this range set to zero
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


function gt_vmap,map,centroid,vrange=vrange,err=err,offset=offset

on_error,1

err=''
sc=size(map)
if not valid_map(map,err=err) then begin
 message,err,/cont & return,''
endif

if not exist(centroid) then begin
 pr_syntax,'vmap=gt_vmap(map,centroid)'
 return,''
endif

clight=3.e5
if not tag_exist(map,'centroid') then begin
 err='no centroid field in map'
 message,err,/cont
 return,''
endif

if not exist(offset) then offset=0.
vdata=(clight*(map.centroid-centroid)/centroid)-offset

if n_elements(vrange) eq 2 then begin
 vmin=min(vrange) & vmax=max(vrange)
 nok=where( (vdata gt vmax) or (vdata lt vmin),count)
 if count gt 0 then vdata(nok)=0.
endif

return,vdata & end
