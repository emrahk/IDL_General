;---------------------------------------------------------------------------
; Document name: itool_img_match.pro
; Created by:    Liyun Wang, NASA/GSFC, September 2, 1997
;
; Last Modified: Fri Sep 26 11:44:39 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_img_match, image_2nd, csi_2nd, csi=csi, image=image, extend=extend, $
         noremap=noremap, xrange=xrange, yrange=yrange, device=device, $
         error=error
;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_IMG_MATCH()
;
; PURPOSE:
;       Make the given image array match the base image
;
; CATEGORY:
;       Image Tool
;
; SYNTAX:
;       itool_img_match, image_2nd, csi_2nd, csi=csi
;
; INPUTS:
;      IMAGE_2ND - 2D image array to be modified
;      CSI_2ND   - CSI structure for IMAGE_2ND
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;      IMAGE_2ND - Modified image array that matches the base image
;      CSI_2ND   - Modified CSI structure for IMAGE_2ND
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       CSI    - CSI structure of the base image; required
;       IMAGE  - 2d data array of the base image; required only if the
;                DEVICE keyword is set
;       DEVICE - Set this keyword to adjust both base and secondary
;                images to device resolution (useful for interlacing)
;       EXTEND - Set this keyword to extend (or shrink) IMAGE_2ND to
;                make the same size as the base image
;       XRANGE - X position range of secondary image on based image
;       YRANGE - Y position range of secondary image on based image
;       ERROR  - Error message
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       IMAGE_2ND must be differentially rotated to match the imaging
;       time of the base image (via ITOOL_DIFF_ROT)
;
; SIDE EFFECTS:
;       Input IMAGE_2ND and CSI_2ND are modified; if DEVICE keyword
;       is set, base IMAGE and CSI can be modified
;
; HISTORY:
;       Version 1, September 2, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 1
   error = ''
   IF KEYWORD_SET(device) THEN BEGIN
      IF N_ELEMENTS(image) EQ 0 THEN BEGIN
         error = 'Base image array required.'
         MESSAGE, error, /cont
         RETURN
      ENDIF
      IF csi.ddelt1*csi.ddelt2 NE 1.0 THEN BEGIN
;---------------------------------------------------------------------------
;        Resize the base image
;---------------------------------------------------------------------------
         image = congrid(TEMPORARY(image), csi.daxis1, csi.daxis2)
         cval = cnvt_coord(csi.drpix1, csi.drpix2, from=1, to=3, csi=csi)
         
         csi.ddelt1 = 1.0
         csi.ddelt2 = 1.0

         csi.cdelt1 = csi.cdelt1*FLOAT(csi.naxis1)/FLOAT(csi.daxis1)
         csi.cdelt2 = csi.cdelt2*FLOAT(csi.naxis2)/FLOAT(csi.daxis2)

         csi.crpix1 = 1.0
         csi.crpix2 = 1.0
         csi.crval1 = cval(0, 0)
         csi.crval2 = cval(0, 1)
         csi.naxis1 = csi.daxis1
         csi.naxis2 = csi.daxis2
      ENDIF
   ENDIF

;---------------------------------------------------------------------------
;  reset the image size such that the scaling factor is the same
;  as the base image
;---------------------------------------------------------------------------
   IF (csi_2nd.cdelt1 NE csi.cdelt1) OR $
      (csi_2nd.cdelt2 NE csi.cdelt2) THEN BEGIN
      m = ROUND((csi_2nd.cdelt1*csi_2nd.naxis1)/csi.cdelt1)
      n = ROUND((csi_2nd.cdelt2*csi_2nd.naxis2)/csi.cdelt2)
      csi_2nd.crpix1 = $
         ROUND((csi_2nd.cdelt1*csi_2nd.crpix1)/csi.cdelt1)
      csi_2nd.crpix2 = $
         ROUND((csi_2nd.cdelt2*csi_2nd.crpix2)/csi.cdelt2)
      csi_2nd.cdelt1 = csi.cdelt1
      csi_2nd.cdelt2 = csi.cdelt2
      csi_2nd.naxis1 = m
      csi_2nd.naxis2 = n
      IF NOT KEYWORD_SET(noremap) THEN $
         image_2nd = congrid(TEMPORARY(image_2nd), m, n)
   ENDIF ELSE $
      image_2nd = congrid(TEMPORARY(image_2nd), csi_2nd.naxis1, csi_2nd.naxis2)

;---------------------------------------------------------------------------
;  Get position of secondary image on base image
;---------------------------------------------------------------------------
   low = cnvt_coord(1, 1, csi=csi_2nd, from=2, to=3)
   low = cnvt_coord(low, csi=csi, from=3, to=2)-1
   high = cnvt_coord(csi_2nd.naxis1, csi_2nd.naxis2, csi=csi_2nd, $
                     from=2, to=3)
   high = cnvt_coord(high, csi=csi, from=3, to=2)-1
   xll = low(0, 0) > 0
   xur = high(0, 0) < (csi.naxis1-1)
   yll = low(0, 1) > 0
   yur = high(0, 1) < (csi.naxis2-1)
   xrange = [xll, xur]
   yrange = [yll, yur]
   IF (xll GT xur) OR (yll GT yur) THEN BEGIN
      error = 'The secondary image in no way matches the base image.'
      MESSAGE, error, /cont
      RETURN
   ENDIF

   dx = -low(0, 0)
   dy = -low(0, 1)

;---------------------------------------------------------------------------
;  In case the secondary image is larger than the base image, cut its
;  lower-left corner to match the base image
;---------------------------------------------------------------------------
   IF dx GT 0 THEN image_2nd = image_2nd(dx:*, *)
   IF dy GT 0 THEN image_2nd = image_2nd(*, dy:*)
   sz2 = SIZE(image_2nd)
   IF csi_2nd.naxis1 NE sz2(1) OR csi_2nd.naxis2 NE sz2(2) THEN BEGIN
      csi_2nd.naxis1 = sz2(1)
      csi_2nd.naxis2 = sz2(2)
      low_bs = cnvt_coord(xll, yll, csi=csi, from=2, to=3)
      csi_2nd.crpix1 = 1.0
      csi_2nd.crpix2 = 1.0
      csi_2nd.crval1 = low_bs(0, 0)
      csi_2nd.crval2 = low_bs(0, 1)
   ENDIF

   IF NOT KEYWORD_SET(extend) THEN RETURN

;---------------------------------------------------------------------------
;  Extend IMAGE_2ND to make the same size as the base image
;---------------------------------------------------------------------------
   IF dx LT 0 THEN image_2nd = extend_matrix(TEMPORARY(image_2nd), -dx, /xprep)
   IF dy LT 0 THEN image_2nd = extend_matrix(TEMPORARY(image_2nd), -dy, /yprep)

   sz2 = SIZE(image_2nd)
   dx = sz2(1)-csi.naxis1
   dy = sz2(2)-csi.naxis2
   IF dx NE 0 THEN BEGIN
      IF dx GT 0 THEN image_2nd = image_2nd(0:csi.naxis1-1, *) ELSE $
         image_2nd=extend_matrix(TEMPORARY(image_2nd), -dx, /xappd)
   ENDIF
   IF dy NE 0 THEN BEGIN
      IF dy GT 0 THEN image_2nd = image_2nd(*, 0:csi.naxis2-1) ELSE $
         image_2nd=extend_matrix(TEMPORARY(image_2nd), -dy, /yappd)
   ENDIF
   csi_2nd = csi
END

;---------------------------------------------------------------------------
; End of 'itool_img_match.pro'.
;---------------------------------------------------------------------------
