;---------------------------------------------------------------------------
; Document name: mask_matrix.pro
; Created by:    Liyun Wang, GSFC/ARC, October 27, 1995
;
; Last Modified: Tue Nov 28 12:04:04 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       MASK_MATRIX()
;
; PURPOSE:
;       Create a mask matrix for image manipulation
;
; CATEGORY:
;
;
; EXPLANATION:
;       This function routine can be used for creating an interleave
;       (i.e., checkerboard) or an interlace mask matrix.
;
; SYNTAX:
;       Result = mask_matrix()
;
; EXAMPLES:
;
; INPUTS:
;       M - The first dimension of the matrix
;       N - The second dimension of the matrix
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - An MxN integer mask matrix
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       FIRST      - If set, value of the first pixel is 1, otherwise 0
;       INTERLEAVE - Make interleave mask matrix. This is default if
;                    there is no other keyword being set
;       XINTERLACE - Make X-direction interlaced mask matrix
;       YINTERLACE - Make Y-direction interlaced mask matrix
;
;       Note: Only one of above keywords can be set at a time.
;
;       ERROR - A named keyword variable that contains error message;
;               a null string is returned if no error occurs
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
;       Version 1, October 27, 1995, Liyun Wang, GSFC/ARC. Written
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

FUNCTION mask_matrix, m, n, interleave=interleave, xinterlace=xinterlace,$
                      yinterlace=yinterlace, first=first, error=error
   ON_ERROR, 2
   IF N_ELEMENTS(m) EQ 0 OR N_ELEMENTS(n) EQ 0 THEN BEGIN
      error = 'Syntax: RESULT = mask_matrix(m,n)'
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF
   a = INTARR(m, n)
   IF KEYWORD_SET(first) THEN off = 0 ELSE off = 1

   IF (m/2)*2 NE m THEN BEGIN
      b = LONG(2*LINDGEN((LONG(m)*LONG(n))/2l)+off)
      a(b) = 1
   ENDIF ELSE BEGIN
      IF (n/2)*2 NE n THEN BEGIN
         b = LONG(2*LINDGEN((LONG(m)*LONG(n))/2l)+off)
         c = TRANSPOSE(a)
         c(b) = 1
         a = TRANSPOSE(c)
      ENDIF ELSE BEGIN
         b = LONG(2*LINDGEN(LONG(n)/2)+off)
         IF off EQ 0 THEN c = b+1 ELSE c = b-1
         FOR i=0, m-1 DO BEGIN
            IF (i/2)*2 EQ i THEN a(i,b) = 1 ELSE a(i,c) = 1
         ENDFOR
      ENDELSE
   ENDELSE
   RETURN, a
END

;---------------------------------------------------------------------------
; End of 'mask_matrix.pro'.
;---------------------------------------------------------------------------
