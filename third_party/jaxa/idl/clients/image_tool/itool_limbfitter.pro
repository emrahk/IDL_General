;---------------------------------------------------------------------------
; Document name: itool_limbfitter.pro
; Created by:    Liyun Wang, NASA/GSFC, January 25, 1995
;
; Last Modified: Fri Sep 19 09:33:13 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_LIMBFITTER
;
; PURPOSE:
;       Widget interface of limb-fitter for Image Tool
;
; CALLING SEQUENCE:
;       child = itool_limbfitter(parent)
;
; INPUTS:
;       PARENT - ID of parent widget upon which the limbfit widget is built
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       CHILD  - ID of the base widget being built and leter on remapped
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       FONT   - Font name to be used for labelling
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       LIMB_FITTING - Internal common block used by this routine and
;                      LIMBFIT_EVENT
;       Others       - Included in image_tool_com.pro
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Image Tool
;
; PREVIOUS HISTORY:
;       Written January 25, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, January 25, 1995
;       Version 2, Liyun Wang, NASA/GSFC, February 28, 1995
;          Added elliptical limb fitting option
;       Version 3, Liyun Wang, NASA/GSFC, April 27, 1995
;          Added the FONT keyword
;       Version 4, October 27, 1995, Liyun Wang, NASA/GSFC
;          Modified to cope with the cursor tracking option
;       Version 5, November 2, 1995, Liyun Wang, NASA/GSFC
;          Modified to cope with image icon stacking
;       Version 6, June 11, 1997, Liyun Wang, NASA/GSFC
;          Changed call from CROSS_HAIR to ITOOL_CROSS_HAIR
;
; VERSION:
;       Version 6, June 11, 1997
;-
;
PRO UPDATE_FITLIMB, fit_limb
;----------------------------------------------------------------------
; NAME:
;       UPDATE_FITLIMB
;
; PURPOSE:
;       Updates contents of the limb-fitting widget
;
; EXPLANATION:
;       This routine updates contents of the limb-fitting widget and plot the
;       fitted limb and solar disk center on the displayed image.
;
; CALLING SEQUENCE:
;       update_fitlimb
;
; INPUTS:
;       FIT_LIMB - A structure containing widget IDs and other info set as
;                  UVALUE from MK_LIMBFIT_BS.
; SIDE EFFECTS:
;       A dotted circle and a cross hair is over plotted on displayed image
;----------------------------------------------------------------------
;
@image_tool_com

   COMMON limb_fitting, xpos_fit, ypos_fit, fit_num, f_num, $
      fit_result, fit_xs, fit_ys, fit_xx, fit_yy, ifact

   ON_ERROR, 2
   WIDGET_CONTROL, fit_limb.fitted_x, $
      set_value=num2str(fit_result(0), FORMAT='(f10.2)')
   WIDGET_CONTROL, fit_limb.fitted_y, $
      set_value=num2str(fit_result(1), FORMAT='(f10.2)')
   WIDGET_CONTROL, fit_limb.fitted_ddelt1, $
      set_value=num2str(fit_result(2), FORMAT='(f10.2)')
   WIDGET_CONTROL, fit_limb.fitted_ddelt2, $
      set_value=num2str(fit_result(3), FORMAT='(f10.2)')
   WIDGET_CONTROL, fit_limb.fitted_cdelt1, $
      set_value=num2str(fit_result(4), FORMAT='(f10.2)')
   WIDGET_CONTROL, fit_limb.fitted_cdelt2, $
      set_value=num2str(fit_result(5), FORMAT='(f10.2)')
;----------------------------------------------------------------------
;  Refresh the image plot
;----------------------------------------------------------------------
   IF !d.window NE root_win THEN setwindow, root_win
   itool_display, image_arr, MAX=cur_max, MIN=cur_min, $
      relative=exptv_rel, csi=csi
   IF N_ELEMENTS(xxx) NE 0 THEN delvarx, xxx, yyy

;----------------------------------------------------------------------
;  Plot the fitted circle and its center
;----------------------------------------------------------------------
   dgr = 6.0
   angle = [0.0, !dtor*(dgr*FINDGEN(360.0/dgr)+dgr)]
   rmajor = fit_result(2)/csi.ddelt1
   rminor = fit_result(3)/csi.ddelt2
   temp = cnvt_coord(fit_result(0), fit_result(1), csi=csi, from=2, to=1)
   px = temp(0, 0)+rmajor*COS(angle)
   py = temp(0, 1)+rminor*SIN(angle)
   PLOTS, px, py, /DEVICE, color=l_color, lines=1, noclip=0, $
      clip=[csi.drpix1, csi.drpix2, csi.drpix1+csi.daxis1, $
            csi.drpix2+csi.daxis2]
   itool_copy_to_pix

   itool_cross_hair, temp(0, 0), temp(0, 1), color=l_color, /keep, $
      pixmap=pix_win

   WIDGET_CONTROL, fit_limb.fit_accept, sensitive=1
   WIDGET_CONTROL, comment_id, set_value='The dotted ' + $
      'circle on the image is the fitted limb. Press the Accept ' + $
      'button if you are satisfied.'
   RETURN
END

PRO make_auto_fit
;----------------------------------------------------------------------
; NAME:
;       MAKE_AUTO_FIT
;
; PURPOSE:
;       Interface to procedures of auto limb fitting.
;
; CALLING SEQUENCE:
;       make_auto_fit
;----------------------------------------------------------------------
;
@image_tool_com

   COMMON limb_fitting, xpos_fit, ypos_fit, fit_num, f_num, $
      fit_result, fit_xs, fit_ys, fit_xx, fit_yy, ifact
   ON_ERROR, 2
   limbfit_flag_sv = limbfit_flag
   WIDGET_CONTROL, tools(curr_tool).base, get_uvalue=fit_limb
   limbfit_flag = 3

   WIDGET_CONTROL, fit_limb.fitted_x, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_y, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_ddelt1, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_ddelt2, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_cdelt1, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_cdelt2, set_value=''
;----------------------------------------------------------------------
;  Try with LIMB_INFO
;----------------------------------------------------------------------
   flash_msg, comment_id, $
      'Calling LIMB_INFO to make a try....', num=2, /nobeep
   WIDGET_CONTROL, /hourglass
   limb_info, image_arr, csi.date_obs, x_temp, y_temp, s_temp, r_temp
   IF !err EQ -1 THEN BEGIN
      flash_msg, comment_id, $
         'LIMB_INFO failed. You may want to try semi-auto fitting by '+$
         'selecting enough points around the limb.', $
         num=2
   ENDIF ELSE BEGIN
      csi.flag = 1
      fit_result = FLTARR(6)
      fit_result(0) = x_temp
      fit_result(1) = y_temp
      fit_result(2) = r_temp
      fit_result(3) = r_temp
      fit_result(4) = s_temp
      fit_result(5) = s_temp
      update_fitlimb, fit_limb
   ENDELSE
   limbfit_flag = limbfit_flag_sv
END

PRO make_manual_fit
;----------------------------------------------------------------------
; NAME:
;       MAKE_MANUAL_FIT
;
; PURPOSE:
;       Interface to the manual limb fitting process
;
; CALLING SEQUENCE:
;       make_manual_fit
;
;----------------------------------------------------------------------
;
@image_tool_com

   COMMON limb_fitting, xpos_fit, ypos_fit, fit_num, f_num, $
      fit_result, fit_xs, fit_ys, fit_xx, fit_yy, ifact
   ON_ERROR, 2

   WIDGET_CONTROL, tools(curr_tool).base, get_uvalue=fit_limb
   WIDGET_CONTROL, fit_limb.circle, set_button=1
   limbfit_flag = 1

;   WIDGET_CONTROL, fit_limb.fit_man_bs, map=1
   WIDGET_CONTROL, fit_limb.fit_reset, sensitive=1
   WIDGET_CONTROL, fit_limb.fit_accept, sensitive=0

   xpos_fit = INTARR(50) & ypos_fit=xpos_fit
   fit_num = 10
   f_num = 0
;----------------------------------------------------------------------
;  Get info about the fit_zoom window
;----------------------------------------------------------------------
   old_window = !d.window
   WIDGET_CONTROL, fit_limb.fit_zoom, get_value=z_win
   WSET, z_win
   fit_xs = !d.x_size
   fit_ys = !d.y_size
   fit_xx = INTARR(4)
   fit_yy = fit_xx
   xk = fit_xs/2-1 & yk=fit_ys/2-1
   fit_xx(0) = xk-10
   fit_xx(1) = xk+10
   fit_xx(2) = xk & fit_xx(3)=xk
   fit_yy(0) = yk & fit_yy(1)=yk
   fit_yy(2) = yk-10
   fit_yy(3) = yk+10
   ifact = 4
   WSET, old_window
   WIDGET_CONTROL, fit_limb.fit_sld, sensitive=1
   WIDGET_CONTROL, fit_limb.fit_sld, set_value=fit_num
   reset_limbfit, fit_limb
END

PRO reset_limbfit, fit_limb
;----------------------------------------------------------------------
; NAME:
;       RESET_LIMBFIT
;
; PURPOSE:
;       Reset contents on the limb fit widget base
;
; CALLING SEQUENCE:
;       make_manual_fit
;
; INPUTS:
;       FIT_LIMB - A structure containing widget IDs and other info set as
;                  UVALUE from MK_LIMBFIT_BS.
;----------------------------------------------------------------------
;
@image_tool_com

   COMMON limb_fitting, xpos_fit, ypos_fit, fit_num, f_num, $
      fit_result, fit_xs, fit_ys, fit_xx, fit_yy, ifact
   ON_ERROR, 2
   f_num = 0
   xpos_fit(0:fit_num-1) = 0
   ypos_fit(0:fit_num-1) = 0
   WIDGET_CONTROL, fit_limb.fit_accept, sensitive=0
   WIDGET_CONTROL, fit_limb.fit_n, set_value=''
   WIDGET_CONTROL, fit_limb.fit_xpos, set_value=''
   WIDGET_CONTROL, fit_limb.fit_ypos, set_value=''
   WIDGET_CONTROL, fit_limb.fit_last, set_value=num2str(fit_num-f_num)
   WIDGET_CONTROL, fit_limb.fitted_x, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_y, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_ddelt1, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_ddelt2, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_cdelt1, set_value=''
   WIDGET_CONTROL, fit_limb.fitted_cdelt2, set_value=''
   RETURN
END

PRO limbfit_cleanup
@image_tool_com
   WIDGET_CONTROL, draw_id, draw_motion=track_cursor
   WIDGET_CONTROL, draw_icon, draw_button=1
   limbfit_flag = 0
   itool_overlay_bt
   itool_button_refresh
   itool_refresh
END

PRO LIMBFIT_EVENT, event, uvalue
;----------------------------------------------------------------------
; NAME:
;       LIMBFIT_EVENT
;
; PURPOSE:
;       Event handler for events generated by the limb-fitting base widget
;
; CALLING SEQUENCE:
;       limbfit_event, event, uvalue
;
; INPUTS:
;       EVENT  - The event structure handled by XMANAGER
;       UVALUE - User value from a widget
;----------------------------------------------------------------------
;
@image_tool_com

   COMMON limb_fitting, xpos_fit, ypos_fit, fit_num, f_num, $
      fit_result, fit_xs, fit_ys, fit_xx, fit_yy, ifact

   ON_ERROR, 2

   IF limbfit_flag EQ 0 THEN RETURN

;---------------------------------------------------------------------------
;  Use the rather crude help system for now
;---------------------------------------------------------------------------
   IF help_mode THEN BEGIN
      xshow_help, help_stc, 'LIMB_FITTING', tbase=help_wbase
      RETURN
   ENDIF

   WIDGET_CONTROL, tools(curr_tool).base, get_uvalue=fit_limb
   CASE (uvalue) OF
      'DRAW': BEGIN             ; Event from the draw widget
         IF limbfit_flag EQ 3 THEN RETURN
         cx = event.x & cy=event.y
         cursor_info, cx, cy, txt_id, csi=csi, d_mode=d_mode
;---------------------------------------------------------------------------
;        Plot an enlarged image around the cursor center in a zoom-in window
;---------------------------------------------------------------------------
         xx0 = 0 > (cx-fit_xs/(ifact*2)) ;left edge from center
         yy0 = 0 > (cy-fit_ys/(ifact*2)) ;bottom
         nnx = fit_xs/ifact     ;Size of new image
         nny = fit_ys/ifact
         nnx = nnx < (!d.x_vsize-xx0)
         nny = nny < (!d.y_vsize-yy0)
         xx0 = xx0 < (!d.x_vsize - nnx)
         yy0 = yy0 < (!d.y_vsize - nny)
         a = TVRD(xx0, yy0, nnx, nny) ;Read image
         old_window = !d.window
         WIDGET_CONTROL, fit_limb.fit_zoom, get_value=z_win
         WSET, z_win
         xss = nnx * ifact	;Make integer rebin factors
         yss = nny * ifact
         TV, REBIN(a, xss, yss, sample=1), /dev
         PLOTS, fit_xx(0:1), fit_yy(0:1), /dev
         PLOTS, fit_xx(2:3), fit_yy(2:3), /dev
         WSET, old_window
         IF event.type EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;           Select points around the limb
;---------------------------------------------------------------------------
            IF f_num LT fit_num THEN BEGIN
               itool_cross_hair, cx, cy, color=l_color, /keep, pixmap=pix_win
;----------------------------------------------------------------------
;              xpos_fit and ypos_fit should be converted into data
;              coordinate system (i.e., in data pixels)
;----------------------------------------------------------------------
               temp = cnvt_coord(cx, cy, csi=csi, from=1, to=2)
               xpos_fit(f_num) = temp(0, 0)
               ypos_fit(f_num) = temp(0, 1)
               WIDGET_CONTROL, fit_limb.fit_sld, sensitive=0
               WIDGET_CONTROL, fit_limb.fit_n, $
                  set_value=num2str(f_num+1)
               WIDGET_CONTROL, fit_limb.fit_xpos, $
                  set_value=num2str(xpos_fit(f_num))
               WIDGET_CONTROL, fit_limb.fit_ypos, $
                  set_value=num2str(ypos_fit(f_num))
               WIDGET_CONTROL, fit_limb.fit_last, $
                  set_value=num2str(fit_num-f_num-1)
               f_num = f_num+1
               IF f_num EQ fit_num THEN BEGIN
                  WIDGET_CONTROL, comment_id, /hour, set_value=$
                     'Calling non-lenear least squre fitting routine...'
                  xxx_tmp = FLOAT(xpos_fit(0:fit_num-1))
                  yyy_tmp = FLOAT(ypos_fit(0:fit_num-1))
                  acc = 1.e-6
                  dtx = TRANSPOSE([[xxx_tmp], [yyy_tmp]])
                  sig = FLTARR(fit_num) & dty=sig
                  sig(*) = 1.0
                  dty(*) = 0.0
                  IF limbfit_flag EQ 1 THEN BEGIN
                     b = [271.0, 264.0, 200.0]
                     nl_lsqfit, dtx, dty, sig, b, chisq, acc, funcs=$
                        'funcir'
                     a = [b, b(2)]
                  ENDIF ELSE BEGIN
                     a = [271.0, 264.0, 200.0, 200.0]
                     nl_lsqfit, dtx, dty, sig, a, chisq, acc, funcs=$
                        'ellipse'
                  ENDELSE
;----------------------------------------------------------------------
;                 Get the apparent radius of the solar disc
;----------------------------------------------------------------------
                  angles = pb0r(csi.date_obs)
                  sradius = 60.*angles(2) ; in arcseconds
                  cdelt1 = sradius/a(2)
                  cdelt2 = sradius/a(3)
                  fit_result = [a, cdelt1, cdelt2]
                  update_fitlimb, fit_limb
               ENDIF
            ENDIF
         ENDIF
      END
      'FIT_RESET': BEGIN
         IF !d.window NE root_win THEN setwindow, root_win
         itool_display, image_arr, MAX=cur_max, MIN=cur_min, $
            relative=exptv_rel, csi=csi
         IF N_ELEMENTS(xxx) NE 0 THEN delvarx, xxx, yyy
         fit_num = 10
         WIDGET_CONTROL, fit_limb.fit_sld, sensitive=1
         WIDGET_CONTROL, fit_limb.fit_sld, set_value=fit_num
         reset_limbfit, fit_limb
      END
      'FIT_AUTO': BEGIN
         make_auto_fit
      END

      'fit_circle': limbfit_flag = 1
      'fit_ellipse': limbfit_flag = 2

      'FIT_SLD': BEGIN
         WIDGET_CONTROL, fit_limb.fit_sld, get_value=fit_num
         reset_limbfit, fit_limb
      END
      'FIT_ACCEPT': BEGIN
         WIDGET_CONTROL, comment_id, set_value=''
         csi.crpix1 = fit_result(0)
         csi.crpix2 = fit_result(1)
         csi.crval1 = 0.0
         csi.crval2 = 0.0
         csi.cdelt1 = fit_result(4)
         csi.cdelt2 = fit_result(5)
         csi.flag = 1
         d_mode = 3
         WIDGET_CONTROL, txt_lb, set_value=$
            '(in solar disc coordinate system)'
         itool_switcher, 0
         itool_overlay_bt
         itool_button_refresh
         itool_refresh
      END
      'FIT_CANCEL': BEGIN
         WIDGET_CONTROL, comment_id, set_value=''
         itool_switcher, 0
         itool_button_refresh
         itool_refresh
      END
      ELSE: RETURN
   ENDCASE
END

FUNCTION itool_limbfitter, parent, font=font
;---------------------------------------------------------------------------
;  Main routine
;---------------------------------------------------------------------------
@image_tool_com
   ON_ERROR, 2
   child = WIDGET_BASE(parent, map=0, /column, xpad=10)
   mk_dfont, bfont=bfont, lfont=lfont
   fit_title = WIDGET_LABEL(child, value='Image Tool Limb Fitter')

   temp = WIDGET_BASE(child, /row, /frame, xpad=30)
   fit_reset = WIDGET_BUTTON(temp, value='Reset', uvalue='FIT_RESET')
   fit_cancel = WIDGET_BUTTON(temp, value='Cancel', uvalue='FIT_CANCEL')
   fit_accept = WIDGET_BUTTON(temp, value='Accept', uvalue='FIT_ACCEPT')
   junk = WIDGET_LABEL(temp, value=' ', font=lfont)
   auto_fit = WIDGET_BUTTON(temp, value='Auto Fit', uvalue='FIT_AUTO')

   fit_rslt = WIDGET_BASE(child, /column, /frame, space=-10)
   tmp = WIDGET_LABEL(fit_rslt, value='Results')
   temp = WIDGET_BASE(fit_rslt, /column, xpad=10)
   tmp = WIDGET_BASE(temp, /row)
   xsize = 8
   fitted_x = cw_field(tmp, title=' CRPIX1', xsize=xsize, value=' ', $
                       font=font, fieldfont=font)
   fitted_y = cw_field(tmp, title=' CRPIX2', xsize=xsize, value=' ', $
                       font=font, fieldfont=font)
   tmp = WIDGET_BASE(temp, /row)
   fitted_rx = cw_field(tmp, title='RADIUS1', xsize=xsize, value=' ', $
                        font=font, fieldfont=font)
   fitted_ry = cw_field(tmp, title='RADIUS2', xsize=xsize, value=' ', $
                        font=font, fieldfont=font)

   tmp = WIDGET_BASE(temp, /row)
   fitted_cdelt1 = cw_field(tmp, title=' CDELT1', xsize=xsize, value=' ', $
                         font=font, fieldfont=font)
   fitted_cdelt2 = cw_field(tmp, title=' CDELT2', xsize=xsize, value=' ', $
                         font=font, fieldfont=font)

   fit_man_bs = WIDGET_BASE(child, /column, /frame)

   row = WIDGET_BASE(fit_man_bs, /row)

   temp = WIDGET_BASE(row, /column)
   fit_sld = WIDGET_SLIDER(temp, /drag, maximum=50, minimum=4, $
                           value=10, uvalue='FIT_SLD', font=font)
   fit_tmp = WIDGET_LABEL(temp, value='NUMBER OF POINTS TO USE', $
                          font=font)

   junk = WIDGET_BASE(row, /column, /exclusive, /frame)
   circle = WIDGET_BUTTON(junk, value='as a circle', font=lfont, $
                          uvalue='fit_circle')
   junk1 = WIDGET_BUTTON(junk, value='as an ellipse', font=lfont, $
                         uvalue='fit_ellipse')

   fit_row3 = WIDGET_BASE(fit_man_bs, /row, space=10)

   temp = WIDGET_BASE(fit_row3, /column, /frame)

   tmp = WIDGET_BASE(temp, /row)
   junk = WIDGET_LABEL(tmp, value='    POINT #', font=font)
   fit_n = WIDGET_TEXT(tmp, value='', xsize=2, font=font)

   tmp = WIDGET_BASE(temp, /row)
   fit_xpos = cw_field(tmp, title='X', /row, xsize=4, value=' ', $
                       font=font, fieldfont=font)
   fit_ypos = cw_field(tmp, title='Y', /row, xsize=4, value=' ', $
                       font=font, fieldfont=font)

   tmp = WIDGET_BASE(temp, /row)
   junk = WIDGET_LABEL(tmp, value='', font=font)
   fit_last = WIDGET_TEXT(tmp, value='', font=font, xsize=2)
   junk = WIDGET_LABEL(tmp, value='POINTS TO GO', font=font)

   fit_zoom = WIDGET_DRAW(fit_row3, xsize=130, ysize=130)
   fit_limb = {fit_limb, fit_xpos:fit_xpos, fit_ypos:fit_ypos, fit_n:fit_n, $
               fit_last:fit_last, fit_sld:fit_sld, fit_zoom:fit_zoom, $
               fitted_x:fitted_x, fitted_y:fitted_y, fitted_ddelt1:fitted_rx, $
               fitted_ddelt2:fitted_ry, fitted_cdelt1:fitted_cdelt1, $
               fitted_cdelt2:fitted_cdelt2, fit_accept:fit_accept, $
               fit_title:fit_title, fit_man_bs:fit_man_bs, $
               fit_reset:fit_reset, circle:circle}

;---------------------------------------------------------------------------
;  Save widget IDs and other info into the UVALUE of base CHILD as a structure
;---------------------------------------------------------------------------
   WIDGET_CONTROL, child, set_uvalue=fit_limb
   RETURN, child
END

;---------------------------------------------------------------------------
; End of 'itool_limbfitter.pro'.
;---------------------------------------------------------------------------
