function smooth_edge,x,width,edge
;
; PURPOSE:
;	generalized smoothing function which extrapolates 2-D image
;	beyond boundaries before smoothing. This reduces edge-effects
;	that occur with the standard smoothing function
;
; INPUT:
;	x	= 2D image
;	width	= number of pixels of ramp (to be extrpolaed beyond boundaries)
;	edge	= option of extapolation:
;		  EDGE=0	constant extrapolation at boundary
;		  EDGE=1	linear extrapolation at boundary
;		  EDGE=2	parabolic extrapolation at boundary
;
; EXAMPLE:
;	smooth_array = smooth_edge(array,nx/10,0)
;
; HISTORY:
;	aschwand@lmsal.com


DIM	=SIZE(X)
NX	=DIM(1)

;1-dim smoothing-----------------------------------------------
if (dim(0) eq 1) then begin
ny	=1
XX	=SMOOTH(X,WIDTH)
 
IF (EDGE EQ 0) THEN BEGIN
 XX(0:WIDTH)=XX(WIDTH)
 XX(NX-1-WIDTH:NX-1)=XX(NX-1-WIDTH)
ENDIF

IF (EDGE EQ 1) THEN BEGIN
 Y1	=XX(WIDTH)	&Y2=XX(WIDTH*2)
 Y4	=XX(NX-1-WIDTH) &Y3=XX(NX-1-WIDTH*2)
 C1	=(Y2-Y1)/FLOAT(WIDTH)
 C3	=(Y4-Y3)/FLOAT(WIDTH)
 FOR I=0,WIDTH DO XX(I)=Y1+C1*FLOAT(I-WIDTH)
 FOR I=0,WIDTH DO XX(NX-1-WIDTH+I)=Y4+C3*FLOAT(I)
ENDIF

IF (EDGE EQ 2) THEN BEGIN
 I1	=WIDTH		&I2=WIDTH+WIDTH/2  	&I3=WIDTH*2
 X1	=FLOAT(I1)	&X2=FLOAT(I2)		&X3=FLOAT(I3)
 Y1	=XX(I1)		&Y2=XX(I2)		&Y3=XX(I3)
 PARABOL2,X1,X2,X3,Y1,Y2,Y3,X0,Y0,A,IER
 FOR I=0,WIDTH DO XX(I)=Y0+A*(FLOAT(I)-X0)^2
 I1	=NX-1-2*WIDTH	&I2=NX-1-WIDTH-WIDTH/2  &I3=NX-1-WIDTH
 X1	=FLOAT(I1)	&X2=FLOAT(I2)		&X3=FLOAT(I3)
 Y1	=XX(I1)		&Y2=XX(I2)		&Y3=XX(I3)
 PARABOL2,X1,X2,X3,Y1,Y2,Y3,X0,Y0,A,IER
 FOR I=I3,NX-1 DO XX(I)=Y0+A*(FLOAT(I)-X0)^2
ENDIF
end

;2-dim smoothing__________________________________________________
if (dim(0) gt 1) then begin
ny	=dim(2)
XX	=SMOOTH(X,WIDTH)
 
IF (EDGE EQ 0) THEN BEGIN
 for i=0,ny-1 do begin
  XX(0:WIDTH,i)=XX(WIDTH,i)
  XX(NX-1-WIDTH:NX-1,i)=XX(NX-1-WIDTH,i)
 endfor
 for i=0,nx-1 do begin
  XX(i,0:WIDTH)=XX(i,WIDTH)
  XX(i,Ny-1-WIDTH:Ny-1)=XX(i,Ny-1-WIDTH)
 endfor 
ENDIF

IF (EDGE EQ 1) THEN BEGIN
 for j=0,ny-1 do begin
  Y1	=XX(WIDTH,j)		&Y2=XX(WIDTH*2,j)
  Y4	=XX(NX-1-WIDTH,j) 	&Y3=XX(NX-1-WIDTH*2,j)
  C1	=(Y2-Y1)/FLOAT(WIDTH)
  C3	=(Y4-Y3)/FLOAT(WIDTH)
  FOR I=0,WIDTH DO XX(I,j)=Y1+C1*FLOAT(I-WIDTH)
  FOR I=0,WIDTH DO XX(NX-1-WIDTH+I,j)=Y4+C3*FLOAT(I)
 endfor
 for j=0,nx-1 do begin
  Y1    =XX(j,WIDTH)            &Y2=XX(j,WIDTH*2)
  Y4    =XX(j,Ny-1-WIDTH)       &Y3=XX(j,Ny-1-WIDTH*2)
  C1    =(Y2-Y1)/FLOAT(WIDTH)
  C3    =(Y4-Y3)/FLOAT(WIDTH)
  FOR I=0,WIDTH DO XX(j,I)=Y1+C1*FLOAT(I-WIDTH)
  FOR I=0,WIDTH DO XX(j,Ny-1-WIDTH+I)=Y4+C3*FLOAT(I)
 endfor  
ENDIF

IF (EDGE EQ 2) THEN BEGIN
 for j=0,ny-1 do begin
  I1	=WIDTH		&I2=WIDTH+WIDTH/2  	&I3=WIDTH*2
  X1	=FLOAT(I1)	&X2=FLOAT(I2)		&X3=FLOAT(I3)
  Y1	=XX(I1,j)	&Y2=XX(I2,j)	&Y3=XX(I3,j)
  PARABOL2,X1,X2,X3,Y1,Y2,Y3,X0,Y0,A,IER
  FOR I=0,WIDTH DO XX(I,j)=Y0+A*(FLOAT(I)-X0)^2
  I1	=NX-1-2*WIDTH	&I2=NX-1-WIDTH-WIDTH/2  &I3=NX-1-WIDTH
  X1	=FLOAT(I1)	&X2=FLOAT(I2)		&X3=FLOAT(I3)
  Y1	=XX(I1,j)	&Y2=XX(I2,j)		&Y3=XX(I3,j)
  PARABOL2,X1,X2,X3,Y1,Y2,Y3,X0,Y0,A,IER
  FOR I=I3,NX-1 DO XX(I,j)=Y0+A*(FLOAT(I)-X0)^2
 endfor
 for j=0,nx-1 do begin
  I1    =WIDTH          &I2=WIDTH+WIDTH/2       &I3=WIDTH*2
  X1    =FLOAT(I1)      &X2=FLOAT(I2)           &X3=FLOAT(I3)
  Y1    =XX(j,I1)       &Y2=XX(j,I2)   		&Y3=XX(j,I3)
  PARABOL2,X1,X2,X3,Y1,Y2,Y3,X0,Y0,A,IER
  FOR I=0,WIDTH DO XX(j,I)=Y0+A*(FLOAT(I)-X0)^2
  I1    =Ny-1-2*WIDTH   &I2=Ny-1-WIDTH-WIDTH/2  &I3=Ny-1-WIDTH
  X1    =FLOAT(I1)      &X2=FLOAT(I2)           &X3=FLOAT(I3)
  Y1    =XX(j,I1)       &Y2=XX(j,I2)            &Y3=XX(j,I3)
  PARABOL2,X1,X2,X3,Y1,Y2,Y3,X0,Y0,A,IER
  FOR I=I3,Ny-1 DO XX(j,I)=Y0+A*(FLOAT(I)-X0)^2
 endfor  
ENDIF
endif
RETURN,XX	&END
