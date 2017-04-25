
;+
; NAME:
;	S2C
; PURPOSE:
;	Returns Cartesian coordinates (X,Y,Z) of a position vector
;	or array of position vectors whose spherical coordinates are
;	specified by V0.
; CALLING SEQUENCE:
;	V1 = SPH2XYZ(V0, YOFF=YOFF, ZOFF=ZOFF, ROLL=ROLL, B0=B0)
; INPUTS:
;	V0 = Spherical coordinates (r,theta,phi) of a 2- OR 3-vector  with theta and phi in degrees.
;		 If V0 is a 2-vector (2xN) then those are theta and phi and r is assumed to be 1
;
; OPTIONAL INPUTS:
;       YOFF, ZOFF = Y AND Z TRANSLATIONS
;       ROLL
;       B0
; OUTPUTS:
;       V1 = 3-vector containing Cartesian coordinates (x,y,z)
;       corresponding to spherical coordinates specified in V0.  It is
;       a 3xn array if v0 is.
; MODIFICATION HISTORY:
;       Written, Dec 2013, richard.schwartz@nasa.gov, wrapper around S2c by  G. L. Slater, LPARL
;
;-
function sph2xyz, V0, _extra = extra

szl  = size( v0, /struct )
dim  = szl.dimensions
nel  = szl.n_elements
case nel of
	2: input = [1.0, v0[*] ]
	3: input = v0
	else: input = dim[0] eq 3 ? v0 : [ fltarr(1, dim[1]) + 1.0, v0 ]
	endcase
out = s2c( input, _extra = extra )
return, out
end