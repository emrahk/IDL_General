;+
; Project     : SOHO-CDS
;
; Name        : BREAK_MAP
;
; Purpose     : Break map up into small pieces
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : f=break_map(map,pieces,size=size)
;
; Examples    :
;
; Inputs      : MAP = map structure 
;               PIECES = number of equal pieces 
;
; Opt. Inputs : None
;
; Outputs     : f= array of pointers containing each piece
;
; Opt. Outputs: 
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 Sep 1998, D. Zarro, SMA/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


function break_map,map,pieces

on_error,1

if (not valid_map(map)) or ( not exist(pieces)) then begin
 pr_syntax,'break_map,map,p1,p2,p3,p4...,pieces=pieces'
 return,-1
endif

nx=get_map_prop(map,/nx)
ny=get_map_prop(map,/ny)

p1=pieces(0)
if n_elements(pieces) eq 1 then p2=1 else p2=pieces(n_elements(pieces)-1)

if p1 le 1. then sx=1 else sx=nint(indgen(p1)*float(nx)/float(p1))
if p2 le 1. then sy=1 else sy=nint(indgen(p2)*float(ny)/float(p2))

k=0
nsx=n_elements(sx) & nsy=n_elements(sy)
make_pointer,f,dim=nsx*nsy
for i=0,nsx-1 do for j=0,nsy-1 do begin
 x1=sx(i)  &  y1=sy(j) 
 if i eq (nsx-1) then x2=nx-1 else x2=sx(i+1)-1
 if j eq (nsy-1) then y2=ny-1 else y2=sy(j+1)-1
 tmap=rep_tag_value(map,(map.data)(x1:x2,y1:y2),'data')
 xp=get_map_prop(map,/xp) & yp=get_map_prop(map,/yp)
 tmap=repack_map(tmap,xp(x1:x2,y1:y2),yp(x1:x2,y1:y2),/no_copy)
 set_pointer,f(k),tmap,/no_copy
 k=k+1
endfor

return,f & end


