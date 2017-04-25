;---------------------------------------------------------------------------
; Document name: itool_zoom.pro
; Created by:    Liyun Wang, NASA/GSFC, November 8, 1994
;
; Last Modified: Thu Sep 11 15:01:20 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO ITOOL_ZOOM, draw_id, fact = fact, interp = interp, csi=csi,$
                continuous = cont, text_id=text_id, d_mode=d_mode, $
                cursor=cursor
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ITOOL_ZOOM
;
; PURPOSE:
;       Zoom in on part of an image in a given draw widget window
;
; EXPLANATION:
;	Display part of an image (or graphics) from the current window
;	enlarged in another window.
;
;	The cursor is used to mark the center of the zoom.
;
;	Note:  This routine is identical to the version of ZOOM distributed
;	       with IDL starting with version 3.1.
;
;
; CALLING SEQUENCE:
;       ITOOL_ZOOM, draw_id, [, TEXT_id=text_id, FACT = Fact, $
;                 /INTERP, /CONTINUOUS]
;
; INPUTS:
;	DRAW_ID  -- ID of the draw widget on which the zoomed image is drawn
;	TEXT_ID  -- ID of a text widget on which the cursor position will be
;                   reported.
;       CSI -- Coordinate system information structure that contains some
;              basic information of the coordinate systems involved. 
;
;       D_MODE   -- This is set in accordence with the
;                   IMAGE_TOOL. It is a code of showing the
;                   cursor position in different ways. Default
;                   display mode is 3.
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
; KEYWORD PARAMETERS:
;	FACT:	Zoom factor.  This parameter must be an integer.  The default
;		zoom factor is 4.
;
;	INTERP:	Set this keyword to use bilinear interpolation, otherwise
;		pixel replication is used.
;
;   CONTINUOUS:	Set this keyword to make the zoom window track the mouse
;		without requiring the user to press the left mouse button.
;		This feature only works well on fast computers.
;
; CALLS:
;	CURSOR_INFO
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	ZOOM only works with color systems.
;
; SIDE EFFECTS:
;       Control cannot be returned back till right button is pressed
;
; CATEGORY:
;	Utilities, Image_display.
;
; PREVIOUS HISTORY:
;       Written November 8, 1994, by Liyun Wang, NASA/GSFC
;
; HISTORY:
;       Version 1, November 8, 1994, Liyun Wang, NASA/GSFC. Written
;       Version 2, November 18, 1994, Liyun Wang, NASA/GSFC
;          Calls the improved CURSOR_INFO; coordinate system conversions are
;             now handed to CNVT_COORD.
;       Version 3, March 19, 1996, Liyun Wang, NASA/GSFC
;          Made the central cursor visible regardless of the background
;       Version 4, 22 May 1997, SVH Haugan, UiO
;          Switched to using WIDGET_EVENT instead of TVRDC (CURSOR).
;       Version 5, August 13, 1997, Liyun Wang, NASA/GSFC
;          Took out the DATE keyword (now included in CSI)
;	Version 6, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; VERSION:
;	Version 6, 8 April 1998
;-
;
   ON_ERROR, 2                  ;Return to caller if an error occurs

   IF N_ELEMENTS(draw_id) EQ 0 THEN BEGIN
      PRINT, 'Syntax error. Usage:'
      PRINT, '   itool_zoom, draw_id'
      PRINT, ' '
      RETURN
   ENDIF
;----------------------------------------------------------------------
;  check the validity of the draw widget
;----------------------------------------------------------------------
   IF WIDGET_INFO(draw_id, /type) NE 4 OR $
      WIDGET_INFO(draw_id, /valid) NE 1 OR $
      WIDGET_INFO(draw_id, /realized) NE 1 THEN BEGIN
      PRINT, 'Zoomming window is not ready.'
      RETURN
   ENDIF
   WIDGET_CONTROL, draw_id, get_value=zoom_win
   old_window = !d.window
   WSET, zoom_win & ERASE
   xs = !d.x_size
   ys = !d.y_size
   WSET, old_window

   IF N_ELEMENTS(text_id) NE 0 THEN BEGIN
      IF WIDGET_INFO(text_id, /type) NE 3 OR $
         WIDGET_INFO(text_id, /valid) NE 1 OR $
         WIDGET_INFO(text_id, /realized) NE 1 THEN t_widget = 0 ELSE $
         t_widget = 1
   ENDIF ELSE t_widget = 0
   IF N_ELEMENTS(cursor) NE 0 THEN BEGIN
      hlf_length = 10
      xx = intarr(4)
      yy = xx
      x = xs/2+1 & y=ys/2+1
      xx(0) = x-hlf_length
      xx(1) = x+hlf_length
      xx(2) = x & xx(3)=x
      yy(0) = y & yy(1)=y
      yy(2) = y-hlf_length
      yy(3) = y+hlf_length
   ENDIF

   IF N_ELEMENTS(fact) LE 0 THEN fact = 4
   IF KEYWORD_SET(cont) THEN waitflg = 2 ELSE waitflg = 3
   ifact = fact
   old_w = !d.window

   tvcrs, 1, /dev               ;enable cursor
   ierase = 0                   ;erase zoom window flag
   IF t_widget EQ 0 THEN PRINT, $
      'Left for zoom center, Middle for new zoom factor, Right to quit'
   
   widget = find_draw_widget(old_w)
   
   WHILE (1) DO BEGIN
      IF widget EQ -1 THEN tvrdc, x, y, waitflg, /dev $ ;Wait for change
      ELSE BEGIN 
         event = WIDGET_EVENT(widget)
         !err = event.press
         x = event.x
         y = event.y
      END 
      CASE !err OF
         4: RETURN
         
         2: BEGIN
            IF !d.name EQ 'SUN' OR !d.name EQ 'X' THEN BEGIN ;Sun view?
               s = ['New Zoom Factor:', STRTRIM(INDGEN(19)+2, 2)]
               ifact = wmenu(s, init=ifact-1, title=0)+1
               tvcrs, x, y, /dev ;Restore cursor
               ierase = 1
            ENDIF ELSE BEGIN
               Read, 'Current factor is', ifact+0, $
                  '.  Enter new factor: ', ifact
               IF ifact LE 0 THEN BEGIN
                  ifact = 4
                  PRINT, 'Illegal Zoom factor.'
               ENDIF
               ierase = 1       ;Clean out previous display
            ENDELSE
         END
         ELSE: BEGIN
            x0 = 0 > (x-xs/(ifact*2)) ;left edge from center
            y0 = 0 > (y-ys/(ifact*2)) ;bottom
            nx = xs/ifact       ;Size of new image
            ny = ys/ifact
            nx = nx < (!d.x_vsize-x0)
            ny = ny < (!d.y_size-y0)
            x0 = x0 < (!d.x_vsize - nx)
            y0 = y0 < (!d.y_vsize - ny)
            a = tvrd(x0, y0, nx, ny) ;Read image
            wset, zoom_win
            IF ierase THEN erase ;Erase it?
            ierase = 0
            xss = nx * ifact	 ;Make integer rebin factors
            yss = ny * ifact
            tv, rebin(a, xss, yss, sample=1-KEYWORD_SET(interp)), /dev
            IF KEYWORD_SET(cursor) THEN BEGIN
;---------------------------------------------------------------------------
;              Plot the central cursor
;---------------------------------------------------------------------------
               PLOTS, xx(0:1), yy(0:1), /dev, color=!d.table_size-1, thick=3
               PLOTS, xx(2:3), yy(2:3), /dev, color=!d.table_size-1, thick=3
               PLOTS, xx(0:1), yy(0:1), /dev, color=0, thick=1
               PLOTS, xx(2:3), yy(2:3), /dev, color=0, thick=1
            ENDIF
            IF t_widget THEN BEGIN ; Update the label widget
               cursor_info, x, y, text_id, csi=csi, d_mode=d_mode
            ENDIF
            wset, old_w
         ENDCASE
      ENDCASE
   ENDWHILE
END

;---------------------------------------------------------------------------
; End of 'itool_zoom.pro'.
;---------------------------------------------------------------------------
