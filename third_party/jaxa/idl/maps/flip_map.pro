;+
; Project     : SOHO-CDS
;
; Name        : FLIP_MAP
;
; Purpose     : Flip map to correct for 180 degree roll
;
; Category    : imaging
;
; Syntax      : fmap=flip_map(map)
;
; Inputs      : MAP = image map structure
;
; Outputs     : FMAP = flipped map
;
; Keywords    : None
;
; History     : Written 7 April 2005 - Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function flip_map,map,err=err

err=''

;-- check input

if ~valid_map(map) then begin
 pr_syntax,'fmap=flip_map(map)'
 if exist(map) then return,map else return,-1
endif

;-- check what needs correcting

chk=where( abs(map.roll_angle) eq 180,count)
if count eq 0 then begin
 message,'Input map(s) already corrected',/cont
 return,map
endif

nmap=map
nx=get_map_prop(map[0],/nx)
ny=get_map_prop(map[0],/ny)

for i=0,n_elements(map)-1 do begin

 if abs(map[i].roll_angle) eq 180. then begin

;-- determine original crpix values

  crpix1=comp_fits_crpix(map[i].xc,map[i].dx,nx)
  crpix2=comp_fits_crpix(map[i].yc,map[i].dy,ny)

;-- flip coordinates

  crpix1 = nx-1.d0-crpix1
  crpix2 = ny-1.d0-crpix2

;-- compute new center

  nmap[i].xc=comp_fits_cen(crpix1,map[i].dx,nx)
  nmap[i].yc=comp_fits_cen(crpix2,map[i].dy,ny)

;-- flip data

  nmap[i].data=rotate(map[i].data,2)
  nmap[i].roll_angle=0d.
  nmap[i].roll_center=[nmap[i].xc,nmap[i].yc]
 endif
endfor

return,nmap & end

