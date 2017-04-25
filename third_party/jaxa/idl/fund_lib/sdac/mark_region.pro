;+
; Project     : SDAC
;
; Name        : MARK_REGION
;
; Purpose     : This procedure selects an interval from a plot window.
;
; Category    : UTIL, GEN, GRAPHICS
;
; Explanation : The cursor is used to interactively select an x range.
;
; Use         : MARK_REGION, Start, Endr
;
; Inputs      : None
;
; Opt. Inputs : None
;
; Outputs     : Start- Time in seconds from plot basetime
;		Endr - Time in seconds from plot basetime
;
; Opt. Outputs: None
;
; Keywords    : WMESSAGE- a message to appear in a text widget as in GOES
;
; Calls       : GRAPHICS_PAGE, CROSSBAR
;
; Common      : None
;
; Restrictions:
;
; Side effects: None.
;
; Prev. Hist  : UNKNOWN
;
; Modified    : Version 2, Documented, 29-jan-1997
;				Version 3, richard.schwartz 13-nov-1999. Fixed for windows and Mac.
; Contact     : richard.schwartz@gsfc.nasa.gov
;-
;==============================================================================
pro mark_region, start, endr, wmessage=wmessage

; Get x and y window limits.

l = !x.window(0)
r = !x.window(1)
b = !y.window(0)
t = !y.window(1)

!err = 0

if !d.name eq xdevice() then begin
   xyouts, l+.02, t-.06, $
       'Position cursor at background start time and press MB1.',/norm
endif else begin
   xyouts, l+.02, t-.06, $
      'Position cursor at background start time and press x.', /normal
   graphics_page
   device,gin_char=6
endelse
cursor, start, y1, /down
crossbar, start, y1

if !d.name eq xdevice() then begin
   xyouts, l+.02, t-.09, $
       'Position cursor at background end time and press MB1.',/norm
endif else begin
   xyouts, l+.02, t-.09, $
      'Position cursor at background end time and press x.', /normal
   if keyword_set(wmessage) then begin
      widget_control, wmessage, /append, set_value = $
         'Position cross at background start time, Press ' + $
         'left mouse button.'
      widget_control, wmessage, /append, set_value = $
         '  Then position cross at background end time, Press '+$
         'left mouse button.'
   endif
endelse
cursor, endr, y2, /down
crossbar, endr, y2

end
