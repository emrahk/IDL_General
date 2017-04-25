;---------------------------------------------------------------------------
; Document name: itool_composite.pro
; Created by:    Liyun Wang, NASA/GSFC, September 12, 1997
;
;---------------------------------------------------------------------------
;
FUNCTION itool_composite, image1, csi1, image2, csi2, average=average, $
              interlace=interlace, addition=addition, replace=replace, $
              missing=missing, split=split
;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_COMPOSITE()
;
; PURPOSE:
;       Make composite image array out of two image arrays
;
; CATEGORY:
;       Image Tool
;
; SYNTAX:
;       result = itool_composite(image1, csi1, image2, csi2)
;
; INPUTS:
;       IMAGE1 - 2D array of base image
;       IMAGE2 - 2D array of secondary image
;       CSI1   - CSI structure for IMAGE1
;       CSI2   - CSI structure for IMAGE2
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - 2D byte-scaled array, composite image
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       CT1 - ID of IDL colar table (0-43) for IMAGE1, default to 3
;       CT2 - ID of IDL colar table (0-43) for IMAGE2, default to 1
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       IMAGE2 must be differentially rotated to match the imaging
;       time of the base image IMAGE1
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 12, 1997, Liyun Wang, NASA/GSFC. Written
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;       Version 2, 24-Sep-2010, William Thompson, use [] indexing
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''

   IF N_PARAMS() NE 4 THEN BEGIN
      error = 'Syntax error: wrong number of parameters. 4 required.'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF
   IF datatype(csi1) NE 'STC' OR datatype(csi2) NE 'STC' THEN BEGIN
      error = 'CSI structure required for both image arrays.'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

   ksum = KEYWORD_SET(average)+KEYWORD_SET(addition)+KEYWORD_SET(interlace)+$
      KEYWORD_SET(replace)
   IF ksum GT 1 THEN BEGIN
      error = 'Only one of keywords AVERAGE, ADDITION, REPLACE, '+$
         'or INTERLACE is allowed.'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF

   IF N_ELEMENTS(missing) EQ 0 THEN missing = 0.0
   ncsi = csi2
   itool_img_match, image2, ncsi, csi=csi1, image=image1, $
      xrange=xr, yrange=yr, error=error, device=KEYWORD_SET(interlace)

   xsize = xr[1]-xr[0]
   ysize = yr[1]-yr[0]

   top = !d.table_size-1
   min2 = MIN(image2)
   max2 = MAX(image2)

   IF KEYWORD_SET(addition) THEN BEGIN
      nc = !d.table_size
      nc2 = nc/2
      nc3 = nc-nc2
      min1 = MIN(image1)
      max1 = MAX(image1)
      image = BYTSCL(image1, min=min1, max=max1, top=nc2)
      image[xr[0]:xr[1], yr[0]:yr[1]] = image[xr[0]:xr[1], yr[0]:yr[1]]+$
         BYTSCL(image2(0:xsize, 0:ysize), min=min2, max=max2, top=nc3)
      RETURN, TEMPORARY(image)
   ENDIF

   image = BYTSCL(image1, top=top)

   IF KEYWORD_SET(replace) THEN BEGIN
      sub1 = image[xr[0]:xr[1], yr[0]:yr[1]]
      sub2 = image2[0:xsize, 0:ysize]
;---------------------------------------------------------------------------
;     Record indices of missing points in 2nd image 
;---------------------------------------------------------------------------
      ii = WHERE(sub2 EQ missing)
      sub2 = BYTSCL(TEMPORARY(sub2), min=min2, max=max2, top=top)
      IF ii[0] GE 0 THEN sub2[ii] = sub1[ii]
      image[xr[0]:xr[1], yr[0]:yr[1]] = TEMPORARY(sub2)
      RETURN, TEMPORARY(image)
   ENDIF

   IF KEYWORD_SET(average) THEN BEGIN
      sub1 = image[xr[0]:xr[1], yr[0]:yr[1]]
      sub2 = image2[0:xsize, 0:ysize]
;---------------------------------------------------------------------------
;     Record indices of missing points in 2nd image 
;---------------------------------------------------------------------------
      ii = WHERE(sub2 EQ missing)
      sub2 = BYTSCL(TEMPORARY(sub2), min=min2, max=max2, top=top)
      sub2 =  0.5*(FLOAT(sub1)+FLOAT(TEMPORARY(sub2)))
      IF ii[0] GE 0 THEN sub2[ii] = sub1[ii]
      image[xr[0]:xr[1], yr[0]:yr[1]] = TEMPORARY(sub2)
      RETURN, BYTSCL(TEMPORARY(image), top=top)
   ENDIF

   IF KEYWORD_SET(interlace) THEN BEGIN
      sub2 = image2[0:xsize, 0:ysize]
;---------------------------------------------------------------------------
;     Record indices of missing points in 2nd image 
;---------------------------------------------------------------------------
      ii = WHERE(sub2 EQ missing)
      IF KEYWORD_SET(split) THEN BEGIN
         nc = !d.table_size
         nc2 = nc/2
         nc3 = nc-nc2
         min1 = MIN(image1)
         max1 = MAX(image1)
         sub1 = BYTSCL(image1[xr[0]:xr[1], yr[0]:yr[1]], $
                       min=min1, max=max1, top=nc2)
         sub2 = nc2+BYTSCL(TEMPORARY(sub2), min=min2, max=max2, top=nc3)
      ENDIF ELSE BEGIN
         sub1 = image[xr[0]:xr[1], yr[0]:yr[1]]
         sub2 = BYTSCL(TEMPORARY(sub2), min=min2, max=max2, top=top)
      ENDELSE
      mask_img = mask_matrix(xsize+1,ysize+1)
      sub1(WHERE(mask_img EQ 1)) = 0.0
      sub2(WHERE(mask_img EQ 0)) = 0.0
      sub2 = sub1+TEMPORARY(sub2)
      IF ii[0] GE 0 THEN BEGIN
         sub1 = image[xr[0]:xr[1], yr[0]:yr[1]]
         sub2[ii] = sub1[ii]
      ENDIF 
      image[xr[0]:xr[1], yr[0]:yr[1]] = TEMPORARY(sub2)
      RETURN, TEMPORARY(image)
   ENDIF
END

;---------------------------------------------------------------------------
; End of 'itool_composite.pro'.
;---------------------------------------------------------------------------
