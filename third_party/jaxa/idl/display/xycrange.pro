;+
; NAME:
;       xycrange
; PURPOSE:
;       get x and y ranges using cursors
; CALLING SEQUENCE:
;       xycrange,xrange,yrange
; OUTPUTS:
;       xrange= [x1,x2] = first and second x-values selected
;       yrange= [y1,y2] = first and second y-values selected
; PROCEDURE:
;       uses CURSOR
; HISTORY:
;       Written Mar'93 (DMZ,ARC)
;-
  

pro xycrange,xrange,yrange,linestyle=linestyle,quit=quit

if n_elements(linestyle) eq 0 then linestyle=1
if n_elements(quit) eq 0 then quit=1

cursor,p,q,/data
oplot,[p,p],!y.crange,linestyle=linestyle
xrange=p
yrange=q
if quit lt 2 then return
wait,1
cursor,p1,q1,/data
oplot,[p1,p1],!y.crange,linestyle=linestyle
xrange=[p,p1]
yrange=[q,q1]

return & end
