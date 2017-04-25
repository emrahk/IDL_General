;+
; Project     : SOHO-CDS
;
; Name        : REPACK_MAP
;
; Purpose     : Pack pixel coordinate arrays into image map
;
; Category    : imaging
;
; Syntax      : rmap=repack_map(map,xp,yp)
;
; Inputs      : MAP = map structure
;               XP,YP = 2-d coordinate arrays
;
; Opt. Inputs : None
;
; Outputs     : RMAP = repacked map
;
; History     : Written 22 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function repack_map,map,xp,yp,err=err,no_copy=no_copy

err=''
if ~valid_map(map,err=err,old=old) then begin
 message,err,/cont 
 if exist(map) then return,map else return,0
endif

if keyword_set(no_copy) then rmap=temporary(map) else rmap=map

if old then begin
 s1=size(xp)
 s2=size(rmap.xp)
 if (s1[1] eq s2[1]) and (s1[2] eq s2[2]) then begin
  rmap.xp=xp & rmap.yp=yp
 endif else begin
  rmap=rep_tag_value(rmap,xp,'xp',/no_copy)
  rmap=rep_tag_value(rmap,yp,'yp',/no_copy)
 endelse
endif else begin
 rmap.xc=get_arr_center(xp,dx=dx)
 rmap.yc=get_arr_center(yp,dy=dy)
 rmap.dx=dx
 rmap.dy=dy
endelse

return,rmap & end

