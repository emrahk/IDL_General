;+
; PROJECT:
;       SDAC
; NAME: 
;	CROSSBAR
;
; PURPOSE: 
;	This procedure overplots a crossbar for the procedures point and zoom_coor.
;
; CATEGORY:
;       GRAPHICS 
;
; CALLING SEQUENCE:
;       CROSSBAR,X,Y
;
; INPUTS: 
;	X:	x argument where crossbar is to be plotted.
;	Y:	y argument where crossbar is to be plotted.
;
; OUTPUTS:
;       No arguments  returned, crossbar overplotted on graphics window.
;
; KEYWORDS:
;       None.
;
; RESTRICTIONS:
;	To get a cross bar of equal height and width requires converting 
;	the coordinates form data to normalized values make a 2 element 
;	array for both x + and - offset and y + and - offset. Convert these 
;	2 arrays back to data coordinate values.  Written to support early
;	programs from SDAC.
;
; HISTORY:
;       Written by:	Shelby Kennard, ~1989.
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-

;
pro crossbar,x,y
;
;
nxo = fltarr(2)
nyo = fltarr(2)
xx = fltarr(2)
yy = fltarr(2)
;
xx = [x,x]
yy = [y,y]
;
xi = !x.s
yi = !y.s
;
logy = !y.type
if logy then begin
  ny = yi(0) + yi(1)*alog10(y)
  nyo = [ny-.03,ny+.03]
  dy = 10^((nyo-yi(0)) / yi(1))
endif else begin
  ny = yi(0) + yi(1)*y
  nyo = [ny-.03,ny+.03]
  dy = (nyo-yi(0)) / yi(1)
endelse
nx = xi(0) + xi(1)*x
nxo = [nx-.03,nx+.03]
dx = (nxo-xi(0)) / xi(1)
;
oplot,xx,dy
oplot,dx,yy
;
end
