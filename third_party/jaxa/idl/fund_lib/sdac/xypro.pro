;+
; PROJECT:
;	SDAC
; NAME: XYPRO
;
; PURPOSE: compute spherical from cartestian coordinates (3-d) 
;
; CATEGORY: util, math, geometry
;
; CALLING SEQUENCE: XYPRO, Xyz, Az_el
; 
; EXAMPLES:
;	xypro, xyz, az_el
;
; INPUTS:
;       Xyz, array of n 3 vectors (unit measure), n x 3
; OUTPUTS:
;       Az_el - azimuth and elevation in degrees, n x 2
; HISTORY:
;	 richard.schwartz@gsfc.nasa.gov
;-
pro xypro, xyz, az_el

on_error,2
az_el = !radeg*[[atan(xyz(*,1),xyz(*,0))],[asin(xyz(*,2))]]

end
