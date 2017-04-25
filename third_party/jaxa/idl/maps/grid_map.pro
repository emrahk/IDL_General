;+
; Project     : SOHO-CDS
;
; Name        : GRID_MAP
;
; Purpose     : Regrid an image map 
;
; Category    : imaging
;
; Syntax      : gmap=grid_map(map,gx,gy)
;
; Inputs      : MAP = image map structure
;               GX,GY = new grid dimensions
;
; Outputs     : GMAP = regridded map
;
; Keywords    : SPACE = [sx,sy] = new grid spacing [def= auto determine]
;                or
;               DX=DX, DY=DY
;               INTERPOLATE = us interpolation instead of rebin
;
; History     : Written 22 August 1997, D. Zarro, ARC/GSFC
;               Modified 11 March 2005, Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function grid_map,map,gx,gy,dx=dx,dy=dy,space=space,err=err,$
        _extra=extra,interpolate=interpolate

err=''

;-- check inputs (valid map & grid dimensions)

space_input=exist(space) or exist(dx) or exist(dy)
dim_input=exist(gx)

if (not valid_map(map,old=old)) or ((not space_input) and (not dim_input)) then begin
 pr_syntax,'gmap=grid_map(map,gx,gy,[space=space)'
 if exist(map) then return,map else return,-1
endif

if dim_input then if not exist(gy) then gy=gx

;-- determine from keywords or from map itself 

if space_input then begin

 if exist(dx) or exist(dy) then begin
  mspace=[1.,1.]
  if exist(dx) then mspace[0]=dx else begin
   xp=get_map_xp(map,dx=dx,err=err)
   if err ne '' then begin
    message,err,/cont
    return,map
   endif
   mspace[0]=dx
  endelse
  if exist(dy) then mspace[1]=dy else begin
   yp=get_map_yp(map,dy=dy,err=err)
   if err ne '' then begin
    message,err,/cont
    return,map
   endif
   mspace[1]=dy
  endelse

 endif else mspace=float([space[0],space[n_elements(space)-1]])
endif

;-- if user doesn't specify spacings and dimensions simultaneously then go 
;   the fast rebin route

mk_float=size(map.data,/type) lt 4

if (1-keyword_set(interpolate)) then begin
 if space_input and (not dim_input) then return,respace_map(map,mspace[0],mspace[1])
 if dim_input and (not space_input) then return,rebin_map(map,gx,gy)
endif

msize=float([gx,gy])

for i=0,n_elements(map)-1 do begin
 err=''
 unpack_map,map[i],dx=mdx,dy=mdy,nx=nx,ny=ny,err=err
 gmap=map[i]
 if mk_float then gmap=rep_tag_value(gmap,float(gmap.data),'DATA')
 if err eq '' then begin
  if exist(mspace) then dspace=mspace else dspace=[mdx,mdy]
  if exist(msize) then dsize=msize else dsize=[nx,ny]
  if (dspace[0] eq mdx) and (dspace[1] eq mdy) and $
     (dsize[0] eq nx) and (dsize[1] eq ny) then begin
   message,'no gridding necessary',/cont
  endif else begin
   xp=get_map_xp(map[i])
   yp=get_map_yp(map[i])
   grid_xy,xp,yp,xg,yg,size=dsize,space=dspace
   if (nx ne dsize[0]) or (ny ne dsize[1]) then $
    gmap=rep_tag_value(gmap,interp2d(gmap.data,xp,yp,xg,yg,_extra=extra),'DATA',/no_copy) else $
     gmap=temporary(interp2d(gmap.data,xp,yp,xg,yg,_extra=extra))
   ndx=dspace[0]
   ndy=dspace[1]
   gmap.xc=get_arr_center(xg,dx=ndx)
   gmap.yc=get_arr_center(yg,dy=ndy)
   gmap.dx=ndx
   gmap.dy=ndy
  endelse
  tmap=merge_struct(tmap,gmap,/no_copy)
 endif
endfor

return,tmap & end

