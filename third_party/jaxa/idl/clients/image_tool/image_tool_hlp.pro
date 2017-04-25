;---------------------------------------------------------------------------
; Document name: image_tool_hlp.pro
; Created by:    Liyun Wang, NASA/GSFC, May 15, 1995
;
; Last Modified: Tue Aug 26 09:58:36 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO image_tool_hlp, uvalue
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       IMAGE_TOOL_HLP
;
; PURPOSE:
;       Print selected help message for a given uvalue of a widget
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       image_tool_hlp, uvalue
;
; INPUTS:
;       UVALUE - User value of a widget created from an widget event
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
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       @IMAGE_TOOL_COM
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;
; PREVIOUS HISTORY:
;       Written May 15, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, May 15, 1995
;       Version 2, October 27, 1995, Liyun Wang, NASA/GSFC
;          Modified to cope with the cursor tracking option
;
; VERSION:
;       Version 2, October 27, 1995
;-
;

@image_tool_com

   ON_ERROR, 2

   IF NOT help_mode THEN RETURN

   CASE (uvalue) OF
      'HELP_ONLINE': BEGIN
;---------------------------------------------------------------------------
;        Turn off the help mode
;---------------------------------------------------------------------------
         help_mode = 0
         WIDGET_CONTROL, draw_id, draw_motion = track_cursor
         xkill, help_wbase
         itool_refresh
      END
;---------------------------------------------------------------------------
;     Single widget help topics
;---------------------------------------------------------------------------
      'QUIT': xshow_help, help_stc, 'FILE', tbase = help_wbase
      'color_tb': xshow_help, help_stc, 'LOAD_COLOR', tbase = help_wbase
      'PROFILE': xshow_help, help_stc, 'PROFILE', tbase = help_wbase
      'REFRESH': xshow_help, help_stc, 'REFRESH', tbase = help_wbase
      'img_info': xshow_help, help_stc, 'IMAGE_INFO', tbase = help_wbase
      'HEADER': xshow_help, help_stc, 'FITS_HEADER', tbase = help_wbase
      'SHOW_CSI': xshow_help, help_stc, 'SHOW_CSI', tbase = help_wbase
      'cursor': xshow_help, help_stc, 'SET_CURSOR', tbase = help_wbase
      'cursor_size': xshow_help, help_stc, 'SET_CURSOR', tbase = help_wbase
      'exptv': xshow_help, help_stc, 'SET_IMAGE_SIZE', tbase = help_wbase
      'reset_img': xshow_help, help_stc, 'RESET_IMAGE', tbase = help_wbase
      'rotate_img': xshow_help, help_stc, 'ROTATE_IMAGE', tbase = help_wbase
      'rvs_img': xshow_help, help_stc, 'REVERSE_IMAGE', tbase = help_wbase
      'flip_img': xshow_help, help_stc, 'FLIP_IMAGE', tbase = help_wbase
      'hist_img': xshow_help, help_stc, 'HISTOGRAM', tbase = help_wbase
      'sig_img': xshow_help, help_stc, 'SIGRANGE_IMAGE', tbase = help_wbase
      'keep_img': xshow_help, help_stc, 'RETAIN_IMAGE', tbase = help_wbase
      'reset_limits': xshow_help, help_stc, 'RESET_LIMITS', tbase = help_wbase
      'DRAW': xshow_help, help_stc, 'IMAGE_DISPLAY', tbase = help_wbase
      'POINTING': xshow_help, help_stc, 'POINTING', tbase = help_wbase
      'img_lock': xshow_help, help_stc, 'LOCK_ORIENTATIO', tbase = help_wbase
      'HELP': xshow_help, help_stc, 'OVERVIEW', tbase = help_wbase
      ELSE:
   ENDCASE

;---------------------------------------------------------------------------
;  Multiple widget help topics
;---------------------------------------------------------------------------
   IF grep('OLD_IMG', uvalue) THEN $
      xshow_help, help_stc, 'LOAD_IMAGE', tbase = help_wbase
   IF grep(uvalue, ['GRID','del_lat','del_long']) NE '' THEN $
      xshow_help, help_stc, 'GRID', tbase = help_wbase
   IF grep(uvalue, ['save_ps','save_cps','save_eps','save_ceps',$
                    'save_prn','save_cpt','save_gif']) NE '' THEN $
      xshow_help, help_stc, 'SAVE_IMAGE', tbase = help_wbase
   IF grep(uvalue,['zoom_in_out','zoom_1','zoom_2']) NE '' THEN $
      xshow_help, help_stc, 'ZOOM', tbase = help_wbase
   IF grep(uvalue,['p_color','p_bg','p_cs','p_ct','p_tick','c_color']) NE '' $
      THEN xshow_help, help_stc, 'SET_SYSTEM_VAR', tbase = help_wbase
   IF grep(uvalue,['mode_1','mode_2','mode_3','mode_4']) NE '' THEN $
      xshow_help, help_stc, 'COORDINATES', tbase = help_wbase
   IF grep(uvalue,['min_v','SET_MIN']) NE '' THEN $
      xshow_help, help_stc, 'SET_MIN_VALUE', tbase = help_wbase
   IF grep(uvalue,['max_v','SET_MAX']) NE '' THEN $
      xshow_help, help_stc, 'SET_MAX_VALUE', tbase = help_wbase
   IF grep(uvalue,['any_study','study_start','img_time','disp_time']) NE '' $
      THEN xshow_help, help_stc, 'TIME_SETTING', tbase = help_wbase
   IF grep(uvalue,['forward','backward','TIME_GAP','rot_now','rot_limb',$
                   'rot_1pt','rot_reg','rot_regmap','rot_img'],/exact) NE '' $
      THEN xshow_help, help_stc, 'DIFF_ROTATE', tbase = help_wbase
   IF grep(uvalue,['load_fits','load_myfits','load_gif','S_LIST']) NE '' $
      THEN xshow_help, help_stc, 'LOAD_IMAGE', tbase = help_wbase
   IF grep(uvalue,['FIT_MAN','FIT_MAN1','FIT_AUTO'],/exact) NE '' THEN $
      xshow_help, help_stc, 'LIMB_FITTING', tbase = help_wbase
   RETURN
END

;---------------------------------------------------------------------------
; End of 'image_tool_hlp.pro'.
;---------------------------------------------------------------------------
