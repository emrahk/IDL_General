;---------------------------------------------------------------------------
; Document name: cir_mask.pro
; Created by:    Liyun Wang, GSFC/ARC, February 15, 1996
;
; Last Modified: Thu Feb 15 14:24:29 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION cir_mask, array, x0, y0, r0, outside=outside, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       CIR_MASK()
;
; PURPOSE: 
;       Get indices of a circular mask over a 2D array
;
; CATEGORY:
;       Utility
; 
; EXPLANATION:
;       There are cases where there is a need of getting indices of
;       all pixels of a circular region in a 2D array. This routine
;       does just that.
;
; SYNTAX: 
;       Result = cir_mask(array, x0, y0, r0)
;
; INPUTS:
;       ARRAY - 2D array
;       X0    - X position of the center of the circular region, in pixels
;       Y0    - Y position of the center of the circular region, in pixels
;       R0    - Radius of the circular region, in pixels
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - Indices of pixels inside (or outside, if OUTSIDE keyword 
;                is set) the circular region. A -1 is returned if an
;                error occurs 
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       OUTSIDE - Set this keyword to mask outside of the circular region
;       ERROR   - Error message returned; a null string if no error
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       Number of elements in ARRAY cannot exceed the maximum limit of
;       long integer
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, February 15, 1996, Liyun Wang, GSFC/ARC. Written
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''
   IF N_PARAMS() NE 4 THEN BEGIN
      error = 'Sytax: a = cir_mask(array, x0, y0, r0)'
      RETURN, -1
   ENDIF
   sz = SIZE(array)

   IF sz(0) NE 2 THEN BEGIN
      error = 'The first input parameter must be a 2D array'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF
   
   x = sz(1)
   a = sz(2)
   x1 = LONG(x0)
   y1 = LONG(y0)
   r = r0*r0
   a = LINDGEN(x*a)
   tmp = LONG(a/x)
   yy = tmp - 1L
   xx = a - tmp*x - 1L
   a = (xx-x1)^2 + (yy-y1)^2
   IF NOT KEYWORD_SET(outside) THEN $
      ii = WHERE(a LE r) $
   ELSE $
      ii = WHERE(a GE r)
   RETURN, ii
END

;---------------------------------------------------------------------------
; End of 'cir_mask.pro'.
;---------------------------------------------------------------------------
