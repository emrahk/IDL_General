
function polar2cartesian, polar_coords, offset=offset, scale_fac=scale_fac, qstop=qstop

;+
;NAME:
;       polar2cartesian
;PURPOSE:
;       To convert from polar heliocentric coordinates to cartesian heliocentric
;	coordinates
;SAMPLE CALLING SEQUENCE:
;       xy_coords = polar2cartesian(polar_coords)
;       xy_coords = polar2cartesian(polar_coords [,offset=offset, scale_fac=scale_fac])
;INPUT:
;	polar_coords
;		- A 2xN array of polar coordinate pairs defined as follows:
;			(0,*) = radial coordinate in arbitrary units
;			(1,*) = angular cordinate in degrees ccw from 'north'
;OPTIONAL KEYWORD INPUTS: 
;	offset	- A coordinate pair.  If present, the output x,y coordinates will be
;		  offset by these amounts.
;	scale_fac
;		- Scalar real.  If present, the output x,y coordinates are scaled by
;		  this factor.
;OUTPUT:
;	xy_coords
;		- A 2xN array of cartesian coordinate pairs defined as follows:
;			(0,*) = x coordinates in units matching those of input radial
;				coordinates (multiplied by SCALe_FAC, if present).
;			(1,*) = y coordinates in units matching those of input radial
;				coordinates (multiplied by SCALe_FAC, if present).
;HISTORY:
;       Written by G.L. Slater sometime in the distant past

if n_elements(offset) eq 0 then offset = [0,0]
if n_elements(scale_fac) eq 0 then scale_fac = 1

r = reform(polar_coords(0,*))
theta = reform(polar_coords(1,*))
x = r*cos((theta+90)/!radeg)*scale_fac + offset(0)
y = r*sin((theta+90)/!radeg)*scale_fac + offset(1)

if keyword_set(qstop) then stop
return, transpose([[x],[y]])

end

