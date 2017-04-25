;+
; Project     : SOHO-CDS
;
; Name        : UNPACK_MAP
;
; Purpose     : Unpack data and pixel coordinate arrays for image
;               saved in a map structure created by MK_MAP
;
; Category    : imaging
;
; Syntax      : unpack_map,map,data,xp,yp
;
; Inputs      : MAP = map structure created by MK_MAP
;
; Outputs     : DATA = 2d image array
;               XP = cartesian coordinates of image pixels in x-direction (+ W)
;               YP = cartesian coordinates of image pixels in y-direction (+ N)
;
; Keywords    : VELOCITY = set to check and extract velocity map data
;                          stored with tag name starting with "VELOCITY"
;               CENTROID = reference centroid for velocity maps
;               DX,DY = mean spacing between pixels (arcsecs)
;               XC,YC = mean center of image (arcsecs)
;               XSIDE,YSIDE = mean x,y size of image (arcsecs)
;               TAG_ID = tag name or index to extract
;               ROLL_ANGLE = image roll angle (deg clockwise from N)
;               ROLL_CENTER = coordinates of roll center [def = xc,yc] 
;               XRANGE,YRANGE = coordinate limits
;               NO_DATA = set to not return DATA array
;
; History     : Written 22 October 1996, D. Zarro, ARC/GSFC
;               Modfied 22 Cotober 2007, Zarro (ADNET) - added /NO_DATA
;
; Contact     : dzarro@solar.stanford.edu
;-

pro unpack_map,map,data,xp,yp,dx=dx,dy=dy,xc=xc,yc=yc,nx=nx,ny=ny,$
      xside=xside,yside=yside,tag_id=tag_id,roll_angle=roll_angle,$
      roll_center=roll_center,$
      centroid=centroid,velocity=velocity,err=err,xrange=xrange,$
      yrange=yrange,no_data=no_data

err=''
if not valid_map(map,err=err) then begin
 message,err,/cont & return
endif

;-- velocity is treated differently

yes_data=1-keyword_set(no_data)
if (n_params() gt 1) and yes_data then begin
 clight=3.e5
 if keyword_set(velocity) or exist(centroid) then begin
  vfound=0
  if tag_exist(map,'velocity') then begin
   data=map.velocity
   vfound=1
  endif else begin
   if tag_exist(map,'centroid') then begin
    if not exist(centroid) then begin
     repeat begin
      ans='' & read,'* enter reference centroid: ',ans
      centroid=float(ans)
     endrep until (centroid gt 0)
    endif
    data=gt_vmap(map,centroid)
    vfound=1
   endif 
  endelse
  if not vfound then begin
   err='No velocity data in MAP structure'
   message,err,/cont
   return
  endif
 endif else begin
  if not exist(tag_id) then tag_no=get_tag_index(map,'data') else $
   tag_no=get_tag_index(map,tag_id)
  if tag_no eq -1 then begin
   err='Invalid TAG input'
   message,err,/cont
   return
  endif
  data=map.(tag_no)
 endelse
endif

;-- scale info

xrange=get_map_prop(map,/xrange)
yrange=get_map_prop(map,/yrange)
dx=get_map_prop(map,/dx)
dy=get_map_prop(map,/dy)
xc=get_map_prop(map,/xc)
yc=get_map_prop(map,/yc)
nx=get_map_prop(map,/nx)
ny=get_map_prop(map,/ny)

;-- roll info

xside=(nx-1.)*dx
yside=(ny-1.)*dy
if tag_exist(map,'roll_angle') then roll_angle=map.roll_angle else roll_angle=0.
if tag_exist(map,'roll_center') then roll_center=map.roll_center else $
 roll_center=[xc,yc]

;-- save some memory by only returning requested coordinate arrays

if (n_params() eq 3) then xp=get_map_xp(map)
if (n_params() eq 4) then begin
 xp=get_map_xp(map) & yp=get_map_yp(map)
endif

return & end

