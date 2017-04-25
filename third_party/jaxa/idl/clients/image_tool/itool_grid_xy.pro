;---------------------------------------------------------------------------
; Document name: itool_grid_xy.pro
; Created by:    Liyun Wang, NASA/GSFC, September 25, 1997
;
; Last Modified: Thu Sep 25 14:10:36 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_grid_xy, xx, yy, nx, ny, space=space
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_GRID_XY
;
; PURPOSE: 
;       
;
; CATEGORY:
;       
; 
; EXPLANATION:
;       
; SYNTAX: 
;       itool_grid_xy, 
;
; EXAMPLES:
;       
; INPUTS:
;       
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
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 25, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   xll = MIN(xx)
   xur = MAX(xx)
   yll = MIN(yy)
   yur = MAX(yy)
   xa = ROUND((xur-xll)/space(0))+1
   ya = ROUND((yur-yll)/space(1))+1
   xa = xll+FINDGEN(xa)*space(0)
   ya = yll+FINDGEN(ya)*space(1)
   nx = xa # REPLICATE(1, N_ELEMENTS(ya))
   ny = REPLICATE(1, N_ELEMENTS(xa)) # ya
   RETURN
END


;---------------------------------------------------------------------------
; End of 'itool_grid_xy.pro'.
;---------------------------------------------------------------------------
