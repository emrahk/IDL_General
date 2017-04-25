;+
; PROJECT:
;	SDAC
; NAME:
;	SPHCART
;
; PURPOSE:
;	This function computes cartesion coordinates from RA and DEC
;
; CATEGORY:
;	GEN, VECTOR ANALYSIS, UTILITY, GEOMETRY
;
; CALLING SEQUENCE:
;	Cartesian_coordinates = SPHCART( RA, DEC)
;
; INPUTS:
;	RA: right ascension in degrees, scalar or vector
;	DEC: declination angle in degrees, scalar or vector
;
; EXAMPLE:
;	Cartesian_coordinates = SPHCART( RA, DEC)
;	xc=transpose(sphcart(x_ra(*), x_dec(*))) ;3 by nx;
;	sunxyz=sphcart(sradec(0),sradec(1))
;
; MODIFICATION HISTORY:
; 	Documented richard.schwartz@gsfc.nasa.gov, Version 2 , 29-mar-1996
;-
function sphcart,ra,dec

on_error, 2
; compute cartesian coordinates from long and lat

r=ra/!radeg&d=dec/!radeg
return,temporary( [[cos(r)*cos(d)],[sin(r)*cos(d)],[sin(d)]])

end

