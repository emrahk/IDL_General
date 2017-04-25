;+
; Name: color_box
;
; Purpose: Draw a color-filled rectangle
; 
; Input Keywords:
;  x - low, high x values of rectangle (default is full x range)
;  y - low, high y values of rectangle (default is full y range)
;  _extra - color or any other keywords to pass to polyfill
; 
; Written: Kim Tolbert 3_may-2012
;-
pro color_box, x=xvals, y=yvals, _extra=_extra


x = keyword_set(xvals) ? xvals : crange('x')
y = keyword_set(yvals) ? yvals : crange('y')

polyfill, [x[0],x[0],x[1],x[1]], [y[0],y[1],y[1],y[0]], _extra=_extra

end
 