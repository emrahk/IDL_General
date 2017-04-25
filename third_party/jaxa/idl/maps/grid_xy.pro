;+
; Project     : SOHO-CDS
;
; Name        : GRID_XY
;
; Purpose     : Make a uniform 2d X-Y grid of coordinates
;
; Category    : imaging
;
; Syntax      : grid_xy,x,y,xg,yg
;
; Inputs      : X,Y = input coordinate arrays
;
; Outputs     : xg,yg = gridded arrays
;
; Keywords    : space = grid spacing [def= determine from inputs]
;               size    = grid size [def = determine from spacing]
;               preserve_area = adjust size to preserve area
;               adjust_resolution = adjust resolution to preserve size
;               center  = [xc,yc] = center of image
;
; History     : Written 22 August 1997, D. Zarro, ARC/GSFC
;               Modified, 19 May 2004, Zarro (L-3Com/GSFC) 
;              - added /PRESERVE_AREA
;               Modified, 19 March 2009, Zarro (ADNET)
;              - added /ADJUST_RESOLUTION
;               Modified 22 October 2014, Zarro (ADNET)
;               - use double-precision arithmetic
;
; Contact     : dzarro@solar.stanford.edu
;-

pro grid_xy,x,y,xg,yg,size=gsize,space=gspace,$
            preserve_area=preserve_area,err=err,center=center,$
            adjust_resolution=adjust_resolution           

err=''
if n_params(0) ne 4 then begin
 pr_syntax,'grid_xy,x,y,xg,yg'
 return
endif

sx=size(x) & sy=size(y)
np=n_elements(sx)
chk=where_vector(sx,sy,count)
if count ne np then begin
 err='Input arrays do not match in size'
 message,err,/cont
 return
endif

min_x=min(x) & max_x=max(x)
min_y=min(y) & max_y=max(y)
xc=(min_x+max_x)/2.d &  yc=(min_y+max_y)/2.d
if n_elements(center) eq 2 then begin
 xc=center[0] & yc=center[1]
endif

xside=abs(max_x-min_x) & yside=abs(max_y-min_y)
nx=sx[1] & ny=sx[2]
dx=xside/(nx-1.d) & dy=yside/(ny-1.d)

mspace=[dx,dy]
msize=[nx,ny]
if exist(gspace) then mspace=double([gspace[0],gspace[n_elements(gspace)-1]])
if exist(gsize) then msize=[gsize[0],gsize[n_elements(gsize)-1]]

if keyword_set(preserve_area) then $
 msize=[xside/mspace[0]+1.d,yside/mspace[1]+1.d] else $
if keyword_set(adjust_resolution) then $
 mspace=[xside/(msize[0]-1.d),yside/(msize[1]-1.d)]

make_xy,msize[0],msize[1],xg,yg,xc=xc,yc=yc,dx=mspace[0],dy=mspace[1]
gsize=long((size(xg))([1,2]))
gspace=[mspace[0],mspace[1]]

return & end
