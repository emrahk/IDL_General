;---------------------------------------------------------------------------
; Document name: reverse_colors.pro
; Created by:    Liyun Wang, GSFC/ARC, April 1, 1996
;
; Last Modified: Mon Apr  1 17:32:12 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO reverse_colors
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       REVERSE_COLORS
;
; PURPOSE: 
;       Reverse the current color table
;
; CATEGORY:
;       Graphics, utility
; 
; SYNTAX: 
;       reverse_colors
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; COMMON:
;       colors
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       Current color table is changed
;
; HISTORY:
;       Version 1, April 1, 1996, Liyun Wang, GSFC/ARC. Written
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
   IF N_ELEMENTS(r_orig) EQ 0 THEN BEGIN
      TVLCT, r_orig, g_orig, b_orig, /get
      r_curr = r_orig
      g_curr = g_orig
      b_curr = b_orig
   ENDIF
   r_curr = ROTATE(r_curr, 2)
   g_curr = ROTATE(g_curr, 2)
   b_curr = ROTATE(b_curr, 2)
   TVLCT, r_curr, g_curr, b_curr
END

;---------------------------------------------------------------------------
; End of 'reverse_colors.pro'.
;---------------------------------------------------------------------------
