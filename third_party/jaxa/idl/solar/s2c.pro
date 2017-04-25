
; (4-feb-91)
FUNCTION S2C,V0,YOFF=YOFF,ZOFF=ZOFF,ROLL=ROLL,B0=B0
;+
; NAME:
;	S2C
; PURPOSE:
;	Returns Cartesian coordinates (X,Y,Z) of a position vector
;	or array of position vectors whose spherical coordinates are
;	specified by V0.
; CALLING SEQUENCE:
;	V1 = S2C(V0,YOFF=YOFF,ZOFF=ZOFF,ROLL=ROLL,B0=B0)
; INPUTS:
;	V0 = Spherical coordinates (r,theta,phi) of a 3-vector or
;	     array of 3-vectors, with theta and phi in degrees.
; OPTIONAL INPUTS:
;       YOFF, ZOFF = Y AND Z TRANSLATIONS
;       ROLL
;       B0
; OUTPUTS:
;       V1 = 3-vector containing Cartesian coordinates (x,y,z)
;       corresponding to spherical coordinates specified in V0.  It is
;       a 3xn array if v0 is.
; MODIFICATION HISTORY:
;       Written, Jan, 1991, G. L. Slater, LPARL
;       GLS - Modified to allow translation, roll, and b0 corrections
;-

  if n_elements(yoff) eq 0 then yoff = 0
  if n_elements(zoff) eq 0 then zoff = 0
  if n_elements(roll) eq 0 then roll = 0
  if n_elements(b0) eq 0 then b0 = 0
  v0 = makarr(v0)
  r = makvec(v0(0,*)) & theta = makvec(v0(1,*))/!radeg
  phi = makvec(v0(2,*))/!radeg
  x = r*cos(theta)*cos(phi) & y = r*cos(theta)*sin(phi) & z = r*sin(theta)
  cosb0 = cos(b0/!radeg)
  sinb0 = sin(b0/!radeg)
  x1 = x*cosb0 - z*sinb0
  y1 = y
  z1 = x*sinb0 + z*cosb0
  cosroll = cos(roll/!radeg)
  sinroll = sin(roll/!radeg)
  x2 = x1
  y2 = y1*cosroll - z1*sinroll
  z2 = y1*sinroll + z1*cosroll
  y2 = y2 - yoff & z2 = z2 - zoff

  return,transpose([[x2],[y2],[z2]])

  end

