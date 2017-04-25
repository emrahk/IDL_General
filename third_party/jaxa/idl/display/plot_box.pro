;+
; Project     : RHESSI
;
; Name        : PLOT_BOX
;
; Purpose     : just plot a box
;
; Category    : display
;
; Syntax      : plot_box,xcen,ycen,width,height
;
; Inputs      : XCEN, YCEN - box center coordinates
;               WIDTH, HEIGHT - box width & height
;               [Default units are data]
;
; Keywords    : all plot keywords
;
; History     : Written:  D. Zarro, 23-May-04 (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro plot_box,xcen,ycen,width,height,_extra=extra

if n_params() ne 4 then begin
 pr_syntax,'plot_box,xcen,ycen,width,height'
 return
endif

error=0
catch,error
if error ne 0 then begin
 message,err_state(),/cont
 return
endif

w2=width/2.
h2=height/2.

plots,[xcen-w2,xcen-w2,xcen+w2,xcen+w2,xcen-w2],$
      [ycen-h2,ycen+h2,ycen+h2,ycen-h2,ycen-h2],/data,_extra=extra

return
end
