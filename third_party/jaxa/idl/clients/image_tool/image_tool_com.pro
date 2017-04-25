;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       IMAGE_TOOL_COM
;
; PURPOSE:
;       Common blocks for IMAGE_TOOL
;
; CATEGORY:
;       Planning, Image_tool
;
; PREVIOUS HISTORY:
;       Written January 13, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, January 13, 1995, 1995
;-
;
COMMON i_tool_wid0, draw_id, draw_icon, button_base, cursor_shape, $
   cursor_size, $
   txt_lb, txt_id, min_id, max_id, comment_id, mode3_bt, mode4_bt, csr_bt, $
   src_text,src_title, zoom_win, zoom_base, source_base, rot_text, rot_int, $
   rot_bs, time_bs, set_long, set_lat, pointing_base, limbfit_base, $
   grid_base, grid_bt, img_sel_bs, img_sel_bt, fit_bs, zoom_bt, $
   pointing_button, reset_img, show_csi, opt_bs, save_img, $
   obs_text, load_img_bt, rot_limb, study_start, start_text, $
   fits_header, menu_row, lock_bt, old_img_bt, misc_bt, rot_img90,$
   site_list, d_type, modify_fh, img_quit, cursor_track, $
   soho_dbs, own_dbs, zoom_title, zoom_msg,noaa_bt,log_bt

COMMON i_tool_wid2, ptool, ptool_send, log_scale, sc_view, ptool_peek, $
   ptool_fov, ol_reg_rep, ol_reg_con, ol_reg_cmp, ol_reg_int, ol_reg_ave, $
   ol_reg_add, ol_cmp, ol_con, ol_int, rm_stack, rot_reg_bt, $
   rot_img45, rot_img45n, write_fits, draw_2nd, ol_text, rot_longi_bt, $
   rot_solarx_bt, rot_1pt_bt

COMMON i_tool_var0, data_file, image_arr, image_max, image_min, $
   cur_max, cur_min, root_win, header_cur, disp_utc, $
   study_utc, ppxg, ppyg, keep_csr, pt_1st, initial, time_gap, rot_dir, $
   scale, d_mode, tai_start, tai_stop, l_color, $
   time_proj, limbfit_flag, ut_delay, tool_title, zoom_in, csi, csi_sv,$
   img_sv, min_sv, max_sv, img_sel_show, data_info, exit_ok, point_wid, $
   boxed_cursor, cursor_wid, cursor_ht, cursor_unit, src_bs, $
   rot_mode, ras_pnt, grid, del_long, del_lat, cando_pointing, $
   pointing_stc, gif_file, sources, source_num, src_name, img_type, $
   exptv_rel, exptv_sav, load_path, img_lock, rgb, show_src,noaa

COMMON i_tool_var2, help_stc, help_mode, help_wbase, img_stack, prev_file,$
   prev_col, bt4icon, img_handle, binary_fits, rot_unit, rot_ison, $
   summary, ps_stc, img_icon, icon_win, icon_size, icon_height, track_cursor,$
   dtype, id_prev, px_icon, py_icon, icon_stc, messenger, log_scaled, scview, $
   fov_stc, fov_flag, mdi_view, icon_id, lfont, win_xs, win_ys, pix_win

COMMON itool_var3, tools, tools_bt, curr_tool, prev_tool, can_zoom, $
   xzoom, yzoom, pointing_go, pointing_fov, eventx, eventy, clevel, $
   max_stack

COMMON itool_2nd_win, win_2nd, root_2nd, pix_win_2nd, csi_2nd, image_2nd, $
   align_flag

