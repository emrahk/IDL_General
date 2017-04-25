PRO itool_load_image, image_file, group=group, column=column, $
                      err=err, status=status
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_LOAD_IMAGE
;
; PURPOSE:
;       Load in a FITS or GIF file and try to determine the CSI structure
;
; SYNTAX:
;       itool_load_image, image_file, group=group
;
; INPUTS:
;       IMAGE_FILE -- Name of the image file to be loaded
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;
; KEYWORDS:
;       COLUMN - Column number of data in FITS binary tabel. If passed, it
;                will call CDS_IMAGE to load the image in that column directly
;       GROUP  - ID of the widget that serves as a group leader
;       ERR    - string scalar indicating any error message. A null string
;                is returned if no error occurs
;       STATUS - 0/1, status flag indicating failure/sucess of operation
;
; EFFECT:
;       Following variables in the common blocks are updated: csi,
;          image_arr, cur_min, cur_max, image_min, image_max, header_cur
;
; CATEGORY:
;       Image Tool
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
;       Version 1, January 29, 1997, Liyun Wang, NASA/GSFC.
;          Extracted from image_tool.pro
;       Version 2, June 11, 1997, Liyun Wang, NASA/GSFC
;          Fixed problem of not scaling EIT images if the FITS file
;             does not conform with the SOHO filenaming convention
;	Version 3, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;	Version 4, Zarro (SAC/GSFC), 8-Jun-1998, added TRACE color scaling
;       Version 5, Zarro (SM&A/GSFC), 7-Oct-1999, reversed stack order
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-

@image_tool_com
   ON_ERROR, 2
   err = ''
   status = 1

;---------------------------------------------------------------------------
;  Make sure the image file exists
;---------------------------------------------------------------------------
   IF NOT file_exist(image_file) THEN BEGIN
      err = 'File '+image_file+' not exist!'
      status = 0
      RETURN
   ENDIF

   IF N_ELEMENTS(image_arr) NE 0 AND !version.release GE '3.6.1' THEN BEGIN
;---------------------------------------------------------------------------
;     Save the curreny image status information for stacking
;---------------------------------------------------------------------------

      IF grep('sohologo', prev_file) EQ '' THEN BEGIN
         TVLCT, r, g, b, /get
         rgb = [[r], [g], [b]]
         icon = mk_img_icon(icon_size, image_arr, err=err)
         stack = {prev_file:prev_file, image_arr:image_arr, csi:csi, rgb:rgb, $
                  cur_min:cur_min, cur_max:cur_max, binary_fits:binary_fits, $
                  data_info:data_info, header_cur:header_cur, $
                  exptv_rel:exptv_rel, src_name:src_name, img_type:img_type, $
                  img_lock:img_lock, gif_file:gif_file, $
                  d_mode:d_mode, prev_col:prev_col, log_scaled:log_scaled, $
                  scview:scview,noaa:noaa}
      ENDIF
   ENDIF
;---------------------------------------------------------------------------
;  Test to see if the file to be loaded is already in the image stack
;---------------------------------------------------------------------------
   fname = strip_dirname(image_file)
   IF N_ELEMENTS(column) NE 0 THEN fname = fname+'_'+STRTRIM(column, 2)
   IF N_ELEMENTS(img_icon) NE 0 THEN BEGIN
      id = (WHERE(fname EQ img_icon.filename))(0)
      IF id GE 0 THEN BEGIN
         dprint, 'Switch images from the stack...'
         itool_xchg_stack, id, stack, icon, err=err
         IF err EQ '' THEN BEGIN
            itool_icon_plot
            RETURN
         ENDIF
      ENDIF
   ENDIF
;---------------------------------------------------------------------------
;  Do nothing if the same file is tried to be loaded again
;---------------------------------------------------------------------------
   IF N_ELEMENTS(prev_file) NE 0 THEN BEGIN
      IF image_file EQ prev_file THEN BEGIN
         redo = 0
         IF N_ELEMENTS(column) NE 0 THEN BEGIN
            redo = 1
         ENDIF
         IF NOT redo THEN BEGIN
            itool_refresh
            RETURN
         ENDIF
      ENDIF
   ENDIF

   gif_true = valid_gif(image_file) or valid_jpeg(image_file)
   IF NOT gif_true THEN BEGIN
      itool_rd_fits, image_file, image_arr, header_cur, $
         image_max=image_max, image_min=image_min, data_info=data_info, $
         errmsg=errmsg, group=group, column=column, csi=img_csi, $
         status=status,index=index
      IF NOT status THEN BEGIN
         err = errmsg
         xack,err
         RETURN
      ENDIF
      gif_file = 0
   ENDIF ELSE BEGIN
      itool_rd_gif, image_file, image_arr, minimum=image_min, err=err, $
         maximum=image_max, color=ctable, group=group, $
         status=status, csi=img_csi
      IF NOT status THEN BEGIN
         xack,err
         RETURN
      ENDIF
      header_cur = ''
      data_info = {binary:0, label:'', col:1, cur_col:1}
      gif_file = 1
   ENDELSE

   IF !version.release GE '3.6.1' AND exist(stack) THEN BEGIN
;---------------------------------------------------------------------------
;     Put the current image and related variables into image stack
;---------------------------------------------------------------------------
      n_stack = N_ELEMENTS(img_stack)
      fname = strip_dirname(prev_file)
      IF prev_col NE 0 THEN BEGIN
         fname = fname+'_'+STRTRIM(prev_col, 2)
      ENDIF
      IF n_stack EQ 0 THEN BEGIN
         make_pointer,img_stack
         set_pointer,img_stack,stack
         img_icon = {data:icon, filename:fname}
      ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;        Pop off the last image if more than 12 images already
;---------------------------------------------------------------------------
         IF n_stack EQ max_stack THEN BEGIN
            free_pointer, img_stack(n_stack-1)
            img_stack = img_stack(0:n_stack-2)
            img_icon = img_icon(0:n_stack-2)
         ENDIF
         make_pointer,temp
         set_pointer,temp,stack
         img_stack = [temp,img_stack]
         img_icon = concat_struct({data:icon, filename:fname},img_icon)
      ENDELSE
      itool_update_iconbt
   ENDIF

   prev_file = image_file
   IF N_ELEMENTS(column) NE 0 THEN prev_col = column ELSE prev_col = 0
   disp_utc = anytim2utc(img_csi.date_obs, /ecs)

   IF N_ELEMENTS(data_info) EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     A plain FITS file is read in
;---------------------------------------------------------------------------
      binary_fits = 0
   ENDIF ELSE BEGIN
      IF data_info.binary THEN BEGIN
;---------------------------------------------------------------------------
;        A FITS file with binary table in it is encountered
;---------------------------------------------------------------------------
         binary_fits = 1
         multi_file_button, img_sel_bt, img_sel_show, data_info, $
            uvalue='IMG_SEL_BT'
      ENDIF ELSE binary_fits = 0
   ENDELSE
   cur_max = image_max & cur_min=image_min
   exptv_rel = 1.0
   WIDGET_CONTROL, draw_id, map=1
   IF !d.window NE root_win THEN setwindow, root_win
   csi = itool_new_csi()
   log_scaled = 0
   scview = 0
   IF soho_view() THEN scview = 1

   log_list = ['YOHK', 'MLSO', 'SEIT', 'PDMO']

   src_name = itool_img_src(img_csi.origin)
   img_type = itool_img_type(img_csi.imagtype)
      dprint,'%src_name: ',src_name,img_type
   if (src_name eq 'TRACE') and (strpos(strup(img_type),'WHITE') eq -1) then $
    log_list = [log_list,'STRA']
   IF (grep(img_csi.origin, log_list))(0) NE '' AND gif_file EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     Take logarithmic scale
;---------------------------------------------------------------------------
      done = 0
      IF src_name EQ 'SOHO EIT' THEN BEGIN
;---------------------------------------------------------------------------
;        For SOHO EIT, rescale it and load EIT's color table
;---------------------------------------------------------------------------
         image_arr = itool_eit_scale(temporary(image_arr), header_cur, min_val=cur_min, $
                                 max_val=cur_max,index=index)
         done = 1
      ENDIF

      IF NOT done THEN BEGIN
         dprint, 'Converting to log scale...'
         scl = FLOAT(!d.table_size - 1)/ALOG10(cur_max)
         image_arr = scl*ALOG10((temporary(image_arr) > 1.0) < cur_max)
         
         image_max = MAX(image_arr)
         image_min = MIN(image_arr)
         cur_max = image_max 
         cur_min=image_min
         loadct, 3, /silent
      ENDIF
      log_scaled = 1
   ENDIF ELSE BEGIN
      IF gif_true AND N_ELEMENTS(ctable) NE 0 THEN $
         TVLCT, ctable(*, 0), ctable(*, 1), ctable(*, 2) $
      ELSE BEGIN

         IF src_name EQ 'SOHO EIT' THEN BEGIN
;---------------------------------------------------------------------------
;           For SOHO EIT, rescale it and load EIT's color table
;---------------------------------------------------------------------------
            image_arr = itool_eit_scale(temporary(image_arr), header_cur, min_val=cur_min, $
                                    max_val=cur_max,index=index)
            done = 1
            log_scaled = 1
         ENDIF ELSE IF STRPOS(STRUPCASE(img_type),'MAGNETOGRAM') gt -1  THEN BEGIN
            loadct, 0, /silent
;           chg_ctable, gam=0.3, bot=20, top=55
         ENDIF ELSE if src_name eq 'TRACE' THEN BEGIN
             image_arr=itool_trace_scale(temporary(image_arr),header_cur,$
              log_scaled=log_scaled,min_val=cur_min,max_val=cur_max)
         ENDIF ELSE IF strpos(src_name,'LASCO') gt -1 then BEGIN
             if strpos(img_type,'C1') gt -1 then loadct,8,/silent
             if strpos(img_type,'C2') gt -1 then loadct,3,/silent
             if strpos(img_type,'C3') gt -1 then loadct,1,/silent
         ENDIF ELSE loadct, 3, /silent
      ENDELSE
   ENDELSE
   TVLCT, r, g, b, /get
   rgb = [[r], [g], [b]]
   csi.imagtype=img_csi.imagtype
   csi.origin=img_csi.origin

   itool_display, image_arr, max=cur_max, min=cur_min, relative=exptv_rel, $
      csi=csi
;missing=0
   itool_icon_plot
   itool_adj_ctable, /init

   copy_struct, img_csi, csi

   doy=' (doy '+trim(string(utc2doy(anytim2utc(disp_utc))))+')'
   WIDGET_CONTROL, obs_text, set_value=disp_utc+doy

;    WIDGET_CONTROL, min_id, $
;       set_value=num2str(cur_min, FORMAT='(f20.1)')
;    WIDGET_CONTROL, max_id, $
;       set_value=num2str(cur_max, FORMAT='(f20.1)')
   IF NOT csi.flag THEN BEGIN
;      WIDGET_CONTROL, ptool, sensitive=0
      WIDGET_CONTROL, ptool_send, sensitive=0
      flash_msg, comment_id, $
         ['Warning: This image file does NOT have necessary '+$
          'information to establish a solar coordinate system. '+$
             'Pointing Tool is disabled for this image.', $
          '    To make Pointing Tool available, please use the '+$
          '"Limb Fitter" Tool to fit the solar disc limb.'], $
         num=2
      
      IF tools(curr_tool).uvalue EQ 'ptool' THEN BEGIN
;---------------------------------------------------------------------------
;        Since CSI is not complete for pointing, we have to
;        desensitize the pointing tool
;---------------------------------------------------------------------------
         WIDGET_CONTROL, tools(curr_tool).base, sensitive=0
      ENDIF
   ENDIF
;   IF (csi.crval1 NE 0 OR csi.crval2 NE 0) THEN BEGIN
;---------------------------------------------------------------------------
;     Do not plot gridding lines because solar disk center may not be the
;     reference point
;---------------------------------------------------------------------------      
;   ENDIF

;---------------------------------------------------------------------------
;  Since a new image is loaded in, we have to reset certain things
;---------------------------------------------------------------------------
   IF N_ELEMENTS(initial) NE 0 THEN delvarx, initial
   IF zoom_in EQ 1 THEN BEGIN
      zoom_in = 0
      WIDGET_CONTROL, zoom_bt, set_value='Zoom In'
   ENDIF

   img_lock = 0
   WIDGET_CONTROL, lock_bt, set_value='Lock Orientation'

   itool_disp_plus, /keep
   WIDGET_CONTROL, save_img, sensitive=1
   RETURN
END

