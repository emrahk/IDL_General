
;+
; NAME: vis_spatial_frequency_weighting
;
; CALLING SEQUENCE:
;       spatial_frequency_weighting =  vis_spatial_frequency_weighting(vis, spatial_frequency_weighting, $
;       uniform_weighting=uniform_weighting)
;
; PURPOSE:
;       This function returns the spatial_frequency_weighting factor for
;       each visibility in the input vis bag. The weights are not normalized. That's
;       left for the task that uses them
;
; METHOD:
;
; INPUTS:
;    vis - visibility bag (array of visibility structures)
;    spatial_frequency_weighting - this may take several forms, normally as a float array or a single scalar
;    1. Single scalar 1.0 - so-called natural weighting. Will return an array of 1's for each visibility
;    2. Array of values - the number of visibilities and weights must agree
;    3. If UNIFORM_WEIGHTING is set, then the spatial weights will be computed based on 
;     sqrt(vis.u^2 + vis.v^2))
; KEYWORD INPUTS:
;     UNIFORM_WEIGHTING - return weights given by sqrt( vis.u^2 + vis.v^2)
;   
; OPTIONAL KEYWORD INPUTS:
;  
; OUTPUTS;
;
; HISTORY:
; richard.schwartz@nasa.gov, 
; 22-apr-2013, based on hsi_sigma_clean_beam
;-
function vis_spatial_frequency_weighting, vis, spatial_frequency_weight, uniform_weighting=uniform_weighting,$
  error=error, err_msg=err_msg


error = 1
;default error message on failure
err_msg = 'Visibility bag, vis, and SPATIAL_FREQUENCY_WEIGHTs cannot be reconciled. ' + $
  'spatial_frequency_weighting - must have 1 element, or the same number as vis, or UNIFORM_WEIGHTING must be set'
;  
vis_sz = size(/struct, vis)
nvis = vis_sz.n_elements
if vis_sz.type_name ne 'STRUCT' then begin
  err_msg = 'Visibility bag, vis, is not a structure'
  message,/info, err_msg
  endif
default, spatial_frequency_weight, 1.0
;Deal with UNIFORM_WEIGHTING first

if keyword_set( uniform_weighting ) then $
  spatial_frequency_weight = sqrt( vis.u^2 + vis.v^2) ;uniform weight
nsfw = n_elements( spatial_frequency_weight )
spatial_frequency_weight = nsfw eq 1 ? spatial_frequency_weight + fltarr( nvis ): spatial_frequency_weight
nsfw = n_elements( spatial_frequency_weight )
error = nsfw eq nvis ? 0 : 1

if error then begin 
  message, err_msg
  return, 0
  endif
  
error = 0
err_msg = ''
return, spatial_frequency_weight
end