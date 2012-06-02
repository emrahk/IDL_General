FUNCTION CCD_HCORR, date, ra, dec
;+
; NAME:
;	CCD_HCORR (modified HELIO_JD)
;
; PURPOSE:
;	Calculate heliocentric correction from geocentric (reduced)
;	Julian date (i.e. correct for extra light travel time between
;	Earth and Sun).
;
; CATEGORY:
;	Astronomy.
;
; CALLING SEQUENCE:
;	helioc = CCD_HCORR( date, ra, dec )
;
; INPUTS
;	DATE   : Reduced Julian date (= JD - 2 400 000), scalar or vector,
;	         MUST be double precision.
;	RA,DEC : Scalars giving right ascension and declination in DEGREES.
;
; OUTPUTS:
;	HELIOC : Heliocentric correction HJD = GeocenJD + helioc.
;
; PROCEDURES CALLED:
;	ZPARCHECK, xyz
;
; REVISION HISTORY:
; 	Algorithm from the book Astronomical Photometry by Henden, p. 114
;	Written,   W. Landsman       STX     June, 1989 
;	Algorithm checked and constants refined R.D.Geckeler, Nov., 1996.
;	- sign is OK.
;-

On_error,2

If N_params() LT 3 then begin
   message,'Syntax -   helioc = HELIO_JD( date, ra, dec)',/inf
   message,'NOTE - Ra and Dec must be in degrees',/inf
endif
    
zparcheck,'HELIO_JD',date,1,[3,4,5],[0,1],'Reduced Julian Date'

epsilon = 23.43929111d0/!RADEG     ;Obliquity of the ecliptic
ra_rad = ra/!RADEG
dec_rad = dec/!RADEG

xyz, date, x, y, z

RETURN, -0.0057755d0*(cos(dec_rad)*cos(ra_rad)*x+ $
       (tan(epsilon)*sin(dec_rad)+cos(dec_rad)*sin(ra_rad))*y)
END
