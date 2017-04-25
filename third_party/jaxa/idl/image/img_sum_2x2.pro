function IMG_SUM_2X2,Img
;+
; NAME:
;	IMG_SUM_2X2
;
; PURPOSE:
;	This function does a rebinning into an array that is 1/2 the size of
;	the original image in each axis, by summing 2x2 pixels.  This increases
;	signal to noise.  
;
; CATEGORY:
;	LASCO ANALYSIS
;
; CALLING SEQUENCE:
;	Result = IMG_SUM_2X2 ( Img )
;
; INPUTS:
;	Img:	Input image, can be any type other than string
;
; OPTIONAL INPUTS:
;	None
;	
; OUTPUTS:
;	This function returns an image which is the result of the 2x2 pixel summing.
;
; RESTRICTIONS:
;	Forces the input array to have an even number of rows and columns.
;
; PROCEDURE:
;	Generates the indices of the 2x2 pixels and forms the summing explicitly from
;	these indices.
;
; MODIFICATION HISTORY:
; 	Written by:	RA Howard, 12 March 1996.
;
;	@(#)img_sum_2x2.pro	1.1 10/04/96 LASCO IDL LIBRARY
;-
;
sz = SIZE(img)
nx = sz(1)	; number of columns in original
ny = sz(2)	; number of rows in original
;
;	Make sure that Img has an even number of columns and rows
;
mx = nx/2
my = ny/2
IF ( (mx*2 NE nx) OR (my*2 NE ny) )  THEN orig=img(0:mx*2-1,0:my*2-1) $
                                     ELSE orig=img
;
;	Form indices of the lower left point of the 2x2 squares in the image
;
nt = LONG (mx)*my
ind = LINDGEN (nt)
rows = mx*(ind/mx)
cols = ind-rows
rows=reform(rows,mx,my)
cols=reform(cols,mx,my)
p0 = 2*cols+4*rows		; lower left point of the array
p1 = p0+1			; lower right point of the array
p2 = p0+nx			; upper left point
p3 = p2+1			; upper right point
;
;	Do the sum and reformat into a 2-D array
;
RETURN , REFORM ( orig(p0)+orig(p1)+orig(p2)+orig(p3) , mx, my )
END

