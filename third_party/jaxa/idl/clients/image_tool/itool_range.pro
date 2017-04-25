;---------------------------------------------------------------------------
; Document name: itool_range.pro
; Created by:    Liyun Wang, NASA/GSFC, September 25, 1997
;
; Last Modified: Thu Sep 25 16:43:39 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_range, csi, xrange=xrange, yrange=yrange
;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_RANGE
;
; PURPOSE:
;       Get solar X and Y range of a given image
;
; CATEGORY:
;       Image Tool
;
; SYNTAX:
;       itool_range, csi, xrange=xrange, yrange=yrange
;
; INPUTS:
;       CSI - CSI structure of the concerned image
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
;       XRANGE - 2-element array for solar X range (in arc seconds)
;       YRANGE - 2-element array for solar Y range (in arc seconds)
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
   temp = cnvt_coord(1, 1, from=2, to=3, csi=csi)
   x0 = temp(0,0)-0.5*csi.cdelt1
   y0 = temp(0,1)-0.5*csi.cdelt2

   temp = cnvt_coord(csi.naxis1, csi.naxis2, from=2, to=3, csi=csi)
   x1 = temp(0,0)+0.5*csi.cdelt1
   y1 = temp(0,1)+0.5*csi.cdelt2
   xrange = [x0, x1]
   yrange = [y0, y1]
   RETURN
END

;---------------------------------------------------------------------------
; End of 'itool_range.pro'.
;---------------------------------------------------------------------------
