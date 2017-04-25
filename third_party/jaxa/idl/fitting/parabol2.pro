pro parabol2,x1,x2,x3,y1,y2,y3,x0,y0,a,ier
;
; PURPOSE:
;	Parabol-Fit trough three points   
;			 2
;	(yi-y0)=a*(xi-x0)
;
; INPUT:
;	x1,x2,x3	= 3 x-coordinates on x-axis
;	y1,y2,y3	= 3 y-function values y(x)
;
; OUTPUT:
;	x0,y0,a		= parameters of parabola
;	ier		= error status
;
; HISTORY:
;	1990, aschwand@lmsal.com
;

	X0 =0.
	Y0 =0.
	A  =0.
	IER=0
	IF (X2 LT min([X1,X3])) THEN IER=1
	IF (X2 GT max([X1,X3])) THEN IER=1
	IF (IER NE 0) THEN GOTO,FINI
;Analytical parabol equations inverted
	A=(Y2-Y1)*(X3-X2)
	B=(Y3-Y2)*(X2-X1)
	C=(X3+X2)
	D=(X2+X1)
	IF (B-A EQ 0) THEN IER=2
	IF (IER NE 0) THEN GOTO,FINI
	X0=(B*D-A*C)/(2*(B-A))
	IF (D-2.*X0 EQ 0) THEN IER=3
	IF (IER NE 0) THEN GOTO,FINI
	IF (Y1 NE Y2) THEN A =(Y2-Y1)/((D-2.*X0)*(X2-X1))
	IF (Y1 EQ Y2) THEN A =(Y3-Y2)/((C-2.*X0)*(X3-X2))
	Y0=Y1-A*(X1-X0)^2
FINI:
  	RETURN
	END
