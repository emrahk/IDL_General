;---------------------------------------------------------------------------
; Document name: lat2y.pro
; Created by:    Liyun Wang, GSFC/ARC, May 1, 1995
;
; Last Modified: Tue May  2 14:24:00 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION lat2y, x, lat, date=date, longi=longi
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       LAT2Y()
;
; PURPOSE:
;       Convert heliographic latitute to Y value in arcsec
;
; EXPLANATION:
;       Given the X position (in arcsec) of a point and optionally the
;       heliographic latitude of the point, this routine returns the Y
;       position (in arcsec) of the point, and optionally the heliographic
;       longitude of the point.
;
; CALLING SEQUENCE:
;       y = lat2y(x, lat, date=date)
;
; INPUTS:
;       X   - X value of the point in arcsec
;
; OPTIONAL INPUTS:
;       LAT - heliographic latitute of the point in degrees. If this parameter
;             is missing, zero degree latitude will be assumed.
;
; OUTPUTS:
;       Y   - Y value of the point in arcsec
;
; OPTIONAL OUTPUTS:
;       LONGI - Heliographic longitude of the concerned point (in degs)
;
; KEYWORD PARAMETERS:
;       DATE - Date/Time in CCSDS or ECS time format, based on which the
;              coversion is done. If missing, the current system time will be
;              used 
;
; CALLS:
;       PB0R, GET_UTC
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;
; PREVIOUS HISTORY:
;       Written May 1, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, May 1, 1995
;
; VERSION:
;       Version 1, May 1, 1995
;-
;
   ON_ERROR, 2
   IF N_PARAMS() LT 1 THEN MESSAGE, 'Syntax: lat2y, x [, lat]'
   
   IF N_ELEMENTS(date) EQ 0 THEN get_utc, date ELSE date = anytim2utc(date)
   IF N_ELEMENTS(lat) EQ 0 THEN lat = 0.0
   
;---------------------------------------------------------------------------
;  get B0 and solar radius
;---------------------------------------------------------------------------
   angles = pb0r(date)
   sunr = angles(2)*60.0
   b0 = angles(1)/!radeg
   
   colat = (90.0-lat)/!radeg
   sinphi = x/(sunr*SIN(colat))
   cosphi = SQRT(1.0-sinphi*sinphi)
   y = sunr*(COS(colat)*COS(b0)-SIN(colat)*cosphi*SIN(b0))
   longi = ATAN(sinphi,cosphi)*!radeg
   
   RETURN, y
END

;---------------------------------------------------------------------------
; End of 'lat2y.pro'.
;---------------------------------------------------------------------------
