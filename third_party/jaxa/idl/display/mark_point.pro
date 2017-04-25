;+
; Project     : RHESSI
;
; Name        : MARK_POINT
;
; Purpose     : mark a point at a specified position on an existing plot
;
; Category    : display
;
; Syntax      : IDL> mark_point,mark_point
;
; Inputs      : MARK_POINT=[X,Y] = data coordinates at which to plot point
;
; Outputs     : None
;
; Keywords    : None
;
; History     : Written 26 December 2002, Zarro (EER/GSFC), based on Kim's earlier version
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mark_point,mark_point

if n_elements(mark_point) ne 2 then return
xmin=!x.crange[0]
xmax=!x.crange[1]
ymin=!y.crange[0]
ymax=!y.crange[1]

good_size = ( (xmax-xmin) > (ymax-ymin) ) / 100.
mark_colors = [50,100,150,200,255]
xx=mark_point[0] & yy = mark_point[1]

; if point is within current plot winodw, draw a few concentric circles in a few colors
;   so at least some color will show against whatever color the image is

if xx ge xmin and xx le xmax and yy ge ymin and yy le ymax then begin
 for i=0,4 do draw_circle, mark_point[0], mark_point[1], good_size*(1.+i*.2), $
  color=mark_colors[i]

; otherwise draw an arrow at the edge of the plot showing the direction to the point
endif else begin
 if abs(xx - xmax) lt abs(xx - xmin) then xclosest = xmax else xclosest = xmin
 if abs(yy - ymax) lt abs(yy - ymin) then yclosest = ymax else yclosest = ymin
 xcen = (xmin + xmax)/2.  &  ycen = (ymin + ymax)/2.
 if xx eq xcen then xymark = [xx, yclosest]
 if yy eq ycen then xymark = [xclosest, yy]
 if not exist(xymark) then begin
  m = (yy - ycen) / (xx - xcen) & b = yy - m*xx
  x = (yclosest - b) / m
  y = m*xclosest + b
  if (x ge xmin) and (x le xmax) then xymark = [x,m*x+b] else xymark = [(y-b)/m, y]
 endif
 ang = atan(yy-ycen, xx-xcen) * !radeg
 arrow2, xymark[0], xymark[1], ang, good_size*8., /angle, /data
endelse

return
end

