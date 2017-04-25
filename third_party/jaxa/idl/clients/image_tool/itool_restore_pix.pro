;---------------------------------------------------------------------------
; Document name: itool_restore_pix.pro
; Created by:    Liyun Wang, NASA/GSFC, June 12, 1997
;
; Last Modified: Thu Jun 12 10:43:29 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_restore_pix, pixmap
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_RESTORE_PIX
;
; PURPOSE: 
;       Restore current plot window with pixmap saved in pixmap.id
;
; CATEGORY:
;       IMAGE_TOOL
; 
; SYNTAX: 
;       itool_restore_pix, pixmap
;
; INPUTS:
;       PIXMAP - A structure with tags XSIZE, YSIZE, and ID
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
;       Only works for devices that supports COPY keyword (X, WIN,
;       SUN, and MAC)
;
; SIDE EFFECTS:
;       Current contents on current window (!d.window) get replaced.
;
; HISTORY:
;       Version 1, June 12, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   
   ON_ERROR, 2
   DEVICE, copy=[0, 0, pixmap.xsize, pixmap.ysize, 0, 0, pixmap.id]
END

;---------------------------------------------------------------------------
; End of 'itool_restore_pix.pro'.
;---------------------------------------------------------------------------
