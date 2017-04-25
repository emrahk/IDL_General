;---------------------------------------------------------------------------
; Document name: itool_xy.pro
; Created by:    Liyun Wang, NASA/GSFC, September 2, 1997
;
; Last Modified: Tue Sep 23 18:09:01 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_xy, csi, xx=xx, yy=yy, vector=vector
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_XY
;
; PURPOSE: 
;       Create array for Solar X and Solar Y coordinates for a given CSI
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       itool_xy, csi, xx=xx, yy=yy
;
; INPUTS:
;       CSI - Coordinate system info structure
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
;       XX     - Solar X coordinates in arcsecs, 2D (or 1D if VECTOR
;                keyword is set) array
;       YY     - Solar Y coordinates in arcsecs, 2D (or 1D if VECTOR
;                keyword is set) array
;       VECTOR - Set this keyword to return only 1D vector of solar X and Y
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
;       Version 2, September 15, 1997, Liyun Wang, NASA/GSFC
;          Added VECTOR keyword
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   xx = csi.crval1+(FINDGEN(csi.naxis1)+1.0-csi.crpix1)*csi.cdelt1
   yy = csi.crval2+(FINDGEN(csi.naxis2)+1.0-csi.crpix2)*csi.cdelt2
   IF KEYWORD_SET(vector) THEN RETURN
   xx = xx # REPLICATE(1, csi.naxis2)
   yy = REPLICATE(1, csi.naxis1) # yy
   RETURN
END

;---------------------------------------------------------------------------
; End of 'itool_xy.pro'.
;---------------------------------------------------------------------------
