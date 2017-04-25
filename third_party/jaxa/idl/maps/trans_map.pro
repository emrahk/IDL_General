;+
; Project     : SOHO-CDS
;
; Name        : TRANS_MAP
;
; Purpose     : Transform an image map by shifting center, 
;               rescaling pixel spacings, or rotating.
;
; Category    : imaging
;
; Syntax      : IDL> trans_map,map,xshift=xshift,yshift=yshift,xscale=xscale,yscale=yscale
;
; Inputs      : MAP = image map structure
;
; Outputs     : MAP = shifted map
;
; Keywords    : XSHIFT, YSHIFT = shift values in x- and y- directions                                                   (arcsec +W, +N)
;               XSCALE, YSCALE = fractions to expand ( > 1) or shrink
;               ( <1 ) pixel spacings 
;
; History     : Written 28 June 2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro trans_map,map,xshift=xshift,yshift=yshift,xscale=xscale,yscale=yscale,$
                  err=err,_extra=extra

err=''

;-- check inputs 

if ~valid_map(map) then begin
 err='Invalid input map'
 pr_syntax,'trans_map,map,xshift=xshift,yshift=yshift,xscale=xscale,yscale=yscale'
 return
endif

map=shift_map(map,xshift,yshift,/no_copy,_extra=extra)
map=scale_map(map,xscale,yscale,/no_copy,_extra=extra)

return
end
