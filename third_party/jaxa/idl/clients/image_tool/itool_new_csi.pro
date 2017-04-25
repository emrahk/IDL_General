;---------------------------------------------------------------------------
; Document name: itool_new_csi.pro
; Created by:    Liyun Wang, NASA/GSFC, June 2, 1995
;
; Last Modified: Thu Sep 11 15:38:24 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool_new_csi, basic=basic
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:	
;       ITOOL_NEW_CSI()
;
; PURPOSE:
;       Create a new CSI (coordinate system info) structure
;
; CALLING SEQUENCE: 
;       csi = itool_new_csi()
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       CSI -- Coordinate system information structure that contains some
;              basic information of the coordinate systems involved. It should
;              have the following tags:
;
;              DAXIS1   - X size of the displayed image in device pixels
;              DAXIS2   - Y size of the displayed image in device pixels
;              DRPIX1   - Location of the first image pixel along X axis, in
;                         units of device pixels (0 based)
;              DRPIX2   - Location of the first image pixel along Y axis, in
;                         units of device pixels (0 based)
;              DDELT1   - The rate of change for the image pixels along
;                         axis X per unit change in device pixels,
;                         evaluated at the reference point DRPIX1 
;                         (ratio of NAXIS1/DAXIS1)
;              DDELT2   - The rate of change for the image pixels along
;                         axis Y per unit change in device pixels,
;                         evaluated at the reference point DRPIX2 
;                         (ratio of NAXIS2/DAXIS2)
;              BITPIX   - Standard FITS keyword for data type   
;              NAXIS1   - The image size in X direction in image pixels
;              NAXIS2   - The image size in Y direction in image pixels
;              ORIGIN   - Origin of image, in standard 4-char code
;              IMAGTYPE - Type of image, in standard 5-char code
;              CRPIX1   - Location of reference pixel along X axis, in
;                         units of the counting index (image pixel, 1 based)
;              CRPIX2   - Location of reference pixel along Y axis, in
;                         units of the counting index (image pixel, 1 based)
;              CRVAL1   - Value of the physical coordinate given by
;                         CTYPE1 (usually arcsec) on X axis at the
;                         reference point
;              CRVAL2   - Value of the physical coordinate given by
;                         CTYPE2 (usually arcsec) on Y axis at the
;                         reference point
;              CDELT1   - The rate of change for the physical
;                         coordinate along axis X per unit change in
;                         the counting index, evaluated at the
;                         reference point (usually: arcsec/pixel)
;              CDELT2   - The rate of change for the physical
;                         coordinate along axis Y per unit change in
;                         the counting index, evaluated at the
;                         reference point (usually: arcsec/pixel)
;              CTYPE1   - Name of the physical coordinate for axis X
;                         (string), default to 'Solar X'
;              CTYPE2   - Name of the physical coordinate for axis Y
;                         (string), default to 'Solar Y'
;              CROTA    - Rotation angle, in degrees, of CCW from
;                         solar north polar direction (+solar_y)
;              REFLECT  - True (1) if image is flipped upside down
;                         (south pole up); else False (0)   
;              DATE_OBS - Date/time of date acquisition, in ECS UTC
;                         format (default to current date/time)
;              FLAG     - indicator with value 0 or 1 showing if the solar
;                         coodinate system is established. 1 is yes.
;              RADIUS   - Solar disc radius in arcsecs, initialized to 960.0
;   
;       Note 1: DAXIS1, DAXIS2, DRPIX1, DRPIX2, DDELT1, and DDELT2 are
;               device dependent and also depend on display of image 
;   
;       Note 2: By FITS standards, CRPIXn is in the range of (1, NAXISn), 
;               not (0, NAXISn-1). This is why DRVALn is always set to 1.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       BASIC - Set this keyword to return the basic CSI structure
;               (without device dependent tags)
;
; CALLS:
;       None.
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
;       Image_tool, utility
;
; HISTORY:
;       Version 1, June 2, 1995, Liyun Wang, NASA/GSFC. Written
;       Version 2, April 1, 1996, Liyun Wang, NASA/GSFC
;          Added RADIUS tag in output structure
;       Version 3, August 12, 1997, Liyun Wang, NASA/GSFC
;          Changed CSI tag names to conform with the FITS standards
;          Added BASIC keyword
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   get_utc, date_obs, /ecs
   IF KEYWORD_SET(basic) THEN BEGIN
      csi = {bitpix:0, naxis1:0, naxis2:0, origin:'', imagtype:'', $
             crpix1:1.0, crpix2:1.0, crval1:0.0, crval2:0.0, $
             cdelt1:0.0, cdelt2:0.0, ctype1:'Solar X', ctype2:'Solar Y', $
             crota:0.0, reflect:0, date_obs:date_obs, flag:0, radius:960.0}
   ENDIF ELSE BEGIN
      csi = {csi, daxis1:0, daxis2:0, $
             drpix1:0, drpix2:0, ddelt1:0.0, ddelt2:0.0, $
             bitpix:0, naxis1:0, naxis2:0, origin:'', imagtype:'', $
             crpix1:1.0, crpix2:1.0, crval1:0.0, crval2:0.0, $
             cdelt1:0.0, cdelt2:0.0, ctype1:'Solar X', ctype2:'Solar Y', $
             crota:0.0, reflect:0, date_obs:date_obs, flag:0, radius:960.0}
   ENDELSE
   RETURN, csi
END

;---------------------------------------------------------------------------
; End of 'itool_new_csi.pro'.
;---------------------------------------------------------------------------
