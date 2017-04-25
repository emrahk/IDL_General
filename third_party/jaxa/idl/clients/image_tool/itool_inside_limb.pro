;---------------------------------------------------------------------------
; Document name: itool_inside_limb.pro
; Created by:    Liyun Wang, NASA/GSFC, April 3, 1996
;
; Last Modified: Wed Sep 17 14:37:31 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool_inside_limb, ppx, ppy, csi=csi, error=error, index=index
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_INSIDE_LIMB()
;
; PURPOSE:
;       Detect if points defined by ppx and ppy are within the limb
;
; CATEGORY:
;       Utility, Image Tool
;
; SYNTAX:
;       result = itool_inside_limb(ppx, ppy, csi=csi)
;
; INPUTS:
;       PPX - X position of points in data pixels
;       PPY - Y position of points in data pixels
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - 1 if all points are within the limb, otherwise 0. For
;                syntax errors, a -1 is returned
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       CSI   - Coordinate system info structure; required
;       INDEX - Indices of points remaining inside the limb 
;       ERROR - Error message; a null string if no error occurs
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
;       Version 1, April 3, 1996, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''
   npt = N_ELEMENTS(ppx)
   IF N_ELEMENTS(ppy) NE npt THEN BEGIN
      error = 'Two input parameters must have the same dimension!'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

   IF datatype(csi) NE 'STC' THEN BEGIN
      error = 'Keyword CSI must be a CSI structure.'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

;---------------------------------------------------------------------------
;  Get solar disc center position in image pixels
;---------------------------------------------------------------------------
   x0 = ROUND(csi.crpix1-csi.crval1/csi.cdelt1)
   y0 = ROUND(csi.crpix2-csi.crval2/csi.cdelt2)

;---------------------------------------------------------------------------
;  Get solar disc radius in image pixels
;---------------------------------------------------------------------------
   r0 = 2.0*csi.radius/(csi.cdelt1+csi.cdelt2)

;---------------------------------------------------------------------------
;  Get indices of points which are inside the limb
;---------------------------------------------------------------------------
   dist = SQRT((ppx-x0)^2+(ppy-y0)^2)
   index = WHERE(dist LE r0, cnt)

   IF cnt EQ npt THEN RETURN, 1 ELSE RETURN, 0

END

;---------------------------------------------------------------------------
; End of 'itool_inside_limb.pro'.
;---------------------------------------------------------------------------
