;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_SPACE
;
; Purpose     : extract dx,dy spacings from map
;
; Category    : imaging
;
; Syntax      : space=get_map_space(map)
;
; Inputs      : MAP = image map
;
; Outputs     : SPACE = [dx,dy]
;
; Keywords    : ERR = error string
;
; History     : Written 16 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_space,map,err=err

on_error,1

err=''
if not valid_map(map,err=err,old=old) then return,-1

if old then begin
 for i=0,n_elements(map)-1 do begin
  xc=get_arr_center(map.xp,dx=dx)
  yc=get_arr_center(map.yp,dy=dy)
  boost_array,space,[dx,dy]
 endfor
endif else begin
 space=reform(transpose([[map.dx],[map.dy]]))
endelse

return,space

end
