;+
; Project     : SOHO-CDS
;
; Name        : RESPACE_MAP
;
; Purpose     : Convert an image map to new pixel spacing  
;
; Category    : imaging
;
; Explanation : Interpolate (using congrid) user-specified spacings and
;               compute new output dimensions
;
; Syntax      : gmap=respace_map(map,sx,sy)
;
; Inputs      : MAP = image map structure
;               SX,SY = new (x,y) spacing
;
; Outputs     : GMAP = rebinned map
;
; History     : Written 22 March 1998, D. Zarro, SAC/GSFC
;		P. Saint-Hilaire, 2007/01/04: added keyword
;		INTERACTIVE (if not set, program will no longer prompt
;		user)
;               Modified 11-Jun-2014, Zarro (ADNET)
;                - optimized code and updated documentation
;
; Contact     : dzarro@solar.stanford.edu
;-

function respace_map,map,sx,sy,err=err,_extra=extra,max_dim=max_dim, INTERACTIVE=INTERACTIVE
err=''

;-- check inputs (valid map & spacings)

if ~valid_map(map,old=old) or ~exist(sx) then begin
 pr_syntax,'gmap=respace_map(map,sx,sy)'
 if exist(map) then return,map else return,-1
endif
if ~exist(sy) then sy=sx

IF KEYWORD_SET(INTERACTIVE) THEN asked=0 ELSE asked=1

for i=0,n_elements(map)-1 do begin
 err=''
 unpack_map,map[i],dx=dx,dy=dy,nx=nx,ny=ny,/no_data
 if (sx eq dx) and (sy eq dy) then begin
  message,'no rebinning necessary',/cont
  gmap=merge_struct(gmap,map[i])
 endif else begin

;-- compute and check new output dimensions

  gx=nint(1.d0+dx*(nx-1.d0)/sx)
  gy=nint(1.d0+dy*(ny-1.d0)/sy)
  if ~asked then begin
   if (gx gt 1024) or (gy gt 1024) then begin
    message,'excessive new output dimensions - '+trim(string(gx))+','+trim(string(gy)),/cont
    ans='' & read,'* continue [def=n]?',ans
    ans=strmid(strupcase(ans),0,1)
    if ans ne 'Y' then begin
     err='Aborted' & message,err,/cont
     return,map
    endif
    asked=0
   endif
  endif
  tmap=rep_tag_value(map[i],congrid(map[i].data,gx,gy,_extra=extra),'data',/no_copy)
  tmap.dx=sx
  tmap.dy=sy
  gmap=merge_struct(gmap,tmap,/no_copy)
 endelse
endfor

return,gmap & end
