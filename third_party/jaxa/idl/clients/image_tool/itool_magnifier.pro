;---------------------------------------------------------------------------
; Document name: itool_magnifier.pro
; Created by:    Liyun Wang, NASA/GSFC, August 18, 1997
;
; Last Modified: Wed Oct  1 16:53:11 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_magnify_cleanup
@image_tool_com
   widget_control2, menu_row, sensitive=1
   IF !d.window NE root_win THEN setwindow, root_win
   widget_control2, comment_id, set_value=''
END

PRO itool_profiler_run
@image_tool_com
   
   IF N_ELEMENTS(image_arr) EQ 0 THEN BEGIN
      PRINT, 'There is NO image to profile to.'
      PRINT, ''
      RETURN
   ENDIF
   IF !d.window NE root_win THEN setwindow, root_win
   widget_control2, comment_id, set_value=''
   widget_control2, menu_row, sensitive=0
   widget_control2, rot_bs, sensitive=0
   widget_control2, grid_base, sensitive=0

   widget_control2, zoom_title, set_value='Image Tool Profiler'
   widget_control2, zoom_msg, $
      set_value='Use left button to toggle col/row,'
   widget_control2, zoom_win, get_value=zwin
   setwindow, zwin
   ERASE
   setwindow, root_win
   motion_sv = WIDGET_INFO(draw_id, /draw_motion)
   widget_control2, draw_id, draw_motion=1
   tvprofile, image_arr, win_id=zwin, /quiet
   widget_control2, draw_id, draw_motion=motion_sv
   
   widget_control2, tools(curr_tool).base, map=0
   widget_control2, tools(prev_tool).base, map=1
   curr_tool = prev_tool
   itool_magnify_cleanup
   itool_button_refresh
END 

PRO itool_magnify_run
@image_tool_com
;---------------------------------------------------------------------------
;  Desensitize certain buttons while in this mode
;---------------------------------------------------------------------------
   IF !d.window NE root_win THEN setwindow, root_win
   widget_control2, menu_row, sensitive=0
   widget_control2, rot_bs, sensitive=0
   widget_control2, grid_base, sensitive=0
   widget_control2, comment_id, set_value=''
   widget_control2, zoom_title, set_value='Image Tool Magnifier'
   widget_control2, zoom_msg, $
      set_value='Middle button to change zoom factor,'
   widget_control2, zoom_win, get_value=zwin
   setwindow, zwin
   ERASE
   setwindow, root_win
   motion_sv = WIDGET_INFO(draw_id, /draw_motion)
   widget_control2, draw_id, draw_motion=1
   itool_zoom, zoom_win, continuous=1, /cursor, $
      text_id=txt_id, csi=csi, d_mode=d_mode
   widget_control2, draw_id, draw_motion=motion_sv

   widget_control2, tools(curr_tool).base, map=0
   widget_control2, tools(prev_tool).base, map=1
   curr_tool = prev_tool   
   itool_magnify_cleanup
   itool_button_refresh
END

FUNCTION itool_magnifier, parent
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_ZOOMMER()
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
;       Result = itool_zoommer(parent)
;
; INPUTS:
;       PARENT - Widget ID of base widget acting as parent
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - ID of child widget on which the tool is built
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
;       Version 1, August 18, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com
   ON_ERROR, 2
   
   zoom_base = WIDGET_BASE(parent, map=0, /column, xpad=5)
   zoom_title = WIDGET_LABEL(zoom_base, value='Image Tool Magnifier')
   
   IF N_ELEMENTS(win_2nd) EQ 0 THEN win_2nd = 340
   zoom_win = WIDGET_DRAW(zoom_base, xsize=win_2nd, ysize=win_2nd, /frame)
   zoom_msg = WIDGET_LABEL(zoom_base, value='Middle button: change zoom')
   tmp = WIDGET_LABEL(zoom_base, value='right button: quit')
   RETURN, zoom_base
END

;---------------------------------------------------------------------------
; End of 'itool_magnifier.pro'.
;---------------------------------------------------------------------------
