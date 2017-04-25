;+
; Project     : SOHO-CDS
;
; Name        : MK_MAP_XP
;
; Purpose     : compute X-coordinate arrays from center and spacing
;
; Category    : imaging
;
; Syntax      : xp=mk_map_xp(xc,dx,nx,ny)
;
; Inputs      : XC = x-coord image center (arcsecs)
;               DX = pixel spacing in x-direc (arcsecs)
;               NX,NY = output dimensions
;
; Outputs     : XP = 2d X-coordinate array
;
; History     : Written 16 Feb 1998, D. Zarro, SAC/GSFC
;               Modified, 22 September 2014, Zarro (ADNET)
;               - converted to double precision arithmetic
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_map_xp,xc,dx,nx,ny
dumx = nx*dx/2.d0

;dprint,'% mk_map_xp: being called by '+get_caller()
xp=(dindgen(nx)+0.5d0)*dx - dumx + xc
if ~exist(ny) then ny=1
if ny gt 1 then return,rebin(temporary(xp),nx,ny,/sample) else return,xp
end

