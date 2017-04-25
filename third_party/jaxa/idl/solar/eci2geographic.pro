;+
; NAME:
;       ECI2GEOGRAPHIC
;
; PURPOSE:
;	Wrapper for the eci2geo.pro routine, for SSW users of the ANYTIM time format.
;
;       Converts from ECI (Earth-Centered Inertial) (X,Y,Z) rectangular coordinates to 
;	geographic spherical coordinates (latitude, longitude, altitude).
;	A time is also needed.
;
;	ECI coordinates are in km from Earth center.
;	Geographic coordinates are in degrees/degrees/km
;	Geographic coordinates assume the Earth is a perfect sphere, with radius equal to its equatorial radius.
;
; CALLING SEQUENCE:
;       gcoord=eci2geographic(ECI_XYZ,time)
;
; INPUT:
;	ECI_XYZ : the ECI [X,Y,Z] coordinates (in km), can be an array [3,n] of n such coordinates.
;	time: in any ANYTIM format, can be a 1-D array of n such times.
;
; KEYWORD INPUTS:
;	None
;
; OUTPUT:
;	a 3-element array of geographic [latitude,longitude,altitude], or an array [3,n] of n such coordinates	
;
; COMMON BLOCKS:
;	None
;
; RESTRICTIONS:
;       None
;
; EXAMPLE:
;	IDL> gcoord=eci2geographic([6378.137+600,0,0],'2002/03/09 21:21:21.021')
;	IDL> print,gcoord
;       0.0000000       232.27096       600.00000
;
;	(The above is also the geographic direction of the vernal point on 
;	2002/03/09 21:21:21.021, in geographic coordinates.)
;
;	gcoord can be further transformed into geodetic coordinates (using geo2geodetic.pro)
;	or into geomagnetic coordinates (using geo2mag.pro)
;
;       HESSI trajectory:
;               IDL> oso=hsi_obs_summary()
;               IDL> oso->set,obs_time_interval='2002/04/21 '+['00:30:00','01:30:00']
;               IDL> eph_times=oso->getdata(class_name='ephemeris',/time)
;               IDL> eph=oso->getdata(class_name='ephemeris')
;               IDL> gcoord=eci2geographic(eph(0:2,*),eph_times)
;               IDL> map_set,/cont,/mercator,/iso
;               IDL> oplot,gcoord(1,*),gcoord(0,*)
;
;
; MODIFICATION HISTORY:
;	Written by Pascal Saint-Hilaire (Saint-Hilaire@astro.phys.ethz.ch) on 2001/05/14
;		
;-

;=============================================================================================
FUNCTION eci2geographic,ECI_XYZ,tme
	MJDstc=anytim(tme,/mjd)
	JDtime=DOUBLE(MJDstc.mjd) + 2400000.5 + DOUBLE(MJDstc.time)/86400000
	RETURN,eci2geo(ECI_XYZ,JDtime)
END
;=============================================================================================
