;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: limb_info.pro
; Created by:    Liyun Wang, NASA/GSFC, October 7, 1994
;
; Last Modified:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO LIMB_INFO, image, date_obs, x0, y0, scale, r0
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       LIMB_INFO
;
; PURPOSE:
;       Get position of solar disk center and radius from an image.
;
; EXPLANATION:
;       This routine calls FIND_LIMB2 (a modified version of FIND_LIMB
;       from the Yohkoh IDL library) to determine the coordinates of
;       the solar disk center (in data pixels) and the solar radius
;       (also in data pixels). It shares the same restriction imposed
;       by FIND_LIMB.
;
; CALLING SEQUENCE:
;       LIMB_INFO, image, date_obs, x0, y0, scale
;
; INPUTS:
;       IMAGE    -- A 2D image array that contains the full disk image of
;                   the sun.
;       DATE_OBS -- String scalar, date/time in any CDS format
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       X0    -- X position of the solar center in data pixels
;       Y0    -- Y position of the solar center in data pixels
;       SCALE -- scale factor of the image in arc seconds per pixel
;       R0    -- Radius of the solar disk in data pixels
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       FIND_LIMB2, PB0R
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       See find_limb.pro
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;
; PREVIOUS HISTORY:
;       Written October 7, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;
; VERSION:
;       Version 1, October 7, 1994
;-
;
   ON_ERROR, 2
   !err = 0
   IF N_PARAMS() LT 2 THEN BEGIN
      PRINT, 'LIMB_INFO -- Syntax error.'
      PRINT, '   Usage: LIMB_INFO, image, date_obs, x0, y0, scale'
      PRINT, ' '
      !err = -1
      RETURN
   ENDIF

   s = SIZE(image)
   IF s(0) NE 2 THEN BEGIN
      PRINT,'Input image array must be two-dimensional.'
      !err = -1
      RETURN
   ENDIF

   find_limb2, image, x0, y0, r0, r_err, oblateness, ob_angle, bias, $
      brightness, sig_bright
   IF !err EQ -1 THEN RETURN    ; find_limb failed

   angles = pb0r(date_obs)
   sradius = 60.*angles(2)      ; in arcseconds
   scale = sradius/r0

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'limb_info.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
