;+
; Project     : SOHO-CDS
;
; Name        : MAKE_XY
;
; Purpose     : Make a uniform 2d X-Y grid of coordinates
;
; Category    : imaging
;
; Syntax      : make_xy,nx,ny,xp,yp
;
; Inputs      : NX,NY = X,Y dimensions
;
; Outputs     : XP,YP = 2d (X,Y) coordinates
;
; Opt. Outputs: None
;
; Keywords    : DX, DY = grid spacing [def=1,1]
;               XC, YC = grid center  [def=0,0]
;
; History     : Written 22 June 1997, D. Zarro, ARC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro make_xy,nx,ny,xp,yp,xc=xc,yc=yc,dx=dx,dy=dy

if n_params(0) ne 4 then begin
 pr_syntax,'make_xy,nx,ny,xp,yp,[xc=xc,yc=yc,dx=dx,dy=dy]'
 return
endif

if ~exist(dx) then dx=1.d0
if ~exist(dy) then dy=1.d0
if ~exist(xc) then xc=0.d0
if ~exist(yc) then yc=0.d0

xp=mk_map_xp(xc,dx,nx,ny)
yp=mk_map_yp(yc,dy,nx,ny)

return & end

