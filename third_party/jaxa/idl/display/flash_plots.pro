;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: flash_plots.pro
; Created by:    Liyun Wang, NASA/GSFC, November 2, 1994
;
; Last Modified: Thu Apr  6 11:29:18 1995 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO FLASH_PLOTS, xx, yy, num=num, rate=rate, psystem=psystem, $
                 color=color
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       FLASH_PLOTS
;
; PURPOSE: 
;       Make a flashing plot of a polygon
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       FLASH_PLOTS, xx, yy [,num=num] [,rate=rate]
;
; INPUTS:
;       XX -- X coordinates of points to be connected.
;       YY -- Y coordinates of points to be connected.
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
;       NUM    -- Number of flashing times; default is 4 times.
;       RATE   -- Flashing rate in seconds; default: 0.25 sec.
;       COLOR  -- Index of color to be used; default: !d.table_size-1
;       PSYSTEM -- Coordinate system used for plotting. Valid values are:
;                  0 -- device coodinate system (default)
;                  1 -- data coordinate system
;                  2 -- normal coordinate system
;
; CALLS:
;       None.
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
;       Written November 2, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;	Version 2, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;       
; VERSION:
;	Version 2, 8 April 1998
;-
;
   ON_ERROR, 2
   IF N_PARAMS() NE 2 THEN MESSAGE, $
      'Syntax: FALSH_PLOTS, xx, yy'
   
   IF N_ELEMENTS(xx) NE N_ELEMENTS(yy) THEN $
      MESSAGE, 'Arrays XX and YY are not compatiable.'
   
   IF N_ELEMENTS(color) EQ 0 THEN color = !d.table_size-1
   IF N_ELEMENTS(num) EQ 0 THEN num = 4
   IF N_ELEMENTS(rate) EQ 0 THEN rate = .25
   IF N_ELEMENTS(psystem) EQ 0 THEN psystem = 0
;----------------------------------------------------------------------
;  Set graphics function to be GXxor so that anything drawn on the
;  device can be removed without disturbing the device screen.
;----------------------------------------------------------------------
   DEVICE, get_graphics = old, set_graphics = 6 ;Set xor

;    CASE (psystem) OF
;       0: BEGIN
;          FOR i = 0, num-1 DO BEGIN
;             PLOTS, xx, yy, color = color, /DEVICE ; Plotting
;             wait, rate
;             PLOTS, xx, yy, color = color, /DEVICE ; Erasing
;             WAIT, .1            ;Dont hog it all
;          ENDFOR
;       END
;       1: BEGIN
;          FOR i = 0, num-1 DO BEGIN
;             PLOTS, xx, yy, color = color, /data ; Plotting
;             wait, rate
;             PLOTS, xx, yy, color = color, /data ; Erasing
;             WAIT, .1            ;Dont hog it all
;          ENDFOR
;       END
;       2: BEGIN
;          FOR i = 0, num-1 DO BEGIN
;             PLOTS, xx, yy, color = color, /normal ; Plotting
;             wait, rate
;             PLOTS, xx, yy, color = color, /normal ; Erasing
;             WAIT, .1            ;Dont hog it all
;          ENDFOR
;       END
;    ENDCASE

   CASE (psystem) OF
      0: plot_func = 'PLOTS, xx, yy, color = color, /DEVICE'
      1: plot_func = 'PLOTS, xx, yy, color = color, /DATA'
      2: plot_func = 'PLOTS, xx, yy, color = color, /NORMAL'
   ENDCASE

   FOR i = 0, num-1 DO BEGIN
      s = EXECUTE(plot_func)    ; Plotting
      WAIT, rate
      s = EXECUTE(plot_func)    ; Erasing
      WAIT, .1                  ;Dont hog it all
   ENDFOR
   
;----------------------------------------------------------------------
;  Set graphics function back to its original value
;----------------------------------------------------------------------
   DEVICE, set_graphics =  old 
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'flash_plots.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
