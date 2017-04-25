;---------------------------------------------------------------------------
; Document name: itool_restore.pro
; Created by:    Liyun Wang, NASA/GSFC, October 1, 1997
;
; Last Modified: Wed Oct  1 16:37:34 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_RESTORE, full=full
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_RESTORE
;
; PURPOSE:
;       Restore zoomed-in image to its original status
;
; CATEGORY:
;       Image Tool
;
; SYNTAX:
;       itool_restore
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
;       FULL - Set this keyword to save current color table too.
;
; COMMON:
;       @image_tool_com
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, October 1, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com
   ON_ERROR, 2
   IF zoom_in THEN BEGIN
;---------------------------------------------------------------------------
;     Zoom out
;---------------------------------------------------------------------------
      zoom_in = 0
      IF (csi.cdelt1 NE csi_sv.cdelt1) OR $
         (csi.cdelt2 NE csi_sv.cdelt2) THEN BEGIN
;---------------------------------------------------------------------------
;        Just in case csi.cdelt1, and csi.cdelt2 are changed, update that
;---------------------------------------------------------------------------
         csi_sv.crpix1 = csi.crpix1
         csi_sv.crpix2 = csi.crpix2
         csi_sv.cdelt1 = csi.cdelt1
         csi_sv.cdelt2 = csi.cdelt2
      ENDIF
      csi = csi_sv
      image_arr = img_sv
      cur_min = min_sv
      cur_max = max_sv
      exptv_rel = exptv_sav
      WIDGET_CONTROL, comment_id, set_value=''
      can_zoom = 0
   ENDIF
   IF NOT KEYWORD_SET(full) THEN RETURN
;---------------------------------------------------------------------------
;  Save current color table
;---------------------------------------------------------------------------
   TVLCT, r, g, b, /get
   rgb = [[r], [g], [b]]
   RETURN
END

;---------------------------------------------------------------------------
; End of 'itool_restore.pro'.
;---------------------------------------------------------------------------
