;---------------------------------------------------------------------------
; Document name: itool_set_csi.pro
; Created by:    Liyun Wang, NASA/GSFC, September 27, 1994
;
; Last Modified: Fri Oct  3 14:19:43 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool_set_csi, header, quiet=quiet, err=err, file=file
;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_SET_CSI()
;
; PURPOSE:
;       Obtain iamge scale and disk center coord. from the given FITS header
;
; EXPLANATION:
;       This routine searches for some possible keywords through the given
;       FITS header, trying to obtain three sets of important parameters,
;       CRPIX*, CRVAL*, and CDELT*, which are required when calculating the
;       coordinates of any point on the solar image. Searching is done
;       according to the order of keywords. The most probable keyword
;       are searched first. Currently the following keywords are searched:
;
;          CRPIX*, CRVAL*, CDELT*, CRRADIUS, R0, SCALE, DXB_IMG, X0, Y0,
;          CENTER_X, CENTER_Y, RADIUS, SOLAR_R
;
; CALLING SEQUENCE:
;       ims_csi = ITOOL_SET_CSI(header)
;
; INPUTS:
;       HEADER -- String array, header of a FITS file
;
; OPTIONAL INPUTS:
;
; OUTPUTS:
;       IMG_CSI - Basic CSI structure, containing the following tags:
;                 NAXIS1, NAXIS2, CRPIX1, CRPIX2, CRVAL1, CRVAL2,
;                 CDELT1, CDELT2, CTYPE1, CTYPE2, CROTA, REFLECT,
;                 DATE_OBS, FLAG, and RADIUS
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       ERR   - A named string variable containing error message. Null
;               string is returned if there is no error
;       QUIET - Set this keyword to suppress error messages to the screen
;       FILE  - Name of FITS file; can be useful to determine imaging
;               time if passed in
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
;       Version 1, September 27, 1994, Liyun Wang, NASA/GSFC. Written
;       Version 2, April 1, 1996, Liyun Wang, NASA/GSFC
;          Added RADIUS tag in output structure
;       Version 3, July 30, 1996, Liyun Wang, NASA/GSFC
;          Added searching for keyword SOLAR_R for solar radius in pixels
;       Version 4, August 28, 1996, Liyun Wang, NASA/GSFC
;          Modified such that the first image pixel starts at (1, 1)
;             as in FITS specification 
;          Renamed it from SET_CSI to ITOOL_SET_CSI
;       Version 5, August 28, 1997, Liyun Wang, NASA/GSFC
;          Added FILE keyword to be used by ITOOL_GET_TIME
;       Version 6, September 2, 1997, Liyun Wang, NASA/GSFC
;          Added search for CENTER_X and CENTER_Y keywords when CRPIX*
;             are not present in FITS header
;       Version 7, 10-Jul-2003, William Thompson, GSFC
;               Look for CROTA2 as well, to be more standards compliant
;
; VERSION:
;       Version 7, 10-Jul-2003
;-
;
   ON_ERROR, 2
   err = ''
   IF N_ELEMENTS(file) EQ 0 THEN file = ''
   flag = 1
   img_csi = itool_new_csi(/basic)

   IF N_PARAMS() NE 1 THEN BEGIN
      err = 'Syntax: img-csi = ITOOL_SET_CSI(header)'
      flag = 0
      IF NOT KEYWORD_SET(quiet) THEN MESSAGE, err, /cont
      RETURN, img_csi
   ENDIF
   IF datatype(header) NE 'STR' THEN BEGIN
      err = 'Input parameter has to be of string type.'
      flag = 0
      IF NOT KEYWORD_SET(quiet) THEN MESSAGE, err, /cont
      RETURN, img_csi
   ENDIF

   
   temp = anytim2utc(itool_get_time(header, file=file), $
                                 /ecs, /trunc)

   img_csi.date_obs=y2kfix(temp)   ; Y2K fix

   img_csi.origin = itool_get_src(header, file=file)
   img_csi.imagtype = itool_get_type(header, file=file)
   
   img_csi.bitpix = fxpar(header, 'BITPIX')

   img_csi.naxis1 = fxpar(header, 'NAXIS1')
   img_csi.naxis2 = fxpar(header, 'NAXIS2')

   radius = 60.*(pb0r(img_csi.date_obs))(2)
   img_csi.radius = radius

;---------------------------------------------------------------------------
;  Determine CRPIX*
;---------------------------------------------------------------------------
   crpix = fxpar(header,'CRPIX*')
   IF !err EQ -1 THEN BEGIN
      crpix = FLTARR(2)
      crpix(0) = fxpar(header,'X0')
      crpix(1) = fxpar(header,'Y0')
      IF !err EQ -1 THEN BEGIN
         crpix(0) = fxpar(header,'CENTER_X')
         crpix(1) = fxpar(header,'CENTER_Y')
         IF !err EQ -1 THEN BEGIN
            err = 'No reference point is given in FITS header.'
            flag = 0
            IF NOT KEYWORD_SET(quiet) THEN MESSAGE, err, /cont
         ENDIF
      ENDIF
   ENDIF
   img_csi.crpix1 = crpix(0)
   img_csi.crpix2 = crpix(1)

;---------------------------------------------------------------------------
;  Determine CRVAL* (value of the reference point)
;---------------------------------------------------------------------------
   crval = fxpar(header,'CRVAL*')
   IF !err EQ -1 THEN BEGIN
      crval = FLTARR(2)
   ENDIF
   img_csi.crval1 = crval(0)
   img_csi.crval2 = crval(1)

;---------------------------------------------------------------------------
;  Determine CDELT*
;---------------------------------------------------------------------------
   cdelt = fxpar(header, 'CDELT*')
   IF !err EQ -1 THEN BEGIN
      crradius = fxkvalue(header, ['CRRADIUS', 'R0', 'RADIUS', 'R_SUN', $
                                   'SOLAR_R'])
      IF !err NE -1 THEN BEGIN
         cdelt = FLTARR(2)
         cdelt(0) = radius/crradius
         cdelt(1) = cdelt(0)
      ENDIF ELSE BEGIN
;----------------------------------------------------------------------
;     Try to see if SCALE or DXB_IMG keyword is present
;----------------------------------------------------------------------
         cdelt = fxkvalue(header, ['SCALE', 'DXB_IMG'])
         IF !err EQ -1 THEN BEGIN
;----------------------------------------------------------------------
;           Well, we have exhausted all means to get the scale, but still
;           with no luck. So we issue a warning and set SCALE to be 0.0.
;----------------------------------------------------------------------
            err = 'Cannot figure out scaling factor. Set CDELT*=0.0.'
            flag = 0
            IF NOT KEYWORD_SET(quiet) THEN MESSAGE, err, /cont
            cdelt = FLTARR(2)
         ENDIF ELSE BEGIN
            IF N_ELEMENTS(cdelt) EQ 1 THEN cdelt = REPLICATE(cdelt, 2)
         ENDELSE 
      ENDELSE
   ENDIF
   img_csi.cdelt1 = cdelt(0)
   img_csi.cdelt2 = cdelt(1)
   img_csi.flag = flag

;---------------------------------------------------------------------------
;  Determine CROTA
;---------------------------------------------------------------------------
   img_csi.crota = FLOAT(fxkvalue(header, ['CROTA1','CROTA2','CROTA','CROT','SC_ROLL']))

;---------------------------------------------------------------------------
;  Determine CTYPE*
;---------------------------------------------------------------------------
   ctype = fxpar(header, 'CTYPE1')
   IF !err NE -1 THEN img_csi.ctype1 = STRTRIM(ctype, 2)
   ctype = fxpar(header, 'CTYPE2')
   IF !err NE -1 THEN img_csi.ctype2 = STRTRIM(ctype, 2)
   pattern = ['N-S', 'North-South', 'N-S ARCS']
   IF (grep(img_csi.ctype2, pattern, /exact))(0) NE '' THEN img_csi.reflect = 1

   RETURN, img_csi
END

;---------------------------------------------------------------------------
; End of 'itool_set_csi.pro'.
;---------------------------------------------------------------------------
