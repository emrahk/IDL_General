;+
; Project     : SOHO-CDS
;
; Name        : INTER_MAP
;
; Purpose     : interpolate an image map onto a new coordinate system
;
; Category    : imaging
;
; Syntax      : imap=inter_map(map,rmap)
;
; Inputs      : MAP = image map structure
;               RMAP = reference map with coordinates 
;
; Outputs     : IMAP = interpolated map
;
; Keywords    : ERR = error strings
;
; History     : Written 22 August 1997, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function inter_map,map,rmap,err=err,_extra=extra,use_min=use_min

err=''

if ~valid_map(map) || ~valid_map(rmap)  then begin
 pr_syntax,'imap=inter_map(map,rmap)'
 return,-1
endif

xr=get_map_xp(rmap)
yr=get_map_yp(rmap)

xp=get_map_xp(map)
yp=get_map_yp(map)

xmax=max(xp)
xmin=min(xp)
ymax=max(yp)
ymin=min(yp)

;-- flag data outside reference map range

outside=where( (xr gt xmax) or (xr lt xmin) or $
               (yr gt ymax) or (yr lt ymin), count)

if count eq n_elements(rmap.data) then begin
 err='No overlapping data between input and reference map'
 message,err,/cont
 return,map
endif

imap=repack_map(map,xr,yr)
imap=rep_tag_value(imap,interp2d(map.data,xp,yp,xr,yr,_extra=extra),'data')

if keyword_set(use_min) then dmin=min(map.data) else dmin=0.

if count gt 0 then imap.data[outside]=dmin

return,imap

end

