;+
; NAME: vis_sigma_clean_beam
;
; CALLING SEQUENCE:
;	sigma_clean_beam =  vis_sigma_clean_beam(image_obj)
;
; PURPOSE:
;       This function calcualtes the sigma of the clean beam
;
; METHOD:
;       SUGGESTED ALGORITHM: (gordon hurford mail from Thu, 25 Jan 2001 15:43:17 -0800)
;
;       1. Generate the backprojection map with a set of weights, Wi,
;       (presumably found in SPATIAL_FREQEUNCY_WEIGHT).  Let W = SUMi(Wi).  We
;       need not assume that W = 1. (For a single point source of incident flux,
;       N photons per subcollimator, we would expect the peak of the
;       backprojection map to have the value, WN.)
;
;       2. Determine the components as at present, where the component flux is
;       set equal to the 'gain' times the peak value in the dirty map.  Let Cj
;       be the flux in the j'th component.  (For the single point source,
;       SUMj(Cj) in a fully cleaned map would be WN.)  Let M(x,y) be the
;       residual map (whose original peak value, before cleaning, was about WN).
;
;       3. Calculate the sigma of the CLEAN gaussian beam.  If Ri is the
;       resolution (corresponding to the half pitch) of the i'th subcollimator,
;       then to match the curvature at the peak, sigma is given by:
;       sigma = 0.45 * SQRT ( W / SUMi( Wi/ Ri^2) )
;
;       4. Gi(r) = exp(-0.5*(r/sigma)^2) is the gaussian of unit peak value and
;       sigma as given above.  (The area under Gi(r) is 2pi*sigma^2.)  Then the
;       cleaned map is given by:
;       [SUMj (Cj * G(r) + M(x,y)] / K
;
;       There are three options for K.
;
;       a. If K is set to 1, then (for a single point source) then peak of the
;       map is WN incident photons/subcollimator (as at present).
;
;       b. If K is set to W * 2 * pi * sigma^2,  then the integrated area under
;       any feature has the units 'incident photons / subcollimator.
;
;       c. If K is set to (W * 2 * pi * sigma^2 / 39.6), then the integrated
;       area under any feature has the units, 'photons / cm^2'.   (39.6 cm^2 is
;       just the nominal area of the lower detector segment.)
;
;       My suggestion is to use option c.;
;
; INPUTS:
;    vis - visibility bag (array of visibility structures 
;		
; OPTIONAL KEYWORD INPUTS:
;  SPATIAL_FREQUENCY_WEIGHTING = visibility dependent weighting, one for each visibility
;  BEAM_WIDTH_FACTOR =
; OUTPUTS;
;
; HISTORY:
; richard.schwartz@nasa.gov, 
; 22-apr-2013, based on hsi_sigma_clean_beam
;-
FUNCTION vis_sigma_clean_beam, vis, $
  spatial_frequency_weighting = spatial_frequency_weighting, $
  beam_width_factor=beam_width_factor


default, beam_width_factor, 1.0
default, spatial_frequency_weighting, 1.0

wi= spatial_frequency_weighting
ri = ( vis.u^2 + vis.v^2 )^(-0.5) / 2.0
wi = ri * 0.0 + wi ;make sure same number of wi as ri
ri = get_uniq( eps=0.01, ri, sorder)
wi = wi[sorder]

w=total(wi)

s  = total( wi / ri^2 )
sigma_clean_beam=0.45*sqrt(w/s)

return, sigma_clean_beam/beam_width_factor

END