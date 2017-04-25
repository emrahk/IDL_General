PRO itool_point_plot
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_POINT_PLOT
;
; PURPOSE: 
;       Plot all pointing area in Pointing Tool
;
; CATEGORY:
;       Image Tool, Pointing Tool
; 
; SYNTAX: 
;       itool_point_plot
;
; HISTORY:
;       Version 1, July 30, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
@image_tool_com

if not exist(image_arr) then return

   COMMON for_pointing

;----------------------------------------------------------------------
;  When plotting a pointing area, it is plotted against the displayed
;  image which was possibly taken a period of time earlier than
;  the study starting time. Therefore, the pointing area should be
;  plotted at the position where the area would have been at
;  the imaging time. In other words, the pointing area should be
;  rotated back to the imaging time when plotted. Of course, if
;  the center of the pointing area would be off the limb, we just have
;  to warn the user and plot the raster at the study starting time.
;----------------------------------------------------------------------
   IF !d.window NE root_win THEN setwindow, root_win
   WIDGET_CONTROL, /hour
   IF NOT itool_getxy_field(event) THEN RETURN
   initial = [[pointing_stc.pointings.ins_x], [pointing_stc.pointings.ins_y]]
;---------------------------------------------------------------------------
;  Do the rotation outside of the loop
;---------------------------------------------------------------------------
   itool_restore_pix, pix_win
   IF time_proj THEN initial = pt_rotate_point(initial)
   FOR i=0, pointing_stc.n_pointings-1 DO BEGIN
      init_pos = [initial(i, 0), initial(i, 1)]
      temp = pt_fov_dshape(pointing_stc.pointings(i).width, $
                           pointing_stc.pointings(i).height, $
                           initial=init_pos, time_proj=time_proj, $
                           off_limb=pointing_stc.pointings(i).off_limb, $
                           csi=csi, /norotate)
      PLOTS, temp(*, 0), temp(*, 1), /dev, color=l_color
   ENDFOR
   itool_copy_to_pix
   RETURN
END

