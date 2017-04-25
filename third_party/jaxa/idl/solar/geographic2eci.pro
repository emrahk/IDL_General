;+
; NAME:
;       GEOGRAPHIC2ECI
;
; PURPOSE:
;	Wrapper for the geo2eci.pro routine, for SSW users of the ANYTIM time format.
;
;       Converts from geographic spherical coordinates [latitude, longitude, altitude]
;	to ECI (Earth-Centered Inertial) [X,Y,Z] rectangular coordinates.
;	A time is also needed.
;
;	ECI coordinates are in km from Earth center.
;	Geographic coordinates are in degrees/degrees/km
;	Geographic coordinates assume the Earth is a perfect sphere, with radius equal to its equatorial radius.
;
; CALLING SEQUENCE:
;       ECIcoord=geographic2eci(gcoord,time)
;
; INPUT:
;	gcoord : the geographic coordinates [latitude,longitude,altitude], can be an array [3,n] of n such coordinates.
;	time: in any ANYTIM format, can be a 1-D array of n such times.
;
; KEYWORD INPUTS:
;	None
;
; OUTPUT:
;	a 3-element array of ECI [X,Y,Z] (in km), or an array [3,n] of n such coordinates	
;
; COMMON BLOCKS:
;	None
;
; RESTRICTIONS:
;       None
;
; EXAMPLE:
;
;	IDL> ECIcoord=geographic2eci([0,0,0], '2002/03/09 21:21:21.021')
;	IDL> print,ECIcoord
;	-3902.9606       5044.5547       0.0000000
;
;	(The above is the ECI coordinates of the intersection of the equator and Greenwitch's 
;	meridien on 2002/03/09 21:21:21.021)
;
;
; MODIFICATION HISTORY:
;	Written by Pascal Saint-Hilaire (Saint-Hilaire@astro.phys.ethz.ch) on 2001/05/14
;		
;-

;=============================================================================================
FUNCTION geographic2eci,gcoord,tme
	MJDstc=anytim(tme,/mjd)
	JDtime=DOUBLE(MJDstc.mjd) + 2400000.5 + DOUBLE(MJDstc.time)/86400000
	RETURN,geo2eci(gcoord,JDtime)
END
;=============================================================================================
