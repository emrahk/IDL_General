;+
; PROJECT:
;	SSW
; NAME:
;	SUN_OCC
;
; PURPOSE:
;	This results of this procedure are used to determine whether a position
;	(as in a spacecraft around the Earth) has a view angle to the Sun
;	that is above an occultation height, Hmin
;
; CATEGORY:
;	Solar viewing
;
; CALLING SEQUENCE:
;	sun_occ, scxyz, ut, hmin, smin
;
; CALLS:
;	Solephut - used to obtain the position of the Sun in celestial coord, J2000
;
;
; INPUTS:
;       SCXYZ - 3 vector, or array of 3 vectors (3xN) in celestial coordinates, J200, in meters
;		UT - time argument to be interpreted by anytim()
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       HMIN - Minimum height of tangent to source above the Earth's surface
;		SMIN - Distance along line of sight to the Sun to the HMIN
;	Here's how to use them.  If SMIN is negative then the Sun can be
;	seen from that position regardless of HMIN.  If SMIN is positive then
;	the Sun can be seen if HMIN is greater than a critical value.
;	For x-rays, HMIN is 70 km.  For optical wavelengths, HMIN is 0. See
;	the referenced paper for the geometry
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Taken from:
;	The Burst and Transient Source Experiment
;	Earth Occultation Technique
;	Short title: BATSE Earth Occultation
;	B. A. Harmon1, G. J. Fishman, & C. A. Wilson
;	NASA Marshall Space Flight Center, SD50, Huntsville, AL 35812 USA
;	W. S. Paciesas2& S. N. Zhang
;	Department of Physics, University of Alabama in Huntsville, Huntsville, AL USA 35899
;	M. H. Finger3, T. M. Koshut, M. L. McCollough, C. R. Robinson4 & B. C. Rubin5
;	Universities Space Research Association, SD50, NASA Marshall Space Flight Center, Huntsville, AL 35812 USA
;	The Astrophysical Journal Supplement Series, 138:149-183, 2002
;	© 2002. The American Astronomical Society. All rights reserved. Printed in U.S.A.
;;
; MODIFICATION HISTORY:
;	18-MAR-2010, richard.schwartz@nasa.gov
;
;-
pro sun_occ, scxyz, ut, hmin, smin

sun = solephut(ut)
sunxyz = transpose( sphcart(reform(sun[0,*]),reform(sun[1,*])))
nel = n_elements(sunxyz)/3

f = 1/298.258 ; earth oblateness
a = 6378.136*1e3 ;earth radius in m
s = sunxyz * rebin([1.,1.,1./(1-f)],3,nel)
g = scxyz * rebin([1.,1.,1./(1-f)],3,nel)


hmin = sqrt(( total(g*g,1) - total(g*s,1)^2/total(s^2,1))>0) -a
smin = - (total(g*s,1)/total(s^2,1))

end
