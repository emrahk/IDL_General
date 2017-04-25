;---------------------------------------------------------------------------
; Document name: cursor_info.pro
; Created by:    Liyun Wang, NASA/GSFC, September 14, 1994
;
; Last Modified: Thu Sep 11 15:10:45 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO CURSOR_INFO, cx, cy, widget_id, csi=csi, d_mode=d_mode, $
                 inside=inside
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       CURSOR_INFO
;
; PURPOSE:
;       Report cursor's position to a text widget.
;
; EXPLANATION:
;       In image_tool, cursor's position is displayed in variety of
;       ways depending on the display mode being set. When using the
;       zoom feature, such position is also needed. Note: Each time when this
;       routine is called, coordinates of a reference point in all three
;       coordinate systems (device, data, and solar) have to be given. Since
;       this routine has to tell if the cursor is within the plotting area,
;       the reference point should therefore always be the lower left corner
;       of the image.
;
; CALLING SEQUENCE:
;       CURSOR_INFO, cx, cy, widget_id, csi=csi
;
; INPUTS:
;       CX  -- X position of the cursor, in device pixcels
;       CY  -- Y position of the cursor, in device pixcels
;       WIDGET_ID -- ID of the text widget in which the cursor pistion
;                    is displayed.
;       CSI -- Coordinate system information structure that contains some
;              basic information of the coordinate systems involved. 
;              See itool_new_csi.pro for more information about CSI.
;
;       D_MODE -- Code for the coordinate system in which the cursor position
;                 is shown. Possible code numbers are:
;
;                 1. Device coordinate system, in device pixcels
;                 2. Data (image) coordinate system, in data pixels
;                 3. Solar disk coordinate system, in arc seconds
;                 4. Heliographic coordinate system, in degrees
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       Cursor's position is displayed on the given text widget.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       INSIDE - Set this keyword to show cursor position only when
;                the cursor is inside the image array
;
; CALLS:
;       CNVT_COORD, NUM2STR
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
;       Written September 14, 1994, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 2, Liyun Wang, NASA/GSFC, November 18, 1994
;          Calls CNVT_COORD to make conversion between any two of four
;             coordinate systems involved in solar image displaying;
;          Improved the way of displaying heliographic latitude and longitude
;       Version 3, August 17, 1995, Liyun Wang, NASA/GSFC
;          Added INSIDE keyword
;       Version 4, November 8, 1995, Liyun Wang, NASA/GSFC
;          Added display for position angle of the cursor
;       Version 5, November 17, 1995, Liyun Wang, NASA/GSFC
;          Fixed a bug that caused inaccurate conversion to or from
;             the heliographic system
;       Version 6, August 28, 1996, Liyun Wang, NASA/GSFC
;          Modified such that if cursor is outside the image, image
;             data pixel is not displayed
;       Version 7, August 13, 1997, Liyun Wang, NASA/GSFC
;          Took away DATE keyword (now included in CSI)
;
; VERSION:
;       Version 7, August 13, 1997
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(d_mode) EQ 0 THEN d_mode = 2
   CASE (d_mode) OF
      1: BEGIN
;---------------------------------------------------------------------------
;        Display cursor position in device pixels
;---------------------------------------------------------------------------
         pos_str = num2str(cx)+', '+num2str(cy)
         WIDGET_CONTROL, widget_id, set_value=pos_str, /no_copy
      END
      2: BEGIN
;---------------------------------------------------------------------------
;        Display cursor position in image data pixels
;---------------------------------------------------------------------------
         IF KEYWORD_SET(inside) THEN BEGIN
            show = ((cx GE csi.drpix1) AND (cx LE csi.drpix1+csi.daxis1-1)) $
               AND ((cy GE csi.drpix2) AND (cy LE csi.drpix2+csi.daxis2-1))
         ENDIF ELSE show = 1
         IF show THEN BEGIN
            new_pos = cnvt_coord(cx, cy, csi=csi, from=1, to=2)
            pos_str = num2str(new_pos(0, 0))+', '+num2str(new_pos(0, 1))
            WIDGET_CONTROL, widget_id, set_value=pos_str, $
               /no_copy
         ENDIF ELSE WIDGET_CONTROL, widget_id, set_value='', /no_copy
      END
      3: BEGIN
;---------------------------------------------------------------------------
;        Display cursor position in arcsecs
;---------------------------------------------------------------------------
         IF KEYWORD_SET(inside) THEN BEGIN
            show = ((cx GE csi.drpix1) AND (cx LE csi.drpix1+csi.daxis1-1)) $
               AND ((cy GE csi.drpix2) AND (cy LE csi.drpix2+csi.daxis2-1))
         ENDIF ELSE show = 1
         IF show THEN BEGIN
;---------------------------------------------------------------------------
;           Following is equivalent to 
;           new_pos = TRANSPOSE(CONVERT_COORD(cx, cy, /device, /to_data))
;---------------------------------------------------------------------------
            new_pos = cnvt_coord(cx, cy, csi=csi, from=1, to=3)

            pangle = ATAN(-new_pos(0, 0), new_pos(0, 1))/!dtor
            rsun=sqrt(new_pos(0,1)^2+new_pos(0,0)^2)/csi.radius
            IF pangle LT 0.0 THEN pangle = 360.0+pangle
            pos_str = num2str(new_pos(0, 0), FORMAT='(f10.2)')+'", '+$
               num2str(new_pos(0, 1), FORMAT='(f10.2)')+'"'+$
               ', P '+num2str(pangle, FORMAT='(f10.2)')+', RSUN '+$
                      num2str(rsun,format='(f3.1)')
            WIDGET_CONTROL, widget_id, set_value=pos_str, /no_copy
         ENDIF ELSE WIDGET_CONTROL, widget_id, set_value='', /no_copy
      END
      4: BEGIN
;---------------------------------------------------------------------------
;        Display cursor position in heliographic coordinates
;---------------------------------------------------------------------------
         IF ((cx GE csi.drpix1) AND (cx LE csi.drpix1+csi.daxis1-1)) AND $
            ((cy GE csi.drpix2) AND (cy LE csi.drpix2+csi.daxis2-1)) THEN BEGIN
            new_pos = cnvt_coord(cx, cy, csi=csi, from=1, to=4, $
                                 off_limb=off_limb)
            IF off_limb(0) THEN BEGIN
;----------------------------------------------------------------------
;              Cursor is off the limb, no need to show its position
;----------------------------------------------------------------------
               WIDGET_CONTROL, widget_id, set_value='Off limb', /no_copy
            ENDIF ELSE BEGIN
               pos_tmp = cnvt_coord(cx, cy, csi=csi, from=1, to=3)
               pangle = ATAN(-pos_tmp(0, 0), pos_tmp(0, 1))/!dtor
               IF pangle LT 0 THEN pangle = 360.0+pangle
               IF new_pos(0, 0) LT 0 THEN $
                  h_lat = 'S '+num2str(ABS(new_pos(0, 0)), FORMAT='(f10.2)')+$
                  STRING(176b) $
               ELSE $
                  h_lat = 'N '+num2str(ABS(new_pos(0, 0)), FORMAT='(f10.2)')+$
                  STRING(176b)
               IF new_pos(0, 1) LT 0 THEN $
                  h_long = 'E '+num2str(ABS(new_pos(0, 1)), FORMAT='(f10.2)')+$
                  STRING(176b) $
               ELSE $
                  h_long = 'W '+num2str(ABS(new_pos(0, 1)), FORMAT='(f10.2)')+$
                  STRING(176b)
               rsun=sqrt(new_pos(0,1)^2+new_pos(0,0)^2)/csi.radius
               pos_str = h_lat+', '+h_long+', P '+$
                  num2str(pangle, FORMAT='(f10.2)')+', RSUN '+$
                      num2str(rsun,format='(f3.1)')

               WIDGET_CONTROL, widget_id, set_value=pos_str, /no_copy
            ENDELSE
         ENDIF ELSE WIDGET_CONTROL, widget_id, set_value='', /no_copy
      END
      ELSE: RETURN
   ENDCASE
   RETURN
END

;---------------------------------------------------------------------------
;  End of 'cursor_info.pro'
;---------------------------------------------------------------------------
