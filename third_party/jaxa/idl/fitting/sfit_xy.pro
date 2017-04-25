;+
; NAME:
;	SFIT_XY
;
; PURPOSE:
;	Polynomial fit to a surface on non-uniform grids. 
;
; CATEGORY:
;	Curve and surface fitting.
;
; CALLING SEQUENCE:
;	Result = SFIT_XY(Data, Degree_X [ , Degree_Y, X=X, Y=Y, KX=Kx ] )
;
; INPUTS:
; 	Data:	The array of data to fit. The sizes of the dimensions may 
;               be unequal.
;
;	Degree_x: The degree of fit in the X dimension
;
;	Degree_y: The degree of fit in the Y dimension (def.: Degree_x)
;
; OUTPUT:
;	This function returns a fitted array.
;
; OUTPUT KEYWORDS:
;       X,Y:    array of coordinates
;
; OUTPUT KEYWORDS:
;	Kx:	The array of coefficients for a polynomial function
;		of x and y to fit data.
;		This parameter is returned as a (Degree+1) by (Degree+1) 
;		element array.
;
; PROCEDURE:
; 	Fit a 2D array Z as a polynomial function of x and y.
; 	The function fitted is:
;  	    F(x,y) = Sum over i and j of kx(j,i) * x^i * y^j
; 	where kx is returned as a keyword.
;
; MODIFICATION HISTORY:
;	July, 1998, V. Andretta: Modified from SFIT
;
;-

function sfit_xy, z, degree_x, degree_y, kx=kx, x=x, y=y

   on_error, 2

   s=size(z)
   dims=s[1:s[0]]
   m=n_elements(z)
   nx = dims[0]
   if s[0] gt 1 then ny = dims[1]

   if n_elements(x) eq 0 then x = findgen(nx) # replicate(1., ny)
   if n_elements(y) eq 0 then y = replicate(1.,nx) # findgen(ny)
   if n_elements(x) ne m or n_elements(y) ne m then $
     message,'Dimensions of coordinate array(s) incompatible with data array'

   if n_elements(degree_y) eq 0 then degree_y = degree_x
   n2=(degree_x+1)*(degree_y+1) ;# of coefficients to solve

   ut = dblarr(n2, m, /nozero)
   for i=0, degree_x do for j=0,degree_y do $
	ut[i*(degree_y+1) + j, 0] = reform(float(x)^i * float(y)^j, 1, m)

   kk = invert(ut # transpose(ut)) # ut
   kx = fltarr(degree_y+1, degree_x+1) + float(kk # reform(z, m, 1))
   fit = reform(reform(kx,n2) # ut, dims)
   return, fit
end


