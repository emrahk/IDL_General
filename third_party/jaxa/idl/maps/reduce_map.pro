;+
; Project     : SOHO-CDS
;
; Name        : REDUCE_MAP
;
; Purpose     : create a low resolution map by removing pixels
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : rmap=reduce_map(map,fx,fy)
;
; Examples    :
;
; Inputs      : MAP = image map structure
;               FX = factor to reduce X-resolution by (e.g. .5)
;               FY = factor to reduce Y-resolution by
;
; Opt. Inputs : None
;
; Outputs     : IMAP = low resolution map
;
; Opt. Outputs: None
;
; Keywords    : ERR = error strings
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 Nov 1998, D. Zarro, SM&A/SAC
;
; Contact     : dzarro@solar.stanford.edu
;-

function reduce_map,map,fx,fy,err=err

err=''
on_error,1
if (not valid_map(map)) or (not exist(fx)) then begin
 pr_syntax,'imap=low_res__map(map,fx,fy)'
 return,-1
endif

if not exist(fy) then fy=1.
               
xp=get_map_prop(map,/xp)
yp=get_map_prop(map,/yp)

rx= float(fx < 1)
ry= float(fy < 1)

if (rx eq 0.) or (ry le 0.) then begin
 message,'cannot have negative or zero resolution factors',/cont
 return,-1
endif

nx=get_map_prop(map,/nx)
ny=get_map_prop(map,/ny)

;-- reduce resolution by removing every 1/f'th pixel 

npx=nint(1./rx)
badx=(1.+indgen(nx))*npx
xfix=where(badx ge nx,xcount)
if xcount gt 0 then badx(xfix)=nx-1
px=lindgen(nx)
px(badx)=-1
goodx=where(px ne -1,countx)
if countx le 1 then begin
 message,'insufficient X-data points in low-res image',/cont
 return,-1
endif


npy=nint(1./ry)
bady=(1.+indgen(ny))*npy
py=lindgen(ny)
py(bady < (ny-1))=-1
goody=where(py ne -1,county)
if county le 1 then begin
 message,'insufficient Y-data points in low-res image',/cont
 return,-1
endif

a=map.data
a=a(*,goody)
a=a(goodx,*)
rmap=rep_tag_value(map,a,'data',/no_copy)

a=xp(*,goody)
xp=a(goodx,*)

a=yp(*,goody)
yp=a(goodx,*)

rmap=repack_map(rmap,xp,yp,/no_copy)

return,rmap

end

