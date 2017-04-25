;+
; PROJECT:
;       SOHO
;
; NAME:
;       IMAGE_TOOL
;
; PURPOSE:
;       User interface of SOHO Pointing Tool and synoptic/summary database
;
; CALLING SEQUENCE:
;       IMAGE_TOOL [, fits_file] [, point_stc=point_stc] [, start=start]
;                  [, min=min, max=max] [, /reset] [, group=group] [,/modal]
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       FITS_FILE -- String scalar or array, list of FITS image files
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       POINT_STC -- If present, it has to be a pointing structure that has
;                    the following tags:
;
;          INSTRUME   - Code specifying the instrument; e.g., 'C' for CDS
;          G_LABEL    - Generic label for the pointing; e.g., 'RASTER'
;          X_LABEL    - Label for X coordinate of pointing; e.g., 'INS_X'
;          Y_LABEL    - Label for Y coordinate of pointing; e.g., 'INS_Y'
;          DATE_OBS   - Date/time of beginning of observation, in TAI format
;          N_POINTINGS- Number of pointings to be performed by IMAGE_TOOL
;          POINTINGS  - An array (with N_POINTINGS elements) of pointings to
;                       be handled by IMAGE_TOOL. It has the following tags:
;
;                       POINT_ID - A string scalar for pointing ID
;                       INS_X    - X coordinate of pointing area center in arcs
;                       INS_Y    - Y coordinate of pointing area center in arcs
;                       WIDTH    - Area width (E/W extent)  in arcsec
;                       HEIGHT   - Area height (N/S extent) in arcsec
;                       OFF_LIMB - An interger with value 1 or 0 indicating
;                                  whether or not the pointing area should
;                                  be off limb
;
;          N_RASTERS  - Number of rasters for each pointing (this is
;                       irrelevant to the SUMER)
;          RASTERS    - A array (N_RASTERS-element) of structure that
;                       contains raster size and pointing information
;                       (this is irrelevant to the SUMER). It has the
;                       following tags:
;
;                       POINTING - Pointing handling code; valid
;                                  values are: 1, 0, and -1
;                       INS_X    - Together with INS_Y, the pointing to use
;                                  when user-supplied values are not
;                                  allowed.  Only valid when POINTING=0
;                                  (absolute) or POINTING=-1 (relative to
;                                  1st raster).
;                       INS_Y    - ...
;                       WIDTH    - Width (E/W extent) of the raster, in arcs
;                       HEIGHT   - Height (N/S extent) of the raster, in arcs
;
;          Note that values of POINT_STC structure can be returned to the
;          caller of IMAGE_TOOL if the MODAL kyeword is set, or it is returned
;          as a UVALUE of a massenger of a calling widget.
;
;       AUTO_PLOT - Keyword used with POINT_STC. When Image Tool (and
;                   Pointing Tool) is running and is called again with a new
;                   POINT_STC and with AUTO_PLOT set, the
;                   corresponding pointing area(s) will be plotted
;                   automatically.
;
;       START -- Start time of a study, in TAI format; defaults to
;                current date and time. Note: If POINT_STC is passed
;                in and POINT_STC.DATE_OBS represents a valid TAI,
;                START will be overwritten by POINT_STC.DATE_OBS.
;       MIN   -- Minimum value of the image
;       MAX   -- Maximum value of the image
;       GROUP -- ID of the widget which serves as a group leader
;       MODAL -- Set this keyword to make IMAGE_TOOL a blocking widget program
;       RESET -- If set, all images saved in image stack will be removed
;       FOV   -- A field of view (FOV) structure having the following tags:
;
;                X - array, X coordinates of the FOV, in arcsecs
;                Y - array, Y coordinates of the FOV, in arcsecs
;
; COMMON BLOCKS:
;       @IMAGE_TOOL_COM, CROSS_HAIR
;
; RESTRICTIONS:
;       Cannot be run two copies simultaneously (guaranteed by the call to
;       'XREGISTERED')
;
; SIDE EFFECTS:
;       IDL color table may be changed or modified
;
; CATEGORY:
;       Image processing, science planning
;
; PREVIOUS HISTORY:
;       Written August 29, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       See image_tool.log
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-

;---------------------------------------------------------------------------
;  Real routines start here
;---------------------------------------------------------------------------
PRO multi_file_button, parent, ids, data_info, uvalue=uvalue, force=force
;---------------------------------------------------------------------------
; INPUTS:
;      PARENT - ID of the menu widget_button under which a submenu is
;               constructed
;      IDS    - IDs of previous submenu buttons, long integer vector;
;               modified upon exit
;      DATA_INFO - A structure containing data information. It has the
;                  following tags:
;
;                  COL     - Integer vector that indicates all column
;                            numbers for the data
;                  LABEL   - String vector showing the label of data in
;                            each column
;                  CUR_COL - Current column of data being read
;
;      UVALUE    - Uvalue to be set
; OUTPUTS:
;      IDS    - New IDs of submenu buttons
;
; KEYWORDS:
;      FORCE  - Set this keyword to force building the multi-file button
;---------------------------------------------------------------------------
   COMMON mf_button, prev_data_info

   IF N_ELEMENTS(prev_data_info) NE 0 AND N_ELEMENTS(ids) NE 0 THEN $
      done=match_struct(data_info, prev_data_info, exclude='CUR_COL') $
   ELSE done = 0
   IF done EQ 1 AND KEYWORD_SET(force) THEN done = 0

   IF done EQ 1 THEN BEGIN
      WIDGET_CONTROL, parent, sensitive=1
      RETURN
   ENDIF

   IF N_ELEMENTS(ids) NE 0 THEN BEGIN
      FOR i=0, N_ELEMENTS(ids)-1 DO BEGIN
         IF WIDGET_INFO(ids(i), /valid) THEN $
            xkill, ids(i)
      ENDFOR
   ENDIF
   IF data_info.binary EQ 1 THEN BEGIN
      i_num = N_ELEMENTS(data_info.label)
      ids = LONARR(i_num)
      FOR i=0, i_num-1 DO BEGIN
         ids(i) = WIDGET_BUTTON(parent, uvalue=uvalue, $
                                value=num2str(data_info.col(i))+$
                                ': '+data_info.label(i))
      ENDFOR
   ENDIF
   prev_data_info = data_info
   RETURN
END


PRO itool_display, image, MAX=cur_max, MIN=cur_min, relative=relative, $
                   _extra=_extra, csi=csi
;---------------------------------------------------------------------------
;  Note: CSI can be modified by this routine
;---------------------------------------------------------------------------
   noexact = (relative NE 1.0)
   
   if strpos(csi.origin,'EIT') gt -1 then begin
    eit_sys
    sys_var=float(csi.imagtype)
    wave_len=float([304,195,284,171])
    chk=where(sys_var eq wave_len,count)
    if count gt 0 then begin
     s=execute('sys_col=!'+trim(sys_var))
     cmax=!d.table_size-1
     cur_min=byte(0 > sys_col.lo < cmax)
     cur_max=byte(0 > sys_col.hi < cmax)
     dprint,'% type, limits: ',sys_var,' ',cur_min,' ',cur_max
    endif
   endif

   exptv, image, MAX=cur_max, MIN=cur_min, relative=relative, $
      noexact=noexact, xalign=0.65, yalign=0.8, _extra=_extra

   get_tv_scale, sx, sy, daxis1, daxis2, jx, jy
   rx = FLOAT(sx)/FLOAT(daxis1)
   ry = FLOAT(sy)/FLOAT(daxis2)
   temp = {drpix1:jx, drpix2:jy, daxis1:daxis1, daxis2:daxis2, $
           ddelt1:rx, ddelt2:ry}
   copy_struct, temp, csi
END

PRO itool_disp_plus, keep=keep, color=color, alt_csi=alt_csi
;---------------------------------------------------------------------------
;  After calling itool_display, there might be other things like axes,
;  grids, etc., needed to be plotted. This routine does just that
;---------------------------------------------------------------------------
@image_tool_com
   IF N_ELEMENTS(alt_csi) EQ 0 THEN alt_csi = csi
   IF alt_csi.flag THEN itool_plot_axes, csi=alt_csi, $
      title=['Solar X', 'Solar Y']
   widget_control,set_lat,get_value=temp
   if is_number(temp(0)) then begin
    temp_lat=nint(temp(0))
    if temp_lat ne del_lat then begin
     del_lat=temp_lat
     widget_control,set_lat,set_value=string(del_lat,'(i3)')
    endif
   endif
   widget_control,set_long,get_value=temp
   if is_number(temp(0)) then begin
    temp_long=nint(temp(0))
    if temp_long ne del_long then begin
     del_long=temp_long
     widget_control,set_long,set_value=string(del_long,'(i3)')
    endif
   endif

   IF N_ELEMENTS(color) EQ 0 THEN BEGIN
      if alt_csi.flag then begin
       IF grid THEN itool_solar_grid, del_lat, del_long, date=disp_utc
       if noaa then itool_noaa,disp_utc
      endif
      IF img_lock THEN orient_mark, csi=alt_csi
   ENDIF ELSE BEGIN
      if alt_csi.flag then begin
       IF grid THEN $
         itool_solar_grid, del_lat, del_long, date=disp_utc, color=color
       if noaa then itool_noaa,disp_utc
      endif
      IF img_lock THEN orient_mark, csi=alt_csi, color=color
   ENDELSE

   IF N_ELEMENTS(fov_stc) NE 0 AND fov_flag EQ 1 THEN BEGIN
      temp = cnvt_coord([[fov_stc.x], [fov_stc.y]], csi=alt_csi, from=3, to=1)
      PLOTS, temp(*, 0), temp(*, 1), /dev
   ENDIF
   IF mdi_view EQ 1 AND alt_csi.flag THEN BEGIN
      xx = [-300, 320, 320, -300, -300]
      yy = [-188, -188, 432, 432, -188]
;
;  If SOHO is upside-down, then flip the MDI field of view.
;
      sc_roll=getenv('SOHO_ORIENT')
      if is_blank(sc_roll) then sc_roll=get_soho_roll(csi.date_obs)
      if fix(sc_roll) eq 180 then begin
          xx = -xx
          yy = -yy
      endif
      temp = cnvt_coord([[xx], [yy]], csi=alt_csi, from=3, to=1)
      PLOTS, temp(*, 0), temp(*, 1), /dev, noclip=0, linestyle=3
   ENDIF
   itool_copy_to_pix
END

;--------------------------------------------------------------------------
pro itool_noaa,time   ;-- overlay NOAA info

common itool_noaa,last_time,last_nar
err=''
one_day=24.*3600.
new_read=1

;-- bail out on bad time inputs

dtime=anytim2tai(time,err=err)
if err ne '' then return

;-- bail out if !path doesn't have RD_NAR

if not have_proc('get_nar') then begin
 xack,['NOAA Active Region coordinates information unavailable ',$
        'in current software environment.'],/suppress
 return
endif

;-- don't re-read if time hasn't changed by more than a 1/2 day

old_read=exist(last_time) and (datatype(last_nar) eq 'STC')
if old_read then begin
 diff=abs(last_time-dtime)
 if diff lt one_day/2. then begin
  new_read=0 & nar=last_nar & count=n_elements(last_nar)
 endif
endif

;-- read here

if new_read then begin
 dprint,'% ITOOL_NOAA: reading NOAA DB'
 nar=call_function('get_nar',dtime,count=count,/nearest,/unique)
 if count gt 0 then begin
  last_nar=nar & last_time=dtime
 endif
endif

;-- have to rotate pointings to time of image

noaa_mess='NOAA Active Region coordinates unavailable for current time'
if count gt 0 then rnar=call_function('drot_nar',nar,dtime,count=count) else $
 xack,noaa_mess,/suppress

;-- plot here

if count gt 0 then $
 oplot_nar,rnar,charsize=2,font=0,charthick=1.5,color=!d.table_size-1 else $
  xack,noaa_mess,/suppress

return & end

;-------------------------------------------------------------------------

PRO itool_refresh, win_id=win_id
;---------------------------------------------------------------------------
; Refresh the draw widget
;---------------------------------------------------------------------------
@image_tool_com
   IF N_ELEMENTS(win_id) EQ 0 THEN win_id = root_win
   setwindow, win_id
   xhour
   itool_display, image_arr, MAX=cur_max, MIN=cur_min, $
      relative=exptv_rel, csi=csi
   itool_disp_plus
;   WIDGET_CONTROL, min_id, set_value=num2str(cur_min, FORMAT='(f20.1)')
;   WIDGET_CONTROL, max_id, set_value=num2str(cur_max, FORMAT='(f20.1)')
   WIDGET_CONTROL, comment_id, set_value=''
   itool_button_refresh
   WIDGET_CONTROL, rot_longi_bt, sensitive=1
   WIDGET_CONTROL, rot_solarx_bt, sensitive=1
   WIDGET_CONTROL, rot_1pt_bt, sensitive=1
   RETURN
END

PRO itool_icon_plot
;---------------------------------------------------------------------------
;  Plot image icons in the secondary graphic window
;---------------------------------------------------------------------------
@image_tool_com
   setwindow, icon_win
   ERASE
   n_icons = N_ELEMENTS(img_icon)
   IF n_icons NE 0 THEN BEGIN
      ylow = icon_height-icon_size-1
      xlow = !x.window(0)+2
      FOR i=0, n_icons-1 DO BEGIN
         TV, img_icon(i).data, xlow, ylow
         ylow = ylow-icon_size-2 > 0
      ENDFOR
   ENDIF
   setwindow, root_win
END

PRO itool_mark_icon, id, remove=remove
;---------------------------------------------------------------------------
;  Plot a box around the image icon selected in the secondary graphic window
;
;  Set REMOVE keyword to just remove the previous mark without plotting
;  new ones
;---------------------------------------------------------------------------
@image_tool_com
   setwindow, icon_win
   DEVICE2, get_graphics=old, set_graphics=6

   IF N_ELEMENTS(id_prev) NE 0 THEN BEGIN
;---------------------------------------------------------------------------
;     Remove previous icon mark
;---------------------------------------------------------------------------
      PLOTS, px_icon, py_icon, /DEVICE
   ENDIF
   IF KEYWORD_SET(remove) THEN BEGIN
      delvarx, id_prev, px_icon, py_icon
      DEVICE2, set_graphics=old
      RETURN
   ENDIF
   xlow = !x.window(0)+1
   xhigh = xlow+icon_size+1
   ylow = icon_height-(icon_size+2)*(id+1)
   yhigh = ylow+icon_size+2
   px_icon = [xlow, xhigh, xhigh, xlow, xlow]
   py_icon = [ylow, ylow, yhigh, yhigh, ylow]
   PLOTS, px_icon, py_icon, /DEVICE
   DEVICE2, set_graphics=old
   id_prev = id
   setwindow, root_win
END

PRO itool_update_iconbt
;---------------------------------------------------------------------------
;  Update image stack icon buttons
;---------------------------------------------------------------------------
@image_tool_com

  widget_control,old_img_bt,update=0   
   n_stack = N_ELEMENTS(img_icon)

do_it=since_version('5.0')
do_it=0

   IF do_it THEN BEGIN 
;---------------------------------------------------------------------------
;     Special treatment for IDL 5.0 to prevent the main window from growing
;---------------------------------------------------------------------------
      IF N_ELEMENTS(bt4icon) EQ 0 THEN BEGIN
         bt4icon = LONARR(max_stack)
         str = blank(31)
         FOR i=0, max_stack-1 DO BEGIN 
            bt4icon(i) = WIDGET_BUTTON(old_img_bt, font=lfont, value=str)
            WIDGET_CONTROL, bt4icon(i), sensitive=0
         ENDFOR
      ENDIF 
      IF n_stack NE 0 THEN BEGIN
         FOR i=0, n_stack-1 DO BEGIN
            uvalue = 'OLD_IMG'+STRTRIM(i, 2)
            value = img_icon(i).filename
            WIDGET_CONTROL, bt4icon(i), set_value=value, set_uvalue=uvalue, $
               sensitive=1
         ENDFOR
      ENDIF 
      ndead = max_stack-n_stack

      IF ndead GT 0 THEN FOR i=0, ndead-1 DO $
         WIDGET_CONTROL, bt4icon(i+n_stack), set_value='', sensitive=0
   ENDIF ELSE BEGIN 
;---------------------------------------------------------------------------
;     Remove the previous buttons for old images
;---------------------------------------------------------------------------
      IF N_ELEMENTS(bt4icon) NE 0 THEN BEGIN
         FOR i=0, N_ELEMENTS(bt4icon)-1 DO xkill, bt4icon(i)
      ENDIF

;---------------------------------------------------------------------------
;     Put buttons for old image names back
;---------------------------------------------------------------------------
      IF n_stack NE 0 THEN BEGIN
         bt4icon = LONARR(n_stack)
         WIDGET_CONTROL, old_img_bt, sensitive=1
         FOR i=0, n_stack-1 DO BEGIN
            uvalue = 'OLD_IMG'+STRTRIM(i, 2)
            bt4icon(i) = WIDGET_BUTTON(old_img_bt, $
                                       value=img_icon(i).filename, $
                                       uvalue=uvalue, font=lfont)
         ENDFOR
      ENDIF    
   ENDELSE
   WIDGET_CONTROL, old_img_bt, sensitive=(n_stack NE 0)
   widget_control,old_img_bt,update=1
  
END

PRO UPDATE_ROT_BUTTON
; PURPOSE:
;       Updates buttons and value of the rotation widget
;
; EXPLANATION:
;       Depending upon the time_gap value that's calculated or
;       entered, this routine will set "Forward" and "Backward" button
;       right, and updates the value in the text widget.
;
; CALLING SEQUENCE:
;       UPDATE_ROT_BUTTON
;
@image_tool_com
   IF (time_gap LT 0.0) THEN BEGIN
      rot_dir = -1
      WIDGET_CONTROL, rot_mode(1), set_button=1
      WIDGET_CONTROL, rot_mode(0), set_button=0
   ENDIF ELSE BEGIN
      rot_dir = 1
      WIDGET_CONTROL, rot_mode(0), set_button=1
      WIDGET_CONTROL, rot_mode(1), set_button=0
   ENDELSE
   WIDGET_CONTROL, rot_text, set_value=$
      num2str(ABS(time_gap/rot_unit), FORMAT='(f20.3)')
END

;----------------------------------------------------------------------
;  Main routine begins here
;----------------------------------------------------------------------
PRO IMAGE_TOOL, input_file, start=start_time, point_stc=point_stc, $
                MIN=MIN, MAX=MAX, reset=reset, group=group, modal=modal, $
                fov=fov, auto_plot=auto_plot,block=block

@image_tool_com
add_psys

;----------------------------------------------------------------------
;  Prevent two copies of Image_tool from running at the same time
;----------------------------------------------------------------------
   IF xregistered2('image_tool') ne 0 THEN BEGIN
      IF N_ELEMENTS(point_stc) EQ 0 THEN BEGIN
         MESSAGE, 'Another IMAGE_TOOL session seems to be running...', /cont
         RETURN
      ENDIF
      IF NOT match_struct(point_stc, pointing_stc) THEN BEGIN
         pointing_stc = point_stc
         pt_fov_reset, pointing_stc, widgets=point_wid
         tai_start = pointing_stc.date_obs
         study_utc = tai2utc(tai_start, /ecs, /trunc)
         WIDGET_CONTROL, start_text, set_value=study_utc
      ENDIF
      IF KEYWORD_SET(auto_plot) AND $
         tools(curr_tool).uvalue EQ 'ptool' THEN BEGIN
         IF auto_plot EQ 2 THEN itool_refresh
         itool_point_plot
      ENDIF
      RETURN
   ENDIF

   IF not since_version('3.6') THEN BEGIN
      MESSAGE, 'Sorry, IMAGE TOOL now requires IDL version 3.6 and up.'
      RETURN
   ENDIF

   IF N_ELEMENTS(fov) NE 0 THEN BEGIN
      IF datatype(fov) NE 'STC' THEN BEGIN
         PRINT, 'The FOV keyword expects a structure with tags X and Y!'
      ENDIF ELSE fov_stc = fov
   ENDIF ELSE delvarx, fov_stc

;---------------------------------------------------------------------------
;  Set font
;---------------------------------------------------------------------------
   bfont = '-adobe-courier-bold-r-normal--20-140-100-100-m-110-iso8859-1'
   bfont = (get_dfont(bfont))(0)

   lfont = '-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1'
   lfont = (get_dfont(lfont))(0)
   IF lfont EQ '' THEN lfont = 'fixed'

   lfont2 = '-misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-1'
   lfont2 = (get_dfont(lfont2))(0)
   IF lfont2 EQ '' THEN lfont2 = 'fixed'

;----------------------------------------------------------------------
;  by default, no effort of getting the center position of the solar
;  disc should be made, i.e., limb fitting is disabled.
;----------------------------------------------------------------------
   fit_flag = 0
   keep_csr = 0

   IF N_ELEMENTS(start_time) EQ 0 THEN BEGIN
;----------------------------------------------------------------------
;     Use the current time as default for start_time
;----------------------------------------------------------------------
      get_utc, tt, /external
      tai_start = utc2tai(tt)
   ENDIF ELSE BEGIN
      tai_start = start_time
   ENDELSE

   IF N_ELEMENTS(point_stc) EQ 0 THEN BEGIN
      cando_pointing = 0
      mk_point_stc, pointing_stc
   ENDIF ELSE BEGIN
      cando_pointing = 1
      pointing_stc = point_stc
;---------------------------------------------------------------------------
;     Overwrite tai_start if pointing_stc.date_obs is valid
;---------------------------------------------------------------------------
      IF pointing_stc.date_obs GT 0.d0 THEN tai_start = pointing_stc.date_obs
   ENDELSE
   study_utc = tai2utc(tai_start, /ecs, /trunc)

;---------------------------------------------------------------------------
;  Initializing some parameters
;---------------------------------------------------------------------------
   delvarx, bt4icon
   IF KEYWORD_SET(reset) THEN BEGIN
    xkill,/all
    delvarx,info
    free_pointer,img_stack
    delvarx, help_stc, img_stack, image_arr, img_icon, $
     prev_col, data_info, rot_unit, limbfit_flag
    delvarx, curr_tool, show_src, log_scaled, boxed_cursor
    free_pointer,img_handle
    delvarx, img_handle
   ENDIF

   time_gap = 1.0
   rot_dir = 1
   time_proj = 1
   del_lat = 15
   del_long = 15
   ut_delay = 1.0
   exit_ok = 1
   max_stack = 12
   icon_size = 50
   icon_height = 680
   fov_flag = 0
   win_xs = 590
   win_ys = 590
   win_2nd = 354
   pt_ok = 0
   limbfit_flag = 0
   can_zoom = 0
   zoom_in = 0
   align_flag = 1
   pointing_go = 0
   clevel = 5
   help_mode = 0
   synop_set = (GETENV('SYNOP_DATA') NE '')
   summary_set = (GETENV('SUMMARY_DATA') NE '')
   private_set = (GETENV('PRIVATE_DATA') NE '')

   IF N_ELEMENTS(exptv_rel) EQ 0 THEN exptv_rel = 0.99
   IF N_ELEMENTS(binary_fits) EQ 0 THEN binary_fits = 0
   IF N_ELEMENTS(prev_col) EQ 0 THEN prev_col = 0
   IF N_ELEMENTS(rot_unit) EQ 0 THEN rot_unit = 1.0
   IF N_ELEMENTS(show_src) EQ 0 THEN show_src = 1
   IF N_ELEMENTS(grid) EQ 0 THEN grid = 0
   IF N_ELEMENTS(noaa) EQ 0 THEN noaa = 0
   IF N_ELEMENTS(log_scaled) EQ 0 THEN log_scaled = 0
   IF N_ELEMENTS(dtype) EQ 0 THEN BEGIN
      IF synop_set THEN dtype = 1 ELSE dtype = 0
   ENDIF
   summary = dtype-1

   IF N_ELEMENTS(track_cursor) EQ 0 THEN track_cursor = 1
   IF N_ELEMENTS(boxed_cursor) EQ 0 THEN boxed_cursor = 0
   IF N_ELEMENTS(limbfit_flag) EQ 0 THEN limbfit_flag = 0
   IF N_ELEMENTS(MIN) NE 0 THEN cur_min = MIN
   IF N_ELEMENTS(MAX) NE 0 THEN cur_max = MAX
   IF N_ELEMENTS(src_name) EQ 0 THEN src_name = 'Unspecified'
   IF N_ELEMENTS(img_type) EQ 0 THEN img_type = 'Unknown'
   IF N_ELEMENTS(scview) EQ 0 THEN scview = 0
   IF N_ELEMENTS(mdi_view) EQ 0 THEN mdi_view = 0
   IF scview NE 1 THEN use_earth_view ELSE use_soho_view
   IF N_ELEMENTS(curr_tool) EQ 0 THEN BEGIN
      curr_tool = 0
      prev_tool = 0
   ENDIF

;----------------------------------------------------------------------
;  Default color for drawing circular cursor:
;----------------------------------------------------------------------
   l_color = !d.table_size-1

   DEVICE2, get_screen_size=sz
   if exist(sz) then begin
    IF (sz(0) GE 1280) AND (sz(1) GE 1024) THEN sz(*) = 0
    sz = sz < [1280, 1024]
   endif else begin
    sz=[1280,1024]
   endelse 
   base0 = WIDGET_BASE(title='', /column, space=5, uvalue='UT_UPDATE', $
                       x_scroll=sz(0), y_scroll=sz(1), mbar=menu_row)

;----------------------------------------------------------------------
;  Pulldown button "File"
;----------------------------------------------------------------------
   file_bs = WIDGET_BUTTON(menu_row, value='Quit', /menu, font=bfont)

   img_quit = WIDGET_BUTTON(file_bs, value='Quit Completely', $
                            uvalue='QUIT', resource_name='QuitButton')

   tmp = WIDGET_BUTTON(file_bs, value='Quit, but Retain Image Window', $
                       uvalue='QUIT2')

;---------------------------------------------------------------------------
;  Pull-down menu for tool switches
;---------------------------------------------------------------------------
   tools = REPLICATE({uvalue:'', name:'', base:-1L, button:-1L}, 6)
   tools.uvalue = ['pftool', 'lftool', 'ptool', 'magnifier', 'profiler', $
                   'overlay']
   tools.name = ['Image Picker', 'Limb Fitter','Pointing Tool', $
                 'Image Magnifier', 'Image Profiler', 'Image Overlayer']
   tools.base = -1L+LONARR(N_ELEMENTS(tools))

   tools_bt = WIDGET_BUTTON(menu_row, value='Tools', font=bfont, /menu)

   FOR i=0, N_ELEMENTS(tools)-1 DO BEGIN
      tools(i).button = WIDGET_BUTTON(tools_bt, value=tools(i).name, $
                                   uvalue=tools(i).uvalue)
   ENDFOR
   tmp = WIDGET_BUTTON(tools_bt, value='Fancy Magnifier', uvalue='zoom_2')
   tmp = WIDGET_BUTTON(tools_bt, value='Color Manipulator', $
                       uvalue='xload')

;----------------------------------------------------------------------
;  Pulldown menu for "Options"
;----------------------------------------------------------------------
   opt_bs = WIDGET_BUTTON(menu_row, value='Options', /menu, font=bfont)
   BEGIN
;----------------------------------------------------------------------
;     Submenu for "Image Manipulation"
;----------------------------------------------------------------------
      img_opt = WIDGET_BUTTON(opt_bs, value='Image Manipulation', /menu)

      lock_bt = WIDGET_BUTTON(img_opt, value='Lock Orientation', $
                              uvalue='img_lock')
      temp = WIDGET_BUTTON(img_opt, value='Flip N/S', uvalue='flip_img')
      temp = WIDGET_BUTTON(img_opt, value='Reverse W/E', uvalue='rvs_img')
      rot_img90 = WIDGET_BUTTON(img_opt, value='Rotate 90'+STRING(176B)+$
                                ' counter-clockwise', $
                                uvalue='rotate_img90')
      rot_img45 = WIDGET_BUTTON(img_opt, value='Rotate 45'+STRING(176B)+$
                                ' counter-clockwise', $
                                uvalue='rotate_img45')
      rot_img45n = WIDGET_BUTTON(img_opt, value='Rotate 45'+STRING(176B)+$
                                 ' clockwise', $
                                 uvalue='rotate_img45n')
      temp = WIDGET_BUTTON(img_opt, value='Rotate 180'+STRING(176B), $
                           uvalue='rotate_img')
      log_scale = WIDGET_BUTTON(img_opt, value='Log Scaling', $
                                uvalue='log_scale')
      temp = WIDGET_BUTTON(img_opt, value='Histogram Equalize', $
                           uvalue='hist_img')
      temp = WIDGET_BUTTON(img_opt, value='SigRange', uvalue='sig_img')
      temp = WIDGET_BUTTON(img_opt, value='Smooth', uvalue='smooth')
      temp = WIDGET_BUTTON(img_opt, value='Show Edge', uvalue='sobel')
      temp = WIDGET_BUTTON(img_opt, value='Plot Contour', uvalue='contour')

      temp = WIDGET_BUTTON(opt_bs, value='')
      WIDGET_CONTROL, temp, sensitive=0
      temp = WIDGET_BUTTON(opt_bs, value='Set Minimum Value', uvalue='min_v')
      temp = WIDGET_BUTTON(opt_bs, value='Set Maximum Value', uvalue='max_v')
      temp = WIDGET_BUTTON(opt_bs, value='Reset Image Limits', $
                           uvalue='reset_limits')

;---------------------------------------------------------------------------
;     Submenu for setting system variables
;---------------------------------------------------------------------------
      sys_var = WIDGET_BUTTON(opt_bs, value='Set System Variable', /menu)
      temp = WIDGET_BUTTON(sys_var, value='!P.Color', $
                           uvalue='p_color')
      temp = WIDGET_BUTTON(sys_var, value='!P.Backgroud', uvalue='p_bg')
      temp = WIDGET_BUTTON(sys_var, value='!P.CharSize', uvalue='p_cs')
      temp = WIDGET_BUTTON(sys_var, value='!P.CharThick', uvalue='p_ct')
      temp = WIDGET_BUTTON(sys_var, value='!P.TickLen', uvalue='p_tick')

      temp = WIDGET_BUTTON(opt_bs, value='Set Contour Level', uvalue='clevel')

      temp = WIDGET_BUTTON(opt_bs, value='')
      WIDGET_CONTROL, temp, sensitive=0
      temp = WIDGET_BUTTON(opt_bs, value='Change Cursor Color', $
                           uvalue='cursor_color')
      cursor_shape = WIDGET_BUTTON(opt_bs, value='Dummy', uvalue='cursor')
      cursor_size = WIDGET_BUTTON(opt_bs, value='Set Boxed Cursor Size', $
                                  uvalue='cursor_size')
      WIDGET_CONTROL, cursor_size, sensitive=boxed_cursor
      temp = WIDGET_BUTTON(opt_bs, value='')
      WIDGET_CONTROL, temp, sensitive=0

      temp = WIDGET_BUTTON(opt_bs, value='Set EXPTV Relative Size', $
                           uvalue='exptv')
;      IF WIDGET_INFO(pointing_stc.messenger, /valid) THEN $
;         temp=WIDGET_BUTTON(opt_bs, value='Refresh Display', uvalue='REFRESH')

      temp = WIDGET_BUTTON(opt_bs, value='')
      WIDGET_CONTROL, temp, sensitive=0
   END

;-- operations menu

   opera_bs = WIDGET_BUTTON(menu_row, value='Operations', /menu, font=bfont)


   save_img = WIDGET_BUTTON(opera_bs, value='Make Hard Copy', /menu)
   tmp = WIDGET_BUTTON(save_img, value='Save Image in PS Format', $
                       uvalue='PS_FORMAT')
   tmp = WIDGET_BUTTON(save_img, value='Save Image as a JPEG File', $
                       uvalue='save_jpeg')
   tmp = WIDGET_BUTTON(save_img, value='Save Image as a JPEG-2 File', $
                       uvalue='save_jpeg2')

   tmp = WIDGET_BUTTON(save_img, value='Dump Image in PS Format', $
                       uvalue='save_ps')
   tmp = WIDGET_BUTTON(save_img, value='Dump Whole Window in PS Format', $
                       uvalue='win_dump_ps')
   tmp1 = WIDGET_BUTTON(save_img, value='Dump Whole Window as a JPEG File', $
                        uvalue='win_dump_jpeg')

   IF STRUPCASE(os_family()) NE 'UNIX' THEN BEGIN
      WIDGET_CONTROL, tmp, sensitive=0
      WIDGET_CONTROL, tmp1, sensitive=0
   ENDIF

   line='-------------------------'
   temp = WIDGET_BUTTON(opera_bs, value='Spawn New Image Window', $
                           uvalue='new_window')
   blank= WIDGET_BUTTON(opera_bs,value=line)

   show_csi = WIDGET_BUTTON(opera_bs, value='Show CSI Structure', uvalue=$
                               'SHOW_CSI')

   temp = WIDGET_BUTTON(opera_bs, value='Show Image Info', uvalue='img_info')
   blank= WIDGET_BUTTON(opera_bs,value=line)
   fits_header = WIDGET_BUTTON(opera_bs, value='Display FITS Header', $
                                  uvalue='HEADER')

   modify_fh = WIDGET_BUTTON(opera_bs, value='Update FITS Header', $
                             uvalue='modify_fh')

   write_fits = WIDGET_BUTTON(opera_bs, value='Save Image in FITS Format', $
                              uvalue='write_fits')
   blank= WIDGET_BUTTON(opera_bs,value=line)


   rm_stack = WIDGET_BUTTON(opera_bs, value='Remove Image from Stack', $
                               uvalue='rm_stack')
   tmp = widget_button(opera_bs,value='Flush ALL Images From Stack',uvalue='flush_stack') 


   blank= WIDGET_BUTTON(opera_bs,value=line)
   xdoc = WIDGET_BUTTON(opera_bs, value='XDOC', uvalue='xdoc')

   WIDGET_CONTROL, rm_stack, sensitive=0
    


;---------------------------------------------------------------------------
;  Add a new base to show and select number of images in each FITS file; if
;  there is only one image in the file, this widget should be unmapped.
;---------------------------------------------------------------------------
   img_sel_bt = WIDGET_BUTTON(menu_row, value='Image_No', /menu, font=bfont)
   WIDGET_CONTROL, img_sel_bt, sensitive=0

   IF N_ELEMENTS(data_info) NE 0 THEN BEGIN
      IF data_info.binary EQ 1 THEN $
         multi_file_button, img_sel_bt, img_sel_show, data_info, $
         uvalue='IMG_SEL_BT', /force $
      ELSE $
         delvarx, img_sel_show
   ENDIF

   IF since_version('4.0') THEN BEGIN
      temp = WIDGET_BUTTON(menu_row, value='Help', font=bfont, /menu, /help)
   ENDIF ELSE BEGIN
      temp = WIDGET_BUTTON(menu_row, $
                           value='                         ', $
                           font=bfont, /menu)
      WIDGET_CONTROL, temp, sensitive=0
      temp = WIDGET_BUTTON(menu_row, value='Help', font=bfont, /menu)
   ENDELSE
   tmp = WIDGET_BUTTON(temp, value='About Image Tool', uvalue='about')
;   tmp = WIDGET_BUTTON(temp, value='Online Help', uvalue='HELP_ONLINE')
   tmp = WIDGET_BUTTON(temp, value='Help on Topic', uvalue='HELP')

;---------------------------------------------------------------------------
;  Second row has two columns.
;---------------------------------------------------------------------------
   base = WIDGET_BASE(base0, /row, space=5)

;----------------------------------------------------------------------
;  Left column is for buttons and info messages, etc.
;----------------------------------------------------------------------
   left_column = WIDGET_BASE(base, /column, space=15)

   button_base = WIDGET_BASE(left_column, /column, space=5)

   grid_base = WIDGET_BASE(button_base, /row, space=10, /frame)
   temp = WIDGET_BASE(grid_base, /nonexclusive, /frame)
   grid_bt = WIDGET_BUTTON(temp, value='GRID', uvalue='GRID', font=lfont2)

   temp = WIDGET_BASE(grid_base, /row)
   tem = WIDGET_LABEL(temp, value='LAT.', font=lfont)
   set_lat = WIDGET_TEXT(temp, value=num2str(del_lat, FORMAT='(i3)'), $
                         xsize=3, uvalue='del_lat', /editable, font=lfont)
   tem = WIDGET_LABEL(temp, value=STRING(176B), font=lfont)

   temp = WIDGET_BASE(grid_base, /row)
   tem = WIDGET_LABEL(temp, value='LONG.', font=lfont)
   set_long = WIDGET_TEXT(temp, value=num2str(del_long, FORMAT='(i3)'), $
                          xsize=3, uvalue='del_long', /editable, font=lfont)
   tem = WIDGET_LABEL(temp, value=STRING(176B), font=lfont)

   temp = WIDGET_BASE(grid_base, /nonexclusive, /frame)
   noaa_bt = WIDGET_BUTTON(temp, value='NOAA', uvalue='NOAA', font=lfont2)

   junk_base = WIDGET_BASE(button_base, /row)

   left_junk = WIDGET_BASE(junk_base, /column, space=5)

   rot_bs = WIDGET_BASE(left_junk, /column, space=1, /frame)

   junk = WIDGET_BASE(rot_bs, /row)
   temp = WIDGET_BUTTON(junk, value='DIFF. ROTATE', /menu, font=lfont)
   rot_limb = WIDGET_BUTTON(temp, value='      ', uvalue='rot_limb')
   tmp = WIDGET_BUTTON(temp, value='points on central meridian', $
                       uvalue='rot_meridian')
   rot_longi_bt = WIDGET_BUTTON(temp, value='points on any longitude', $
                                uvalue='rot_longi')
   rot_solarx_bt = WIDGET_BUTTON(temp, value='points on the same Solar-X', $
                                 uvalue='rot_solarx')
   rot_1pt_bt = WIDGET_BUTTON(temp, value='one point', uvalue='rot_1pt')
   WIDGET_CONTROL, rot_longi_bt, sensitive=1
   WIDGET_CONTROL, rot_solarx_bt, sensitive=1
   WIDGET_CONTROL, rot_1pt_bt, sensitive=1

   rot_reg_bt = WIDGET_BUTTON(temp, value='a region....', /menu)
   tmp1 = WIDGET_BUTTON(rot_reg_bt, value='without remapping pixels', $
                        uvalue='rot_reg')
   tmp1 = WIDGET_BUTTON(rot_reg_bt, value='with pixels remapped', $
                        uvalue='rot_regmap')
   tmp = WIDGET_BUTTON(temp, value='the whole image', uvalue='rot_img')

   rot_dir_bs = WIDGET_BASE(junk, /row)
;   temp = WIDGET_LABEL(rot_dir_bs, value='', font=lfont)
   rot_mode = LONARR(2)
   xmenu, ['WEST', 'EAST'], rot_dir_bs, /exclusive, $
      font=lfont, uvalue=['forward', 'backward'], /no_release, /row, $
      buttons=rot_mode
   WIDGET_CONTROL, rot_mode(0), /set_button

   tmp = WIDGET_BASE(rot_bs, /row)
   temp = WIDGET_LABEL(tmp, value=' ', font=lfont)
   rot_int = WIDGET_BUTTON(tmp, value='INTERVAL', /menu, font=lfont)
   temp = WIDGET_BUTTON(rot_int, value='To Current Starting Time', $
                        uvalue='rot_now', font=lfont)

   rot_text = WIDGET_TEXT(tmp, value=num2str(time_gap, FORMAT='(f20.3)'), $
                          /editable, xsize=6, uvalue='TIME_GAP', font=lfont)
   rot_unitb = cw_bselector2(tmp, ['DAYS', 'HOURS'], uvalue='ROT_UNIT', $
                             /return_index, font=lfont)
   IF rot_unit EQ 1.0 THEN WIDGET_CONTROL, rot_unitb, set_value=0 ELSE $
      WIDGET_CONTROL, rot_unitb, set_value=1

;----------------------------------------------------------------------
;  Add start time of a study
;----------------------------------------------------------------------
   tmp = WIDGET_BASE(left_junk, /row, space=1, /frame)
   temp_tt = WIDGET_BUTTON(tmp, value='OBS TIME', /menu, font=lfont)
   tmp_tt = WIDGET_BUTTON(temp_tt, value='Arbitrary Observation Time', $
                          uvalue='any_study')
   study_start = WIDGET_BUTTON(temp_tt, value='Current Study Start Time', $
                               uvalue='study_start')
   IF N_ELEMENTS(point_stc) EQ 0 THEN $
      WIDGET_CONTROL, study_start, sensitive=0
   start_text = WIDGET_TEXT(tmp, value=anytim2utc(tai_start, /ecs, /trunc), $
                            font=lfont, xsize=19, /edit)

   junk = WIDGET_BASE(junk_base, /column, /frame, space=1)
;---------------------------------------------------------------------------
;  Add a switch button for S/C point of view if SC_VIEW is defined
;---------------------------------------------------------------------------
   tmp = WIDGET_BASE(junk, /nonexclusive)
   sc_view = WIDGET_BUTTON(tmp, value='SOHO  VIEW', uvalue='sc_view', $
                           font=lfont)
   widget_control,sc_view,sensitive=0
   tmp = WIDGET_BUTTON(tmp, value='MDI HR FOV', uvalue='mdi_view', font=lfont)
   WIDGET_CONTROL, tmp, set_button=(mdi_view NE 0)

   junk = WIDGET_BASE(junk, /column)
   zoom_bt = WIDGET_BUTTON(junk, value=' Zoom In ', uvalue='zoom_in_out', $
                           font=lfont)

;   IF WIDGET_INFO(pointing_stc.messenger, /valid) THEN BEGIN
;      tmp = WIDGET_BUTTON(junk, value=' Recover ', uvalue='recover', $
;                          font=lfont)
;   ENDIF ELSE BEGIN
      tmp = WIDGET_BUTTON(junk, value='Refresh', uvalue='REFRESH', $
                          font=lfont)
;   ENDELSE

;---------------------------------------------------------------------------
;  tool_holder is a widget base shared by several widget interface bases. Of
;  course only one of these bases can be mapped at one time
;---------------------------------------------------------------------------
   tool_holder = WIDGET_BASE(left_column, /frame)


;---------------------------------------------------------------------------
;  File picker tool
;---------------------------------------------------------------------------
   tools(0).base = itool_pickfile(parent=tool_holder, path=path, map=0, $
                                  get_path=get_path, stop=tai_start, $
                                  event_pro='image_tool_event', $
                    filter='*.gif *.fts *.fits *.jpeg *.jpg *.Z *.gz *.FTS')
;----------------------------------------------------------------------
;  Limb fitter
;----------------------------------------------------------------------
   tools(1).base = itool_limbfitter(tool_holder, font=lfont)

;----------------------------------------------------------------------
;  Pointing tool
;----------------------------------------------------------------------
   tools(2).base = itool_ptool(tool_holder, font=lfont)

;----------------------------------------------------------------------
;  Mangifier
;----------------------------------------------------------------------
   tools(3).base = itool_magnifier(tool_holder)

;---------------------------------------------------------------------------
;  Profiler shares the same widget with magnifier
;---------------------------------------------------------------------------
   tools(4).base = tools(3).base

;---------------------------------------------------------------------------
;  Image overlayer
;---------------------------------------------------------------------------
   tools(5).base = itool_overlayer(tool_holder)

   WIDGET_CONTROL, tools(curr_tool).base, map=1

;----------------------------------------------------------------------
;  Right column is the base widget that holds the draw widget
;----------------------------------------------------------------------


   right_column = WIDGET_BASE(base, /frame, /column, space=2, $
                              xpad=10, map=1)


   row21 = WIDGET_BASE(right_column, space=10, /row)

   src_bs = WIDGET_BASE(row21, /row, /frame)

   src_title = cw_bselector2(src_bs, ['IMAGE SOURCE', 'IMAGE TYPE'], $
                             uvalue='src_title', /return_index, font=lfont)

   src_text = WIDGET_TEXT(src_bs, value='Unspecified', xsize=28, $
                          font=lfont)

   time_bs = WIDGET_BASE(row21, /row, /frame)
   junk = WIDGET_BUTTON(time_bs, value='IMAGE TIME', /menu, font=lfont)
   junk1 = WIDGET_BUTTON(junk, value='Arbitrary Image Time', $
                         uvalue='disp_time')
   junk1 = WIDGET_BUTTON(junk, value='Current Image Time', $
                         uvalue='img_time')

   obs_text = WIDGET_TEXT(time_bs, value='', xsize=28, font=lfont)

   row31=widget_base(right_column,/row)

   pc1=widget_base(row31,/column)
   draw_id = WIDGET_DRAW(pc1, /frame, ysize=win_ys, xsize=win_xs, $
                         uvalue='DRAW', retain=2, $
                         /button_events)
   WINDOW, /free, /pixmap, xsize=win_xs, ysize=win_ys
   pix_win = {xsize:win_xs, ysize:win_ys, id:!d.window}

   row22 = WIDGET_BASE(pc1, /row, space=10)

   temp = WIDGET_BASE(row22, /frame, /column)

;    junk = WIDGET_BASE(temp, /row, space=5)
;    tmp = WIDGET_BASE(junk, /row)
;    tmp1 = WIDGET_LABEL(tmp, value='MIN', font=lfont)
;    min_id = WIDGET_TEXT(tmp, value='', uvalue='SET_MIN', xsize=6, $
;                         /editable, font=lfont)

;    tmp = WIDGET_BASE(junk, /row)
;    tmp1 = WIDGET_LABEL(tmp, value='MAX', font=lfont)
;    max_id = WIDGET_TEXT(tmp, value='', uvalue='SET_MAX', xsize=6, $
;                         /editable, font=lfont)

   f = concat_dir(GETENV('SSW_SETUP_DATA'), 'color_table.eit')
   IF file_exist(f) THEN $
      color_bar=cw_loadct(temp, xsize=265, ysize=15, font=lfont, $
                          file=f, /menu) $
   ELSE $
      color_bar=cw_loadct(temp, xsize=265, ysize=15, font=lfont, /menu)

;----------------------------------------------------------------------
;  Make "Cursor Position" button a pull-down menu nutton
;----------------------------------------------------------------------
   csr_bs = WIDGET_BASE(row22, /column, /frame)
   txt_bs = WIDGET_BASE(csr_bs, /column, space=0)

   csr_bt = WIDGET_BUTTON(txt_bs, value='Report Cursor Position:', /menu, font=lfont)
   temp = WIDGET_BUTTON(csr_bt, value='In Device System', uvalue='mode_1')
   temp = WIDGET_BUTTON(csr_bt, value='In Image Pixel System', uvalue='mode_2')
   mode3_bt = WIDGET_BUTTON(csr_bt, value='In Solar Disc System', $
                            uvalue='mode_3')
   mode4_bt = WIDGET_BUTTON(csr_bt, value='In Heliographic System', $
                            uvalue='mode_4')
   cursor_track = WIDGET_BUTTON(csr_bt, value='Cursor Track', uvalue='cursor_track')

   txt_id = WIDGET_TEXT(txt_bs, value='', xsize=38, font=lfont, $
                        /edit, uvalue='CURSOR_POS')

   txt_lb = WIDGET_LABEL(csr_bs, value='(in solar disc coordinate system)', $
                         font=lfont)

;---------------------------------------------------------------------------
;  One more column for image icons
;---------------------------------------------------------------------------
   icon_temp = WIDGET_BASE(row31, /column, /frame, map=0)

   old_img_bt = WIDGET_BUTTON(icon_temp, value='ICONS', /menu, font=lfont)

   tmp = WIDGET_BASE(icon_temp, /row)
   draw_icon = WIDGET_DRAW(tmp, xsize=icon_size+4, uvalue='draw_icon', $
                           /button_events, ysize=icon_height)


   itool_update_iconbt

;---------------------------------------------------------------------------
;  Third row is for commentary widget
;---------------------------------------------------------------------------
   comment_id = WIDGET_TEXT(base0, ysize=3, /frame, font=lfont)

;----------------------------------------------------------------------
;  Now make all widgets alive
;----------------------------------------------------------------------
   WIDGET_CONTROL, base0, /realize

;---------------------------------------------------------------------------
;  Remember the messenger ID
;---------------------------------------------------------------------------
   messenger = WIDGET_INFO(base0, /child)

;---------------------------------------------------------------------------
;  Disable the selection of the image display device via TVSELECT and
;  TVUNSELECT
;---------------------------------------------------------------------------
   tvdevice, /disable

;---------------------------------------------------------------------------
;  There is a bug in IDL v 3.5.1 that can cause IDL to hang on a
;  pending timer event. We have to check this
;---------------------------------------------------------------------------
   tool_title = 'Image Tool   (Version 9.0)         '
   IF not since_version('3.5.1') THEN BEGIN
      WIDGET_CONTROL, base0, tlb_set_title=tool_title
   ENDIF ELSE BEGIN
      get_utc, curr_ut, /ecs
      WIDGET_CONTROL, base0, tlb_set_title=tool_title+STRMID(curr_ut, 0, 19)+$
         ' GMT'
      WIDGET_CONTROL, base0, timer=DOUBLE(ut_delay)
   ENDELSE

;    WIDGET_CONTROL, ctb_draw, get_value=tmp1
;    WSET, tmp1
;    TVSCL, BYTSCL(INDGEN(x_scl) # REPLICATE(1, y_scl), top=!d.table_size-1)

   WIDGET_CONTROL, draw_id, get_value=root_win, draw_motion=track_cursor
   WIDGET_CONTROL, draw_icon, get_value=icon_win
   WIDGET_CONTROL, draw_2nd, get_value=root_2nd
   setwindow, root_win

   IF N_ELEMENTS(icon_stc)*N_ELEMENTS(image_2nd) NE 0 THEN itool_disp_2nd

;----------------------------------------------------------------------
;  Now initialize cursor position display mode, d_mode. It is defined
;  as the following:
;     d_mode = 1, in pixels of the graphic device with the origin at
;                 the lower left corner of the graphic window
;     d_mode = 2, in pixels in data coordinate system
;     d_mode = 3, in arcsecs of the solar disc coordinate system
;     d_mode = 4, in longitude and latitude of the heliographic system
;----------------------------------------------------------------------
   IF N_ELEMENTS(d_mode) EQ 0 THEN d_mode = 3 ; default display mode

   IF N_ELEMENTS(input_file) GT 0 THEN BEGIN
      IF N_ELEMENTS(input_file) GT 1 THEN BEGIN
;----------------------------------------------------------------------
;        Filenames are passed in from the caller. Select one file
;----------------------------------------------------------------------
         short_names = strip_dirname(input_file, path=dir_path)
         data_file = xsel_list(short_names)
         IF data_file EQ '' OR data_file EQ ' ' THEN BEGIN
            popup_msg, 'You did not choose any image data.'
            data_file = input_file(0)
         ENDIF
         data_file = concat_dir(dir_path(0), data_file)
      ENDIF ELSE data_file = input_file
;----------------------------------------------------------------------
;     What is passed in data_file is only a string scalar, which is the
;     filename of the image to be loaded up
;----------------------------------------------------------------------
      WIDGET_CONTROL, right_column, map=1
      itool_load_image, data_file(0), err=err
      IF err EQ '' THEN BEGIN
         widget_control,src_title,set_value=1-show_src
         src_name = 'Unspecified'
         IF show_src THEN $
            WIDGET_CONTROL, src_text, set_value=src_name $
         ELSE $
            WIDGET_CONTROL, src_text, set_value=img_type
      ENDIF
   ENDIF ELSE BEGIN
      IF N_ELEMENTS(image_arr) NE 0 AND NOT KEYWORD_SET(reset) THEN BEGIN
;---------------------------------------------------------------------------
;        Restore what was left from the previous run
;---------------------------------------------------------------------------
         WIDGET_CONTROL, draw_id, map=1
         tt=anytim2utc(disp_utc, /ecs, /trunc)
         doy=' (doy '+trim(string(utc2doy(tt)))+')'
         WIDGET_CONTROL, obs_text, set_value=tt+doy
         itool_refresh
         itool_icon_plot
         IF N_ELEMENTS(rgb) NE 0 THEN TVLCT, rgb(*, 0), rgb(*, 1), rgb(*, 2)
      ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;        First time to call and no image file name passed in; Load in
;        the SOHO logo
;---------------------------------------------------------------------------
         img_lock = 0
;         look = loc_file('sohologo.gif', path=get_lib(), count=nf)
         nf=1
         IF nf GT 0 THEN BEGIN
            prev_file = 'sohologo'
            src_name = 'SOHO Logo'
            img_type = 'GIF File'
;            read_gif, prev_file, image_arr, r, g, b
            image_arr=bytarr(128,128)
            cur_min = MIN(image_arr)
            cur_max = FIX(MAX(image_arr))
            ncolor = !d.table_size-1 < 255
;            r = r(0:ncolor)
;            g = g(0:ncolor)
;            b = b(0:ncolor)
;            IF cur_max LT ncolor THEN BEGIN
;               r(cur_max:ncolor) = 255
;               g(cur_max:ncolor) = 255
;               b(cur_max:ncolor) = 255
;            ENDIF
;            TVLCT, r, g, b
;            rgb = [[r], [g], [b]]
;            grid = 0
            d_mode = 2
            get_utc, img_utc, /ecs
            disp_utc = img_utc
            header_cur = ''
            csi = itool_new_csi()
            gif_file = 1
            data_info = {binary:0, label:'', col:1, cur_col:1}
            exptv_rel = 0.95
            WIDGET_CONTROL, draw_id, map=1
            csi.date_obs = img_utc
            itool_display, image_arr, MAX=cur_max, MIN=cur_min, $
               relative=exptv_rel, csi=csi
            itool_copy_to_pix
         ENDIF
         flash_msg, comment_id, $
            'Please load in your images via the Image Picker Tool (by '+$
            'choosing image type, source and pressing the "List file" '+$
            'button).', num=2
      ENDELSE
   ENDELSE
   IF since_version('3.6') THEN WIDGET_CONTROL, icon_temp, map=1

   itool_adj_ctable, /init
   itool_button_refresh

   modal=keyword_set(modal)

;   XMANAGER, 'image_tool', base0, group_leader=group, modal=modal
;   IF NOT KEYWORD_SET(group) THEN xmanager

   caller=trim(get_caller())

   dprint,'% caller: ',caller


   expr='xmanager,"image_tool",base0,group=group,modal=modal'
   if idl_release(lower=5,/incl) and caller eq '' then expr=expr+',/no_block'
   s=execute(expr)
   dprint,'% out of IMAGE_TOOL'
   xmanager_reset,base0,group=group,modal=modal,crash='image_tool'
      
;---------------------------------------------------------------------------
;  Restore pointing parameters
;---------------------------------------------------------------------------
   IF KEYWORD_SET(modal) or (get_caller() eq '') THEN point_stc = pointing_stc

END


;       Version 1, Liyun Wang, NASA/GSFC, October 19, 1994
;          Incorporated into the CDS library
;       Version 2, Liyun Wang, NASA/GSFC, November 18, 1994
;          Added features of rotating a point or a region;
;          All conversions of coordinate systems are done via CNVT_COORD
;             routine, common block IMG_SCALE is removed;
;          Added the capability of fitting the limb and finding the center of
;             the solar disc
;       Version 2.1, Liyun Wang, NASA/GSFC, December 23, 1994
;          Made rasters plotted against the displayed image with
;             respect to the time when the image was shot.
;       Version 2.2, Liyun Wang, NASA/GSFC, December 27, 1994
;          Added feature of plotting grids parallels and meridians on
;             the solar disc
;       Version 3, Liyun Wang, NASA/GSFC, January 25, 1995
;          Generized the pointing widget base siutable for any SOHO instrument
;          Separated codes for pointing and limb-fitting from the main
;             program code.
;          Take out the CDS_RASTER keyword parameter, replaced it with a more
;             general keyword parameter POINT_STC.
;       Version 3.1, Liyun Wang, NASA/GSFC, February 28, 1995
;          Made it capable of reading FITS files that have binary tables
;          Pointing can be done in a zoomed-in window now
;          Added elliptical limb fitting option
;       Version 3.2, Liyun Wang, NASA/GSFC, March 15, 1995
;          Image displayed with axes around it if data coordinate system can
;             be established
;          Pointing criteria is imposed if the pointing area has to be off limb
;          User is warned if any of the pointing area is not pointed
;       Version 3.3, Liyun Wang, NASA/GSFC, April 27, 1995
;          Added GIF output option
;       Version 3.4, Liyun Wang, NASA/GSFC, May 9, 1995
;          Added feature of differentially rotating forward (backward)
;             points on the east (west) limb
;          Made start time and image obsvervation time editable
;          Added feature of box-shaped cursor
;          Made it capabile of reading in GIF images (useful when only
;             the GIF format of the latest solar images are available)
;          Started using the new version of XGET_SYNOPTIC (which has no
;             COMMON blocks in its main and event handler routines)
;          Allowed the user to select FITS files from his/her own
;             directory
;          Added option to set relative size of displayed image
;       Version 3.5, Liyun Wang, NASA/GSFC, May 15, 1995
;          Improved the on-line help system
;       Version 3.6, Liyun Wang, NASA/GSFC, May 31, 1995
;          Added feature of locking up image orientation so that
;             coordinates of the image follow any image manipulation
;             operation
;          Added feature of stacking images for easy retreiving
;          Made cursor be markable via the middle or right mouse button
;       Version 3.7, August 10, 1995, Liyun Wang, NASA/GSFC
;          Allowed the string of image source or image type to be shown
;       Version 3.8, August 16, 1995, Liyun Wang, NASA/GSFC
;          Made it possible to directly access the SOHO summary data
;          Can enter coordinates of a point and show it on the image
;          Added the capability of modifying FITS headers to include
;             the scaling and solar center info from the limbfitting result
;       Version 3.9, October 10, 1995, Liyun Wang, NASA/GSFC
;          Started using XPS_SETUP to handle making hard copies in PS format
;       Version 4.0, October 23, 1995, Liyun Wang, NASA/GSFC
;          Made images saved in the stack retrievable via image icons
;          Made the default starting directory for loading GIF files
;             or personal FITS files be current working directory
;          Removed the option to retain loaded images in a separate window
;          Added option for cursor tracking
;       Version 4.1, November 2, 1995, Liyun Wang, NASA/GSFC
;          Added interface for loading in personal image files
;          Added display for position angle of the cursor
;       Version 4.2, November 15, 1995, Liyun Wang, NASA/GSFC
;          Added image smooth and edge detect option
;          Made image profile to be shown in draw widget window
;       Version 4.3, November 27, 1995, Liyun Wang, NASA/GSFC
;          Added image-overlay feature
;       Version 4.4, December 28, 1995, Liyun Wang, NASA/GSFC
;          Added feature to allow pointing structure to be sent to and
;             received from planning tool
;       Version 4.5, February 26, 1996, Liyun Wang, NASA/GSFC
;          Private data path can be default to PRIVATE_DATA if this env
;             variable is defined
;          Fixed bug that IDL working dir may be changed when navigating
;             through "personal" data paths
;          Boxed cursor is now default to that reflecting the actual
;             pointing area defined in POINT_STC
;          Modified such that upon loading a new image, current zoommed-in
;             image is zoommed out implicitly
;       Version 4.6, March 5, 1996, Liyun Wang, NASA/GSFC
;          Changed button labels for image time and study time
;          Fixed a bug data type being unrecorded
;          Automatically scaling and loading correct color table of
;             the SOHO EIT images
;          Added SOHO EIT color tables in color table list
;          Added an image manipulating button for log scaling the image
;       Version 4.7, March 12, 1996, Liyun Wang, NASA/GSFC
;          Added a switch button to control point of view (Earth or SOHO)
;          Better identified image type and source
;          Point of view is set automatically when loading a new image
;       Version 4.8, March 13, 1996, Liyun Wang, NASA/GSFC
;          Added feature of better adjusting color table without
;             calling XLOADCT
;       Version 4.9, March 19, 1996, Liyun Wang, NASA/GSFC
;          Added an option of plotting a raster position over the
;             displayed image
;          Fixed a bug in reading a new column from a FITS file with
;             binary tables
;          Fixed a bug in changing directory path and filter for
;             selecting personal data
;       Version 4.10, March 27, 1996, Liyun Wang, NASA/GSFC
;          Added interface to SOHO private data directory
;          Made it more robust when loading a new file
;       Version 4.11, April 1, 1996, Liyun Wang, NASA/GSFC
;          Added the FOV keywords for plotting a fixed field of view
;          Added check against the attemp of trying to rotate a point
;             or region which is outside the solar disc
;          Added RADIUS tag in the CSI structure
;          Utilized a new widget program for adjusting arbitrary study
;             or imaging time
;          Added advanced/novice mode switching feature
;       Version 4.12, April 19, 1996, Liyun Wang, NASA/GSFC
;          Added widget window dump option for machines running UNIX
;          Fixed a few bugs in Pointing Tool
;          Applied EIT degridding algorithm
;       Version 4.13, May 29, 1996, Liyun Wang, NASA/GSFC
;          Fixed problem when run on a 24-bit color display
;       Version 4.14, July 15, 1996, Liyun Wang, NASA/GSFC
;          Auto log scaled images from Yohkoh SXT, MLSO, PDMO
;       Version 4.15, August 28, 1996, Liyun Wang, NASA/GSFC
;          Fixed a problem that CRPIX1 and CRPIX2 was treated as the
;             reference pixel based on (0,0), should be (1,1) all the
;             time as in the FITS specification
;          Zoomed-in image is displayed with a better scale
;       Version 4.16, December 4, 1996, Liyun Wang, NASA/GSFC
;          Removed restriction of switching images on stack while in
;             zoom-in mode
;          Added option button to over plot MDI high-res field of view
;          Added option to dump main image window in PS format
;       Version 4.17, December 6, 1996, Liyun Wang, NASA/GSFC
;          Added option to remove a selected image from image stack
;       Version 4.18, February 11, 1997, Liyun Wang, NASA/GSFC
;          Added option to spawn an image window and to quit with
;             image window retained
;          Added option to rotate points on central meridian
;       Version 4.19, February 20, 1997, Liyun Wang, NASA/GSFC
;          Added "Recover" button when called from the Planning Tool
;          Removed novice/advanced mode
;       Version 4.20, March 6, 1997, Liyun Wang, NASA/GSFC
;          Implemented differential rotation indicator for any constant
;             longitudinal points and points at the same Solar X value
;          Replaced the "Recover" button with "Refresh" when not
;             called from the Planning Tool (and "Refresh Display" is
;             removed from the "Misc" menu in this case)
;       Version 4.21, April 1, 1997, Liyun Wang, NASA/GSFC
;          Allowed OBS_TIME field to be editable
;          Fixed a bug occurred during plotting off_limb rasters
;       Version 4.22, June 3, 1997, Liyun Wang, NASA/GSFC
;          Modified such that pointing is updated if called again
;             with another pointing structure while IMAGE_TOOL is
;             still running
;          Improved cursor plotting scheme
;       Version 4.23, July 30, 1997, Liyun Wang, NASA/GSFC
;          Added AUTO_PLOT keyword to be used with POINT_STC input keyword
;       Version 5.0, September 8, 1997, Liyun Wang, NASA/GSFC
;          Major changes on interface as well as on functionality:
;          1) Put all available tools under one pull down menu "Tools"
;          2) Simplified the procedure to zoom in/out and to position
;             the FOV box in Poiting Tool (by getting rid of call to
;             BOX_CURSOR)
;          3) Made XGET_SYNOPTIC as a built-in tool
;          4) Added Overlayer Tool
;          5) Improved ploting on image icons as well as in zoom-in window
;          6) Added option to save current image in FITS format
;          7) Adopted cw_loadct for color table manipulating
;          8) Changed and enhanced CSI tag names to conform with the
;             FITS standards 
;          9) Allowed read GIF format and save it in FITS format
;         10) Greatly improved functionality of differential rotation
;         11) Made full-disk differential rotation available
;         12) Added contour plot option under Image Manipulation
;         13) Avoided rebuilding pull-down button when switch back to
;             image originated from a FITS file with binary table
;         14) Special treatment to overcome an IDL 5.0 bug that causes
;             the whole widget window growing whenever a new image is loaded
;	Version 5.1, October 13, 1998, William Thompson, NASA/GSFC
;	   Limit the special treatment for the window growing problem mentioned
;	   above to IDL 5.0, and treat IDL 5.1 and above as before.
;	Version 6, 14-July-2003, William Thompson, GSFC
;	   Use environment variable SOHO_ORIENT for MDI field-of-view.

