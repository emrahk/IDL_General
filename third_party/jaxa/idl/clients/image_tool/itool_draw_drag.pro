;---------------------------------------------------------------------------
; Document name: itool_draw_drag.pro
; Created by:    Liyun Wang, NASA/GSFC, August 19, 1997
;
; Last Modified: Mon Sep 15 13:37:21 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_draw_drag, event, pixmap=pixmap, color=color, status=status, $
         xrange=xrange, yrange=yrange, box=box, anywhere=anywhere
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_DRAW_DRAG
;
; PURPOSE:
;       Handles press and drag events of draw widget
;
; CATEGORY:
;       Draw widget event handler
;
; SYNTAX:
;       itool_draw_drag, event, xrange=xrange, yrange=yrange, status=status
;       IF status THEN [handles xrange and yrange...]
;
; INPUTS:
;       EVENT - widget event structure
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
;       PIXMAP - Structure of pixel map with tags indicating ID of
;                pixmap source, size of pixel map to be restored. If
;                passed, graphics saved on pixmap will be restored to
;                current window (!d.window) as means of erasing
;                previous box drawing
;       COLOR  - Index of color to be used for drawing the box
;       STATUS - A integer flag indicating whether the selection has
;                been made (1) or not (0)
;       XRANGE - Named varibale containing X range (in device coord)
;                of the "selected" box
;       YRANGE - Named varibale containing Y range (in device coord)
;                of the "selected" box
;       BOX    - A Nx2 array containing X and Y positions of a
;                rectangle or polygon in device coordinates. If
;                passed, pressing and dragging left button will move
;                this box around.
;
; COMMON:
;       ITOOL_DRAG - common block for internal use
;
; RESTRICTIONS:
;       Only works for devices that supports COPY keyword (X, WIN,
;       SUN, and MAC) if PIXMAP keyword is passed in
;
; SIDE EFFECTS:
;       Contents on current window (!d.window) get replaced.
;
; HISTORY:
;       Version 1, August 19, 1997, Liyun Wang, NASA/GSFC. Written
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   COMMON itool_drag, mevent, pstatus, x00, y00, x11, y11, xx, yy, $
      xmin, xmax, ymin, ymax

   IF TAG_NAMES(event, /structure_name) NE 'WIDGET_DRAW' THEN RETURN

   IF N_ELEMENTS(color) EQ 0 THEN color = !d.table_size -1
   status = 0
   CASE (event.type) OF
      0: BEGIN
;---------------------------------------------------------------------------
;        Button pressed; record initial point
;---------------------------------------------------------------------------
         x00 = event.x
         y00 = event.y
         pstatus = event.press
         mevent = WIDGET_INFO(event.id, /draw_motion)
;---------------------------------------------------------------------------
;        Set draw motion event on, and get xsize of the widget window
;---------------------------------------------------------------------------
         WIDGET_CONTROL, event.id, draw_motion=1, get_value=cur_wid
         status = 1
      END
      1: BEGIN
;---------------------------------------------------------------------------
;        Button released; set the motion event attribute back
;---------------------------------------------------------------------------
         IF N_ELEMENTS(mevent) NE 0 THEN $
            WIDGET_CONTROL, event.id, draw_motion=mevent
         
         IF N_ELEMENTS(box) EQ 0 THEN BEGIN
            IF N_ELEMENTS(xx) NE 0 AND N_ELEMENTS(x11) NE 0 THEN BEGIN
               xrange = [MIN(xx), MAX(xx)]
               yrange = [MIN(yy), MAX(yy)]
               status = 1
               xmin = xrange(0)
               xmax = xrange(1)
               ymin = yrange(0)
               ymax = yrange(1)
            ENDIF
         ENDIF 
         IF N_ELEMENTS(x11) EQ 0 THEN delvarx, xx, yy
         delvarx, pstatus, x11, y11
      END
      ELSE:
   ENDCASE

;---------------------------------------------------------------------------
;  Return if it is not a motion event
;---------------------------------------------------------------------------
   IF event.type NE 2 OR N_ELEMENTS(pstatus) EQ 0 THEN RETURN

   IF N_ELEMENTS(box) NE 0 THEN BEGIN
      xmin = MIN(box(*, 0))
      ymin = MIN(box(*, 1))
      xmax = MAX(box(*, 0))
      ymax = MAX(box(*, 1))
   ENDIF

;---------------------------------------------------------------------------
;  pstatus = 1: pressing and dragging left button; 2: pressing and
;  dragging middle button; 3: pressing and dragging right button
;---------------------------------------------------------------------------
   IF pstatus EQ 1 THEN BEGIN
      x11 = event.x
      y11 = event.y
      xx = [x00, x11, x11, x00, x00]
      yy = [y00, y00, y11, y11, y00]
   END ELSE BEGIN 
      x11 = event.x
      y11 = event.y
      dx = x11-x00
      dy = y11-y00
;;    IF NOT KEYWORD_SET(anywhere) THEN BEGIN 
;;;---------------------------------------------------------------------------
;;;      Make sure that BOX is not dragged off the graphic area
;;;---------------------------------------------------------------------------
;;       IF (xmin+dx) LE 0 THEN dx = -xmin
;;       IF (xmax+dx) GE !d.x_size-1 THEN dx = !d.x_size-1-xmax
;;       IF (ymin+dy) LE 0 THEN dy = -ymin
;;       IF (ymax+dy) GE !d.y_size-1 THEN dy = !d.y_size-1-ymax
;;    ENDIF 
      x00 = x11
      y00 = y11
      IF N_ELEMENTS(box) NE 0 THEN BEGIN
         box(*, 0) = box(*, 0)+dx
         box(*, 1) = box(*, 1)+dy
      ENDIF ELSE BEGIN
         IF N_ELEMENTS(xx) NE 0 THEN BEGIN 
            xx = xx+dx
            yy = yy+dy
         ENDIF 
      ENDELSE
   ENDELSE
   
;---------------------------------------------------------------------------
;     Erase previous drawing
;---------------------------------------------------------------------------
   IF N_ELEMENTS(pixmap) EQ 0 THEN BEGIN
      DEVICE, get_graphics=old, set_graphics=6
      IF N_ELEMENTS(box) NE 0 THEN BEGIN
         PLOTS, box(*, 0), box(*, 1), /dev, color=color
      ENDIF ELSE BEGIN
         IF N_ELEMENTS(xx) NE 0 THEN PLOTS, xx, yy, /dev, color=color
      ENDELSE
   ENDIF ELSE $
      DEVICE, copy=[0, 0, pixmap.xsize, pixmap.ysize, 0, 0, pixmap.id]

;---------------------------------------------------------------------------
;  Draw current selection
;---------------------------------------------------------------------------
   IF N_ELEMENTS(box) NE 0 THEN $
      PLOTS, box(*, 0), box(*, 1), /dev, color=color $
   ELSE $
      IF N_ELEMENTS(xx) NE 0 THEN PLOTS, xx, yy, /dev, color=color

   IF N_ELEMENTS(old) NE 0 THEN DEVICE, set_graphics=old

END

;---------------------------------------------------------------------------
; End of 'itool_draw_drag.pro'.
;---------------------------------------------------------------------------
