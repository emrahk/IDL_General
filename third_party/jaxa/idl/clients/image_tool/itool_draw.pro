;---------------------------------------------------------------------------
; Document name: itool_draw.pro
; Created by:    Liyun Wang, NASA/GSFC, January 29, 1997
;
; Last Modified: Wed Sep 17 15:34:12 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_draw, event
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_DRAW
;
; PURPOSE:
;       Handling draw events from the main graphics window
;
; CATEGORY:
;       image tool
;
; SYNTAX:
;       itool_draw, event
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
;       Version 2, March 6, 1997, Liyun Wang, NASA/GSFC
;          Implemented differential rotation indicator for any constant
;             longitudinal points and points at the same Solar X value
;       Version 3, June 12, 1997, Liyun Wang, NASA/GSFC
;          Changed call from CROSS_HAIR to ITOOL_CROSS_HAIR
;       Version 4, September 15, 1997, Liyun Wang, NASA/GSFC
;          Modified such that cross-hair or boxed cursor is plotted
;             only in manual tracking mode
;          Eliminated plotting permanent cursor via middle button
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com
   ON_ERROR, 2
   COMMON itool_draw_com, curr_box
   cx = event.x & cy=event.y

   IF !d.window NE root_win THEN setwindow, root_win

   IF track_cursor THEN $
      cursor_info, cx, cy, txt_id, csi=csi, d_mode=d_mode

   IF pointing_go EQ 1 THEN BEGIN
      itool_draw_drag, event, pixmap=pix_win, status=status, box=pointing_fov
   ENDIF ELSE BEGIN
      itool_draw_drag, event, pixmap=pix_win, status=status, $
         xrange=xrange, yrange=yrange
      IF status EQ 1 THEN BEGIN
         IF N_ELEMENTS(xrange) NE 0 THEN BEGIN
            xzoom = xrange
            yzoom = yrange
            WIDGET_CONTROL2, rot_longi_bt, sensitive=1
            WIDGET_CONTROL2, rot_solarx_bt, sensitive=1
            WIDGET_CONTROL2, rot_1pt_bt, sensitive=1
            WIDGET_CONTROL2, rot_reg_bt, sensitive=1
            IF zoom_in EQ 0 THEN BEGIN
               can_zoom = 1
               delvarx, eventx, eventy
            ENDIF
         ENDIF ELSE BEGIN 
            WIDGET_CONTROL2, rot_reg_bt, sensitive=0
            IF zoom_in EQ 0 THEN can_zoom = 0
         ENDELSE
         IF zoom_in EQ 0 THEN $
            WIDGET_CONTROL2, zoom_bt, sensitive=(can_zoom EQ 1)
      ENDIF
   ENDELSE

   IF event.type EQ 0 THEN BEGIN
      cursor_info, cx, cy, txt_id, csi=csi, d_mode=d_mode
      IF limbfit_flag EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;        Plot cross-hair cursor: Click left button to plot new cursor,
;        middle button to plot a non-removable cursor
;---------------------------------------------------------------------------
         IF event.press EQ 1 THEN BEGIN
            itool_cross_hair, cx, cy, cursor_wid, cursor_ht, cursor_unit, $
               csi=csi, color=l_color, boxed_cursor=boxed_cursor, $
               pixmap=pix_win
         ENDIF 
;         ELSE IF event.press EQ 2 THEN BEGIN
;            itool_cross_hair, cx, cy, cursor_wid, cursor_ht, cursor_unit, $
;               csi=csi, color=l_color, boxed_cursor=boxed_cursor, /keep, $
;               pixmap=pix_win
;         ENDIF
         eventx = cx
         eventy = cy
         WIDGET_CONTROL2, rot_longi_bt, sensitive=1
         WIDGET_CONTROL2, rot_solarx_bt, sensitive=1
         WIDGET_CONTROL2, rot_1pt_bt, sensitive=1
      ENDIF
      IF csi.flag THEN BEGIN
         initial = cnvt_coord(cx, cy, csi=csi, from=1, to=3)
      ENDIF
   ENDIF

END

;---------------------------------------------------------------------------
; End of 'itool_draw.pro'.
;---------------------------------------------------------------------------
