;+
; Project     : SOHO-CDS
;
; Name        : DEF_MAP
;
; Purpose     : Define a basic 2x2 element image map 
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : def_map,map
;
; Examples    :
;
; Inputs      : None
;
; Opt. Inputs : None
;
;
; Outputs     : MAP = {data:data,xp:xp,yp:yp,time:time,id:id} (old format)
;                 or  {data:data,xc:xc,yc:yc,dx:dx,dy:dy,time:time,id:id}
;               where,
;               DATA  = 2x2 image array
;               XP,YP = 2x2 cartesian coordinate arrays
;               XC,YC = image center coordinates
;               DX,DY = image pixel scales
;               ID    = blank ID label
;               TIME  = blank start time of image
;
; Opt. Outputs: None
;
; Keywords    : OLD = use old format
;               DIM = data dimensions [nx,ny]
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 October 1997, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro def_map,map,old_format=old_format,dim=dim

nx=2 & ny=2
ndim=n_elements(dim)
if ndim gt 0 then begin
 nx=dim(0) & ny=dim(0)
 if ndim gt 1 then ny=dim(1)
endif

base=fltarr(nx,ny)
if keyword_set(old) then begin
 map={data:base,xp:base,yp:base,time:'',id:''} 
endif else begin
 map={data:base,xc:0.,yc:0.,dx:1.,dy:1.,time:'',id:''}
endelse 

return
end
