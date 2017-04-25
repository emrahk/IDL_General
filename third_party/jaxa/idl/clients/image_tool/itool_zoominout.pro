;---------------------------------------------------------------------------
; Document name: itool_zoominout.pro
; Created by:    Liyun Wang, NASA/GSFC, January 29, 1997
;
; Last Modified: Wed Oct  1 16:48:49 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_zoominout, event
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_ZOOMINOUT
;
; PURPOSE:
;       Event handler for zooming in/out
;
; CATEGORY:
;       image tool
;
; SYNTAX:
;       itool_zoominout, event
;
; INPUTS:
;       EVENT - Event structure
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
;       @image_tool_com
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, January 29, 1997, Liyun Wang, NASA/GSFC. Written
;          Extracted from image_tool.pro
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com

   ON_ERROR, 2
   IF N_ELEMENTS(exptv_sav) EQ 0 THEN exptv_sav = exptv_rel
   IF !d.window NE root_win THEN setwindow, root_win
   IF zoom_in THEN BEGIN
      itool_restore
      itool_refresh
   ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;     Zoom in
;---------------------------------------------------------------------------
      zoom_in = 1
      delvarx, initial
      csi_sv = csi
      img_sv = image_arr
      min_sv = cur_min
      max_sv = cur_max
      exptv_sav = exptv_rel
      junk = itool_select_img(image_arr, csi, xzoom, yzoom, error=error, $
                              /modify)
      IF error NE '' THEN BEGIN
         xack, error, /modal
         zoom_in = 0
         can_zoom = 0
         WIDGET_CONTROL, draw_id, draw_button=1
         itool_refresh
         RETURN
      ENDIF
      image_arr = junk
      exptv_rel = 0.95
      WIDGET_CONTROL, comment_id, set_value=$
         'To zoom out, please press the "Zoom Out" button.'
      itool_display, image_arr, min=cur_min, max=cur_max, csi=csi, $
         relative=exptv_rel
      itool_disp_plus, /keep
   ENDELSE
END


;---------------------------------------------------------------------------
; End of 'itool_zoominout.pro'.
;---------------------------------------------------------------------------
