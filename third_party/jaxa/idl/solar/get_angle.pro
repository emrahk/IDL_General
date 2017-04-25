;+
; Project     : SDAC
;
; Name        : GET_ANGLE
;
; Purpose     : This function returns the angle (degrees) between two vectors(directions)
;		specified in spherical coordinates of an azimuthal angle
;		and declination, usually right ascension and declination
;
; Category    : GEN, Coordinate Manipulations
;
; Explanation : The vectors are converted to Cartesian coordinates, summed
;		over the products, then the inverse cosine is used to
;		return the angle.
;
; Use         : Angle = GET_ANGLE( Radec1, Radec2 )
;
; Inputs      : Radec1 - Vector 1 right ascension and declination in degrees
;		Radec1 may be an array of vectors, dimensioned 2xN_elements
;             : Radec2 - Vector 2 right ascension and declination in degrees
;		Radec2 may be an array as well, number of vectors must be the same
;			or there must be only a single radec1 or radec2 vector (direction)
;
; Opt. Inputs : None
;
; Outputs     : Returns the angle in degrees.
;
; Opt. Outputs: None
;
; Keywords    :
;
; Calls       : SPHCART
;
; Common      : None
;
; Restrictions:
;
; Side effects: None.
;
; Prev. Hist  : This was originally written as angle.pro in 1987 by RAS.
;
; Modified    : Version 1, RAS, 26-Dec-1996
;				13-jan-2012, richard.schwartz@nasa.gov, moved to ssw/gen/idl/solar
;				Previously, radec1 could be an array of directions, but radec2 could only be a single direction
;				Now, radec1 and radec2 can be arrays provided they are of the same length
;-
;==============================================================================
function get_angle, radec1, radec2

v1 = sphcart( (radec1[0,*])[*], (radec1[1,*])[*] )
;v2 = fltarr(3,1) + (sphcart( radec2(0), radec2(1)))[*]
v2 = sphcart( (radec2[0,*])[*], (radec2[1,*])[*] )
n1 = n_elements(radec1)/2
n2 = n_elements(radec2)/2
if n1 ne n2 then begin
	if min([n1,n2] ) ne 1 then message,'Inconsistent number of radec1 and radec2'
	v1 = n1 eq 1 ? rebin( v1,n2,3) : v1
	v2 = n2 eq 1 ? rebin( v2,n1,3) : v2
	endif
angle = !radeg * acos( total(v1 * v2,2) <1.0)

return, angle
end

