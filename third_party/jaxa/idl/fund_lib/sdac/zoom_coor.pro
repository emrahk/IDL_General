;+
; PROJECT:
;	SDAC
; NAME: 
;	ZOOM_COOR
;
; PURPOSE: This provides a query to mark the corners of an image box range.
;	
; CATEGORY: graphics
;
; CALLING SEQUENCE: zoom_coor,x,y
; 
; EXAMPLES: zoom_coor,x,y
;	
; INPUTS: none.
;       
; OUTPUTS:      x & y ; start and stop limits on x and y axis from chosen points.
;
; RESTRICTIONS: Works on all IDL graphics supported by cursor.
;
; HISTORY:	 Shelby Kennard                                   21Feb1991
;
; CONTACT: richard.schwartz@gsfc.nasa.gov
;-

pro zoom_coor,x,y

on_error, 2

; Get x and y window limits.
;
l = !x.window(0)
r = !x.window(1)
b = !y.window(0)
t = !y.window(1)
;
if !d.name eq 'X' then begin
   xyouts,l+.02,t-.06,'Position cursor at corner of zoom window ' + $
          'and press MB1.', /normal
endif else begin
   xyouts,l+.02,t-.06,'Position cursor at corner of zoom window ' + $
          'and press any key.', /normal
endelse   
;
cursor, x1, y1, /down
;
; Plot a small cross bar at the selected coordinates.
;
crossbar, x1, y1
;
; Get second set of coordinates.
;
if !d.name eq 'X' then begin
   xyouts,l+.02,t-.09,'Move cursor to opposite corner of zoom window ' + $
          'and press MB1.',/normal
endif else begin
   xyouts,l+.02,t-.09,'Move cursor to opposite corner of zoom window ' + $
          'and press any key.',/normal
endelse
;
cursor, x2, y2, /down
;
crossbar, x2, y2
;
; Determine mins and maxs'.
;
if x1 lt x2 then begin
  x = [x1,x2]
endif else begin
  x = [x2,x1]
endelse
;
if y1 lt y2 then begin
  y = [y1,y2]
endif else begin
  y = [y2,y1]
endelse
;
end
