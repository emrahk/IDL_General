;+
;
; NAME:
;	SOLEPHUT
;
; PURPOSE:
;       Calculate the solar ra and dec in degrees given the
;	time in one of our canonical formats.
;
; CATEGORY:
;       GEN
;
; CALLING SEQUENCE:
;       Result = SOLEPHUT(Time)  
;
; CALLS:
;       SUNPOS, ANYTIM 
;
; INPUTS:
;       Time:	A scalar or vector in format anytim format
;
; OUTPUTS:
;       Result:	Right ascension and declination of the Sun in degrees
;	 	returned in an array 2xn where n is the number of elements
;		in the input TIME.  For the equinox of Time	
;
; MODIFICATION HISTORY:
;	RAS. Transposed from a formula in the astronomical almanac.
;	Revised 11/25/92.
;	Mod. 03/29/96 by RAS. Uses SUNPOS from Astro library now.  
;	Mod. 05/08/96 by RCJ. Added documentation.
;	Mod. 18-sep-1996 RAS put in test for new version of sunpos
;	works with either the old or new output units for sunpos 
;-
;*******************************************************************************
function solephut,time ; solar ephemeris 
	
;  
;  Test for version of SUNPOS, output in radians (old version) or degress
;
	jdtest = 2443874.5d   	;julian day on 1 jan 1979 00:00:00 Zulu
	alpha_test = 4.9015982     ;answer in radians
	sunpos, jdtest, alpha, decl
	radeg = ([1.0, !radeg])(alpha-alpha_test lt 1.0) 

	ut = anytim( time, /sec)
	jd = anytim( time,/sec)/ 86400.d0 + jdtest
	sunpos, jd, alpha, decl

	ans = temporary(transpose([[alpha],[decl]])) ; ans is 2xn
return, ans * radeg
end
