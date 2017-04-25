;+
; Project     : SOHO-CDS
;
; Name        : SCOPE
;
; Purpose     : zoom in on an image
;
; Category    : imaging
;
; Explanation : Calls SCOPE_CURSOR to draw a fixed size box in which to zoom.
;               User presses left mouse button to effect zoom
;
; Syntax      : scope,mag
;
; Opt. Inputs : MAG = zoom magnification factor [def=3]
;
; Outputs     : None
;
; Keywords    : SIZE = initial box size [def=100]
;               NOSCALE = set to not bytescale image when zooming
;               PERCENT = box size in % of window units
;
; History     : Written:  D. Zarro, 28-Dec-98 (SMA/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro scope,mag,size=gsize,percent=percent,_extra=extra

if not exist(mag) then mag=3
if exist(gsize) then gsize=[gsize(0),gsize( n_elements(gsize)-1 )] else begin
 if keyword_set(percent) then gsize=[25.,25.] else gsize=[100,100]
endelse

message,'press left mouse to zoom, right mouse to quit',/cont

if keyword_set(percent) then gsize=[gsize(0)*!d.x_vsize,gsize(1)*!d.y_vsize]/100

scope_cursor,mag=mag,/box,/fixed,size=gsize,_extra=extra

return & end
