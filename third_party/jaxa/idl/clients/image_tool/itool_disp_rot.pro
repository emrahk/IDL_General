;---------------------------------------------------------------------------
; Document name: itool_disp_rot.pro
; Created by:    Liyun Wang, NASA/GSFC, September 9, 1997
;
; Last Modified: Tue Sep  9 10:33:12 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_DISP_ROT
;
; PURPOSE: 
;       Plot diff. rotation indicator over the displayed image
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       itool_disp_rot, rot_code
;
; INPUTS:
;       ROT_CODE - Type of rotation (1 -- 5)
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
;       @image_tool_com
;
; RESTRICTIONS: 
;       A point must be selected and must be inside the solar limb 
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 9, 1997, Liyun Wang, NASA/GSFC. Written
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
PRO itool_rotplot, temp
;---------------------------------------------------------------------------
;  temp is Nx2 array
;---------------------------------------------------------------------------
@image_tool_com
   msec = LONG(time_gap*8640000.0) ; in milliseconds
   cur_time = anytim2utc(disp_utc)
   cur_time.time = cur_time.time+msec(0)
   new_date = anytim2utc(cur_time, /external)
   temp = cnvt_coord(temp, csi=csi, from=4, to=1, date=new_date)
   PLOTS, temp(*, 0), temp(*, 1), /dev, color=!d.table_size-1, $
      noclip=0, clip=[csi.drpix1, csi.drpix2, csi.drpix2+csi.daxis1, $
                      csi.drpix2+csi.daxis2]
END

PRO itool_disp_rot, rot_code   
@image_tool_com   
   ON_ERROR, 2
   IF N_ELEMENTS(rot_code) EQ 0 THEN RETURN
   IF !d.window NE root_win THEN setwindow, root_win
   IF rot_code LT 3 THEN BEGIN 
      IF N_ELEMENTS(eventx) EQ 0 THEN RETURN
      old_pos = [eventx, eventy]
      tmp = cnvt_coord(eventx, eventy, csi=csi, from=1, to=3)
      IF SQRT(tmp(0, 0)*tmp(0, 0)+tmp(0, 1)*tmp(0, 1)) GT csi.radius THEN BEGIN
         flash_msg, comment_id, num=3, $
            'The selected point must be inside the solar limb!'
         RETURN
      ENDIF
   ENDIF
   CASE (rot_code) OF
      1: BEGIN 
;---------------------------------------------------------------------------
;        Rotate 1 point
;---------------------------------------------------------------------------
         helio = cnvt_coord(old_pos(0), old_pos(1), csi=csi, from=1, $
                            to=4, date=disp_utc)
         msec = LONG(time_gap*8640000.0) ; in milliseconds
         cur_time = anytim2utc(disp_utc)
         cur_time.time = cur_time.time+msec(0)
         new_date = anytim2utc(cur_time, /external)
         helio(0, 1) = helio(0, 1)+diff_rot(time_gap, helio(0, 0), /synodic)
         IF (90.0-helio(0, 1)) LE 0 THEN BEGIN
            flash_msg, comment_id, 'The point will be off the limb!'
            RETURN
         ENDIF
         itool_restore_pix, pix_win
         new_pos = cnvt_coord(helio, csi=csi, from=4, to=1, date=new_date)
         PLOTS, [old_pos(0), new_pos(0, 0)], [old_pos(1), new_pos(0, 1)], $
            /dev, color=!d.table_size-1
         itool_copy_to_pix
         itool_cross_hair, new_pos(0), new_pos(1), cursor_wid, cursor_ht, $
            cursor_unit, csi=csi, color=l_color, /keep, $
            boxed_cursor=boxed_CURSOR, pixmap=pix_win
      END
      2: BEGIN
;---------------------------------------------------------------------------
;        Rotate points that have the same longitude value
;---------------------------------------------------------------------------
         helio = cnvt_coord(old_pos(0), old_pos(1), csi=csi, $
                            from=1, to=4, date=disp_utc)
         lat = 2.0*FINDGEN(85)-84.0
         longi = FLTARR(N_ELEMENTS(lat))
         longi(*) = helio(0, 1)
         temp = cnvt_coord(lat, longi, csi=csi, from=4, to=1, date=new_date)
         itool_restore_pix, pix_win
         PLOTS, temp(*, 0), temp(*, 1), /dev, color=!d.table_size-1, $
            noclip=0, clip=[csi.drpix1, csi.drpix2, csi.drpix2+csi.daxis1, $
                            csi.drpix2+csi.daxis2], linestyle=2
         temp = [[lat], [longi+diff_rot(time_gap, lat, /synodic)]]
         itool_rotplot, temp
         itool_copy_to_pix         
      END
      3: BEGIN
;---------------------------------------------------------------------------
;        Rotate points that have the same Solar X value
;---------------------------------------------------------------------------
         IF N_ELEMENTS(eventx) EQ 0 THEN RETURN
         old_pos = [eventx, eventy]
         tmp = cnvt_coord(eventx, eventy, csi=csi, from=1, to=2)
         rpixel = LONG(csi.radius/csi.cdelt1)
         xx2 = (tmp(0, 0)-csi.crpix1)^2
         rr2 = rpixel*rpixel
         IF xx2 GE rr2 THEN BEGIN
            flash_msg, comment_id, num=3, $
               'The point you select must go through the solar disc!'
            RETURN
         ENDIF
         square = SQRT(rr2-xx2)
         offset = 5
         y1 = FIX(csi.crpix2-square)+offset
         y2 = FIX(csi.crpix2+square)-offset
         x0 = tmp(0, 0)
         ydev = y1+INDGEN(y2-y1+1)
         xdev = INTARR(N_ELEMENTS(ydev))
         xdev(*) = x0
         helio = cnvt_coord([[xdev], [ydev]], csi=csi, from=2, $
                            to=4, date=disp_utc)
         lat = helio(*, 0)
         longi = helio(*, 1)
         ii = WHERE(lat LE 85., count)
         IF count GT 0 THEN BEGIN
            lat = lat(ii)
            longi = longi(ii)
            temp = [[lat], [longi+diff_rot(time_gap, lat, /synodic)]]
            tmp = cnvt_coord([[xdev(ii)], [ydev(ii)]], csi=csi, from=2, to=1)
            itool_restore_pix, pix_win
            PLOTS, tmp(*, 0), tmp(*, 1), /dev, linestyle=2
            itool_rotplot, temp
            itool_copy_to_pix
         ENDIF
      END
      4: BEGIN
;---------------------------------------------------------------------------
;        Rotate points on central meridian
;---------------------------------------------------------------------------
         lat = 2*FINDGEN(85)-84.0
         temp = [[lat], [diff_rot(time_gap, lat, /synodic)]]

         msec = LONG(time_gap*8640000.0) ; in milliseconds
         cur_time = anytim2utc(disp_utc)
         cur_time.time = cur_time.time+msec(0)
         new_date = anytim2utc(cur_time, /external)
         temp = cnvt_coord(temp, csi=csi, from=4, to=1, date=new_date)
         itool_restore_pix, pix_win
         PLOTS, temp(*, 0), temp(*, 1), /dev, color=!d.table_size-1, $
            noclip=0, clip=[csi.drpix1, csi.drpix2, csi.drpix2+csi.daxis1, $
                            csi.drpix2+csi.daxis2]
         itool_copy_to_pix         
      END
      5: BEGIN
;---------------------------------------------------------------------------
;        Rotate points on the limb
;---------------------------------------------------------------------------
         temp = rotate_limb(time_gap)
         msec = LONG(time_gap*8640000.0) ; in milliseconds
         cur_time = anytim2utc(disp_utc)
         cur_time.time = cur_time.time+msec(0)
         new_date = anytim2utc(cur_time, /external)
         temp = cnvt_coord(temp, csi=csi, from=4, to=1, date=new_date)
         itool_restore_pix, pix_win
         PLOTS, temp(*, 0), temp(*, 1), /dev, color=!d.table_size-1, $
            noclip=0, clip=[csi.drpix1, csi.drpix2, csi.drpix2+csi.daxis1, $
                            csi.drpix2+csi.daxis2]
         itool_copy_to_pix         
      END
      ELSE:
   ENDCASE
   WIDGET_CONTROL, comment_id, set_value=''
   WIDGET_CONTROL, rot_longi_bt, sensitive=1
   WIDGET_CONTROL, rot_solarx_bt, sensitive=1
   WIDGET_CONTROL, rot_1pt_bt, sensitive=1
END

;---------------------------------------------------------------------------
; End of 'itool_disp_rot.pro'.
;---------------------------------------------------------------------------
