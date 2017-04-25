;---------------------------------------------------------------------------
; Document name: itool_diff_rot.pro
; Created by:    Liyun Wang, NASA/GSFC, September 3, 1997
;
; Last Modified: Thu Sep 25 14:06:22 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool_diff_rot, image, csi, new_csi=new_csi, newtime=newtime, $
              missing=missing, error=error, noremap=noremap
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_DIFF_ROT()
;
; PURPOSE:
;       Coalign and differentially rotate a solar image to a new time
;
; CATEGORY:
;       Image Tool
;
; EXPLANATION:
;
; SYNTAX:
;       Result = itool_diff_rot(image, csi)
;
; INPUTS:
;       IMAGE - 2D array containing the original solar image
;       CSI   - Coordinate system info structure of the IMAGE (made
;               via ITOOL_SET_CSI); modified upon success
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - 2D array containing rotated solar image
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       NEWTIME - Target time to which the image is rotated. If not
;                 passed, current system time is assumed.
;       NEW_CSI - Modified CSI structure for RESULT
;       MISSING - data value to set for bad pixels (or off-limb points)
;       ERROR   - Named variable containing possible error message
;       NOREMAP - Set this keyword to just return rotated CSI without
;                 remapping    
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 3, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''
   IF N_ELEMENTS(image) EQ 0 THEN BEGIN
      error = 'Syntax: result = itool_diff_rot(image, csi)'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF ELSE BEGIN
      sz = SIZE(image)
      IF sz(0) NE 2 THEN BEGIN
         error = 'IMAGE must be a 2D array!'
         MESSAGE, error, /cont
         RETURN, -1
      ENDIF
   ENDELSE

   IF datatype(csi) NE 'STC' THEN BEGIN
      error = 'CSI structure must be passed in.'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

   IF N_ELEMENTS(newtime) EQ 0 THEN BEGIN
      get_utc, newtime
   ENDIF ELSE newtime = anytim2utc(newtime, err=error)
   IF error NE '' THEN BEGIN
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

   tend = utc2tai(newtime)
   IF N_ELEMENTS(missing) EQ 0 THEN missing = 0
   new_csi = csi

;---------------------------------------------------------------------------
;  If time interval is less than 10 seconds, no need to rotate
;---------------------------------------------------------------------------
   tstep = tend-anytim2tai(csi.date_obs)
   IF ABS(tstep) LE 10.0 THEN RETURN, image
   
;---------------------------------------------------------------------------
;  Get solar X and Y for all image pixels
;---------------------------------------------------------------------------
   itool_xy, csi, xx=xx, yy=yy
   
   xx = REFORM(xx, LONG(csi.naxis1)*LONG(csi.naxis2))
   yy = REFORM(yy, LONG(csi.naxis1)*LONG(csi.naxis2))

;---------------------------------------------------------------------------
;  Differentially rotate those points
;---------------------------------------------------------------------------
   out = rot_xy(xx, yy, tstep, date=tend, offlimb=offlimb, $
                index=index, error=error)
   
   IF error NE '' THEN BEGIN
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

   IF index(0) LT 0 THEN BEGIN
      error = 'All points would be rotated off the limb and invisible!'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

;---------------------------------------------------------------------------
;  There are still points remain visible
;---------------------------------------------------------------------------
   out = out(index, *)
   itool_grid_xy, out(*, 0), out(*, 1), fx, fy, space=[csi.cdelt1, csi.cdelt2]

;---------------------------------------------------------------------------
;  Size of output array may have changed
;---------------------------------------------------------------------------
   sz = SIZE(fx)
   new_csi.naxis1 = sz(1)
   new_csi.naxis2 = sz(2)
   
   fx = REFORM(fx, LONG(new_csi.naxis1)*LONG(new_csi.naxis2))
   fy = REFORM(fy, LONG(new_csi.naxis1)*LONG(new_csi.naxis2))
   
;---------------------------------------------------------------------------
;  Change reference point to the first image pixel
;---------------------------------------------------------------------------
   new_csi.crpix1 = 1
   new_csi.crpix2 = 1
   new_csi.crval1 = fx(0)
   new_csi.crval2 = fy(0)
   new_csi.date_obs = anytim2utc(newtime, /ecs, /trunc)

   IF KEYWORD_SET(noremap) THEN RETURN, image
   
;---------------------------------------------------------------------------
;  Set those points to be rotated off the limb to value MISSING
;---------------------------------------------------------------------------
;  off_limb = where(out(*, 0) lt -9995., ocount)
;  IF ocount GT 0 THEN image(off_limb) = missing

;---------------------------------------------------------------------------
;  Rotate fx, fy back to get ox, and oy
;---------------------------------------------------------------------------
   out = rot_xy(fx, fy, -tstep, date=tend, offlimb=offlimb, $
                index=index, error=error)
   ox = REFORM(out(*, 0), new_csi.naxis1, new_csi.naxis2)
   oy = REFORM(out(*, 1), new_csi.naxis1, new_csi.naxis2)

;---------------------------------------------------------------------------
;  Call INTER2D to get interpolated data from original image array
;---------------------------------------------------------------------------
   xx = REFORM(TEMPORARY(xx), csi.naxis1, csi.naxis2)
   yy = REFORM(TEMPORARY(yy), csi.naxis1, csi.naxis2)
   image = interp2d(TEMPORARY(image), xx, yy, ox, oy, missing=missing)
   RETURN, image
END

;---------------------------------------------------------------------------
; End of 'itool_diff_rot.pro'.
;---------------------------------------------------------------------------
