;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_REGION
;
; Purpose     : compute pixel indicies of region [xmin,xmax,ymin,ymax]
;
; Category    : imaging
;
; Syntax      : indicies=get_map_region(xp,yp,region)
;
; Inputs      : XP,YP = 2-d X- and Y- coordinate arrays
;               REGION = coordinate region to window = [xmin,max,ymin,ymax]
;
; Outputs     : [imin,imax,jmin,jmax] = x and y indicies or region, as in,
;               (imin:imax,jmin:jmax)
;
; Keywords    : ERR = error string
;               COUNT = # of points in subregion
;
; History     : Written 20 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_region,xp,yp,region,count=count,err=err,fast=fast

err=''
count=0

if (n_elements(region) ne 4) or ~exist(xp) or ~exist(yp) then begin
 pr_syntax,'index=get_map_region(xp,yp,region)'
 err='Invalid input' 
 return,[-1,-1,-1,-1]
endif

xmin=min(region[0:1])
xmax=max(region[0:1])
ymin=min(region[2:3])
ymax=max(region[2:3])

dreg=[-1,-1,-1,-1]

vfind=where( (xp ge xmin) and (xp le xmax) and (yp ge ymin) and $
             (yp le ymax) ,count)
if (count eq 0) then return,dreg

;-- fast option

if keyword_set(fast) then begin
 ox=where((xp ge xmin) and (xp le xmax),xcount)
 oy=where((yp ge ymin) and (yp le ymax),ycount)
 if (xcount gt 0) and (ycount gt 0) then $
  return,[min(ox),max(ox),min(oy),max(oy)] else begin
  count=0
  return,dreg
 endelse
endif

sz=size(xp)
nx=sz[1] & ny=sz[2]

xy1=get_ij(vfind[0],nx)
xy2=get_ij(vfind[count-1],nx)
imin=[0,0]
imax=imin
imin[0]=min([xy1[0],xy2[0]])
imin[1]=min([xy1[1],xy2[1]])
imax[0]=max([xy1[0],xy2[0]])
imax[1]=max([xy1[1],xy2[1]])
imin[0]= 0 > imin[0] < (nx-1)
imax[0]= 0 > imax[0] < (nx-1)
imin[1]= 0 > imin[1] < (ny-1)
imax[1]= 0 > imax[1] < (ny-1)
delvarx,vfind

return,[imin[0],imax[0],imin[1],imax[1]]
end

