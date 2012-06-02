;==============================================================================
;   REMOVEORB.PRO
;   07-01-92
;   Deepto Chakrabarty, Caltech
;
;   Take an input time array and correct the values to place
;   them in a reference frame inertial wrt the pulsar. Uses
;   an exact elliptical orbit model, and inverts. 
;
;   ARGUMENTS:
;	time:	event time (TDB)
;	asini:	Projected semi-major axis [lt-secs]  
;	porb:	Orbital period [days]
;	t90:	Epoch for mean longitude of 90 degrees [MJD]  
;	ecc:	Eccentricity
;	omega_d:Longitude of periastron [degrees]
;
;   RETURNS an array of same type, length, and units as the input 
;	time array. 
;	
;
;   REVISIONS:
;   11-23-92 Deepto: Bug fixed for circular orbits.
;   09-01-97 Deepto: Bug fixed for ecc orbits: loop indexing error
;==============================================================================

function removeorb, time, asini, porb, t90, ecc, omega_d

; Compute time shifts due to orbit around center of mass
asini_d = asini/86400.0D
twopi = 2.0D*!pi
t = time
if (ecc gt 0.0) then begin	
        omega = omega_d * !pi/180.0D
        sinw = sin(omega)
        cosw = cos(omega)
	for i=0, 5 do begin
		m = twopi*(t - t90)/porb + !pi/2.0D - omega
		eanom = m
		for j=0, 4 do begin
		  eanom = eanom $
			- (eanom - ecc*sin(eanom) - m)/(1.0D -ecc*cos(eanom))
		endfor
		sin_e = sin(eanom)
		cos_e = cos(eanom)
		z = asini_d*(sinw*(cos_e-ecc)+sqrt(1.0D -ecc*ecc)*cosw*sin_e)
		dz = (twopi*asini_d/(porb*(1.0D -ecc*cos_e)))* $
			(sqrt(1.0D -ecc*ecc)*cosw*cos_e - sinw*sin_e)
		f = t + z - time
		df = 1.0D + dz
		t = temporary(t) - f/df
	endfor
endif else begin
	for i=0, 5 do begin
		L = twopi*(t - t90)/porb + !pi/2.0D
		z = asini_d*sin(L)
		dz = twopi*asini_d*cos(L)/porb
		f = t + z - time
		df = 1.0D + dz
		t = temporary(t) - f/df
	endfor
endelse
return, t
;return,(t - mjdref)*86400d/16d
end
