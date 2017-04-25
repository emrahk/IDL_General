pro parabol_max,x,y,xmax,ymax,xx,yy
;
; PURPOSE:
;	parabolic interpolation through 3 nearest points at maximum
;	including interpolated parabola segment (xx,yy)
;
; INPUT:
;	x	= 1D array of x-coordinates
;	y	= 1D array of y-function values y(x)
;
; OUTPUT:
;	xmax	= location of parabola maximum on x-axis
;	ymax	= y-function value at parabola maximum
;	xx	= interpolatex values on x-axis
;	yy	= parabola function yy(xx)
;
; HISTORY:
;	1999, aschwanden@lmsal.com


n	=n_elements(y)
ymax	=max(y)
im	=(!c > 1) < (n-2)
parabol2,x(im-1),x(im),x(im+1),y(im-1),y(im),y(im+1),xmax,ymax,amax
if (xmax ge x(im+1)) then begin &xmax=x(im+1) &ymax=y(im+1) &endif
if (xmax le x(im-1)) then begin &xmax=x(im-1) &ymax=y(im-1) &endif
xx	=x(im-1)+(x(im+1)-x(im-1))*findgen(100)/float(99)
yy	=ymax+amax*(xx-xmax)^2
end

