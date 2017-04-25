;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_CENTER
;
; Purpose     : extract xc,yc center from map
;
; Category    : imaging
;
; Syntax      : center=get_map_center(map)
;
; Inputs      : MAP = image map
;
; Outputs     : CENTER = [xc,yc]
;
; Keywords    : ERR = error string
;
; History     : Written 16 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_center,map,err=err

err=''
if ~valid_map(map,err=err,old=old) then return,-1

if old then begin
 xc=get_arr_center(map.xp,dx=dx)
 yc=get_arr_center(map.yp,dy=dy)
 boost_array,center,[xc,yc]
endif else begin
 center=reform(transpose([[map.xc],[map.yc]]))
endelse

return,center

end
