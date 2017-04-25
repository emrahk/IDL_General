;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: polygon_csr.pro
; Created by:    Liyun Wang, GSFC/ARC, September 9, 1994
;
; Last Modified: Tue Mar 21 15:35:40 1995 (lwang@achilles.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO POLYGON_CSR, px, py, color=color, widget_id=widget_id, csi=csi, $
                 pointing=pointing, keep_csr=keep_csr, d_mode=d_mode
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       POLYGON_CSR
;
; PURPOSE:
;       Make a size-fixed polygon cursor movable with a mouse
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       POLYGON_CSR, px, py, wlabel=wlabel
;
; INPUTS:
;       px -- Array that holds initial X position of points that make
;             the polygon, also returns the final position upon exit
;             this program.
;       py -- Array that holds initial Y position of points that make
;             the polygon, also returns the final position upon exit
;             this program.
;       SCALE -- scaling factor, arcsecond/data pixels
;       CSI -- Coordinate system information structure that contains some
;              basic information of the coordinate systems involved. It should
;              have the following 14 tags:
;
;              XD0 -- X position of the first pixcel of the
;                     image (lower left coner), in device pixels
;              YD0 -- Y position of the first pixcel of the
;                     image (lower left coner), in device pixels
;              XU0 -- X position of the first pixcel of the image (lower 
;                     left coner), in user (or data) pixels. 
;              YU0 -- Y position of the first pixcel of the image (lower 
;                     left coner), in user (or data) pixels
;              MX  -- X size of the image in device pixels
;              MY  -- Y size of the image in device pixels
;              RX  -- ratio of SX/MX, (data unit)/(device pixel), where 
;                     SX is the image size in X direction in data pixels
;              RY  -- ratio of SY/MY, (data unit)/(device pixel), where 
;                     SY is the image size in Y direction in data pixels
;              X0  -- X position of the reference point in data pixels
;              Y0  -- Y position of the reference point in data pixels
;              XV0 -- X value of the reference point in absolute units
;              YV0 -- Y value of the reference point in absolute units
;              SRX -- scaling factor for X direction in arcsec/(data pixel)
;              SRY -- scaling factor for Y direction in arcsec/(data pixel)
;
;              Note: Units used for XV0 ans YV0 are arc senconds in
;                    case of solar images. If the reference point is
;                    the solar disk center, XV0 = YV0 = 0.0. The
;                    reference point can also be the first pixel of
;                    the image (i.e., the pixcel on the lower-left
;                    coner of the image).
;                    When the whole image is displayed, XU0 and YU0 are all
;                    equal to 0; for subimages, XU0 and YU0 may not be zero.
;
;       D_MODE -- This is set in accordence with the
;                 IMAGE_TOOL. It is a code of showing the
;                 cursor position in different ways. Default
;                 display mode is 2.
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       px -- Final X position of points of the polygon
;       py -- Final Y position of points of the polygon
;
; OPTIONAL OUTPUTS:
;       POINTING -- A 2-element vector that contains the coordinates of the
;                   first point of the polygon.
;
; KEYWORD PARAMETERS:
;       COLOR -- Index of the color to be used to draw the polygon
;       GROUP -- ID of the widget who serves as a group leader
;       KEEP_CSR -- If set, will retian the final cursor on the screen 
;                   upon exit; otherwise the cursor is removed.
;
; CALLS:
;       CURSOR_INFO
;
; COMMON BLOCKS:
;       IMG_SCALE -- Common block used in IMAGE_TOOL
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
;       Written September 9, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       September 14, 1994, Liyun Wang, GSFC/ARC
;          Added common block and allowed to display cursor posistion
;          in a text widget.  
;       Version 2, Liyun Wang, GSFC/ARC, October 31, 1994
;          Report of the position of the polygon made in terms of that of the
;          polygon center (defined by 0.5*(x_max+x_min) and 0.5*(x_max+x_min)
;          where x_max/x_min and y_max/y_min are max and min values of the
;          polygon in X and Y directions respectively.
;       Version 3, Liyun Wang, GSFC/ARC, November 18, 1994
;          Coordinate system conversion is made by CNVT_COORD; removed the
;             common block IMG_SCALE
;	Version 4, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; VERSION:
;	Version 4, 8 April 1998
;-
;

   ON_ERROR, 2

   IF N_PARAMS() NE 2 THEN BEGIN
      PRINT, 'POLYGON_CSR -- Syntax error.'
      PRINT, '   Usage: PLOYGON_CSR, px, py [,color=color]'
      PRINT, ' '
      RETURN
   ENDIF

   IF N_ELEMENTS(color) EQ 0 THEN color = !d.table_size-1

   IF N_ELEMENTS(widget_id) NE 0 THEN BEGIN
      IF WIDGET_INFO(widget_id,/valid) THEN have_widget = 1
   ENDIF ELSE  have_widget = 0

   IF N_ELEMENTS(d_mode) EQ 0 THEN d_mode = 2

;----------------------------------------------------------------------
;  Set graphics function to be GXxor so that anything drawn on the
;  device can be removed without disturbing the device screen.
;----------------------------------------------------------------------
   DEVICE, get_graphics = old, set_graphics = 6 ;Set xor

   x_min = MIN(px) & x_max = MAX(px)
   y_min = MIN(py) & y_max = MAX(py)

   x_id0 = WHERE(px EQ x_min) & x_id1 = WHERE(px EQ x_max)
   y_id0 = WHERE(py EQ y_min) & y_id1 = WHERE(py EQ y_max)

   button = 0
   GOTO, middle

   WHILE 1 DO BEGIN
      old_button = button
      cursor, x, y, 2, /dev	;Wait for a button
      button = !err
      IF (old_button EQ 0) AND (button NE 0) THEN BEGIN
         mx0 = x
         my0 = y
         px0 = px
         py0 = py
      ENDIF
      IF !err EQ 1 THEN BEGIN   ; Dragging...
         dx = x-mx0
         dy = y-my0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Make sure that the polygon is not dragged off the graphic window
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         IF (px0(x_id0(0))+dx) LE 0 THEN dx = -px0(x_id0(0))
         IF (px0(x_id1(0))+dx) GE !d.x_size-1 THEN $
            dx = !d.x_size-1-px0(x_id1(0))
         IF (py0(y_id0(0))+dy) LE 0 THEN dy = -py0(y_id0(0))
         IF (py0(y_id1(0))+dy) GE !d.y_size-1 THEN $
            dy = !d.y_size-1-py0(y_id1(0))
         px = px0+dx
         py = py0+dy
      ENDIF
      PLOTS, px1, py1, col=color, /dev, thick=1, lines=0 ; Erase previous box
      EMPTY                     ; Decwindow bug

      IF !err EQ 4 THEN BEGIN   ; Exiting...
         IF KEYWORD_SET(keep_csr) THEN BEGIN
            DEVICE, set_graphics =  old 
            PLOTS, px1, py1, col=color, /dev, thick=1, lines=0
         ENDIF
         pointing = [ras_x,ras_y]
         DEVICE, set_graphics = old
         RETURN
      ENDIF

middle:
      px1 = px &  py1 = py

      ras_x = 0.5*(px(x_id0(0))+px(x_id1(0)))
      ras_y = 0.5*(py(y_id0(0))+py(y_id1(0)))
      
      IF have_widget THEN BEGIN ; Update the label widget
         cursor_info, ras_x, ras_y, widget_id, csi=csi, $
            d_mode=d_mode
      ENDIF

      PLOTS, px1, py1, col=color, /dev, thick=1, lines=0 ; Draw the box
      WAIT, .1                  ;Dont hog it all
   ENDWHILE

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'polygon_csr.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
