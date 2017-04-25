;---------------------------------------------------------------------------
; Document name: itool_overlayer.pro
; Created by:    Liyun Wang, NASA/GSFC, September 5, 1997
;
; Last Modified: Mon Sep 29 17:18:00 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_OVERLAYER()
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
;       Result = itool_overlayer()
;
; EXAMPLES:
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
;       Version 1, September 5, 1997, Liyun Wang, NASA/GSFC. Written
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
PRO itool_overlay_bt, sensitive=sensitive
;---------------------------------------------------------------------------
;  Control the overley buttons
;---------------------------------------------------------------------------
@image_tool_com
   COMMON itool_ol_com, csi_rd, img_rd, csi_sub, xrange, yrange
   IF N_ELEMENTS(sensitive) EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     Compare flags of two images and see if overlay should be sensitized
;---------------------------------------------------------------------------
      IF N_ELEMENTS(icon_stc) NE 0 THEN $
         sensitive = (icon_stc.csi.flag EQ 1 AND csi.flag EQ 1) $
      ELSE sensitive = 0
   ENDIF
   sens = (N_ELEMENTS(xrange) NE 0) AND (sensitive EQ 1)
   WIDGET_CONTROL, ol_reg_con, sensitive=sens
   WIDGET_CONTROL, ol_reg_ave, sensitive=sens
   WIDGET_CONTROL, ol_reg_rep, sensitive=sens
   WIDGET_CONTROL, ol_reg_int, sensitive=sens
   WIDGET_CONTROL, ol_reg_cmp, sensitive=sens
   WIDGET_CONTROL, ol_reg_add, sensitive=sens
   WIDGET_CONTROL, ol_con, sensitive=(align_flag EQ 0)
   WIDGET_CONTROL, ol_cmp, sensitive=(align_flag EQ 0)
   WIDGET_CONTROL, ol_int, sensitive=(align_flag EQ 0)
   RETURN
END

PRO itool_disp_2nd
@image_tool_com
   ON_ERROR, 2
   setwindow, root_2nd
   ERASE
   junk = congrid(image_2nd, csi_2nd.daxis1, csi_2nd.daxis2)
   TV, BYTSCL(junk, max=icon_stc.cur_max, min=icon_stc.cur_min, $
              top=(!d.table_size - 1))
   saved_win = !d.window
   dwin_xs=!d.x_size
   dwin_ys=!d.y_size
   WSET, pix_win_2nd.id
   DEVICE, copy=[0, 0, win_2nd < dwin_xs, win_2nd < dwin_ys, 0, 0, saved_win]
   WSET, saved_win
   itool_overlay_bt
   WIDGET_CONTROL, ol_text, set_value=itool_img_src(icon_stc.csi.origin)+', '+$
      itool_img_type(icon_stc.csi.imagtype)+', '+$
      STRMID(icon_stc.csi.date_obs,2,14)
END

PRO itool_select_icon, id
;---------------------------------------------------------------------------
;  Load an image on the stack as a secondary image
;---------------------------------------------------------------------------
@image_tool_com
   COMMON itool_ol_com, csi_rd, img_rd, csi_sub, xrange, yrange
   ON_ERROR, 2
   WIDGET_CONTROL, /hour
   icon_stc=get_pointer(img_stack(id))
   csi_2nd = icon_stc.csi
   image_2nd = icon_stc.image_arr
   IF csi_2nd.naxis1 GT csi_2nd.naxis2 THEN BEGIN
      xy = FLOAT(csi_2nd.naxis2)/FLOAT(csi_2nd.naxis1)
      sx = win_2nd
      sy = win_2nd*xy
   ENDIF ELSE BEGIN
      xy = FLOAT(csi_2nd.naxis1)/FLOAT(csi_2nd.naxis2)
      sy = win_2nd
      sx = win_2nd*xy
   ENDELSE
   csi_2nd.daxis1 = ROUND(sx)
   csi_2nd.daxis2 = ROUND(sy)
   csi_2nd.drpix1 = 0
   csi_2nd.drpix2 = 0
   csi_2nd.ddelt1 = FLOAT(csi_2nd.naxis1)/FLOAT(csi_2nd.daxis1)
   csi_2nd.ddelt2 = FLOAT(csi_2nd.naxis2)/FLOAT(csi_2nd.daxis2)
   itool_disp_2nd
   delvarx, xrange, yrange
   itool_overlay_bt
END

PRO itool_ov_image, code
;---------------------------------------------------------------------------
;  Give different overlaying code, do necessary overlay operation
;---------------------------------------------------------------------------
@image_tool_com
   ON_ERROR, 2
   COMMON itool_ol_com, csi_rd, img_rd, csi_sub, xrange, yrange
   IF N_ELEMENTS(code) EQ 0 THEN RETURN
   IF N_ELEMENTS(xrange) EQ 0 THEN RETURN
   WIDGET_CONTROL, comment_id, set_value='Just a second...', /hour
   csi2 = csi_2nd
   img2 = itool_select_img(image_2nd, csi2, xrange, yrange, $
                           error=error, /modify)
   IF has_error(error) THEN RETURN
   IF align_flag EQ 1 THEN BEGIN
;---------------------------------------------------------------------------
;     Diff rot the image only if the imaging time difference is
;     more than 10 minutes
;---------------------------------------------------------------------------
      need_rot = (N_ELEMENTS(img_rd) EQ 0)
      IF need_rot EQ 0 THEN BEGIN
         need_rot = (match_struct(csi_sub, csi2) EQ 0)
         IF need_rot EQ 0 THEN BEGIN
            IF N_ELEMENTS(csi_rd) EQ 0 THEN ncsi = csi2 ELSE ncsi = csi_rd
            need_rot = ABS(utc2tai(csi.date_obs)-utc2tai(ncsi.date_obs)) GT 600.d0
         ENDIF
      ENDIF
      IF need_rot EQ 1 THEN BEGIN
         img2 = itool_diff_rot(img2, csi2, new_csi=ncsi, $
                               newtime=csi.date_obs, error=error)
         IF has_error(error) THEN RETURN
         csi_sub = csi2
         csi2 = ncsi
         img_rd = img2
         csi_rd = csi2
      ENDIF ELSE BEGIN
         csi2 = csi_rd
         img2 = img_rd
      ENDELSE
   ENDIF
   CASE (code) OF
      1: BEGIN                  ; contour
         itool_img_match, img2, csi2, csi=csi, error=error
         IF has_error(error) THEN RETURN
         itool_xy, csi2, xx=xx, yy=yy, /vector
         irange = MAX(img2)-MIN(img2)
         imax = MAX(img2)-0.02*irange
         irange = irange/10.0
         levels = ROTATE(imax-FINDGEN(clevel)*irange, 2)
         setwindow, root_win
         CONTOUR, img2, xx, yy, levels=levels, /overplot, /follow, $
            color=FIX(0.85*!d.table_size)
         itool_copy_to_pix
      END
      2: BEGIN                  ; Average
         image = itool_composite(image_arr, csi, img2, csi2, /average)
         setwindow, root_win
         itool_display, image, relative=exptv_rel, csi=csi, /noscale
         itool_disp_plus
      END
      3: BEGIN                  ; Transparent via interlacing
         img1 = image_arr
         csi1 = csi
         image = itool_composite(img1, csi1, img2, csi2, /interlace)
         setwindow, root_win
         itool_display, image, relative=exptv_rel, csi=csi1, /noscale
         itool_disp_plus, alt_csi=csi1
      END
      4: BEGIN                  ; Addition
         image = itool_composite(image_arr, csi, img2, csi2, /addi)
         setwindow, root_win
         itool_display, image, relative=exptv_rel, csi=csi, /noscale
         itool_disp_plus
      END
      5: BEGIN                  ; Replace
         image = itool_composite(image_arr, csi, img2, csi2, /replace)
         setwindow, root_win
         itool_display, image, relative=exptv_rel, csi=csi, /noscale
         itool_disp_plus
      END
      6: BEGIN                  ; Composite via interlacing
         img1 = image_arr
         csi1 = csi
         image = itool_composite(img1, csi1, img2, csi2, /interlace, /split)
         setwindow, root_win
         itool_display, image, relative=exptv_rel, csi=csi1, /noscale
         itool_disp_plus, alt_csi=csi1
         f = concat_dir(GETENV('SSW_SETUP_DATA'), 'color_table.eit')
         IF file_exist(f) THEN xload, file=f, /two ELSE $
            xload, /two
      END
      ELSE:
   ENDCASE
   WIDGET_CONTROL, comment_id, set_value=''
   RETURN
END

PRO itool_overlayer_event, event
@image_tool_com
   ON_ERROR, 2
   COMMON itool_ol_com, csi_rd, img_rd, csi_sub, xrange, yrange
   WIDGET_CONTROL, event.id, get_uvalue=uvalue
   CASE (uvalue(0)) OF
      'ol_quit': BEGIN
          itool_switcher, 0
          itool_button_refresh
      END
      'draw_2nd': BEGIN
         IF !d.window NE root_2nd THEN setwindow, root_2nd
         itool_draw_drag, event, pixmap=pix_win_2nd, status=status, $
            xrange=xx, yrange=yy
         IF status EQ 1 THEN BEGIN
            IF N_ELEMENTS(xx) NE 0 THEN BEGIN
               xrange = xx
               yrange = yy
            ENDIF ELSE BEGIN
               status = 0
               DEVICE, copy=[0, 0, pix_win_2nd.xsize, pix_win_2nd.ysize, $
                             0, 0, pix_win_2nd.id]
               delvarx, xrange, yrange
            ENDELSE
            itool_overlay_bt
         ENDIF
      END
      'ol_reg_con':  BEGIN
         itool_ov_image, 1
      END
      'ol_reg_ave': BEGIN
         itool_ov_image, 2
      END
      'ol_reg_int': BEGIN
         itool_ov_image, 3
      END
      'ol_reg_add':  BEGIN
         itool_ov_image, 4
      END
      'ol_reg_cmp':  BEGIN
         itool_ov_image, 6
      END
      'ol_reg_rep':  BEGIN
         itool_ov_image, 5
      END
      'ol_align': BEGIN
         align_flag = event.select
         WIDGET_CONTROL, ol_con, sensitive=(align_flag EQ 0)
         WIDGET_CONTROL, ol_cmp, sensitive=(align_flag EQ 0)
         WIDGET_CONTROL, ol_int, sensitive=(align_flag EQ 0)
      END
      'ol_con': BEGIN
         WIDGET_CONTROL, /hour
         img2 = image_2nd
         csi2 = csi_2nd
         itool_img_match, img2, csi2, csi=csi
         itool_xy, csi2, xx=xx, yy=yy
         irange = MAX(img2)-MIN(img2)
         imax = MAX(img2)-0.02*irange
         irange = irange/10.0
         levels = ROTATE(imax-FINDGEN(clevel)*irange, 2)
         setwindow, root_win
         CONTOUR, img2, xx, yy, levels=levels, /overplot
         itool_copy_to_pix
      END
      'ol_cmp': BEGIN
         WIDGET_CONTROL, /hour
         img2 = image_2nd
         csi2 = csi_2nd
         image = itool_composite(image_arr, csi, img2, csi2, /interlace, /spl)
         setwindow, root_win
         itool_display, image, relative=exptv_rel, csi=csi, /noscale
         itool_disp_plus
         f = concat_dir(GETENV('SSW_SETUP_DATA'), 'color_table.eit')
         IF file_exist(f) THEN xload, file=f, /two ELSE $
            xload, /two
      END
       'ol_int': BEGIN
         WIDGET_CONTROL, /hour
         img2 = image_2nd
         csi2 = csi_2nd
         image = itool_composite(image_arr, csi, img2, csi2, /interlace)
         setwindow, root_win
         itool_display, image, relative=exptv_rel, csi=csi, /noscale
         itool_disp_plus
      END
      ELSE:
   ENDCASE
   RETURN
END

FUNCTION itool_overlayer, parent
@image_tool_com
   ON_ERROR, 2
   mk_dfont, lfont=lfont
   child = WIDGET_BASE(parent, map=0, /column, xpad=5)
   title = WIDGET_LABEL(child, value='Image Tool Overlayer')
   junk = WIDGET_BASE(child, /row, /frame)
   ol_quit = WIDGET_BUTTON(junk, value='Exit', uvalue='ol_quit', font=lfont)
   tmp = WIDGET_BUTTON(junk, value='Overlay', /menu, font=lfont)
   ol_reg_con = WIDGET_BUTTON(tmp, value='Region/Contour', $
                              uvalue='ol_reg_con', font=lfont)
   ol_reg_int = WIDGET_BUTTON(tmp, value='Region/Transparent', $
                              uvalue='ol_reg_int', font=lfont)
   ol_reg_cmp = WIDGET_BUTTON(tmp, value='Region/Composite', $
                              uvalue='ol_reg_cmp', font=lfont)
   ol_reg_add = WIDGET_BUTTON(tmp, value='Region/Addition', $
                              uvalue='ol_reg_add', font=lfont)
   ol_reg_ave = WIDGET_BUTTON(tmp, value='Region/Average', $
                              uvalue='ol_reg_ave', font=lfont)
   ol_reg_rep = WIDGET_BUTTON(tmp, value='Region/Replace', $
                              uvalue='ol_reg_rep', font=lfont)
   ol_con = WIDGET_BUTTON(tmp, value='Full/Contour', $
                           uvalue='ol_con', font=lfont)
   ol_int = WIDGET_BUTTON(tmp, value='Full/Transparent', $
                          uvalue='ol_int', font=lfont)
   ol_cmp = WIDGET_BUTTON(tmp, value='Full/Composite', $
                          uvalue='ol_cmp', font=lfont)
   tmp = WIDGET_LABEL(junk, value='     Align With Base Image', font=lfont)
   tmp = WIDGET_BASE(junk, /nonexclusive)
   tmp = WIDGET_BUTTON(tmp, value='', uvalue='ol_align', font=lfont)
   WIDGET_CONTROL, tmp, set_button=(align_flag EQ 1)
   WIDGET_CONTROL, ol_con, sensitive=(align_flag EQ 0)
   WIDGET_CONTROL, ol_cmp, sensitive=(align_flag EQ 0)
   WIDGET_CONTROL, ol_int, sensitive=(align_flag EQ 0)
   itool_overlay_bt, sensitive=0
   IF N_ELEMENTS(win_2nd) EQ 0 THEN win_2nd = 340
   draw_2nd = WIDGET_DRAW(child, xsize=win_2nd, ysize=win_2nd, /frame, $
                          uvalue='draw_2nd', /button_events)
   ol_text = WIDGET_TEXT(child, value='', font='fixed')
   WINDOW, /free, /pixmap, xsize=win_2nd, ysize=win_2nd
   pix_win_2nd = {xsize:win_2nd, ysize:win_2nd, id:!d.window}

   RETURN, child
END

;---------------------------------------------------------------------------
; End of 'itool_overlayer.pro'.
;---------------------------------------------------------------------------
