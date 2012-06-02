PRO  dblstarcor,time,asini,porb,epoch,ecc,omega_d,pporb=pporb,limit=limit
;+
; NAME:         dblstarcor.pro
;
;
;
; PURPOSE:      Removes the influence of the doublestar motion for
;               circular or eliptical orbits.               
;
;
;
; CATEGORY:     timing tools
;
;
;
; CALLING SEQUENCE: 
;               dblstarcor,time,asini,prob,epoch,ecc,omega_d
;
; 
; INPUTS:
;       	time   : event time (MJD)
;	        asini  : Projected semi-major axis [lt-secs]  
;	        porb   : Orbital period [days]
;	        epoch  : Epoch for mean longitude of 90 degrees [MJD]  
;	        ecc    : Eccentricity
;	        omega_d: Longitude of periastron [degrees]
;
;
;
; OPTIONAL INPUTS:
;
;               pporb: the change of the orbit period without dimension 
;               limit: percentage of asini [s] to abort the Iteration 
;      
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;               Returns an array of same type, length, and units as the input 
;	        time array corrected for the orbital motiono of the
;	        neutron star
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:   
;               Version 1.0, 1997/01/09, Deepto Chakrabarty, Caltech/MIT
;               Version 1.1, 1999/11/11, Patrick Risse IAAT        
;                           - Include the optional Input of pporb
;                           - abort criteria for the iteration
; $Log: dblstarcor.pro,v $
; Revision 1.3  2002/09/09 14:58:27  wilms
; removed debugging statement; several cosmetic changes
;
;-


 asini_d = asini/86400.0D
 twopi = 2.0D*!pi
 t = time
 cor=asini

 ;;  set default value of pporb
 IF (n_elements(pporb) EQ 0) THEN pporb = 0.0 

 ;;  set default value of limit
 IF (n_elements(limit) EQ 0) THEN limit = 1E-4 

 ;; Compute time shifts due to orbit around center of mass
 IF (ecc GT  0.0) THEN BEGIN 	
        omega = omega_d * !pi/180.0D
        sinw = sin(omega)
        cosw = cos(omega)
	FOR  i=0,5 do begin
		m=twopi*((t-epoch)/porb-(0.5 *((pporb*((t-epoch)^2))/(porb)^2))) $
                    + !pi/2.0D - omega
		eanom = m
		for j=0, 4 do begin
		  eanom = eanom $
			- (eanom - ecc*sin(eanom) - m)/(1.0D -ecc*cos(eanom))
		ENDFOR 
		sin_e = sin(eanom)
		cos_e = cos(eanom)
		z = asini_d*(sinw*(cos_e-ecc)+sqrt(1.0D -ecc*ecc)*cosw*sin_e)
		dz = (twopi*asini_d/(porb*(1.0D -ecc*cos_e)))* $
			(sqrt(1.0D -ecc*ecc)*cosw*cos_e - sinw*sin_e)
		f = t + z - time
		df = 1.0D + dz
		t = t - f/df
	ENDFOR 
    ENDIF ELSE  BEGIN

   ;; Calculation of the time for a spherical Orbit --> ecc = 0.0

   ;; The calculation of the Phase*2PI=L is taken out of the diploma
   ;; thesis of Beate Stelzer 1999.
   ;; For most of the binary systems the  corrected time (t_cm) after one  
   ;; iteration is good enough. 
   ;; From the corrected time t_cm1 you will get a new phase and out of the
   ;; new phase you get a new time t_cm2.
   ;; This iteration will stop if the difference between two cycles is
   ;; lower than a given limit. 
   
    WHILE abs(max(cor)) GT limit DO BEGIN 
        L = (twopi*((t - epoch)/porb) - (0.5 *((pporb*((t - epoch)^2)) / (porb)^2)))+!pi/2.0D
        z = asini_d*sin(L)
        dz = twopi*asini_d*cos(L)/porb
        f = t + z - time
        df = 1.0D + dz
        cor= f/df
        t = t - cor
    ENDWHILE 
  ENDELSE 
  time=t
END 










