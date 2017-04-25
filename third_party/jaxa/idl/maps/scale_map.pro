;+
; Project     : SOHO-CDS
;
; Name        : SCALE_MAP
;
; Purpose     : Scale an image map.
;               Note that this operation does not rebin pixels.
;
; Category    : imaging
;
; Explanation : scale a map in x- and y-directions by changing pixel spacings
;
; Syntax      : smap=scale_map(map,xscale,yscale)
;
; Inputs      : MAP = image map structure
;               XSCALE,YSCALE = scale values in x- and y- directions
;                              (< shrink, > 1 expand)
;
; Outputs     : SMAP = scaled map
;
; Keywords    : REVERSE = do reverse action
;
; History     : Written 30 June 2008, Zarro (ADNET)
;               Modified, 22 Oct 2014, Zarro (ADNET)
;               - converted to double-precision arithmetic
;
; Contact     : dzarro@solar.stanford.edu
;-

function scale_map,map,xscale,yscale,err=err,no_copy=no_copy,reverse=reverse,$
                       _extra=extra

err=''

;-- check inputs 

if ~valid_map(map) then begin
 err='Invalid input map'
 pr_syntax,'smap=scale_map(map,xscale,yscale,[xc=xc,yc=yc])'
 if exist(map) then return,map else return,-1
endif

err=''
if keyword_set(no_copy) then tmap=temporary(map) else tmap=map
pxscale=1.d0
if is_number(xscale) then pxscale=double(xscale)
pyscale=1.d0
if is_number(yscale) then pyscale=double(yscale) 

reverse=keyword_set(reverse) 
if (pxscale gt 0.) then begin
 if reverse then pxscale=1.d0/pxscale
 tmap.dx=tmap.dx*pxscale
endif

if (pyscale gt 0.) then begin
 if reverse then pyscale=1.d0/pyscale
 tmap.dy=tmap.dy*pyscale
endif

return,tmap
end
