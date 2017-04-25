;---------------------------------------------------------------------------
; Document name: itool2map.pro
; Created by:    Liyun Wang, NASA/GSFC, September 8, 1997
;
; Last Modified: Thu Sep 18 17:57:55 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool2map, image, csi=csi, reverse=reverse, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL2MAP()
;
; PURPOSE:
;       Convert ITOOL data structure into MAP or vice versa
;
; CATEGORY:
;       Image Tool, Map
;
; SYNTAX:
;       RESULT = itool2map(image, csi=csi)
;       RESULT = itool2map(map, csi=csi, /reverse)
;
; INPUTS:
;       IMAGE  - 2D image array, or MAP structure (see MAKE_MAP).
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - A Map structure with tags DATA, XP, YP, TIME, DUR,
;                ID, and SOHO if keyword REVERSE is not set; otherwise
;                a 2D image array.
;                If an error occurs (ERROR is not null), RESULT will
;                be -1.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       CSI     - Coordinate system info structure (basic
;                 form). Required as an input parameter when
;                 converting from ITOOL to MAP; needed as an output
;                 parameter when converting from MAP to ITOOL. See
;                 itool_new_csi.pro for detailed definition of a CSI.
;
;       ERROR   - Named variable containing possible error message
;       REVERSE - Set this keyword to convert MAP structure into image
;                 array and CSI structure suitable for ITOOL
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
;       Version 1, September 8, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''
   IF NOT KEYWORD_SET(reverse) THEN BEGIN
      IF (SIZE(image))(0) NE 2 THEN BEGIN
         error = 'Input parameter must be 2D array.'
         MESSAGE, error, /cont
         RETURN, -1
      ENDIF
      IF datatype(csi) NE 'STC' THEN BEGIN
         error = 'CSI structure must be passed via the CSI keyword.'
         MESSAGE, error, /cont
         RETURN, -1
      ENDIF
      a = grep(csi.origin, ['scds', 'seit', 'ssum', 'suvc', 'slas', 'smdi'], $
               /exact)
      soho = (a(0) NE '')

      temp = cnvt_coord(1, 1, from=2, to=3, csi=csi)
      x0 = temp(0, 0)-0.5*csi.cdelt1
      y0 = temp(0, 1)-0.5*csi.cdelt2

      temp = cnvt_coord(csi.naxis1, csi.naxis2, from=2, to=3, csi=csi)
      x1 = temp(0, 0)+0.5*csi.cdelt1
      y1 = temp(0, 1)+0.5*csi.cdelt2

      xcen = 0.5*(x0+x1)
      ycen = 0.5*(y0+y1)
      RETURN, make_map(image, xc=xcen, yc=ycen, dx=csi.cdelt1, dy=csi.cdelt2, $
                       time=csi.date_obs, id=csi.origin, soho=soho)
   ENDIF ELSE BEGIN
      IF datatype(image) NE 'STC' THEN BEGIN
         error = 'Input parameter must be MAP structure.'
         MESSAGE, error, /cont
         RETURN, -1
      ENDIF
      csi = itool_new_csi(/basic)
      sz = SIZE(image.data)
      CASE (sz(3)) OF
         1: csi.bitpix = 8
         2: csi.bitpix = 16
         3: csi.bitpix = 32
         4: csi.bitpix = -32
         5: csi.bitpix = -64
         ELSE: BEGIN
            csi.bitpix = 8
            image.data = BYTSCL(image.data)
         END
      ENDCASE
      xp=get_map_prop(image,/xp)
      yp=get_map_prop(image,/yp)
      csi.naxis1 = sz(1)
      csi.naxis2 = sz(2)
      csi.crpix1 = 1
      csi.crpix2 = 1
      csi.crval1 = xp(0, 0)
      csi.crval2 = yp(0, 0)
      csi.cdelt1 = (MAX(xp)-MIN(xp))/csi.naxis1
      csi.cdelt2 = (MAX(yp)-MIN(yp))/csi.naxis2
      csi.flag = 1
      csi.date_obs = anytim2utc(image.time, /ecs, /trunc)
      csi.origin = image.id
      RETURN, image.data
   ENDELSE
END

;---------------------------------------------------------------------------
; End of 'itool2map.pro'.
;---------------------------------------------------------------------------
