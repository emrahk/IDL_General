;+
; Project     : HESSI
;
; Name        : SURFACE_MAP
;
; Purpose     : Wrapper around surface plot to plot surfaces of maps
;
; Category    : maps
;
; Syntax      : IDL> surface_map,map
;
; Inputs      : MAP = map structure
;
; Outputs     : Surface plots
;
; Keywords    : All usual plot keywords used by PLOT_MAP and
;               LOG_SCALE = use log scale
;               DRANGE = [dmin,dmax] = data range to plot
;               SHADE_SURF = plot shaded surface
;
; History     : 10-May-2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro surface_map,map,shade_surf=shade_surf,drange=drange,$
             log_scale=log_scale,err=err,_extra=extra

err=''

;-- extract data and coordinate arrays from map

if ~valid_map(map,_extra=extra) then begin
 pr_syntax,'surface_map,map'
 return
endif

pic=get_map_sub(map,count=count,xp=xp,yp=yp,_extra=extra,err=err)
if count lt 2 then return
if valid_range(drange) then dmin=min(drange,max=dmax)

log_scale=keyword_set(log_scale)
if log_scale then begin
 nok=where(pic le 0.,count,complement=ok)
 if count eq n_elements(pic) then begin
  err='All data points negative. Cannot plot using log scale'
  message,err,/cont
  return
 endif 
 if count gt 0 then pic[nok]=min(pic[ok])
 pic=alog10(pic)
endif
 
proc='surface'
if keyword_set(shade_surf) then proc='shade_surf'
call_procedure,proc,pic,xp,yp,min_val=dmin,max_val=dmax,$
               /xstyle,/ystyle,_extra=extra

return & end
