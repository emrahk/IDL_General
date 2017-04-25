;+
; Project     : SOHO-CDS
;
; Name        : ROT_MAP
;
; Purpose     : rotate image contained within structure created by MAKE_MAP
;
; Category    : imaging
;
; Syntax      : rmap=rot_map(map,angle)
;
; Inputs      : MAP = map structure 
;               ANGLE = angle in degrees to rotate image map (+ for clockwise)
;
; Opt. Inputs : None
;
; Outputs     : RMAP = map with rotated coordinates
;
; Keywords    : RCENTER= [XC,YC] = center of rotation 
;               Use MAP.ROLL_CENTER if CENTER is not entered
;             : NO_REMAP = don't remap image data (just rotate coords)
;             : FULL_SIZE = adjust image size to fit all rotated pixels
;             : ROLL_ANGLE = new roll angle for map
;             : NO_COPY = do not make new copy of input
;             : ABOUT_CENTER = force roll about image center
;
; History     : Written 22 November 1996, D. Zarro (ARC/GSFC)
;               Modified 27 December 2002, Zarro (EER/GSFC) - made image center
;               the default roll center for zero roll data
;               Modified 23 March 2009, Zarro (ADNET)
;                - added checks for NaN's
;               12-June-2012, Zarro (ADNET) 
;                - unvectorized (to support /NO_COPY)
;                - preserved input data type
;               Modified 22 October 2014, Zarro (ADNET)
;               - use double-precision arithmetic
;               Modified 24 November 2015, Zarro (ADNET)
;               - changed CENTER to RCENTER to avoid clash with image center
;
; Contact     : dzarro@solar.stanford.edu
;-

function rot_map,map,angle,rcenter=rcenter,no_remap=no_remap,err=err,$
                verbose=verbose,full_size=full_size,_extra=extra,$
                roll_angle=roll_angle,no_copy=no_copy,about_center=about_center

err=''

if ~valid_map(map) then begin
 err='rmap=rot_map(map,angle) OR rmap=rot_map(map,roll_angle=roll_angle)'
 pr_syntax,err 
 print,'% ANGLE = angle (deg clockwise to roll) or ROLL = new map ROLL angle'
 if exist(map) then return,map else return,-1
endif

angle_entered=exist(angle)
roll_entered=exist(roll_angle)

if (~angle_entered) && (~roll_entered) then begin
 err='Enter rotation angle in degrees clockwise from North'
 message,err,/info
 if exist(map) then return,map else return,-1
endif 

verbose=keyword_set(verbose)
adjust_resolution=keyword_set(full_size)

;-- don't rotate if multiple of 360.

if angle_entered then begin
 if (angle mod 360.) eq 0. then return,map
endif 

;-- read image and pixel arrays

dx=map.dx
dy=map.dy
xc=map.xc
yc=map.yc
xp=get_map_xp(map)
yp=get_map_yp(map)

icenter=[xc,yc]
roll_center=get_map_prop(map,/roll_center,def=icenter)
curr_roll=get_map_prop(map,/roll_angle,def=0.d)
if valid_map(rcenter) then roll_center=get_map_center(rcenter) else $
 if n_elements(rcenter) eq 2 then roll_center=double(rcenter)
if angle_entered then ang=double(angle) else ang=double(roll_angle)-curr_roll

if keyword_set(no_copy) then nmap=temporary(map) else nmap=map
dprint,'% ROT_MAP: '
dprint,trim(roll_center)
if keyword_set(about_center) then roll_center=icenter
new_roll=(ang+curr_roll) mod 360
if have_tag(nmap,'roll_angle') then nmap.roll_angle=new_roll else nmap=add_tag(nmap,new_roll,'roll_angle')
if have_tag(nmap,'roll_center') then nmap.roll_center=roll_center else $
 nmap=add_tag(nmap,roll_center,'roll_center',index='roll_angle') 

apply_roll=(ang mod 360.) ne 0.
if apply_roll then begin
 roll_xy,xp,yp,ang,rx,ry,rcenter=roll_center,verbose=verbose
 nmap=repack_map(nmap,rx,ry,/no_copy)

;-- rebin image
;-- do this by regridding rotated coordinates and
;   and computing image data value in pre-rotated image by interpolation

 if ~keyword_set(no_remap) then begin
  grid_xy,rx,ry,gx,gy,space=[dx,dy],$
  _extra=extra,adjust_resolution=adjust_resolution
  roll_xy,gx,gy,-ang,rx,ry,rcenter=roll_center,verbose=verbose
  xmin=min(xp,max=xmax) & ymin=min(yp,max=ymax) 
  out=where((rx lt xmin) or (rx gt xmax) or $
            (ry lt ymin) or (ry gt ymax),count)
  count=0
  if count eq n_elements(rx) then begin
   err='No data in rotated image'
   message,err,/info
  endif else begin
   if verbose then $
    dprint,'% ROT_MAP: # of unrotated points = ',trim(string(count))
   in=where( (rx ge xmin) and (rx le xmax) and $
             (ry ge ymin) and (ry le ymax),icount)
   find=where(finite(nmap.data,/nan),ncount)
   if ncount gt 0 then begin
    nmap.data[find]=0.
    rx[find]=-999999.
    ry[find]=-999999.
   endif
   rdata=interp2d(nmap.data,xp,yp,rx,ry,_extra=extra,missing=0)
   chk=array_equal(size(rdata),size(nmap.data))
   if chk then nmap.data=temporary(rdata) else $
    nmap=rep_tag_value(nmap,temporary(rdata),'data')
   nmap=repack_map(nmap,gx,gy,/no_copy)
  endelse
 endif else nmap.roll_angle=curr_roll
endif 
delvarx,xp,yp,gx,gy,rx,ry,data

return,nmap & end
