;---------------------------------------------------------------------------
; Document name: set_cursor_size.pro
; Created by:    Liyun Wang, NASA/GSFC, May 4, 1995
;
; Last Modified: Fri Oct  3 14:28:11 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       SET_CURSOR_SHAPE
;
; PURPOSE:
;       Widget interface to set cursor size interactively
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       set_cursor_shape, xx, yy [, unit] [, csi=csi] [,status=status]
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       XX     - Cursor width in device pixels
;       YY     - Cursor height in device pixels
;       CURSOR_UNIT - Unit to be used for the cursor size: 1 for device pixels,
;                     2 for image pixels, and 3 for arc seconds. If this
;                     parameter is not passed in, device pixels will be assumed
;
;       CSI    - Coordinate system info structure, used to detect if the unit
;                of arc seconds can be used
;
; OUTPUTS:
;       XX - New cursor width
;       YY - new cursor height
;       CURSOR_UNIT - New unit to be used for the cursor size
;
; OPTIONAL OUTPUTS:
;       STATUS - Operation indicator: 1 for accept, 0 for cancel
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       GET_DFONT, NUM_CHK
;
; COMMON BLOCKS:
;       CURSOR_SIZE - Internal common block
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
;       Written May 4, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, May 4, 1995
;       Version 2, February 26, 1996, Liyun Wang, NASA/GSFC
;          Allowed min value of slider widget to be 1 (previous was 10)
;
; VERSION:
;       Version 2, February 26, 1996
;-
;
PRO setting_size_event, event
   WIDGET_CONTROL, event.top, get_uvalue = unseen
   WIDGET_CONTROL, unseen, get_uvalue = info, /no_copy
   WIDGET_CONTROL, event.id, get_uvalue = uvalue

   CASE (uvalue) OF
      'ACCEPT': BEGIN
         info.update = 1
         WIDGET_CONTROL, info.x_size, get_value = xstr
         WIDGET_CONTROL, info.y_size, get_value = ystr
         xvalue = FIX(xstr(0))
         yvalue = FIX(ystr(0))
         IF xvalue LE 0 OR yvalue LE 0 THEN BEGIN
            xack,'You cannot enter negative number!', group = event.top
         ENDIF ELSE BEGIN
            info.xvalue = xvalue
            info.yvalue = yvalue
            WIDGET_CONTROL, unseen, set_uvalue = info, /no_copy
            WIDGET_CONTROL, event.top, set_uvalue = unseen
            xkill,event.top
            RETURN
         ENDELSE
      END
      'CANCEL': BEGIN
         info.update = 0
         WIDGET_CONTROL, unseen, set_uvalue = info, /no_copy
         xkill,event.top
         RETURN
      END
      'XSIZE': BEGIN
         WIDGET_CONTROL, info.x_size, get_value = xv
         IF NOT num_chk(xv(0)) THEN BEGIN
            xv = FIX(xv(0))
            IF xv GT 0 AND xv LT 1000 THEN $
               WIDGET_CONTROL, info.x_slider, set_value = xv
         ENDIF
      END
      'YSIZE': BEGIN
         WIDGET_CONTROL, info.y_size, get_value = yv
         IF NOT num_chk(yv(0)) THEN BEGIN
            yv = FIX(yv(0))
            IF yv GT 0 AND yv LT 1000 THEN $
               WIDGET_CONTROL, info.y_slider, set_value = yv
         ENDIF
      END
      'X_SLIDER': BEGIN
         WIDGET_CONTROL, info.x_slider, get_value = tt
         WIDGET_CONTROL, info.x_size, set_value = tt(0)
      END
      'Y_SLIDER': BEGIN
         WIDGET_CONTROL, info.y_slider, get_value = tt
         WIDGET_CONTROL, info.y_size, set_value = tt(0)
      END
      ELSE:
   ENDCASE

   aa = WHERE(uvalue EQ info.opts, cnt)
   IF cnt GT 0 THEN BEGIN
      i = aa(0)
      IF info.opts_idx(i) THEN info.opts_idx(i) = 0 ELSE info.opts_idx(i) = 1
      WIDGET_CONTROL, info.opt_bt(i), set_button = info.opts_idx(i)
   ENDIF

   IF WIDGET_INFO(event.top, /valid) THEN BEGIN
      WIDGET_CONTROL, unseen, set_uvalue = info, /no_copy
      WIDGET_CONTROL, event.top, set_uvalue = unseen
   ENDIF
END

PRO set_cursor_size, xx, yy, cursor_unit, csi=csi, status=status
   COMMON cursor_size, opts_idx
   ON_ERROR, 2

   IF N_PARAMS() NE 2 AND N_PARAMS() NE 3 THEN BEGIN
      MESSAGE, 'Syntax: set_cursor_size, xx, yy , unit [, csi=csi]',/cont
      RETURN
   ENDIF

   IF N_ELEMENTS(cursor_unit) EQ 0 THEN cursor_unit = 1
   IF cursor_unit GT 3 OR cursor_unit LE 0 THEN cursor_unit = 1
   max_val = 1000
   min_val = 1

   bfont="-adobe-courier-bold-r-normal--25-180-100-100-m-150-iso8859-1"
   bfont=(get_dfont(bfont))(0)

   base = WIDGET_BASE(title = 'Set Cursor Size', /column)

   row = WIDGET_BASE(base, /row, /frame)
   accept = WIDGET_BUTTON(row, value = 'ACCEPT', uvalue = 'ACCEPT',$
                         font = bfont)
   cancel = WIDGET_BUTTON(row, value = 'CANCEL', uvalue = 'CANCEL',$
                         font = bfont)
   row = WIDGET_BASE(base, /row, /frame)
   junk = WIDGET_LABEL(row, value = 'Selection')
   temp = WIDGET_BASE(row, /row, /frame)
   x_size = cw_field(temp, title = 'X', value = '', uvalue = 'XSIZE',$
                    xsize = 5, /row, /ret)
   y_size = cw_field(temp, title = 'Y', value = '', uvalue = 'YSIZE',$
                    xsize = 5, /row, /ret)

   row = WIDGET_BASE(base, /row, /frame)
   lable = WIDGET_LABEL(row, value = 'Unit to Use')

   opts = ['Device Pixels', 'Image Pixels', 'Arc seconds']
   n_opts = N_ELEMENTS(opts)
   xmenu, opts, row, /column, /exclusive, uvalue=opts, buttons = opt_bt
;---------------------------------------------------------------------------
;  Disable certain buttons
;---------------------------------------------------------------------------
   IF N_ELEMENTS(csi) EQ 0 THEN BEGIN
      WIDGET_CONTROL, opt_bt(1), sensitive = 0
      WIDGET_CONTROL, opt_bt(2), sensitive = 0
      cursor_unit = 1
   ENDIF ELSE BEGIN
      IF csi.cdelt1 EQ 0.0 OR csi.cdelt2 EQ 0.0 THEN BEGIN
         WIDGET_CONTROL, opt_bt(2), sensitive = 0
      ENDIF
   ENDELSE
   
   IF N_ELEMENTS(opts_idx) EQ 0 THEN BEGIN
      opts_idx = INTARR(n_opts)
      opts_idx(cursor_unit-1) = 1
   ENDIF
   
   FOR i = 0, n_opts-1 DO BEGIN
      WIDGET_CONTROL, opt_bt(i), set_button = opts_idx(i)
   ENDFOR

   IF N_ELEMENTS(xx) NE 0 THEN BEGIN
      xvalue = xx < max_val
      yvalue = yy < max_val
   ENDIF ELSE BEGIN
      xvalue = 30
      yvalue = 30
   ENDELSE

;    IF N_ELEMENTS(opts_idx) NE 0 THEN BEGIN
;       unit = (WHERE(opts_idx EQ 1))(0)
;       IF unit GT -1 THEN BEGIN
;          CASE (unit) OF
;             1: BEGIN
;                xvalue = min_val > (FIX(xvalue*csi.ddelt1) < max_val)
;                yvalue = min_val > (FIX(yvalue*csi.ddelt2) < max_val)
;             END
;             2: BEGIN
;                xvalue = min_val > (FIX(xvalue*csi.cdelt1*csi.ddelt1) < max_val)
;                yvalue = min_val > (FIX(yvalue*csi.cdelt2*csi.ddelt1) < max_val)
;             END
;             ELSE:
;          ENDCASE
;       ENDIF
;    ENDIF

   xbase = WIDGET_BASE(base, /column, /frame)
   x_slider = WIDGET_SLIDER(xbase, mini = min_val, maxi = max_val, $
                            value = STRTRIM(xvalue), $
                            uvalue = 'X_SLIDER',/drag)
   lb = WIDGET_LABEL(xbase, value = 'X Value')

   ybase = WIDGET_BASE(base, /column, /frame)
   y_slider = WIDGET_SLIDER(ybase, mini = min_val, maxi = max_val, $
                            value = STRTRIM(yvalue),$
                            uvalue = 'Y_SLIDER',/drag)
   lb = WIDGET_LABEL(ybase, value = 'Y Value')
   
   update = 0
   info = {opt_bt:opt_bt, opts:opts, opts_idx:opts_idx, $
           update:update, xvalue:xvalue, yvalue:yvalue, $
           x_size:x_size, y_size:y_size,x_slider:x_slider,y_slider:y_slider}

   WIDGET_CONTROL, x_size, set_value = STRTRIM(xvalue,2)
   WIDGET_CONTROL, y_size, set_value = STRTRIM(yvalue,2)
   WIDGET_CONTROL, x_slider, set_value = STRTRIM(xvalue,2)
   WIDGET_CONTROL, y_slider, set_value = STRTRIM(yvalue,2)
   WIDGET_CONTROL, base, /realize

   unseen = WIDGET_BASE()
   WIDGET_CONTROL, unseen, set_uvalue = info, /no_copy
   WIDGET_CONTROL, base, set_uvalue = unseen

   XMANAGER, 'setting_size', base, /modal
   WIDGET_CONTROL, unseen, get_uvalue = info, /no_copy
   xkill, unseen
   IF info.update THEN BEGIN
      opts_idx = info.opts_idx
      xx = info.xvalue
      yy = info.yvalue
      unit = (WHERE(opts_idx EQ 1))(0)
      IF unit GT -1 THEN cursor_unit = unit+1 ELSE cursor_unit = 1
;      IF unit GT -1 THEN BEGIN
;          CASE (unit) OF
;             1: BEGIN
;                xx = FIX(info.xvalue/csi.ddelt1)
;                yy = FIX(info.yvalue/csi.ddelt2)
;             END
;             2: BEGIN
;                xx = FIX(info.xvalue/csi.cdelt1/csi.ddelt1)
;                yy = FIX(info.yvalue/csi.cdelt2/csi.ddelt2)
;             END
;             ELSE: BEGIN
;                xx = info.xvalue
;                yy = info.yvalue
;             END   
;          ENDCASE
;       ENDIF
   ENDIF
   status = info.update
END

;---------------------------------------------------------------------------
; End of 'set_cursor_size.pro'.
;---------------------------------------------------------------------------
