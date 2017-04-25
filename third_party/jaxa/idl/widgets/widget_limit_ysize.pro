;+
; NAME: widget_limit_ysize
; 
; PURPOSE;  Adjust y size of scrolling widget to be less than screen size.
; 
; METHOD: For widgets that may too long in y dim, create the top base with /scroll, set up
;  all the inner widgets, and then call this routine just before realizing the widget to limit the view size of the 
;  widget to the specified fraction of the screen.  Uses widget_info(wid,/geom) to get size of widget 
;  and then uses widget_control to set ysize to be less than yfrac of screen size.  If the new ysize is less than
;  the ysize of the full widget, the scroll bar will appear.  Otherwise it won't.
;  
;  On Windows, widget size automatically adjusts to fit contents.  So the geom of the top level widget will reflect
;  the full size needed by the widget.
;  On Unix, the initial size of the widget is very small in both x and y (like 100x100), and this is reflected 
;  in the widget_info(..,/geom) - so doesn't give any info about the full size needed by the widget.  To get around 
;  this problem, create a widget base inside the top level base that contains everything, but is not scrolling.
;  The widget_info(..,/geom) for this widget will give the full size needed.  Use that to set both x and y (but
;  limit y to the fraction of the screen requested).
;  
;  Note: don't use /column or /row on top level base - if do, then puts scroll bar even if not needed.
;  
;  Arguments:
;  w_top_base - widget id of top level base created with /scroll
;  w_box - widget id of inner widget that contains all widgets, but doesn't scroll (not needed for Windows)
;  
;  Input keywords:
;  yfrac - fraction of screen in y dimension to limit widget to.  Default is .75
;  
; Written:  Kim Tolbert 20-Jan-2011
; 
;-
 
pro widget_limit_ysize, w_top_base, w_box, yfrac=yfrac

checkvar, yfrac, .75

device, get_screen_size=scrsize
max_ysize = yfrac * scrsize[1]

 ; on unix top scrollable widget is initially small in both x and y.  Use w_box to get size needed for full widget
 ; on windows, the the scrollable widget is sized as needed to contain everything.  Just adjust y for frac*scrren height.
 
if os_family(/lower) eq 'unix' then begin
  box_geom = widget_info(w_box, /geometry)
  xsize = box_geom.xsize
  ysize = box_geom.ysize
endif else begin
  top_geom = widget_info(w_top_base, /geom)
  ysize = top_geom.ysize
endelse

; set top base to new ysize (and xsize for unix)
widget_control, w_top_base, xsize = xsize, ysize = (ysize < max_ysize)

end