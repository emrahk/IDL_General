;---------------------------------------------------------------------------
; Document name: itool_draw_icon.pro
; Created by:    Liyun Wang, NASA/GSFC, January 29, 1997
;
; Last Modified: Wed Oct  1 16:35:12 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_DRAW_ICON
;
; PURPOSE: 
;       Event handler for draw_icon events
;
; CATEGORY:
;       image tool
; 
; SYNTAX: 
;       itool_draw_icon, event
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
PRO itool_draw_icon, event
@image_tool_com
   ON_ERROR, 2
   n_icons = N_ELEMENTS(img_icon)
   IF n_icons EQ 0 THEN RETURN
   y = event.y
   id = FIX((icon_height-y)/(icon_size+2))
   in_icon = (id GE 0 AND id LT n_icons)
   
   IF !d.window NE icon_win THEN setwindow, icon_win
   
   IF event.press EQ 1 THEN BEGIN
;---------------------------------------------------------------------------
;     User selects an image from the stack with left button
;---------------------------------------------------------------------------
      IF NOT in_icon THEN RETURN
      xhour
      
      itool_restore, /full

      icon = mk_img_icon(icon_size, image_arr)
      stack = {prev_file:prev_file, image_arr:image_arr, csi:csi, $
               rgb:rgb, cur_min:cur_min, cur_max:cur_max, $
               binary_fits:binary_fits, data_info:data_info, $
               header_cur:header_cur, exptv_rel:exptv_rel, $
               src_name:src_name, img_type:img_type, $
               img_lock:img_lock, gif_file:gif_file, d_mode:d_mode, $
               prev_col:prev_col, log_scaled:log_scaled, scview:scview,$
               noaa:noaa}
               
      itool_xchg_stack, id, stack, icon
      itool_icon_PLOT
      itool_overlay_bt
   ENDIF
   IF event.press EQ 4 THEN BEGIN
;---------------------------------------------------------------------------
;     User marks an image in the stack with right button
;---------------------------------------------------------------------------
      IF NOT in_icon THEN BEGIN
         itool_mark_icon, id, /remove
         WIDGET_CONTROL, rm_stack, sensitive=0
         WIDGET_CONTROL, ptool_peek, sensitive=0
         delvarx, icon_id
      ENDIF ELSE BEGIN
         itool_mark_icon, id
         IF valid_pointer(img_stack(id)) THEN BEGIN
            itool_select_icon, id
            icon_id = id
            WIDGET_CONTROL, rm_stack, sensitive=1
         ENDIF
      ENDELSE
   ENDIF
   
END

;---------------------------------------------------------------------------
; End of 'itool_draw_icon.pro'.
;---------------------------------------------------------------------------
