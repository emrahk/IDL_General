;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       IMAGE_TOOL_EVENT
;
; PURPOSE:
;       Event handler of image tool
;
; CATEGORY:
;       image tool
;
; EXPLANATION:
;
; SYNTAX:
;       image_tool_event, event
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
;       @image_tool_com, cross_hair
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
;       Version 2, February 11, 1997, Liyun Wang, NASA/GSFC
;          Implemented following options: 1) to spawn an image window
;          and to quit with image window retained; 2) to rotate points
;          on central meridian
;       Version 3, March 6, 1997, Liyun Wang, NASA/GSFC
;          Implemented differential rotation indicator for any constant
;             longitudinal points and points at the same Solar X value
;       Version 4, March 20, 1997, Liyun Wang, NASA/GSFC
;          Modified not to refresh image window after receiving a new study
;       Version 5, April 1, 1997, Liyun Wang, NASA/GSFC
;          Allowed OBS_TIME field to be editable
;       Version 6, April 15, 1997, Liyun Wang, NASA/GSFC
;          Called XGET_SYNOPTIC with current OBS_TIME
;       Version 7, June 12, 1997, Liyun Wang, NASA/GSFC
;          Changed call from CROSS_HAIR to ITOOL_CROSS_HAIR
;	Version 8, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;	Version 9, Zarro (SM&A/GSFC), 7 Oct 1999, changed stack order such
;               that last viewed image is at bottom of stack
;	Version 10, T. Kucera, GSFC, 2 Apr. 2001, converted from GIF to JPEG
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
PRO itool_xchg_stack, id, stack, icon, err=err
;---------------------------------------------------------------------------
;  Routine to exchange the displayed image and one from the image stack
;---------------------------------------------------------------------------
@image_tool_com
   COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
   err = ''

   IF valid_pointer(img_stack(id)) THEN BEGIN
      WIDGET_CONTROL, comment_id, set_value=''
;---------------------------------------------------------------------------
;     Replace image icon name
;---------------------------------------------------------------------------
      tname = strip_dirname(stack.prev_file)
      IF stack.prev_col NE 0 THEN tname = tname+'_'+STRTRIM(stack.prev_col, 2)
      img_icon(id).filename = tname
      WIDGET_CONTROL, bt4icon(id), set_value=tname
      old_stack=get_pointer(img_stack(id))
;---------------------------------------------------------------------------
;     Restore old information back (notice that tag names are the same as
;     those variable names saved in common block)
;---------------------------------------------------------------------------
      names = TAG_NAMES(old_stack)
      FOR i=0, N_ELEMENTS(names)-1 DO BEGIN
         state = names(i)+'='+'old_stack.('+STRTRIM(STRING(i, '(i2)'), 2)+')'
         s = EXECUTE(state)
      ENDFOR
      disp_utc = anytim2utc(csi.date_obs, /ecs)
      set_pointer,img_stack(id), stack
      img_icon(id).data = icon

;-- fix so that exchanged image moves to bottom of stack

      nstack=n_elements(img_stack)
      if nstack gt 1 then begin
       index=indgen(nstack)
       ok=where(id ne index,count)
       if count gt 0 then begin
        nindex=[index(ok),id]
        img_icon=img_icon(nindex)
        img_stack=img_stack(nindex)
        bt4icon= bt4icon(nindex)
        itool_update_iconbt
       endif
      endif

      IF scview EQ 1 THEN use_soho_view ELSE use_earth_view
      IF show_src THEN $
         WIDGET_CONTROL, src_text, set_value=src_name $
      ELSE $
         WIDGET_CONTROL, src_text, set_value=img_type
      itool_refresh
      WIDGET_CONTROL, txt_id, set_value=''
      can_zoom = 0

      TVLCT, rgb(*, 0), rgb(*, 1), rgb(*, 2)
;---------------------------------------------------------------------------
;     Save current color table in common
;---------------------------------------------------------------------------
      r_orig = rgb(*, 0)
      g_orig = rgb(*, 1)
      b_orig = rgb(*, 2)
      itool_adj_ctable, /init
;---------------------------------------------------------------------------
;     Unmark selected icon image
;---------------------------------------------------------------------------
      itool_mark_icon, id, /remove
      WIDGET_CONTROL, rm_stack, sensitive=0
      WIDGET_CONTROL, ptool_peek, sensitive=0
;---------------------------------------------------------------------------
;     Rebuild the multi-image button for FITS images in binary table
;---------------------------------------------------------------------------
      IF data_info.binary EQ 1 THEN BEGIN
         multi_file_button, img_sel_bt, img_sel_show, data_info, $
            uvalue='IMG_SEL_BT'
      ENDIF
      junk = grep('ptool', tools.uvalue, index=pt_bs)
      IF NOT csi.flag THEN BEGIN
         flash_msg, comment_id, $
         ['Warning: This image file does NOT have necessary '+$
          'information to establish a solar coordinate system. '+$
             'Pointing Tool is disabled for this image.', $
          '    To make Pointing Tool available, please use the '+$
          '"Limb Fitter" Tool to fit the solar disc limb.'], $
            num=2
         WIDGET_CONTROL, tools(pt_bs).base, sensitive=0
         WIDGET_CONTROL, point_wid.point_go, sensitive=0
         IF tools(curr_tool).uvalue EQ 'ptool' THEN BEGIN
            xack, ['Solar coordinate system has not been established for',$
                   'this image. Pointing Tool is therefore disabled. To', $
                   'activate the Pointing Tool, you need to pick an image',$
                   'from the stack for which the solar coordinate system', $
                   'has been established, or run Limb Fitter to establish',$
                   'the solar coordinate system.'], /modal
         ENDIF
      ENDIF ELSE BEGIN
         WIDGET_CONTROL, point_wid.point_go, sensitive=1
         WIDGET_CONTROL, tools(pt_bs).base, sensitive=1
      ENDELSE
   ENDIF ELSE BEGIN
      err = 'Invalid handle ID!'
      MESSAGE, err, /cont
   ENDELSE
   RETURN
END

PRO image_tool_event, event
@image_tool_com
   ON_ERROR, 2
   status = 0

   IF event.id EQ messenger THEN BEGIN
;---------------------------------------------------------------------------
;     Event created from planning tool
;---------------------------------------------------------------------------
      WIDGET_CONTROL, messenger, get_uvalue=point_stc
      IF NOT match_struct(pointing_stc, point_stc) THEN BEGIN
         IF xanswer(['Message from IMAGE_TOOL:', $
                     'New pointing structure received. Accept it?'], $
                    group=event.top, /center, /beep) THEN BEGIN
            delvarx, pointing_stc
            pointing_stc = point_stc
;---------------------------------------------------------------------------
;           PT_FOV_RESET is a routine defined in mk_point_base
;---------------------------------------------------------------------------
            pt_fov_reset, pointing_stc, widgets=point_wid
            tai_start = pointing_stc.date_obs
            study_utc = tai2utc(tai_start, /ecs, /trunc)
            WIDGET_CONTROL, start_text, set_value=study_utc
            WIDGET_CONTROL, event.top, /map, /show
            IF N_ELEMENTS(rgb) NE 0 THEN TVLCT, rgb(*, 0), rgb(*, 1), rgb(*, 2)
         ENDIF
      ENDIF
      RETURN
   ENDIF

   WIDGET_CONTROL, event.id, get_uvalue=uvalue

   IF N_ELEMENTS(uvalue) NE 0 THEN BEGIN
      IF uvalue(0) EQ 'ctb_draw' THEN BEGIN
         itool_adj_ctable, event
         RETURN
      ENDIF
      IF uvalue(0) EQ 'UT_UPDATE' THEN BEGIN
;---------------------------------------------------------------------------
;        This is a timer event. It is generated only for IDL v3.6 and up
;---------------------------------------------------------------------------
         get_utc, curr_ut, /ecs
         WIDGET_CONTROL, event.top, $
            tlb_set_title=tool_title+STRMID(curr_ut, 0, 19)+' GMT'
         WIDGET_CONTROL, event.top, timer=DOUBLE(ut_delay)
         RETURN
      ENDIF

;---------------------------------------------------------------------------
;     Deal with events when in help mode
;---------------------------------------------------------------------------
      IF help_mode THEN BEGIN
         image_tool_hlp, uvalue
         RETURN
      ENDIF
   ENDIF

;---------------------------------------------------------------------------
;  The rest part requires a valid UVALUE
;---------------------------------------------------------------------------
   IF N_ELEMENTS(uvalue) EQ 0 THEN RETURN
   uvalue = uvalue(0)

;---------------------------------------------------------------------------
;  Tool switching
;---------------------------------------------------------------------------
   junk = grep(uvalue, tools.uvalue, /exact, index=index)
   IF index(0) GE 0 THEN BEGIN
      IF index(0) EQ curr_tool THEN RETURN
      itool_switcher, index(0)
   ENDIF

   CASE (tools(curr_tool).uvalue) OF
;---------------------------------------------------------------------------
;     Handles events from different tools
;---------------------------------------------------------------------------
      'pftool': BEGIN
       if widg_type(event.id) ne 'DRAW' then begin
         itool_pickfile_event, event, outfile=d_file, status=status
         IF status EQ 1 THEN BEGIN
            src_name_new = 'Unspecified'
            GOTO, load_file
         ENDIF
       ENDIF
      END
      'overlay': itool_overlayer_event, event
      'ptool': pt_ptool_event, event, uvalue
      'lftool': limbfit_event, event, uvalue
      ELSE:
   ENDCASE

;---------------------------------------------------------------------------
;  Deal with loading the old images. This should be accessible only
;  for IDL 3.6.1 and up
;---------------------------------------------------------------------------
   IF grep('OLD_IMG', uvalue) NE '' THEN BEGIN
      itool_restore, /full
      icon = mk_img_icon(icon_size, image_arr)
      stack = {prev_file:prev_file, image_arr:image_arr, csi:csi, rgb:rgb, $
               cur_min:cur_min, cur_max:cur_max, binary_fits:binary_fits, $
               data_info:data_info, header_cur:header_cur, $
               exptv_rel:exptv_rel, src_name:src_name, img_type:img_type, $
               img_lock:img_lock, gif_file:gif_file, $
               d_mode:d_mode, prev_col:prev_col, log_scaled:log_scaled, $
               scview:scview,noaa:noaa}
      id = FIX(STRMID(uvalue, 7, 2))
      itool_xchg_stack, id, stack, icon
      itool_icon_plot
      RETURN
   ENDIF

   IF uvalue EQ 'QUIT2' THEN BEGIN
      WINDOW, xsize=win_xs, ysize=win_ys, /free
      win_id = !d.window
      itool_refresh, win_id=win_id
      uvalue = 'QUIT'
   ENDIF

;---------------------------------------------------------------------------
;  Get study running time from start_text widget
;---------------------------------------------------------------------------
   IF uvalue NE 'DRAW' THEN BEGIN
      WIDGET_CONTROL, start_text, get_value=temp
      error = ''
      tt = anytim2utc(temp(0), /ecs, /trunc, errmsg=error)
      IF has_error(error, prefix='Invalid value in OBS TIME field.') THEN RETURN
      tai_start = utc2tai(tt)
      WIDGET_CONTROL, start_text, set_value=tt
   ENDIF

   CASE (uvalue) OF
      'contour': BEGIN
         irange = MAX(image_arr)-MIN(image_arr)
         imax = MAX(image_arr)-0.02*irange
         irange = irange/10.0
         levels = ROTATE(imax-FINDGEN(clevel)*irange, 2)
         IF csi.flag EQ 1 THEN BEGIN
            itool_xy, csi, xx=xx, yy=yy, /vector
         ENDIF ELSE BEGIN
            xx = INDGEN(csi.naxis1)
            yy = INDGEN(csi.naxis2)
         ENDELSE
         CONTOUR, image_arr, xx, yy, levels=levels, /overplot
         itool_copy_to_pix
      END
      'clevel': BEGIN
         xhour
         value_old = clevel
         xset_value, value_old, max=10, min=2, status=status, group=event.top,$
            title='Set Contour Level', $
            instruct='Choose a value between 2 and 10:'
         IF status EQ 1 THEN BEGIN
            IF value_old GT 10 OR value_old LT 2 THEN BEGIN
               xack, 'Contour level out of range.', group=event.tpo
               RETURN
            ENDIF
            clevel = value_old
         ENDIF 
         RETURN
      END
      'xload': BEGIN
         xhour
         f = concat_dir(GETENV('SSW_SETUP_DATA'), 'color_table.eit')
         IF file_exist(f) THEN xload, file=f, group=event.top ELSE $
            xload, group=event.top 
      END
     'xdoc': BEGIN
         xhour
         xdoc, group=event.top
      END
      'recover': BEGIN
         IF !d.window NE root_win THEN setwindow, root_win
         IF N_ELEMENTS(rgb) NE 0 THEN TVLCT, rgb(*, 0), rgb(*, 1), rgb(*, 2)
      END
      'win_dump_ps': BEGIN
         get_utc, curr_ut, /ecs
         wtitle = tool_title+STRMID(curr_ut, 0, 19)+' GMT'
         WIDGET_CONTROL, event.top, tlb_set_title=wtitle
         CALL_PROCEDURE, 'win_dump', event.top, wtitle, error=error, /ps
         RETURN
      END
      'win_dump_jpeg': BEGIN
         get_utc, curr_ut, /ecs
         wtitle = tool_title+STRMID(curr_ut, 0, 19)+' GMT'
         junk = 'itool_window.jpg'
         xinput, junk, 'Enter output JPEG filename', group=event.top, /modal, $
            status=status
         IF status EQ 0 THEN RETURN
         WIDGET_CONTROL, event.top, tlb_set_title=wtitle
         CALL_PROCEDURE, 'win_dump', event.top, wtitle, file=junk, error=error
         RETURN
      END
      'ptool_fov': BEGIN
         IF fov_flag EQ 1 THEN BEGIN
            fov_flag = 0
            WIDGET_CONTROL, ptool_fov, set_value='Show Fixed Field of View'
         ENDIF ELSE BEGIN
            fov_flag = 1
            WIDGET_CONTROL, ptool_fov, set_value='Hide Fixed Field of View'
         ENDELSE
         itool_refresh
      END
      'draw_icon': BEGIN
         itool_draw_icon, event
         RETURN
      END

      'flush_stack': begin
        free_pointer,img_stack
        delvarx, img_stack, img_icon
        delvarx, id_prev
        free_pointer,img_handle
        delvarx, img_handle
        
        WIDGET_CONTROL, rm_stack, sensitive=0
        itool_update_iconbt
        itool_icon_plot 
       end

      'rm_stack': BEGIN
;---------------------------------------------------------------------------
;        Remove image from the icon stack (but NOT from Overlayer!)
;---------------------------------------------------------------------------
         n_stack = N_ELEMENTS(img_stack)
         IF N_ELEMENTS(icon_id) EQ 0 OR n_stack EQ 0 THEN RETURN
         xhour
         idx = INDGEN(n_stack)
         ii = WHERE(idx NE icon_id, count)
         IF count GT 0 THEN BEGIN
            HANDLE_FREE, img_stack(icon_id)
            img_stack = img_stack(ii)
            img_icon = img_icon(ii)
            n_stack = N_ELEMENTS(img_stack)
         ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;           No more icons left on stack
;---------------------------------------------------------------------------
            delvarx, img_stack, img_icon
         ENDELSE
         delvarx, id_prev
         WIDGET_CONTROL, rm_stack, sensitive=0
         itool_update_iconbt
         itool_icon_plot
      END

      'QUIT': BEGIN
         IF tools(curr_tool).uvalue EQ 'ptool' AND NOT exit_ok THEN BEGIN
            exit_ok = xanswer(['Warning!!!', $
                               'Not all pointing values are changed.', $
                               'Do you wish to quit Pointing Tool any way?'], $
                              /beep, group=event.top, /center,/suppress)
         ENDIF ELSE exit_ok = 1
         IF exit_ok THEN BEGIN
            itool_RESTORE, /full
            delvarx, id_prev, px_icon, py_icon
;---------------------------------------------------------------------------
;           Reset text and list widgets to avoid bad font problem
;---------------------------------------------------------------------------
            xtext_reset, [set_lat, set_LONG, rot_text, start_text, src_text, $
                          obs_text, txt_id, comment_id]
;            WIDGET_CONTROL, site_list, set_value=sources.name

;---------------------------------------------------------------------------
;           Trigger an event in Planning Tool for it to handle the possiblly
;           changed pointing structure
;---------------------------------------------------------------------------
            IF WIDGET_INFO(pointing_stc.messenger, /valid) THEN $
               WIDGET_CONTROL, pointing_stc.messenger, timer=1.0, $
               set_uvalue=pointing_stc
            xkill, event.top
            RETURN
         ENDIF
      END
      'write_fits': BEGIN
         break_file, data_file, dlog, dir, fname
         CD, curr=curr_dir
         temp = concat_dir(curr_dir, fname+'.fts')
         xinput, temp, 'Enter FITS file name', group=event.top, /modal, $
            status=status
         IF status EQ 0 THEN RETURN
         xhour
         itool_write_fits, temp, image_arr, csi=csi, err=err
         IF err NE '' THEN xtext, err, group=event.top, /just_reg, WAIT=2
         RETURN
      END
      'modify_fh': BEGIN
         IF xanswer('FITS header will be modified. Are you sure?', $
                    /beep, group=event.top, /center) THEN BEGIN
            itool_write_fits, data_file, image_arr, header_cur, csi=csi, $
               err=err, /modify
            IF err NE '' THEN xtext, err, group=event.top, /just_reg, WAIT=2
         ENDIF
         RETURN
      END
      'CURSOR_POS': BEGIN
         WIDGET_CONTROL, txt_id, get_value=line
         pos_str = str2arr(line(0), ',', /nomult)
         IF N_ELEMENTS(pos_str) NE 2 THEN BEGIN
            pos_str = str2arr(line(0), ' ', /nomult)
            IF N_ELEMENTS(pos_str) NE 2 THEN BEGIN
               WIDGET_CONTROL, comment_id, set_value=$
                  'Two numbers are needed!'
               RETURN
            ENDIF
         ENDIF
         IF NOT valid_num(pos_str(0), v1) OR $
            NOT valid_num(pos_str(1), v2) THEN BEGIN
            WIDGET_CONTROL, comment_id, set_value=$
               'Invalid number!'
            RETURN
         ENDIF
         pos = [[FLOAT(v1)], [FLOAT(v2)]]
         IF d_mode NE 1 THEN $
            pos = cnvt_coord(pos, csi=csi, from=d_mode, to=1, date=disp_utc)
         itool_cross_hair, pos(0, 0), pos(0, 1), cursor_wid, cursor_ht, $
            cursor_unit, csi=csi, color=l_color, boxed_cursor=boxed_cursor, $
            pixmap=pix_win, /keep
      END
      'new_window': BEGIN
         break_file, data_file, a1, a2, fname, ext, version, node
         tmp = WIDGET_BASE(title=fname+ext,group=event.top)
         draw_id = WIDGET_DRAW(tmp, ysize=win_ys, xsize=win_xs, retain=2)
         WIDGET_CONTROL, tmp, /realize
         WIDGET_CONTROL, draw_id, get_value=win_id
         itool_refresh, win_id=win_id
      END
      'REFRESH': BEGIN
         itool_refresh
         IF N_ELEMENTS(rgb) NE 0 THEN TVLCT, rgb(*, 0), rgb(*, 1), rgb(*, 2)
      END
      'about': BEGIN
         xhour
         msg = ['The SOHO Image Tool was  developed primarily by  Liyun Wang',$
                '(Liyun.Wang@gsfc.nasa.gov) of NASA/GSFC for the joint Solar',$
                'and Heliospheric Observatory project between NASA and ESA.']
         xack, msg, group=event.top, space=3, inst='OK', $
            title='About Image Tool'
      END
      'HELP': BEGIN
         xhour
         widg_help, 'image_tool', title='IMAGE_TOOL HELP', sep_char='~', $
            font='9x15bold', /modal, group=event.top, subtopic='Overview',$
            /hierarchy
         RETURN
      END
      'HELP_ONLINE': BEGIN
;---------------------------------------------------------------------------
;        Turn on help mode
;---------------------------------------------------------------------------
         IF N_ELEMENTS(help_stc) EQ 0 THEN BEGIN
            xhour
            help_stc = mk_help_stc('image_tool', sep_char='~')
         ENDIF
         help_mode = 1
         WIDGET_CONTROL, draw_id, draw_motion=0
         text = ['`f0`You are now in ONLINE HELP mode', $
                 '(To turn it off, press Online Help button)']
         fonts = ['-adobe-helvetica-bold-r-*-*-30-240-*-*-*-*-*-*']
         disp_txt, text, fonts, 65, ystart=320, xstart=320, def_just=0.5
         DEVICE, font='6x13'
         xshow_help, help_stc, 'OVERVIEW', tbase=help_wbase, $
            group=event.top, font='9x15bold'
      END
      'IMG_SEL_BT': BEGIN
;---------------------------------------------------------------------------
;        This event concerns only FITS files with binary table
;---------------------------------------------------------------------------
         ii = (WHERE(img_sel_show EQ event.id))(0)
         col = data_info.col(ii)
         xhour
         itool_load_image, prev_file, group=event.top, err=err, $
            column=col
         IF err NE '' THEN RETURN
         img_type = data_info.label(ii)
      END
      'img_info': BEGIN
         IF NOT csi.flag THEN BEGIN
            popup_msg, ['drpix1 = '+num2str(csi.drpix1)+$
                        ', drpix2 = '+num2str(csi.drpix2), $
                        'daxis1 = '+num2str(csi.daxis1)+$
                        ', daxis2 = '+num2str(csi.daxis2), $
                        'naxis1 = '+num2str(csi.naxis1)+$
                        ', naxis2 = '+num2str(csi.naxis2)], space=1, $
               title='Image Info', group=event.top
         ENDIF ELSE BEGIN
            popup_msg, ['drpix1 = '+num2str(csi.drpix1)+$
                        ', drpix2 = '+num2str(csi.drpix2), $
                        'daxis1 = '+num2str(csi.daxis1)+$
                        ', daxis2 = '+num2str(csi.daxis2), $
                        'naxis1 = '+num2str(csi.naxis1)+$
                        ', naxis2 = '+num2str(csi.naxis2), $
                        'crpix1 = '+num2str(csi.crpix1, FORMAT='(f10.2)')+$
                        ', crpix2 = '+num2str(csi.crpix2, FORMAT='(f10.2)'), $
                        'crval1 = '+num2str(csi.crval1, FORMAT='(f10.2)')+$
                        ', crval2 = '+num2str(csi.crval2, FORMAT='(f10.2)'), $
                        'cdelt1 = '+num2str(csi.cdelt1, FORMAT='(f10.2)')+$
                        ', cdelt2 = '+num2str(csi.cdelt2, FORMAT='(f10.2)')], $
               space=1, title='Image Info', group=event.top
;----------------------------------------------------------------------
;           Plot a circle around the disc and its center
;----------------------------------------------------------------------
            dgr = 6.0
            angle = [0.0, !dtor*(dgr*FINDGEN(360.0/dgr)+dgr)]
            angles = pb0r(disp_utc)
            sradius = 60.*angles(2)
            rmajor = (sradius/csi.cdelt1)/csi.ddelt1
            rminor = (sradius/csi.cdelt2)/csi.ddelt2
            temp = cnvt_coord(csi.crpix1, csi.crpix2, csi=csi, from=2, to=1)
            px = temp(0, 0)+rmajor*COS(angle)
            py = temp(0, 1)+rminor*SIN(angle)
            PLOTS, px, py, /DEVICE, color=l_color, lines=1, $
               noclip=0, clip=[csi.drpix1, csi.drpix2, csi.drpix2+csi.daxis1, $
                               csi.drpix2+csi.daxis2]
            itool_cross_hair, temp(0), temp(1), color=l_color, /keep, $
               boxed_cursor=0, pixmap=pix_win
         ENDELSE
      END
      'HEADER': BEGIN           ;Show header of the FITS file
         xhour
         xtext, header_cur, title='FITS Header', group=event.top, /modal
      END
      'SHOW_CSI': BEGIN
         xhour
         xstruct, csi, title='Coordinate System Info Structure', $
            group=event.top
      END

      'NOAA': begin        
        if noaa eq 1 then noaa=0 else noaa=1
        widget_control,noaa_bt,set_button=noaa
        itool_refresh
       end

      'GRID': BEGIN
         IF grid EQ 1 THEN $
            grid = 0 $
         ELSE $
            grid = 1
         WIDGET_CONTROL, grid_bt, set_button=grid
         itool_refresh
      END
      'del_lat': BEGIN
         WIDGET_CONTROL, event.id, get_value=str_lat
         del_lat = ABS(FIX(str_lat(0)))
         WIDGET_CONTROL, set_lat, set_value=$
            num2str(del_lat, FORMAT='(i3)')
         WIDGET_CONTROL, set_long, /input_focus
         IF grid EQ 0 THEN grid = 1
         itool_refresh
      END
      'del_long': BEGIN
         WIDGET_CONTROL, event.id, get_value=str_long
         del_long = ABS(FIX(str_long(0)))
         WIDGET_CONTROL, set_long, set_value=$
            num2str(del_long, FORMAT='(i3)')
         WIDGET_CONTROL, set_lat, /input_focus
         IF grid EQ 0 THEN grid = 1
         itool_refresh
      END
      'cursor': BEGIN
         IF boxed_cursor THEN BEGIN
            boxed_cursor = 0
         ENDIF ELSE BEGIN
            boxed_cursor = 1
            IF N_ELEMENTS(pointing_stc) NE 0 THEN BEGIN
               IF pointing_stc.do_pointing EQ 1 AND csi.flag THEN BEGIN
                  cursor_wid = pointing_stc.pointings(0).width
                  cursor_ht = pointing_stc.pointings(0).height
                  cursor_unit = 3
               ENDIF
            ENDIF
            IF N_ELEMENTS(cursor_wid) EQ 0 THEN BEGIN
               cursor_wid = 30
               cursor_ht = 30
               cursor_unit = 1
            ENDIF
         ENDELSE
      END
      'cursor_track': BEGIN
         IF track_cursor THEN BEGIN
            track_cursor = 0
         ENDIF ELSE BEGIN
            track_cursor = 1
         ENDELSE
         WIDGET_CONTROL, draw_id, draw_motion=track_cursor
      END
      'cursor_color': BEGIN
         temp = l_color
         xset_color, temp, title='Set Cursor Color', group=event.top
         IF temp NE l_color THEN BEGIN
            l_color = temp
         ENDIF
      END
      'cursor_size': BEGIN
         set_cursor_size, cursor_wid, cursor_ht, cursor_unit, csi=csi, $
            status=status
      END
      'exptv': BEGIN
         old_exptv = FLOAT(exptv_rel)
         xset_value, old_exptv, MIN=0.1, MAX=1.0, group=event.top
         IF old_exptv NE exptv_rel THEN BEGIN
            exptv_rel = old_exptv
            itool_refresh
         ENDIF
      END
      'img_lock': BEGIN
         IF img_lock THEN BEGIN
            img_lock = 0
;            grid = 0
         ENDIF ELSE BEGIN
            img_lock = 1
            orient_mark, csi=csi
         ENDELSE
         itool_refresh
      END
      'rotate_img': BEGIN
;---------------------------------------------------------------------------
;        Rotate the image 180 degrees
;---------------------------------------------------------------------------
         image_arr = ROTATE(TEMPORARY(image_arr), 2)
         IF !d.window NE root_win THEN setwindow, root_win
         IF csi.flag THEN BEGIN
            sx = FIX(csi.ddelt1*csi.daxis1)
            sy = FIX(csi.ddelt2*csi.daxis2)
            csi.crpix1 = sx-1-csi.crpix1
            csi.crpix2 = sy-1-csi.crpix2
            IF img_lock THEN BEGIN
               csi.cdelt1 = -csi.cdelt1
               csi.cdelt2 = -csi.cdelt2
            ENDIF
         ENDIF
         itool_refresh
      END
      'rotate_img45': BEGIN
;---------------------------------------------------------------------------
;        Rotate the image 45 degrees counter clockwise
;---------------------------------------------------------------------------
         xhour
         image_arr = rot(TEMPORARY(image_arr), -45.0, 1, csi.crpix1, $
                         csi.crpix2, /pivot, /interp, missing=0)
         itool_refresh
      END
      'rotate_img45n': BEGIN
;---------------------------------------------------------------------------
;        Rotate the image 45 degrees clockwise
;---------------------------------------------------------------------------
         xhour
         image_arr = rot(TEMPORARY(image_arr), 45.0, 1, csi.crpix1, $
                         csi.crpix2, /pivot, /interp, missing=0)
         itool_refresh
      END
      'rotate_img90': BEGIN
;---------------------------------------------------------------------------
;        Rotate the image 90 degrees
;---------------------------------------------------------------------------
         image_arr = ROTATE(TEMPORARY(image_arr), 1)
         IF !d.window NE root_win THEN setwindow, root_win
         IF csi.flag THEN BEGIN
            sy = FIX(csi.ddelt1*csi.daxis1)
            sx = FIX(csi.ddelt2*csi.daxis2)
            tmp = csi.crpix1
            csi.crpix1 = sy-1-csi.crpix2
            csi.crpix2 = tmp
            IF img_lock THEN BEGIN
               csi.cdelt1 = csi.cdelt2
               csi.cdelt2 = -csi.cdelt1
            ENDIF
         ENDIF
         itool_refresh
      END
      'rvs_img': BEGIN
         image_arr = reverse(TEMPORARY(image_arr))
         IF !d.window NE root_win THEN setwindow, root_win
         IF csi.flag THEN BEGIN
            sx = FIX(csi.ddelt1*csi.daxis1)
            csi.crpix1 = sx-1-csi.crpix1
            IF img_lock THEN csi.cdelt1 = -csi.cdelt1
         ENDIF
         itool_refresh
      END
      'flip_img': BEGIN
         image_arr = reverse(ROTATE(TEMPORARY(image_arr), 2))
         IF !d.window NE root_win THEN setwindow, root_win
         IF csi.flag THEN BEGIN
            sy = FIX(csi.ddelt2*csi.daxis2)
            csi.crpix2 = sy-1-csi.crpix2
            IF img_lock THEN csi.cdelt2 = -csi.cdelt2
         ENDIF
         itool_refresh
      END
      'hist_img': BEGIN
         new_image = hist_equal(image_arr, minv=cur_min, maxv=cur_max)
         IF !d.window NE root_win THEN setwindow, root_win
         itool_display, new_image, relative=exptv_rel, csi=csi
         itool_disp_plus
      END
      'log_scale': BEGIN
         scl = FLOAT(!d.table_size - 1)/ALOG10(cur_max)
         permanent = xanswer('Do you want to make it a permanent change?', $
                             /beep, group=event.top)
         xhour
         IF permanent THEN BEGIN
            image_arr = scl*ALOG10((TEMPORARY(image_arr) > 1.0) < cur_max)
            cur_max = MAX(image_arr)
            cur_min = MIN(image_arr)
            itool_display, image_arr, MAX=cur_max, MIN=cur_min, $
               relative=exptv_rel, csi=csi
            log_scaled = 1
            WIDGET_CONTROL, log_scale, sensitive=0
         ENDIF ELSE BEGIN
            new_image = scl*ALOG10((image_arr > 1.0) < cur_max)
            max_val = MAX(new_image)
            min_val = MIN(new_image)
            itool_display, new_image, MAX=max_val, MIN=min_val, $
               relative=exptv_rel, csi=csi
         ENDELSE
         itool_disp_plus
      END
      'sobel': BEGIN
         new_image = SOBEL(image_arr)
         IF !d.window NE root_win THEN setwindow, root_win
         itool_display, new_image, MAX=cur_max, MIN=cur_min, $
            relative=exptv_rel, csi=csi
         itool_disp_plus
      END
      'smooth': BEGIN
         new_image = SMOOTH(image_arr, 3)
         IF !d.window NE root_win THEN setwindow, root_win
         itool_display, new_image, MAX=cur_max, MIN=cur_min, $
            relative=exptv_rel, csi=csi
         itool_disp_plus
      END
      'sig_img': BEGIN
         new_image = image_arr
         new_image = sigrange(TEMPORARY(new_image))
         IF !d.window NE root_win THEN setwindow, root_win
         itool_display, new_image, MAX=cur_max, MIN=cur_min, $
            relative=exptv_rel, csi=csi
         itool_disp_plus
      END
      'PS_FORMAT': BEGIN
         xps_setup, ps_stc, group=event.top, status=status
         IF status THEN BEGIN
            xhour
            ps, ps_stc.filename, color=ps_stc.color, copy=ps_stc.copy, $
               encapsulated=ps_stc.encapsulated, $
               INTERPOLATE=ps_stc.interpolate, portrait=ps_stc.portrait
            itool_display, image_arr, MAX=cur_max, MIN=cur_min, $
               relative=exptv_rel, csi=csi
            itool_disp_plus, color=0, /keep
            IF ps_stc.hard THEN BEGIN
               psplot, delete=ps_stc.delete, queue=ps_stc.printer
               popup_msg, 'Plot has been sent to printer '+$
                  ps_stc.printer+'.', group=event.top
            ENDIF ELSE BEGIN
               psclose
               CD, current=curr_path
               full_name = concat_dir(curr_path, ps_stc.filename)
               popup_msg, 'Plot saved to PS file: '+full_name, $
                  group=event.top
            ENDELSE
         ENDIF
      END

      'save_jpeg': BEGIN
         break_file, data_file, a1, a2, fname, ext, version, node
         jpeg_filename = fname+'.jpg'
         xinput, jpeg_filename, 'Enter JPEG filename', $
          status=status,group=event.top, /modal
         if status eq 0 then return
         IF jpeg_filename EQ '' THEN jpeg_filename = 'image_tool.jpg'
         saveimage,jpeg_filename,/jpeg,quality=100
         popup_msg, 'Image saved in '+jpeg_filename, group=event.top
      END


      'save_jpeg2': BEGIN
         break_file, data_file, a1, a2, fname, ext, version, node
         jpeg_filename = fname+'.jpg'
         xinput, jpeg_filename, 'Enter JPEG filename', $
          status=status,group=event.top, /modal
         if status eq 0 then return
         IF jpeg_filename EQ '' THEN jpeg_filename = 'image_tool.jpg'
         x2jpeg,jpeg_filename
         popup_msg, 'Image saved in '+jpeg_filename, group=event.top
      END

      'save_ps': BEGIN
         break_file, data_file, a1, a2, fname, ext, version, node
         ps_filename = fname+'.ps'
         x2ps, ps_filename, win=root_win
         popup_msg, 'Image saved in '+ps_filename, group=event.top
      END
;----------------------------------------------------------------------
;     Following is for the pull-down menu "Zooming"
;----------------------------------------------------------------------
      'zoom_in_out': BEGIN
         xhour
         itool_zoominout, event
      END
      'zoom_2': BEGIN           ; Zooming with original resolution
         IF !d.window NE root_win THEN setwindow, root_win
         tvzoom2, image_arr, MIN=cur_min, MAX=cur_max, /continuous, $
            group=event.top, title='Fancy Magnifier'
      END
;----------------------------------------------------------------------
;     Following are for the pull-down menu "Change System Variable"
;----------------------------------------------------------------------
      'p_color': BEGIN
         temp = !p.color
         xset_color, temp, title='Set !P.Color', group=event.top
         IF temp NE !p.color THEN BEGIN
            !p.color = temp
            itool_refresh
         ENDIF
      END
      'p_bg': BEGIN
         temp = !p.background
         xset_color, temp, title='Set !P.Background', group=event.top
         IF temp NE !p.background THEN BEGIN
            !p.background = temp
            itool_refresh
         ENDIF
      END
      'p_cs': BEGIN
         temp = !p.charsize
         xset_value, temp, MAX=5.0, title='Set !P.CharSize', group=event.top
         IF temp NE !p.charsize THEN BEGIN
            !p.charsize = temp
            itool_refresh
         ENDIF
      END
      'p_ct': BEGIN
         temp = !p.charthick
         xset_value, temp, MAX=5.0, title='Set !P.CharThick', group=event.top
         IF temp NE !p.charthick THEN BEGIN
            !p.charthick = temp
            itool_refresh
         ENDIF
      END
      'p_tick': BEGIN
         temp = !p.ticklen
         xset_value, temp, MIN=-1.0, MAX=1.0, title='Set !P.TickLen', $
            group=event.top
         IF temp NE !p.ticklen THEN BEGIN
            !p.ticklen = temp
            itool_refresh
         ENDIF
      END
;----------------------------------------------------------------------
;     Following are for the pull-down menu button "Cursor Position"
;----------------------------------------------------------------------
      'mode_1': BEGIN
         d_mode = 1
         WIDGET_CONTROL, txt_lb, $
            set_value='(in device coordinate system)'
      END
      'mode_2': BEGIN
         d_mode = 2
         WIDGET_CONTROL, txt_lb, $
            set_value='(in image pixel coordinate system)'
      END
      'mode_3': BEGIN
         d_mode = 3
         WIDGET_CONTROL, txt_lb, $
            set_value='(in solar disc coordinate system)'
      END
      'mode_4': BEGIN
         d_mode = 4
         WIDGET_CONTROL, txt_lb, $
            set_value='(in heliographic coordinate sys)'
      END
;----------------------------------------------------------------------
;     Following are for the pull-down menu "Set Limits"
;----------------------------------------------------------------------
      'min_v': BEGIN
         value_old = cur_min
         loop = 1
         WHILE loop DO BEGIN
            xset_value, cur_min, MAX=image_max, MIN=image_min, $
               title='Set Minimum Value', group=event.top
            IF cur_min GT cur_max THEN BEGIN
               flash_msg, comment_id, 'Minimum value cannot be set ' + $
                  'greater than the maximum value.', num=2
               WAIT, 1.0
               WIDGET_CONTROL, comment_id, set_value=''
               cur_min = value_old
            ENDIF ELSE loop = 0
         END
         IF (cur_min NE value_old) THEN itool_refresh
      END
      'max_v': BEGIN
         value_old = cur_max
         loop = 1
         WHILE loop DO BEGIN
            xset_value, cur_max, MAX=image_max, MIN=image_min, $
               title='Set Maximum Value', group=event.top
            IF cur_max LT cur_min THEN BEGIN
               flash_msg, comment_id, 'Maximum value cannot be set ' + $
                  'smaller than the minimum value.', num=2
               WAIT, 1.0
               WIDGET_CONTROL, comment_id, set_value=''
               cur_max = value_old
            ENDIF ELSE loop = 0
         END
         IF (cur_max NE value_old) THEN itool_refresh
      END
      'reset_limits': BEGIN     ; Reset min/max values and redraw the screen
         cur_max = image_max & cur_min=image_min
         itool_refresh
      END
;       'SET_MIN': BEGIN          ; Minimum value set from the keyboard
;          value_old = cur_min
;          loop = 1
;          WHILE loop DO BEGIN
;             WIDGET_CONTROL, event.id, get_value=str_min
;             cur_min = FLOAT(str_min(0))
;             IF cur_min GT cur_max THEN BEGIN
;                flash_msg, comment_id, 'Minimum value cannot be set ' + $
;                   'greater than the maximum value.', num=2
;                WAIT, 1.0
;                WIDGET_CONTROL, comment_id, set_value=''
;                cur_min = value_old
;             ENDIF ELSE loop = 0
;          END
;          IF (cur_min NE value_old) THEN BEGIN
;             WIDGET_CONTROL, max_id, /input_focus
;             itool_refresh
;          ENDIF
;       END
;       'SET_MAX': BEGIN          ; Maximum value set from the keyboard
;          value_old = cur_max
;          loop = 1
;          WHILE loop DO BEGIN
;             WIDGET_CONTROL, event.id, get_value=str_max
;             cur_max = FLOAT(str_max(0))
;             IF cur_max LT cur_min THEN BEGIN
;                flash_msg, comment_id, 'Maximum value cannot be set ' + $
;                   'smaller than the minimum value.', num=2
;                WAIT, 1.0
;                WIDGET_CONTROL, comment_id, set_value=''
;                cur_max = value_old
;             ENDIF ELSE loop = 0
;          END
;          IF (cur_max NE value_old) THEN BEGIN
;             WIDGET_CONTROL, min_id, /input_focus
;             itool_refresh
;          ENDIF
;       END
      'any_study': BEGIN
         tt = xget_utc(tai2utc(tai_start), group=event.top, /ecs, $
                       /center, error=error, /trunc)
         IF has_error(error) THEN RETURN
         tai_start = utc2tai(tt)
         WIDGET_CONTROL, start_text, set_value=tt
      END
      'study_start': BEGIN
         tt = study_utc
         tai_start = utc2tai(study_utc)
         WIDGET_CONTROL, start_text, set_value=tt
      END
      'mdi_view': BEGIN
         IF mdi_view EQ 0 THEN $
            mdi_view = 1 $
         ELSE $
            mdi_view = 0
         itool_refresh
      END
      'sc_view': BEGIN
         r1 = 60.0*DOUBLE((pb0r(csi.date_obs))(2))
         orbit_info = (GETENV('ANCIL_DATA') NE '')
         IF orbit_info THEN $
            orbit_info = chk_dir(concat_dir('$ANCIL_DATA', 'orbit', /dir))
         IF soho_view() THEN BEGIN
            IF NOT orbit_info THEN BEGIN
               ans = xanswer(['Warning: No SOHO orbit information is available.', $
                              'There will be no way to switch point of view back', $
                              'if you do so. Do you still want to make the switch?'], $
                             group=event.top)
               IF NOT ans THEN BEGIN
                  WIDGET_CONTROL, sc_view, set_button=1
                  RETURN
               ENDIF
            ENDIF
            use_earth_view
            scview = 0
         ENDIF ELSE BEGIN
            IF NOT orbit_info THEN BEGIN
               xack, ['No SOHO orbit file(s) available.', $
                      'Point of view cannot be switched.'], group=event.top, $
                  /modal
               WIDGET_CONTROL, sc_view, set_button=0
               RETURN
            ENDIF
            use_soho_view
            scview = 1
         ENDELSE
         xhour
         csi.radius = 60.0*(pb0r(csi.date_obs))(2)
         r2 = DOUBLE(csi.radius)/r1
         csi.cdelt1 = r2*csi.cdelt1
         csi.cdelt2 = r2*csi.cdelt2
         itool_refresh
         help,zoom_in
      END
      'img_time': BEGIN
         disp_utc = anytim2utc(csi.date_obs, /ecs, /trunc)
         doy=' (doy '+trim(string(utc2doy(disp_utc)))+')'
         WIDGET_CONTROL, obs_text, set_value=disp_utc+doy
      END
      'disp_time': BEGIN
         tt = xget_utc(disp_utc, group=event.top, /ecs, $
                       /center, error=error, /trunc)
         IF has_error(error) THEN RETURN
         disp_utc = tt
         doy=' (doy '+trim(string(utc2doy(disp_utc)))+')'
         WIDGET_CONTROL, obs_text, set_value=disp_utc+doy
      END
;----------------------------------------------------------------------
;     Following is for rotation in time
;----------------------------------------------------------------------
      'forward': BEGIN
         rot_dir = 1
         time_gap = ABS(time_gap)
      END
      'backward': BEGIN
         rot_dir = -1
         time_gap = -1.*ABS(time_gap)
      END
      'TIME_GAP': BEGIN         ; Set rotation time interval from the keyboard
         WIDGET_CONTROL, event.id, get_value=time_gap_str
         time_gap = FLOAT(time_gap_str(0))*rot_unit
         update_rot_button
         time_gap = rot_dir*ABS(time_gap)
      END
      'src_title': BEGIN
         IF event.index EQ 0 THEN BEGIN
            show_src = 1
            WIDGET_CONTROL, src_text, set_value=src_name
         ENDIF ELSE BEGIN
            show_src = 0
            WIDGET_CONTROL, src_text, set_value=img_type
         ENDELSE
      END
      'ROT_UNIT': BEGIN
         IF event.index EQ 0 THEN rot_unit = 1.0 ELSE rot_unit = 1.0/24.0
         update_rot_button
      END
      'rot_now': BEGIN
         time_gap = (tai_start-utc2tai(disp_utc))/86400.0
         update_rot_button
      END
      'rot_1pt': itool_disp_rot, 1
      'rot_longi': itool_disp_rot, 2
      'rot_solarx': itool_disp_rot, 3
      'rot_meridian': itool_disp_rot, 4
      'rot_limb': itool_disp_rot, 5
      'rot_reg': BEGIN
         WIDGET_CONTROL, comment_id, set_value=''
         xhour
         temp = itool_select_img(image_arr, csi, xzoom, yzoom, dbox=dbox, $
                                 error=error, /ibox)
         IF has_error(error) THEN RETURN
         inside = itool_inside_limb(temp(*, 0), temp(*, 1), csi=csi, index=idx)
         IF idx(0) EQ -1 THEN BEGIN
            xack, 'No points inside the limb selected.', /modal
            RETURN
         ENDIF
         temp = temp(idx, *)
         dtemp = cnvt_coord(temp, from=2, to=1, csi=csi)
         itool_restore_pix, pix_win
         PLOTS, dtemp(*, 0), dtemp(*, 1), /dev, linestyle=1, $
            color=!d.table_size-1, thick=2
         temp = cnvt_coord(temp, from=2, to=3, csi=csi)
         temp = rot_xy(temp(*, 0), temp(*, 1), time_gap*86400.0, index=index)
         IF index(0) EQ -1 THEN BEGIN
            xack, 'All points are rotated off the limb!', /modal
            RETURN
         ENDIF
         temp = temp(index, *)
         PLOTS, temp(*, 0), temp(*, 1), /data, color=!d.table_size-1, linestyle=2
         itool_copy_to_pix
      END
      'rot_regmap': BEGIN
         WIDGET_CONTROL, comment_id, set_value='Just a second...'
         xhour
         temp = itool_select_img(image_arr, csi, xzoom, yzoom, dbox=dbox, $
                                 error=error, /ibox)
         IF has_error(error) THEN RETURN
         csi2 = csi
         img2= itool_select_img(image_arr, csi2, xzoom, yzoom, /modify, $
                                error=error)
         IF has_error(error) THEN RETURN
         img2 = itool_diff_rot(img2, csi2, new_csi=ncsi, $
                               newtime=(utc2tai(csi2.date_obs)+$
                                        time_gap*86400.0), error=error)
         IF has_error(error) THEN RETURN
         csi2 = ncsi

         itool_img_match, img2, csi2, csi=csi
         image = itool_composite(image_arr, csi, img2, csi2, /replace)
         itool_display, image, relative=exptv_rel, csi=csi, /noscale
         PLOTS, dbox(*, 0), dbox(*, 1), /dev, color=!d.table_size-1, $
            linestyle=1, thick=2
         itool_disp_plus         
         WIDGET_CONTROL, comment_id, set_value=''
;          IF itool_inside_limb(temp(*, 0), temp(*, 1), csi=csi) EQ 0 THEN BEGIN
;             msg = 'The rectangular area you choose must be completely '+$
;                'within the limb!'
;             flash_msg, comment_id, msg, num=3
;             RETURN
;          ENDIF
;          WIDGET_CONTROL, comment_id, set_value=$
;             'Making differential rotation... Please wait for a moment.'
;          xhour
;          rot_subimage, image_arr, new_image, time_gap, disp_utc, $
;             xrange, yrange, csi=csi, status=status
;          IF status EQ 0 THEN RETURN
;          IF !d.window NE root_win THEN setwindow, root_win
;          itool_display, new_image, MAX=cur_max, MIN=cur_min, $
;             relative=exptv_rel, csi=csi
;          PLOTS, dbox(*, 0), dbox(*, 1), /dev, color=FIX(0.9*(!d.table_size-1))

;          temp = cnvt_coord(temp, csi=csi, from=2, to=4, $
;                            date=disp_utc, off_limb=offlimb)
;          temp(*, 1) = temp(*, 1)+diff_rot(time_gap, temp(*, 0), /synodic)
; ;----------------------------------------------------------------------
; ;        When converting rotated point(s) back, new time should be used
; ;----------------------------------------------------------------------
;          msec = LONG(time_gap*8640000.0) ; in milliseconds
;          cur_time = anytim2utc(disp_utc)
;          cur_time.time = cur_time.time+msec(0)
;          new_date = anytim2utc(cur_time, /external)
;          temp = cnvt_coord(temp, csi=csi, from=4, to=1, date=new_date)
;          PLOTS, temp(*, 0), temp(*, 1), /dev, color=!d.table_size-1
;          itool_disp_plus, /keep
      END
      'rot_img': BEGIN
         IF NOT xanswer(['This operation can be very time consuming.',$
                     'Do you want to proceed?'], group=event.top) THEN RETURN
         WIDGET_CONTROL, comment_id, $
            set_value='Please standby while I am working...'
         xhour
;---------------------------------------------------------------------------
;        Reduce number of image pixels first
;---------------------------------------------------------------------------
         smax = 512
         ncsi = csi
         image = image_arr
         IF MAX([csi.naxis1, csi.naxis2]) GT smax THEN BEGIN 
            IF csi.naxis1 GT csi.naxis2 THEN BEGIN
               xy = FLOAT(csi.naxis2)/FLOAT(csi.naxis1)
               sx = smax
               sy = smax*xy
            ENDIF ELSE BEGIN
               xy = FLOAT(csi.naxis1)/FLOAT(csi.naxis2)
               sy = smax
               sx = smax*xy
            ENDELSE
            cval = cnvt_coord(1, 1, from=2, to=3, csi=csi)
            ncsi.naxis1 = sx
            ncsi.naxis2 = sy
            ncsi.cdelt1 = csi.cdelt1*FLOAT(csi.naxis1)/FLOAT(ncsi.naxis1)
            ncsi.cdelt2 = csi.cdelt2*FLOAT(csi.naxis2)/FLOAT(ncsi.naxis2)
            ncsi.crpix1 = 1
            ncsi.crpix2 = 1
            ncsi.crval1 = cval(0, 0)
            ncsi.crval2 = cval(0, 1)
            image = congrid(TEMPORARY(image), sx, sy)
         ENDIF
         map = itool2map(TEMPORARY(image), csi=ncsi, error=error)
         IF has_error(error) THEN RETURN
         rmap = drot_map(map, time_gap, /days, missing=0.0)
         image = itool2map(TEMPORARY(rmap), csi=ncsi, /reverse, error=error)
         IF has_error(error) THEN RETURN
         itool_display, image, relative=exptv_rel, csi=ncsi
         itool_disp_plus, alt_csi=ncsi
         WIDGET_CONTROL, comment_id, set_value=''
      END
      'DRAW': BEGIN
         itool_draw, event
         RETURN                 ; Don't go through button refresh
      END
      'pickfile': BEGIN
         d_file = itool_pickfile(group=group, /modal, status=status)
         IF status EQ 0 THEN RETURN
         GOTO, load_file
      END
      ELSE: RETURN
   ENDCASE
   IF WIDGET_INFO(event.top, /valid) THEN BEGIN
      itool_button_refresh
   ENDIF

   RETURN

;----------------------------------------------------------------------
;  Load image data here. Severval things have to be reset for a new image
;----------------------------------------------------------------------
load_file:
   WIDGET_CONTROL, comment_id, set_value=''
   IF STRTRIM(d_file, 2) EQ '' THEN BEGIN
      flash_msg, comment_id, 'No new image is loaded.', num=2
      IF N_ELEMENTS(src_num_sv) NE 0 THEN source_num = src_num_sv
      RETURN
   ENDIF
   data_file = d_file
   xhour

   itool_restore

   itool_load_image, data_file, group=event.top, err=err, status=status

   IF NOT status THEN BEGIN
      MESSAGE, err, /cont
      flash_msg, comment_id, 'No new image is loaded.', num=2
      RETURN
   ENDIF

   IF NOT csi.flag THEN BEGIN
      d_mode = 2
      WIDGET_CONTROL, txt_lb, set_value='(in image pixel coordinate system)'
;---------------------------------------------------------------------------
;     Reset size of the boxed-cursor
;---------------------------------------------------------------------------
      cursor_wid = 30
      cursor_ht = 30
      cursor_unit = 1
   ENDIF ELSE BEGIN
      d_mode = 3
      WIDGET_CONTROL, txt_lb, set_value=$
         '(in solar disc coordinate system)'
      IF grid THEN itool_solar_grid, del_lat, del_long, date=disp_utc

   ENDELSE
;   WIDGET_CONTROL, min_id, set_value=num2str(cur_min, FORMAT='(f20.1)')
;   WIDGET_CONTROL, max_id, set_value=num2str(cur_max, FORMAT='(f20.1)')
   itool_button_refresh
   RETURN
END


