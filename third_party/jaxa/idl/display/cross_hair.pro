;---------------------------------------------------------------------------
; Document name: cross_hair.pro
; Created by:    Liyun Wang, NASA/GSFC, October 4, 1994
;
; Last Modified: Wed Mar 13 11:51:58 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO cross_hair, cx, cy, width, height, unit, length=length, color=color, $
                thick=thick, lines=lines, keep=keep, csi=csi, $
                boxed_cursor=boxed_cursor
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       CROSS_HAIR
;
; PURPOSE:
;       Plot a rectangle or cross hair on the current plotting device.
;
; EXPLANATION:
;       This routine plots a rectangle or a cross hair on the current plotting
;       device. The size and location of the rectangle or cross hair are saved
;       in the common block CROSS_HAIR so that when it is called the next
;       time, the previous rectangle or cross hair can be erased from the
;       device screen.
;
; CALLING SEQUENCE:
;       CROSS_HAIR, cx, cy [, width, height [, unit]]
;
; INPUTS:
;       CX     - X position of the cursor center, in device pixels
;       CY     - Y position of the cursor center, in device pixels
;
; OPTIONAL INPUTS:
;       WIDTH  - Width of the rectangle, in device pixels
;       HEIGHT - Height of the rectangle, in device pixels
;
;       If WIDTH and HEIGHT are not passed in, a cross hair will be used.
;
;       UNIT   - Integer scalar indicating what units to be for boxed cursor.
;                1: device pixels, 2: image pixcels, and 3: arcseconds
;       CSI    - Coordinate system info structure; required if UNIT is 2 or 3
;       LENGTH - Length of line segment of the cross hair in device
;                pixels. Default: 40
;       COLOR  - Index of color used to draw the cross hair. Default color
;                used: !d.table_size-1
;       THICK  - Thickness of the cross hair, default: 1
;       LINES  - Line style used for drawing the cross hair. Default: 0
;                (solid line)
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       KEEP -- If set, the cursor will remain on the plotting screen
;               until the whole screen is erased.
;       BOXED_CURSOR - Plot boxed cursor if set and if WIDTH and HEIGHT are
;                      given 
; CALLS:
;       DELVARX
;
; COMMON BLOCKS:
;       CROSS_HAIR
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       A cross hair is plotted on the current device. When the routine is
;       called next time, the previous cross hair is erased and a new one is
;       plotted. If the KEEP keyword is set, the cursor will not be erased
;       next time this routine is called. The only way to remove it from the
;       device is to redraw the plotting.
;
; CATEGORY:
;       Utilities, graphics
;
; PREVIOUS HISTORY:
;       Written October 4, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 2, Liyun Wang, NASA/GSFC, November 8, 1994
;          Added the KEEP keyword
;       Version 3, Liyun Wang, NASA/GSFC, May 11, 1995
;          Added BOXED_CURSOR keyword to enable plotting boxed cursor
;          Changed cross-hair cursor from "+" shape to "x"
;       Version 4, February 26, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug that unit-width or unit-height boxed cursor was
;             not properly plotted
;       Version 5, March 13, 1996, Liyun Wang, NASA/GSFC
;          Changed cross-hair cursor from "x" shape back to "+"
;	Version 6, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; VERSION:
;	Version 6, 8 April 1998
;-
;
   COMMON cross_hair, xx, yy
   ON_ERROR, 2

   np = N_PARAMS() 
   IF np NE 2 AND np NE 4 AND np NE 5 THEN BEGIN
      PRINT, 'CROSS_HAIR -- Syntax error.'
      PRINT, '   Usage: CROSS_HAIR, cx, cy [, width, height [,unit] ]'
      PRINT, ' '
      RETURN
   ENDIF

   IF N_ELEMENTS(thick) EQ 0 THEN thick = 1
   IF N_ELEMENTS(lines) EQ 0 THEN lines = 0
   IF N_ELEMENTS(color) EQ 0 THEN color = !d.table_size-1
   IF N_ELEMENTS(boxed_cursor) EQ 0 THEN boxed_cursor = 0
   IF N_ELEMENTS(unit) EQ 0 THEN unit = 1

   IF unit GT 1 AND N_ELEMENTS(csi) EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     To use units of image pixels or arc seconds, the CSI structure must be
;     passed in
;---------------------------------------------------------------------------
      MESSAGE, 'CSI must be passed in to use units other than device pixels',$
         /cont
      RETURN
   ENDIF

   DEVICE, get_graphics = old
   
   DEVICE, set_graphics = 6     ; Set xor so that previous cursor can be erased

;---------------------------------------------------------------------------
;  Erase previously plotted cursor if it's there
;---------------------------------------------------------------------------
   IF N_ELEMENTS(xx) NE 0 AND N_ELEMENTS(yy) NE 0 THEN BEGIN
      IF N_ELEMENTS(width) NE 0 AND boxed_cursor THEN BEGIN
         PLOTS, xx, yy, col=color, /dev, thick=thick, lines=lines
      ENDIF ELSE BEGIN
         PLOTS, xx(0:1), yy(0:1), col=color, /dev, thick=thick, lines=lines
;         PLOTS, xx(0:1), yy(2:3), col=color, /dev, thick=thick, lines=lines
         PLOTS, xx(2:3), yy(2:3), col=color, /dev, thick=thick, lines=lines
      ENDELSE
   ENDIF

   IF N_ELEMENTS(width) NE 0 AND boxed_cursor THEN BEGIN
;---------------------------------------------------------------------------
;     Plot boxed cursor
;---------------------------------------------------------------------------
      dwidth = width
      dheight = height
      CASE (unit) OF
         2: BEGIN
            dwidth = dwidth/csi.ddelt1
            dheight = dheight/csi.ddelt2
         END
         3: BEGIN
            dwidth = dwidth/csi.cdelt1/csi.ddelt1
            dheight = dheight/csi.cdelt2/csi.ddelt2
         END
         ELSE:
      ENDCASE
      hlf_wid = FIX(dwidth)/2
      hlf_hgt = FIX(dheight)/2
      IF hlf_wid EQ 0 AND hlf_hgt EQ 0 THEN BEGIN
         xx = cx 
         yy = cy
      ENDIF ELSE BEGIN
         IF hlf_wid EQ 0 THEN BEGIN
            yll = cy-hlf_hgt
            yur = cy+hlf_hgt
            xx = [cx, cx]
            yy = [yll, yur]
         ENDIF ELSE IF hlf_hgt EQ 0 THEN BEGIN
            xll = cx-hlf_wid
            xur = cx+hlf_wid
            xx = [xll, xur]
            yy = [cy, cy]
         ENDIF ELSE BEGIN
            xll = cx-hlf_wid
            xur = cx+hlf_wid
            yll = cy-hlf_hgt
            yur = cy+hlf_hgt
            xx = [xll, xur, xur, xll, xll]
            yy = [yll, yll, yur, yur, yll]
         ENDELSE
      ENDELSE
      PLOTS, xx, yy, col=color, /dev, thick=thick, lines=lines
   ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;     Plot cross hair cursor
;---------------------------------------------------------------------------
      IF N_ELEMENTS(length) EQ 0 THEN length = 30
      hlf_length = length/2
      xx = intarr(4)
      yy = xx
      xx(0) = cx-hlf_length
      xx(1) = cx+hlf_length
      yy(0) = cy & yy(1) = cy
      yy(2) = cy+hlf_length
      yy(3) = cy-hlf_length
      xx(2) = cx & xx(3) = cx
;      yy(0) = cy-hlf_length
;      yy(1) = cy+hlf_length
      PLOTS, xx(0:1), yy(0:1), col=color, /dev, thick=thick, lines=lines
      PLOTS, xx(2:3), yy(2:3), col=color, /dev, thick=thick, lines=lines
;      PLOTS, xx(0:1), yy(2:3), col=color, /dev, thick=thick, lines=lines
   ENDELSE
   DEVICE, set_graphics=old
   IF KEYWORD_SET(keep) THEN BEGIN
      IF N_ELEMENTS(width) NE 0 AND boxed_cursor THEN BEGIN
         PLOTS, xx, yy, col=color, /dev, thick=thick, lines=lines
      ENDIF ELSE BEGIN
         PLOTS, xx(0:1), yy(0:1), col=color, /dev, thick=thick, lines=lines
         PLOTS, xx(2:3), yy(2:3), col=color, /dev, thick=thick, lines=lines
;         PLOTS, xx(0:1), yy(2:3), col=color, /dev, thick=thick, lines=lines
      ENDELSE
      delvarx, xx, yy
   ENDIF
   RETURN
END

;---------------------------------------------------------------------------
; End of 'cross_hair.pro'.
;---------------------------------------------------------------------------
