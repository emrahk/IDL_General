PRO itool_button_refresh
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_BUTTON_REFRESH
;
; PURPOSE: 
;       Make sure all buttons appear properly
;
; CATEGORY:
;       image tool
; 
; SYNTAX: 
;       itool_button_refresh
;
; INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; HISTORY:
;       Version 1, January 29, 1997, Liyun Wang, NASA/GSFC. Written
;          Extracted from image_tool.pro
;       Version 2, March 20, 1997, Liyun Wang, NASA/GSFC
;          Modified to allow quiting Image_tool when Pointing Tool is running
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com
   ON_ERROR, 2
   can_send = 0
   IF N_ELEMENTS(pointing_stc) NE 0 THEN BEGIN
      can_send = WIDGET_INFO(pointing_stc.messenger, /valid)
   ENDIF

;   widget_control2, opt_bs, sensitive=(limbfit_flag EQ 0)

   pt_ok = cando_pointing AND (limbfit_flag EQ 0) AND csi.flag
;   widget_control2, pointing_button, sensitive = cando_pointing AND $
;      (limbfit_flag EQ 0) AND csi.flag
;   widget_control2, ptool, sensitive=(pt_ok)
   widget_control2, ptool_send, sensitive=(pt_ok AND can_send)
;   widget_control2, fit_bs, sensitive=(limbfit_flag EQ 0)

;   widget_control2, img_quit, sensitive=(limbfit_flag EQ 0)

   widget_control2, img_sel_bt, sensitive=binary_fits EQ 1

   widget_control2, rot_mode(1), set_button=(rot_dir EQ -1)
   widget_control2, rot_mode(0), set_button=(rot_dir EQ 1)

;   widget_control2, reset_img, sensitive = 0

   widget_control2, fits_header, sensitive=(gif_file NE 1)
   widget_control2, modify_fh, sensitive=csi.flag
   widget_control2, write_fits, sensitive=(csi.flag EQ 1)

;   widget_control2, load_img_bt, sensitive=(limbfit_flag EQ 0)
   widget_control2, button_base, sensitive=(limbfit_flag EQ 0)
   widget_control2, zoom_bt, sensitive=(limbfit_flag EQ 0 AND can_zoom EQ 1)
   widget_control2, rot_reg_bt, sensitive=(limbfit_flag EQ 0 AND can_zoom EQ 1)

   IF N_ELEMENTS(sc_view) NE 0 THEN $
      widget_control2, sc_view, set_button=(scview EQ 1)
   widget_control2, rot_bs, sensitive=csi.flag
   widget_control2, mode3_bt, sensitive=csi.flag
   widget_control2, mode4_bt, sensitive=csi.flag
   widget_control2, show_csi, sensitive=csi.flag
   widget_control2, grid_bt, set_button=grid   

   if not exist(noaa) then noaa=0 
   widget_control2, noaa_bt, set_button=noaa

   widget_control2, grid_base, sensitive=csi.flag
;   widget_control2, save_img, sensitive=!d.window EQ root_win

   widget_control2, cursor_size, sensitive=boxed_cursor
   widget_control2,src_title,set_value=1-show_src
   IF show_src THEN $
      widget_control2, src_text, set_value=src_name $
   ELSE $
      widget_control2, src_text, set_value=img_type
;   doy=' (doy '+trim(string(utc2doy(anytim2utc(disp_utc))))+')'
   widget_control2, obs_text, $
    set_value=anytim2utc(disp_utc, /ecs, /trunc)

   widget_control2, log_scale, sensitive=(log_scaled EQ 0)
   widget_control2, log_bt, set_button=log_scaled

   IF boxed_cursor THEN $
      widget_control2, cursor_shape, set_value='Use Cross-hair Cursor' $
   ELSE $
      widget_control2, cursor_shape, set_value='Use Boxed Cursor'

   IF track_cursor THEN BEGIN
      widget_control2, cursor_track, set_value='Manual Tracking'
   ENDIF ELSE BEGIN
      widget_control2, txt_id, set_value=''
      widget_control2, cursor_track, set_value='Auto Tracking'
   ENDELSE

   IF rot_dir EQ 1 THEN $
      widget_control2, rot_limb, set_value='points on the east limb' $
   ELSE $
      widget_control2, rot_limb, set_value='points on the west limb'

   IF zoom_in THEN BEGIN
      widget_control2, zoom_bt, set_value='Zoom Out '
   ENDIF ELSE BEGIN
      widget_control2, zoom_bt, set_value=' Zoom In '
   ENDELSE

   widget_control2, rot_img90, sensitive=(img_lock EQ 0)
   widget_control2, rot_img45, sensitive=(img_lock EQ 0)
   widget_control2, rot_img45n, sensitive=(img_lock EQ 0)
   IF img_lock THEN BEGIN
      widget_control2, lock_bt, set_value='Unlock Orientation'
   ENDIF ELSE BEGIN
      widget_control2, lock_bt, set_value='Lock Orientation'
   ENDELSE
   widget_control2, lock_bt, sensitive=csi.flag

   CASE (d_mode) OF
      1: widget_control2, txt_lb, set_value='(in device coordinate system)'
      2: widget_control2, txt_lb, set_value='(in image pixel coordinate system)'
      3: widget_control2, txt_lb, set_value='(in solar disc coordinate system)'
      4: widget_control2, txt_lb, set_value='(in heliographic coordinate system)'
      ELSE:
   ENDCASE
   
END

;---------------------------------------------------------------------------
; End of 'itool_button_refresh.pro'.
;---------------------------------------------------------------------------
