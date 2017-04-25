;+
; Project     : SOHO-CDS
;
; Name        : PATCH_MAP
;
; Purpose     : patch plot an array of maps
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : patch_map,map
;
; Examples    :
;
; Inputs      : MAP = image map array
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 26 April 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-



pro patch_map,map,xrange=xrange,yrange=yrange,drange=drange,$
                  composite=composite,_extra=extra

if not valid_map(map) then begin
 pr_syntax,'patch_map,map'
 return
endif

if n_elements(xrange) ne 2 then dxrange=get_map_xrange(map) else dxrange=xrange
if n_elements(yrange) ne 2 then dyrange=get_map_yrange(map) else dyrange=yrange
if n_elements(drange) ne 2 then ddrange=get_map_drange(map) else ddrange=drange

np=n_elements(map)
for i=0,np-1 do begin
 if exist(composite) then comp=composite else comp=(i gt 0)
 plot_map,map(i),xrange=dxrange,yrange=dyrange,drange=ddrange,_extra=extra,$
  composite=dcomp
endfor

return & end

 
