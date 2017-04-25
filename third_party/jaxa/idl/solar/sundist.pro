pro sundist,coord,dist,angle,xsize=xsize,ysize=ysize
;+
; NAME:
;	SUNDIST
;
; PURPOSE:
;   	This procedure generates two arrays whose elements are the distance 
;	from the center of the sun and the position angle from solar north.
;
; CATEGORY:
;	UTIL
;
; CALLING SEQUENCE:
;	SUNDIST,Coord,Dist,Angle
;
; INPUTS:
;	Coord = 4 word array containing the solar coordinates,
;			column center of sun,
;			row center of sun,
;			roll angle of solar north,
;			number of pixels per radius
;
; KEYWORD PARAMETERS:
;	XSIZE = Number of columns in image, default is 1024
;	YSIZE = Number of rows in image, default is square matrix
;
; OUTPUTS:
;	Dist = array whose elements are solar radii
;
; OPTIONAL OUTPUTS:
; 	Angle = array whose elements are position angle
;
; MODIFICATION HISTORY:
; 	Written by:	R.A. Howard, NRL, 27 October 1995
;
;
;	@(#)sundist.pro	1.1 09/19/96 LASCO IDL LIBRARY
;-
;
IF (KEYWORD_SET(xsize)) THEN xs=xsize ELSE xs=1024L
IF (KEYWORD_SET(ysize)) THEN ys=ysize ELSE ys=xs
col = LINDGEN(xs,ys)
row = col/xs
col = coord(0)-FLOAT(col MOD xs)
row = coord(1)-FLOAT(row)
dist = SQRT(row*row+col*col)/coord(3)
IF (N_PARAMS() GT 2) THEN BEGIN
   angle = ATAN(col,row)-coord(2)
   w = WHERE (angle LT 0,nw)
   IF (nw GT 0) THEN angle(w) = 2*!pi + angle(w)
ENDIF
RETURN
END
