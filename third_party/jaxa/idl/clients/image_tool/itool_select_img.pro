;---------------------------------------------------------------------------
; Document name: itool_select_img.pro
; Created by:    Liyun Wang, NASA/GSFC, September 2, 1997
;
;---------------------------------------------------------------------------
;
FUNCTION itool_select_img, image, csi, xrange, yrange, dbox=dbox, $
              error=error, ibox=ibox, modify_csi=modify_csi
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_SELECT_IMG()
;
; PURPOSE: 
;       Get X and Y range of selected image indices
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       Result = itool_select_img(xrange, yrange)
;
; INPUTS:
;       IMAGE  - 2D image array
;       CSI    - CSI structure associated with IMAGE
;       XRANGE - X range of selected box in device pixels (0 based)
;       YRANGE - Y range of selected box in device pixels (0 based)
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - 2D array of selected image
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       IBOX       - Set this keyword to return corner points of selected
;                    image in image pixels
;       DBOX       - 5x2 array, device coordinates of box surrounding
;                    the region being selected
;       ERROR      - Named variable containing possible error message
;       MODIFY_CSI - Set this keyword to modify CSI upon seccess
;                    selection
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
;       Version 1, September 2, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, 24-Sep-2010, William Thompson, use [] indexing
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''
   IF N_PARAMS() NE 4 THEN BEGIN 
      error = 'Required 4 parameters: image, csi, xrange, yrange.'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF
   
   dbox = [[xrange[0], xrange[1], xrange[1], xrange[0], xrange[0]],$
           [yrange[0], yrange[0], yrange[1], yrange[1], yrange[0]]]
;---------------------------------------------------------------------------
;  zrange is image pixel (1 based), not image array indices (0 based)!
;---------------------------------------------------------------------------
   zrange = cnvt_coord([[xrange], [yrange]], from=1, to=2, csi=csi)   

;---------------------------------------------------------------------------
;  xrange and yrange are image array indices (0 based)
;---------------------------------------------------------------------------
   xindex = zrange[*, 0]-1
   yindex = zrange[*, 1]-1

   xll = xindex[0] > 0
   xur = ((xindex[1]-1) < (csi.naxis1-1)) > 0
   yll = yindex[0] > 0
   yur = ((yindex[1]-1) < (csi.naxis2-1)) > 0
   IF (xll GE xur) OR (yll GE yur)THEN BEGIN
      error = 'Invalid selection!'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF
   IF KEYWORD_SET(ibox) THEN BEGIN 
      xx = xll+INDGEN(xur-xll+1)
      yy = yll+INDGEN(yur-yll+1)
      nx = N_ELEMENTS(xx) 
      ny = N_ELEMENTS(yy) 
      box = [[xx, REPLICATE(xur, ny-1), ROTATE(xx, 2), REPLICATE(xll, ny-1)],$
             [REPLICATE(yll, nx-1), yy, REPLICATE(yur, nx-1), ROTATE(yy, 2)]]
      RETURN, box
;      RETURN, [[xll, xur, xur, xll, xll], [yll, yll, yur, yur, yll]] 
   ENDIF ELSE BEGIN 
      IF KEYWORD_SET(modify_csi) THEN BEGIN
         cval = cnvt_coord(xll, yll, csi=csi, from=2, to=3)
;---------------------------------------------------------------------------
;        Modify CSI
;---------------------------------------------------------------------------
         csi.crpix1 = 1
         csi.crpix2 = 1
         csi.crval1 = cval[0]
         csi.crval2 = cval[1]
         csi.naxis1 = xur-xll+1
         csi.naxis2 = yur-yll+1
      ENDIF 
      RETURN, image[xll:xur, yll:yur]
   ENDELSE 
END

;---------------------------------------------------------------------------
; End of 'itool_select_img.pro'.
;---------------------------------------------------------------------------
