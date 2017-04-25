;---------------------------------------------------------------------------
; Document name: mk_point_base.pro
; Created by:    Liyun Wang, NASA/GSFC, January 23, 1995
;
; Last Modified: Fri Aug  1 21:36:52 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       MK_POINT_BASE
;
; PURPOSE:
;       Make a widget base for pointing for an appropriate SOHO instrument
;
; EXPLANATION:
;       This routine creates a widget interface based on a given "parent"
;       base in IMAGE_TOOL for the pointing purpose. Events genereated from
;       this widget set is handled by routine POINTING_EVENT. It requies a
;       pointing structure be defined (in the common block included in
;       image_tool_com.pro) for a given instrument. This pointing structure
;       should include the following tags:
;
;          MESSENGER  - ID of widget in the caller that triggers a
;                       timer event in the planning tool to signal the
;                       completion of pointing; must be a widget that
;                       does not usually generate any event
;          INSTRUME   - Code specifying the instrument; e.g., 'C' for CDS
;          SCI_SPEC   - Science specification
;          STD_ID     - Study ID
;          G_LABEL    - Generic label for the pointing; e.g., 'RASTER'
;          X_LABEL    - Label for X coordinate of pointing; e.g., 'INS_X'
;          Y_LABEL    - Label for Y coordinate of pointing; e.g., 'INS_Y'
;          DATE_OBS   - Date/time of beginning of observation, in TAI format
;          DO_POINTING- An integer of value 0 or 1 indicating whether pointing
;                       should be handled at the planning level (i.e., by
;                       IMAGE_TOOL)
;          N_POINTINGS- Number of pointings to be performed by IMAGE_TOOL
;          POINTINGS  - A structure array (with N_POINTINGS elements) of type
;                       "DETAIL_POINT" to be handled by IMAGE_TOOL. It has the
;                       following tags:
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
;          RASTERS    - A structure array (N_RASTERS-element) of type
;                       "RASTER_POINT" that contains raster size and pointing
;                       information (this is irrelevant to the SUMER). It has
;                       the following tags:
;
;                       POINTING - Pointing handling code; valis
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
;      Note: For the case of CDS, pointings.width, pointings.height,
;            pointings.ins_x, and pointings.ins_y should match the first
;            raster's rasters.width, rasters.height, rasters.ins_x, and
;            rasters.ins_y, respectively.
;
; CALLING SEQUENCE:
;       MK_POINT_BASE, parent, child [,font=font]
;
; INPUTS:
;       PARENT - ID of parent widget upon which the pointing widget is built
;
; OPTIONAL INPUTS:
;       FONT   - Font name to be used for labelling
;
; OUTPUTS:
;       CHILD  - ID of the base widget being built and leter on remapped
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       DATATYPE, NUM2STR, JUSTIFY
;
; COMMON BLOCKS:
;       FOR_POINTING - Internal common block used by this routine and
;                      MK_POINT_BASE
;       Others       - Included in image_tool_com.pro
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Planning, pointing
;
; PREVIOUS HISTORY:
;       Written January 23, 1995, Liyun Wang, NASA/GSFC
;          Separated from the origina code of IMAGE_TOOL
;
; MODIFICATION HISTORY:
;       Version 2, Liyun Wang, NASA/GSFC, March 8, 1995
;          Added indicator showing if a selected pointed area is pointed
;          Added Warnings if there is any pointing area remain unpointed
;       Version 3, Liyun Wang, NASA/GSFC, March 31, 1995
;          Added undo feature
;       Version 4, Liyun Wang, NASA/GSFC, April 27, 1995
;          Added the FONT keyword
;       Version 5, November 2, 1995, Liyun Wang, NASA/GSFC
;          Modified to cope with image icon stacking
;       Version 6, November 17, 1995, Liyun Wang, NASA/GSFC
;          Added validity check for CDS
;       Version 7, December 27, 1995, Liyun Wang, NASA/GSFC
;          Added pointing for MK_SOHO
;       Version 8, April 17, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug that caused the program crash when switching
;             studies with different pointing numbers
;       Version 9, August 19, 1996, Liyun Wang, NASA/GSFC
;          Corrected an error in plotting rasters with relative pointings
;       Version 10, December 18, 1996, Liyun Wang, NASA/GSFC
;          Modified such that the time projection is turned off if
;             raster is placed off the limb
;       Version 11, February 12, 1997, Liyun Wang, NASA/GSFC
;          Fixed a bug causing text widgets remaining inactive when
;             studies with variable pointings are received
;       Version 12, February 18, 1997, Liyun Wang, NASA/GSFC
;          Added fields SCI_SPEC and ID in pointing tool
;       Version 13, April 1, 1997, Liyun Wang, NASA/GSFC
;          Fixed a bug occurred during plotting off_limb rasters
;
; VERSION:
;       Version 13, April 1, 1997
;-

PRO GET_POINTING_SHAPE, width, height, ppx, ppy, initial=initial
;---------------------------------------------------------------------------
; PURPOSE:
;       Get two vectors that reflect the raster shape for plotting purpose
;
; CALLING SEQUENCE:
;       get_pointing_shape, width, height, ppx, ppy [, initial=initial]
;
; INPUTS:
;       WIDTH  - Width (E/W extent) of the raster, in arcsecs
;       HEIGHT - Height (N/S extent) of the raster, in arcsecs
;
; OPTIONAL INPUTS:
;       INITIAL - A 2-element vector that contains the coordinates (in
;                 arc seconds) of center of the raster.
;
; OUTPUTS:
;       PPX - Array of X positions of each point of a pointing area, in arcsec
;       PPY - Array of Y positions of each point of a pointing area, in arcsec
;
;---------------------------------------------------------------------------
;
   ON_ERROR, 2
   IF N_ELEMENTS(initial) EQ 0 THEN initial = [0, 0]
;----------------------------------------------------------------------
;  x0 and y0 are coordinates of the center of a raster
;----------------------------------------------------------------------
   x0 = initial(0) & y0 = initial(1)
;----------------------------------------------------------------------
;  Almost all rasters have even number of pixels in size, the plotted raster
;  is not exactly centered at the pixel indicated by (x0, y0)
;----------------------------------------------------------------------
   hlf_wid = FIX(width/2)
   hlf_hgt = FIX(height/2)
   IF hlf_wid EQ 0 AND hlf_hgt EQ 0 THEN BEGIN
      ppx = x0
      ppy = y0
   ENDIF ELSE BEGIN
      IF hlf_wid EQ 0 THEN BEGIN
         ppx = [x0, x0]
         IF (hlf_hgt*2 EQ height) THEN yll = y0-hlf_hgt+1 ELSE yll = y0-hlf_hgt
         yur = y0+hlf_hgt
         ppy = [yll, yur]
      ENDIF ELSE IF hlf_hgt EQ 0 THEN BEGIN
         ppy = [y0, y0]
         IF (hlf_wid*2 EQ width) THEN xll = x0-hlf_wid+1 ELSE xll = x0-hlf_wid
         xur = x0+hlf_wid
         ppx = [xll, xur]
      ENDIF ELSE BEGIN
         IF (hlf_wid*2 EQ width) THEN xll = x0-hlf_wid+1 ELSE xll = x0-hlf_wid
         xur = x0+hlf_wid
         IF (hlf_hgt*2 EQ height) THEN yll = y0-hlf_hgt+1 ELSE yll = y0-hlf_hgt
         yur = y0+hlf_hgt
         ppx = [xll, xur, xur, xll, xll]
         ppy = [yll, yll, yur, yur, yll]
      ENDELSE
   ENDELSE
END

FUNCTION rotate_point, position
;---------------------------------------------------------------------------
;  To modify the position of a point according to the solar differential
;  rotation
;---------------------------------------------------------------------------
@image_tool_com
   temp = cnvt_coord(position, csi=csi, from=3, to=2, date=study_start)
   inside = itool_inside_limb(temp(0,*), temp(1,*), csi=csi)
   IF inside THEN BEGIN
      time_diff = (utc2tai(img_utc)-tai_start)/86400.0
      study_start = tai2utc(tai_start)
      helio = cnvt_coord(position, csi=csi, from=3, to=4, $
                         date=study_start)
      helio(1,*) = helio(1,*)+diff_rot(time_diff, helio(0,*), /synodic)
      ii = WHERE(helio(1,*) GE -90.0 AND helio(1,*) LE 90.0, count)
      inside = (count GT 0)
   ENDIF
   IF NOT inside THEN BEGIN
      flash_msg, comment_id, $
         'Pointing area was off the limb and is ' + $
         'plotted at current study start time.', num=2
      WIDGET_CONTROL, point_wid.point_tproj, set_button=0
      time_proj = 0
   ENDIF ELSE BEGIN
      position = cnvt_coord(helio, csi=csi, from=4, to=3, date=img_utc)
   ENDELSE
   RETURN, position
END

FUNCTION point_dshape, width, height, initial=initial, time_proj=time_proj, $
              off_limb=off_limb, csi=csi, adjust=adjust, $
              norotate=norotate

;---------------------------------------------------------------------------
; PURPOSE:
;       To return a 2x5 array as pointing area shape in device coordinates
;
; EXPLANATION:
;       Given the initial posistion (in solar disc coordinates), width and
;       height of a pointing area, this routine returns a 2x5 array
;       representing the shape of the pointing area in device coordinates that
;       can be used for plotting. Time projection and off limb criteria are
;       taken into account via the keywords TIME_PROJ and OFF_LIMB.
;
; CALLING SEQUENCE:
;       result = point_dshape(width, height, initial=initial, csi=csi,$
;                            time_proj=time_proj, off_limb=off_limb)
;
; INPUTS:
;       WIDTH   - Width of the pointing area in arcsecs
;       HEIGHT  - Height of the pointing area in arcsecs
;       INITIAL - Initial position of the pointing area in arcsecs
;       CSI     - Coordinate system info structure
;
; OUTPUTS:
;       RESULT - 2x5 integer array representing the pointing area shape in
;                device pixels
;
; KEYWORD PARAMETERS:
;       TIME_PROJ - Do differential rotating if set
;       OFF_LIMB  - Do not do differential rotating if set
;       ADJUST    - If set, the pointing area position will be adjusted so
;                   that it will be within the display area; Needed when you
;                   just want to starting pointing
;       NOROTATE  - Set this keyword not to differentially rotate
;
; COMMON BLOCKS:
;       ITOOL_AXES_COM (from itool_plot_axes.pro)
;
;---------------------------------------------------------------------------
;
   COMMON itool_axes_com, x_range, y_range

   initial0 = initial

   IF time_proj AND NOT off_limb AND NOT KEYWORD_SET(norotate) THEN $
      initial0 = rotate_point(initial0)

;---------------------------------------------------------------------------
;  If ADJUST is set and initial0 is out of displaying range, make it in
;---------------------------------------------------------------------------
   IF KEYWORD_SET(adjust) THEN BEGIN
      IF initial0(0) LT x_range(0) OR initial0(0) GT x_range(1) THEN $
         initial0(0) = 0.5*(x_range(0)+x_range(1))
      IF initial0(1) LT y_range(0) OR initial0(1) GT y_range(1) THEN $
         initial0(1) = 0.5*(y_range(0)+y_range(1))
   ENDIF

   get_pointing_shape, width, height, ppx, ppy, initial = initial0
;----------------------------------------------------------------------
;  convert ppx and ppy into graphic device coordinates
;----------------------------------------------------------------------
   temp = TRANSPOSE([[ppx],[ppy]])
   temp = cnvt_coord(temp,from=3,to=1,csi=csi)
   RETURN, temp
END

PRO SET_POINT_BASE
;----------------------------------------------------------------------
;  Update contents on the point widget base
;----------------------------------------------------------------------
;
@image_tool_com
   COMMON for_pointing, pointing_done, saved_pointings, central_pos, $
      saved_x, saved_y, saved_pt

   ON_ERROR, 2
   IF N_ELEMENTS(index) EQ 0 THEN index = 0
   IF N_ELEMENTS(csi) EQ 0 THEN RETURN

;---------------------------------------------------------------------------
;  Warn the user if the pointing area is wider than the displayed image
;---------------------------------------------------------------------------
   sz = SIZE(image_arr)
   index = 0 > index < (pointing_stc.n_pointings-1)
   IF index LT 0 THEN index = 0

   IF pointing_stc.do_pointing EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     No pointing change is allowed or needed
;---------------------------------------------------------------------------
      WIDGET_CONTROL, point_wid.point_go, sensitive=0
      WIDGET_CONTROL, point_wid.pointed, set_button=1, sensitive=0
      WIDGET_CONTROL, point_wid.point_x, sensitive=0
      WIDGET_CONTROL, point_wid.point_y, sensitive=0

      pointing_done(index) = 1
      WIDGET_CONTROL, point_wid.raster_plot, $
         sensitive=(pointing_stc.n_rasters GT 1)
   ENDIF ELSE BEGIN
      WIDGET_CONTROL, point_wid.point_go, sensitive=1
      WIDGET_CONTROL, point_wid.point_x, sensitive=1
      WIDGET_CONTROL, point_wid.point_y, sensitive=1
      WIDGET_CONTROL, point_wid.pointed, sensitive=1
   ENDELSE

   WIDGET_CONTROL, point_wid.point_list, set_list_select=index

   IF WIDGET_INFO(comment_id, /valid) THEN BEGIN
      IF pointing_stc.pointings(index).width GT csi.srx*sz(1) OR $
         pointing_stc.pointings(index).height GT csi.sry*sz(2) THEN $
         WIDGET_CONTROL, comment_id, set_value=$
         'Warning: Pointing area is wider than the image area!'
   ENDIF

   WIDGET_CONTROL, point_wid.point_size, set_value=$
      STRTRIM(FIX(pointing_stc.pointings(index).width),2)+' X '+$
      STRTRIM(FIX(pointing_stc.pointings(index).height),2)
   WIDGET_CONTROL, point_wid.point_cnt, set_value=num2str(index)
   WIDGET_CONTROL, point_wid.point_x, set_value=$
      num2str(pointing_stc.pointings(index).ins_x, FORMAT='(f8.2)')
   WIDGET_CONTROL, point_wid.point_y, set_value=$
      num2str(pointing_stc.pointings(index).ins_y, FORMAT='(f8.2)')

   WIDGET_CONTROL, point_wid.zone, set_value=pointing_stc.pointings(index).zone
END

PRO pt_button_update, widgets=point_wid, status=status, n_rasters=n_rasters
;---------------------------------------------------------------------------
;  Make sure that buttons look right
;---------------------------------------------------------------------------
   IF status THEN BEGIN
      WIDGET_CONTROL, point_wid.pointed, set_button=1
      WIDGET_CONTROL, point_wid.point_id, sensitive=1
      WIDGET_CONTROL, point_wid.raster_plot, sensitive=(n_rasters GT 1)
   ENDIF ELSE BEGIN
      WIDGET_CONTROL, point_wid.point_id, sensitive=0
      WIDGET_CONTROL, point_wid.pointed, set_button=0
      WIDGET_CONTROL, point_wid.raster_plot, sensitive=0
   ENDELSE
END

PRO pointing_reset, pointing_stc, widgets=point_wid
;---------------------------------------------------------------------------
;  Reset the pointing base upon a given pointing structure
;---------------------------------------------------------------------------
   COMMON for_pointing
   IF pointing_stc.n_pointings EQ 1 THEN $
      WIDGET_CONTROL, point_wid.point_label, set_value='1 POINTING' $
   ELSE $
      WIDGET_CONTROL, point_wid.point_label, $
      set_value=num2str(pointing_stc.n_pointings)+' POINTINGS'

   IF pointing_stc.n_pointings GT 0 THEN BEGIN
      pointing_done = INTARR(pointing_stc.n_pointings)
      FOR i=0, pointing_stc.n_pointings-1 DO BEGIN
         IF N_ELEMENTS(pointing_list) EQ 0 THEN $
            pointing_list = '  '+$
            STRTRIM(pointing_stc.pointings(i).point_id, 2) $
         ELSE $
            pointing_list = [pointing_list,'  '+$
                             STRTRIM(pointing_stc.pointings(i).point_id,2)]
      ENDFOR
   ENDIF ELSE BEGIN
      pointing_list = '  '+'0'
      pointing_done = INTARR(1)
   ENDELSE
   WIDGET_CONTROL, point_wid.sci_spec, set_value=pointing_stc.sci_spec

   IF pointing_stc.std_id GT 0 THEN $
      WIDGET_CONTROL, point_wid.std_id, $
      set_value=STRTRIM(pointing_stc.std_id, 2) $
   ELSE $
      WIDGET_CONTROL, point_wid.std_id, set_value='N/A'

   WIDGET_CONTROL, point_wid.point_list, set_value=pointing_list
   WIDGET_CONTROL, point_wid.undo_one, sensitive=0
   WIDGET_CONTROL, point_wid.undo_all, sensitive=0
   WIDGET_CONTROL, point_wid.raster_plot, sensitive=0
   WIDGET_CONTROL, point_wid.point_id, sensitive=0
   WIDGET_CONTROL, point_wid.pointed, set_button=0
   
   saved_pointings = pointing_stc.pointings
   set_point_base
END

PRO pointing_update
@image_tool_com
   COMMON for_pointing

;---------------------------------------------------------------------------
;  Check if the pointing parameter is valid
;---------------------------------------------------------------------------
   IF pointing_stc.instrume EQ 'C' THEN BEGIN
      IF NOT valid_cds_point(central_pos(0),central_pos(1)) THEN BEGIN
         flash_msg, comment_id, 'Invalid pointing parameter!', num=2
         WAIT, 2
         WIDGET_CONTROL, comment_id, set_value=''
         RETURN
      ENDIF
   ENDIF

   IF pointing_stc.instrume EQ 'S' THEN BEGIN
      dprint, 'Pointing is yet to be validated.'
   ENDIF

   IF pointing_stc.pointings(index).off_limb THEN BEGIN
;---------------------------------------------------------------------------
;     Check to see (by looking at the 4 corners of the pointing area)
;     if the pointing area is off the limb
;---------------------------------------------------------------------------
      get_pointing_shape, pointing_stc.pointings(index).width, $
         pointing_stc.pointings(index).height, ppx, ppy, initial = central_pos
      temp = cnvt_coord(TRANSPOSE([[ppx], [ppy]]), csi=csi, from=3, to=4, $
                        date=img_utc, off_limb=off_limb)
      tmp = WHERE(off_limb EQ 1, cnt)
      IF cnt LT 5 THEN BEGIN
         flash_msg, comment_id, 'Criteria is not met!', num = 2
         RETURN
      ENDIF
   ENDIF
   IF (pointing_stc.pointings(index).ins_x NE central_pos(0) OR $
       pointing_stc.pointings(index).ins_y NE central_pos(1)) THEN BEGIN
      pointing_stc.pointings(index).ins_x = central_pos(0)
      pointing_stc.pointings(index).ins_y = central_pos(1)
      pointing_done(index) = 1
   ENDIF
   pt_button_update, widgets=point_wid, status=pointing_done(index), $
      n_rasters=pointing_stc.n_rasters
   WIDGET_CONTROL, point_wid.undo_one, sensitive=1
   WIDGET_CONTROL, point_wid.undo_all, sensitive=1
   set_point_base
  RETURN
END

PRO pointing_event, event, uvalue
;---------------------------------------------------------------------------
; PURPOSE:
;       Event handler for events generated by the pointing base widget
;
; CALLING SEQUENCE:
;       pointing_event, event, uvalue
;
; INPUTS:
;       EVENT  - The event structure handled by XMANAGER
;       UVALUE - uvalue of the EVENT
;
; COMMON BLOCKS:
;       FOR_POINTING - Internal common block used by this routine and
;                      MK_POINT_BASE
;       Others       - Included in image_tool_com.pro
;---------------------------------------------------------------------------
;
@image_tool_com

   COMMON for_pointing

;---------------------------------------------------------------------------
;  Use the rather crude help system for now
;---------------------------------------------------------------------------
   IF help_mode THEN BEGIN
      xshow_help, help_stc, 'POINTING', tbase = help_wbase
      RETURN
   ENDIF

   tmp = WHERE(pointing_done EQ 1, count)
   IF count LT pointing_stc.n_pointings THEN exit_ok = 0 ELSE exit_ok = 1
   WIDGET_CONTROL, pointing_base, get_uvalue = point_wid
   CASE (uvalue) OF
      'POINT_DONE': BEGIN
         IF NOT exit_ok THEN BEGIN
            exit_ok = xanswer([' ', 'Warning!!!', $
                               'Not all pointing values are changed.', $
                               'Do you wish to finish pointing any way?', $
                               ' '], /beep, /supp, group=event.top, /center)
         ENDIF
         IF exit_ok THEN BEGIN
            WIDGET_CONTROL, pointing_base, map=0
            WIDGET_CONTROL, source_base, map=1
            pointing_flag = 0
            WIDGET_CONTROL, comment_id, set_value=' '
            itool_refresh
         ENDIF
      END
      'POINT_TPROJ': BEGIN
         IF time_proj EQ 1 THEN time_proj = 0 ELSE time_proj = 1
      END
      'POINT_GO': BEGIN
         WIDGET_CONTROL, draw_icon, draw_button=0
         WIDGET_CONTROL, csr_bt, set_value='Central Position'
         xack, ['You are about to enter a special mode which requires your', $
                'attention. Instructions on how to operate in this mode', $
                'will be shown in the message window. ', '', $
                'To get out of this mode, you need to (perhaps repeatedly)', $
                'press the *right* mouse button.'], $
            group=event.top, /modal, instru='Proceed', /suppress
         WIDGET_CONTROL, comment_id, $
            set_value = ['You are now looking at the raster you have chosen.',$
                         'Press and drag the left mouse button to move the '+$
                         'raster, and right button to exit.']

         initial0 = [pointing_stc.pointings(index).ins_x, $
                     pointing_stc.pointings(index).ins_y]

         temp = point_dshape(pointing_stc.pointings(index).width,$
                             pointing_stc.pointings(index).height,$
                             initial=initial0, time_proj=time_proj,$
                             off_limb=pointing_stc.pointings(index).off_limb,$
                             csi=csi, /adjust)
         IF !d.window NE root_win THEN setwindow, root_win
         polygon_csr, temp(0, *), temp(1, *), csi=csi, color=l_color, $
            keep_csr=keep_csr, widget_id=txt_id, pointing=central_pos, $
            d_mode=d_mode
         WIDGET_CONTROL, csr_bt, set_value='Cursor Position'
         WIDGET_CONTROL, comment_id, set_value=''
         central_pos = cnvt_coord(central_pos, csi=csi, from=1, to=3)
         radial = SQRT(central_pos(0)*central_pos(0)+$
                       central_pos(1)*central_pos(1))
         IF (radial GT csi.radius AND time_proj) THEN BEGIN
            flash_msg, comment_id, $
               ['Warning: Time projection option is turned off because you '+$
                'have placed the raster off the limb.'], num=2
            time_proj = 0
            WIDGET_CONTROL, point_wid.point_tproj, set_button=0
         ENDIF
;----------------------------------------------------------------------
;        Currently I decide that only when the time_proj flag
;        is on (with value 1) does the time projection rotate take place
;----------------------------------------------------------------------
         IF time_proj AND NOT pointing_stc.pointings(index).off_limb THEN BEGIN
;----------------------------------------------------------------------
;           Depending on the image observation time and the starting time of
;           the raster, we need to rotate the raster pointing forward from the
;           image observation time to the actual time at which the study
;           begins. If the time lag is greater such that the poiting of the
;           raster would be off, the user is warned, and no correction due to
;           rotation is made
;----------------------------------------------------------------------
            time_diff = (tai_start-utc2tai(img_utc))/86400.0
            helio = cnvt_coord(central_pos, csi=csi, from=3, to=4, $
                               date=img_utc)
            helio(1) = helio(1)+diff_rot(time_diff, helio(0), /synodic)
            long_diff = 90.0-helio(1)
            IF (long_diff LE 0.0 OR long_diff GE 180.0) THEN BEGIN
;---------------------------------------------------------------------------
;              Pointing center off the limb
;---------------------------------------------------------------------------
               flash_msg, comment_id, $
                  ['Warning: The projected raster at the time of '+$
                   'observation will be off the limb!', $
                   'Pointing shown is for the time at '+$
                   'which this displayed image was made.'], num = 2
               WIDGET_CONTROL, point_wid.point_tproj, set_button=0
               time_proj = 0
            ENDIF ELSE BEGIN
;----------------------------------------------------------------------
;              When converting rotated pointing back, actual study time
;              should be used
;----------------------------------------------------------------------
               new_date = tai2utc(tai_start)
               central_pos =cnvt_coord(helio,csi=csi,from=4,to=3,date=new_date)
            ENDELSE
         ENDIF
         WIDGET_CONTROL, draw_icon, draw_button=1
         pointing_update
      END
      'UNDO_ONE': BEGIN
         IF N_ELEMENTS(saved_x) NE 0 THEN BEGIN
            pointing_stc.pointings(index).ins_x = saved_x
            pointing_stc.pointings(index).ins_y = saved_y
            pointing_done(index) = saved_pt
            WIDGET_CONTROL, point_wid.pointed, set_button = saved_pt
         ENDIF ELSE BEGIN
            pointing_stc.pointings(index).ins_x = saved_pointings(index).ins_x
            pointing_stc.pointings(index).ins_y = saved_pointings(index).ins_y
            pointing_done(index) = 0
            saved_pt = 0
            WIDGET_CONTROL, point_wid.pointed, set_button = 0
         ENDELSE
         WIDGET_CONTROL, point_wid.point_id, sensitive = saved_pt
         WIDGET_CONTROL, point_wid.undo_one, sensitive = 0
         WIDGET_CONTROL, point_wid.raster_plot, sensitive = (saved_pt $
            AND pointing_stc.n_rasters GT 1)
         set_point_base
      END
      'UNDO_ALL': BEGIN
         IF xanswer([' ', 'Are you sure?', ' '], /beep, $
                    group=event.top, /center) THEN BEGIN
            pointing_stc.pointings = saved_pointings
            pointing_done(*) = 0
            saved_pt = 0
            saved_x = pointing_stc.pointings(index).ins_x
            saved_y = pointing_stc.pointings(index).ins_y
            WIDGET_CONTROL, point_wid.undo_all, sensitive = 0
            WIDGET_CONTROL, point_wid.undo_one, sensitive = 0
            WIDGET_CONTROL, point_wid.pointed, set_button = 0
            WIDGET_CONTROL, point_wid.point_id, sensitive = 0
            WIDGET_CONTROL, point_wid.raster_plot, sensitive = 0
            set_point_base
         ENDIF
      END
      'POINTED': BEGIN
;---------------------------------------------------------------------------
;        Toggles the current selected pointing area pointed or unpointed
;---------------------------------------------------------------------------
         IF pointing_done(index) THEN BEGIN
            pointing_done(index) = 0
            WIDGET_CONTROL, point_wid.point_id, sensitive = 0
            WIDGET_CONTROL, point_wid.raster_plot, sensitive = 0
;            WIDGET_CONTROL, point_wid.undo_one, sensitive = 0
;---------------------------------------------------------------------------
;           Save current pointing
;---------------------------------------------------------------------------
            saved_x = pointing_stc.pointings(index).ins_x
            saved_y = pointing_stc.pointings(index).ins_y
         ENDIF ELSE BEGIN
            pointing_done(index) = 1
            WIDGET_CONTROL, point_wid.point_id, sensitive = 1
            WIDGET_CONTROL, point_wid.raster_plot, $
               sensitive = (pointing_stc.n_rasters GT 1)
         ENDELSE
         tmp = WHERE(pointing_done EQ 1, count)
         IF count LT pointing_stc.n_pointings THEN exit_ok = 0 ELSE exit_ok = 1
      END
      'POINT_ID': BEGIN
         IF NOT itool_getxy_field(event) THEN RETURN
         IF pointing_done(index) THEN BEGIN
            initial = [pointing_stc.pointings(index).ins_x, $
                       pointing_stc.pointings(index).ins_y]

            temp = point_dshape(pointing_stc.pointings(index).width, $
                                pointing_stc.pointings(index).height, $
                                initial=initial, time_proj=time_proj, $
                                off_limb=pointing_stc.pointings(index).off_limb, $
                                csi=csi)
            flash_plots, temp(0,*), temp(1,*), color = (l_color/2 > 0)
         ENDIF ELSE BEGIN
            flash_msg, comment_id, 'That raster has not been ' + $
               'pointed yet.', num = 2
         ENDELSE
      END
      'POINT_PLOT': BEGIN
         itool_point_plot
      END
      'RASTER_PLOT': BEGIN
;----------------------------------------------------------------------
;        Raster plotting only applies to the case where there are more than 1
;        raster in each pointing area. This is irrelevant to the SUMER.
;
;        First find the target raster (the first in the list that has pointing
;        value being 1, or if there is no such raster, being 0)
;----------------------------------------------------------------------
         IF NOT itool_getxy_field(event) THEN RETURN
         ii = WHERE(pointing_stc.rasters.pointing EQ 1, cnt)
         IF cnt NE 0 THEN BEGIN
            initial0 = [pointing_stc.pointings(index).ins_x, $
                        pointing_stc.pointings(index).ins_y]
         ENDIF ELSE BEGIN
            dhelp, 'No raster with deferred point_wid..'
            ii = (WHERE(pointing_stc.rasters.pointing EQ 0, cnt))(0)
            IF cnt NE 0 THEN BEGIN
               initial0 = [pointing_stc.rasters(ii).ins_x, $
                           pointing_stc.rasters(ii).ins_y]
            ENDIF ELSE BEGIN
               PRINT, 'Target raster not found.'
               RETURN
            ENDELSE
         ENDELSE
         WIDGET_CONTROL, /hour
         IF !d.window NE root_win THEN setwindow, root_win
         IF time_proj AND NOT pointing_stc.pointings(index).off_limb THEN $
            initial0 = rotate_point(initial0)
         itool_restore_pix, pix_win
         FOR i = 0, pointing_stc.n_rasters-1 DO BEGIN
            CASE (pointing_stc.rasters(i).pointing) OF
               -1: BEGIN
;---------------------------------------------------------------------------
;                 Raster position is offset from the first one
;---------------------------------------------------------------------------
                  initial = initial0+[pointing_stc.rasters(i).ins_x,$
                                      pointing_stc.rasters(i).ins_y]
;                  IF time_proj THEN initial = rotate_point(initial)
                  get_pointing_shape, pointing_stc.rasters(i).width, $
                     pointing_stc.rasters(i).height, ppx, ppy, $
                     initial = initial
                  linestyle = 1
               END
               0: BEGIN
;---------------------------------------------------------------------------
;                 Raster position is determined at the study level
;---------------------------------------------------------------------------
                  initial = [pointing_stc.rasters(i).ins_x, $
                             pointing_stc.rasters(i).ins_y]
                  IF time_proj THEN initial = rotate_point(initial)
                  get_pointing_shape, pointing_stc.rasters(i).width, $
                     pointing_stc.rasters(i).height, ppx, ppy, $
                     initial = initial
                  linestyle = 2
               END
               1: BEGIN
;---------------------------------------------------------------------------
;                 Raster position is the same as the pointings(index).ins_x
;                 and pointings(index).ins_y
;---------------------------------------------------------------------------
                  dprint, 'This is a deferred-pointing raster...'
                  get_pointing_shape, pointing_stc.rasters(i).width, $
                     pointing_stc.rasters(i).height, ppx, ppy, $
                     initial = initial0
                  linestyle = 0
               END
            ENDCASE
            temp = TRANSPOSE([[ppx],[ppy]])
            temp = cnvt_coord(temp,csi=csi,from=3,to=1)
            PLOTS, temp(0,*), temp(1,*), /dev, color = l_color, $
               linestyle = linestyle
         ENDFOR
         itool_copy_to_pix
      END
      'POINT_X': BEGIN
         IF NOT itool_getxy_field(event) THEN RETURN
         WIDGET_CONTROL, point_wid.point_y, /input_focus
;         WIDGET_CONTROL, point_wid.point_x, get_value = temp
;         central_pos = [temp,pointing_stc.pointings(index).ins_y]
;         saved_x = pointing_stc.pointings(index).ins_x
;         saved_y = pointing_stc.pointings(index).ins_y
;         saved_pt = pointing_done(index)
;         pointing_update
      END
      'POINT_Y': BEGIN
         IF NOT itool_getxy_field(event) THEN RETURN
         WIDGET_CONTROL, point_wid.point_x, /input_focus
;          WIDGET_CONTROL, point_wid.point_y, get_value = temp
;          central_pos = [pointing_stc.pointings(index).ins_x,temp]
;          WIDGET_CONTROL, point_wid.point_x, /input_focus
;          saved_x = pointing_stc.pointings(index).ins_x
;          saved_y = pointing_stc.pointings(index).ins_y
;          saved_pt = pointing_done(index)
;          pointing_update
      END
      'POINT_LIST': BEGIN
         IF NOT itool_getxy_field(event) THEN RETURN
         index = event.index
         WIDGET_CONTROL, point_wid.undo_one, sensitive = 0
         pt_button_update, widgets=point_wid, status=pointing_done(index), $
            n_rasters=pointing_stc.n_rasters
;---------------------------------------------------------------------------
;        Save current pointing
;---------------------------------------------------------------------------
         saved_x = pointing_stc.pointings(index).ins_x
         saved_y = pointing_stc.pointings(index).ins_y
         saved_pt = pointing_done(index)
         set_point_base
      END
      ELSE:
   ENDCASE
   RETURN
END

PRO MK_POINT_BASE, parent, child, font=font
;---------------------------------------------------------------------------
; PURPOSE:
;       Main program to create the pointing widget
;
; CALLING SEQUENCE:
;       mk_point_base, parent, child [, font=font]
;
; INPUTS:
;       PARENT - ID of the parent base widget on which pointing widget
;                is built up
; OUTPUTS:
;       CHILD  - ID of the pointing base widget
;
; KEYWORD PARAMETERS:
;       FONT   - Basic font to be used in pointing widget
;---------------------------------------------------------------------------
;
@image_tool_com
   COMMON for_pointing

   ON_ERROR, 2

;---------------------------------------------------------------------------
;  Check validity of the given STUDY structure
;---------------------------------------------------------------------------
   IF datatype(pointing_stc) NE 'STC' THEN BEGIN
      MESSAGE, 'Invalid parameter type.',/cont
      RETURN
   ENDIF
   IF N_ELEMENTS(TAG_NAMES(pointing_stc)) NE 13 OR $
      N_ELEMENTS(TAG_NAMES(pointing_stc.pointings)) NE 7 OR $
      N_ELEMENTS(TAG_NAMES(pointing_stc.rasters)) NE 5 THEN BEGIN
      MESSAGE, 'Invalid pointing structure.',/cont
      RETURN
   ENDIF
   IF N_ELEMENTS(font) EQ 0 THEN font = 'fixed'

;---------------------------------------------------------------------------
;  Clean some variables in common block
;---------------------------------------------------------------------------
   IF N_ELEMENTS(saved_x) NE 0 THEN delvarx, saved_x, saved_y, saved_pt

   bfont = '-adobe-courier-bold-r-normal--20-140-100-100-m-110-iso8859-1'
   bfont = (get_dfont(bfont))(0)

   title = 'Pointing Tool'
;---------------------------------------------------------------------------
;  Since this is a general routine to create an instrument base, it should
;  always be unmapped initially. The return widget ID "child" is used to map
;  the base
;---------------------------------------------------------------------------
   child = WIDGET_BASE(parent, /column, map=0, xpad=10)
   temp = WIDGET_LABEL(child, value='')
   temp = WIDGET_LABEL(child, value=title, font=bfont)
   temp = WIDGET_LABEL(child, value='')

   temp = WIDGET_BASE(child, /row, xpad=10)
   point_done = WIDGET_BUTTON(temp, value='Exit Pointing Tool', $
                              uvalue='POINT_DONE')
   ptool_send = WIDGET_BUTTON(temp, uvalue='send', $
                              value='Send to Planning Tool')

   temp = WIDGET_LABEL(child, value='')

;----------------------------------------------------------------------
;  The pointing button row
;----------------------------------------------------------------------
   tmp = WIDGET_BASE(child, /row, /frame)
   point_go = WIDGET_BUTTON(tmp, value='Go', uvalue='POINT_GO')

   undo_one = WIDGET_BUTTON(tmp, value='Undo', uvalue='UNDO_ONE')

   undo_all = WIDGET_BUTTON(tmp, value='Undo All', uvalue='UNDO_ALL')

   temp = WIDGET_BUTTON(tmp, value='Plot', /menu)
   point_plot = WIDGET_BUTTON(temp, value='All Pointing Areas', $
                              uvalue='POINT_PLOT')
   raster_plot = WIDGET_BUTTON(temp, uvalue='RASTER_PLOT', $
                               value='All Rasters for Current Pointing')

   point_id = WIDGET_BUTTON(tmp, value='Identify', uvalue='POINT_ID')

;----------------------------------------------------------------------
;  Make a toggle button to enable/disable time projection. Default is
;  to allow time projection
;----------------------------------------------------------------------
   temp = WIDGET_BASE(child, /row)
   tmp = WIDGET_BASE(temp, /nonexclusive, /frame)
   point_tproj = WIDGET_BUTTON(tmp, value='Allow Time Projection', $
                               uvalue='POINT_TPROJ')
   IF N_ELEMENTS(time_proj) NE 0 THEN BEGIN
      IF time_proj THEN WIDGET_CONTROL, point_tproj, set_button=1 $
      ELSE WIDGET_CONTROL, point_tproj, set_button=0
   ENDIF ELSE BEGIN
      time_proj = 1
      WIDGET_CONTROL, point_tproj, set_button=1
   ENDELSE
   tmp = WIDGET_LABEL(temp, value=' ', font=font)
   tmp = WIDGET_BASE(temp, /row, /frame)
   tmp0 = WIDGET_LABEL(tmp, value='ID', font=font)
   std_id = WIDGET_TEXT(tmp, value='', font=font, xsize=5)

   tmp0 = WIDGET_BASE(child, /column, /frame)
   tmp = WIDGET_BASE(tmp0, /row)
   lb = WIDGET_LABEL(tmp, value='SCI_SPEC', font=font)
   sci_spec = WIDGET_TEXT(tmp, value='', font=font, xsize=30)

   sr_row3 = WIDGET_BASE(child, /row, space=10)

   sr_left = WIDGET_BASE(sr_row3, /column, /frame)
   point_label = WIDGET_LABEL(sr_left, value='', font=font)

   tmp = WIDGET_LABEL(sr_left, value=pointing_stc.g_label, font=font)

   point_list = WIDGET_LIST(sr_left, ysize=9, xsize=4, uvalue='POINT_LIST', $
                            font=font)

   tmp = WIDGET_BASE(sr_row3, /column, /frame)
;---------------------------------------------------------------------------
;  Get maximum length of labels
;---------------------------------------------------------------------------
   max_len = 8
   IF STRLEN(pointing_stc.x_label) GT max_len THEN $
      max_len = STRLEN(pointing_stc.x_label)
   IF STRLEN(pointing_stc.y_label) GT max_len THEN $
      max_len = STRLEN(pointing_stc.y_label)
   tmp1 = WIDGET_BASE(tmp, /row)
   tmp2 = WIDGET_LABEL(tmp1, font=font, value=$
                       justify('POINTING', MAX=max_len, just='>'))
   point_cnt = WIDGET_TEXT(tmp1, value='1', font=font, xsize=2)
   tmp2 = WIDGET_BASE(tmp1, /row, /nonexclusive)
   pointed = WIDGET_BUTTON(tmp2, value='POINTED', uvalue='POINTED', $
                           font=font)

   tmp1 = WIDGET_BASE(tmp, /row)
   tmp2 = WIDGET_LABEL(tmp1, font=font, value=$
                       justify('SIZE', MAX=max_len, just='>'))
   point_size = WIDGET_TEXT(tmp1, value='120x120', font=font, $
                            xsize=16)

;---------------------------------------------------------------------------
;  cw_field can be used here, but it won't accept /input_focus
;---------------------------------------------------------------------------
   temp = WIDGET_BASE(tmp,/row)
   tmp1 = WIDGET_LABEL(temp, value=justify(pointing_stc.x_label, MAX=max_len, $
                                           just='>'), font=font)
   point_x = WIDGET_TEXT(temp, value='0.0', uvalue='POINT_X', $
                         font=font, xsize=8, /editable)
   tmp1 = WIDGET_LABEL(temp, value='"', font=font)

   temp = WIDGET_BASE(tmp,/row)
   tmp1 = WIDGET_LABEL(temp, value=justify(pointing_stc.y_label, MAX=max_len, $
                                           just='>'), font=font)
   point_y = WIDGET_TEXT(temp, value='0.0', uvalue='POINT_Y', $
                         font=font, xsize=8, /editable)
   tmp1 = WIDGET_LABEL(temp, value='"', font=font)

   temp = WIDGET_BASE(tmp,/row)
   tmp1 = WIDGET_LABEL(temp, font=font, value=$
                       justify('ZONE', MAX=max_len, just='>'))
   zone = WIDGET_TEXT(temp, value=' ', font=font, xsize=16)

   point_wid = {point_x:point_x, point_y:point_y, point_size:point_size, $
                point_cnt:point_cnt, point_go:point_go, pointed:pointed, $
                undo_one:undo_one, point_label:point_label, $
                point_list:point_list, point_tproj:point_tproj, $
                point_id:point_id, undo_all:undo_all, $
                raster_plot:raster_plot, zone:zone, $
                sci_spec:sci_spec, std_id:std_id}
   IF pointing_stc.n_pointings GT 0 THEN $
      pointing_done = INTARR(pointing_stc.n_pointings) $
   ELSE BEGIN
      pointing_done = INTARR(1)
   ENDELSE

   pointing_reset, pointing_stc, widgets=point_wid

;---------------------------------------------------------------------------
;  Save widget IDs and other info into the UVALUE of base CHILD as a structure
;---------------------------------------------------------------------------
   WIDGET_CONTROL, child, set_uvalue = point_wid
END

;---------------------------------------------------------------------------
; End of 'mk_point_base.pro'.
;---------------------------------------------------------------------------
