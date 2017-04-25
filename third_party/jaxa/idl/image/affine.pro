;==================================================

FUNCTION AFFINE, image, mx, my, sx, theta, xc, yc,$
                 INTERP=interp, CUBIC=cubic, MISSING=missing

;==================================================
;+
; NAME:
;	AFFINE
;
; PURPOSE:
;	Apply the affine transformation given by the input parameters
;       to IMAGE. 
;	
; CATEGORY:
;	Z3 - Image processing, geometric transforms, image registration.
;
; CALLING SEQUENCE:
;	transformed_image = AFFINE(image,mx,my,sx,theta,xc,yc)
;
; INPUTS:
;       IMAGE:  The image to be transformed. Must be 2-D.
;       MX, MY: Magnification factors in x and y directions.
;       SX:     Horizontal shear term.
;       THETA:  Rotation angle in DEGREES. THETA > 0 => counterclockwise rotation.
;       XC, YC: Center of rotation.
;               
; KEYWORDS:
;	INTERP:	Set this keyword for bilinear interpolation.  If this keyword
;		is set to 0 or omitted, nearest neighbor sampling is used.
;		Note that setting this keyword is the same as using the 
;		ROT_INT User Library function.  This change (and others) 
;		essentially makes ROT_INT obsolete.
;
;	CUBIC:	If specified and non-zero, "Cubic convolution"
;		interpolation is used.  This is a more
;		accurate, but more time-consuming, form of interpolation.
;		CUBIC has no effect when used with 3 dimensional arrays.
;		If this parameter is negative and non-zero, it specifies the
;		value of the cubic interpolation parameter as described
;		in the INTERPOLATE function.  Valid ranges are -1 <= Cubic < 0.
;		Positive non-zero values of CUBIC (e.g. specifying /CUBIC)
;		produce the default value of the interpolation parameter
;		which is -1.0.
;
;      MISSING:	The data value to substitute for pixels in the output image 
;		that map outside the input image.       
;
; OUTPUTS:
;       NONE
;
; RETURNS:
;       TIMAGE: the affine transformation of input image IMAGE.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Uses POLY_2D to warp the input image according to the 
;       given parameters.
;
;	See:	Image Processing for Scientific Applications
;               Bernd J\"ahne
;		CRC Press, 1997, Chapter 8.
;
;       Same as ROT.PRO but includes shear term and /PIVOT is assumed.
;
; MODIFICATION HISTORY:
;	T. Berger, LMATC, 26-February-1998.
;       S.L.Freeland, LMSAL, 10-March-1998 - backward compatible IDV V < 5
;-


ON_ERROR,2

sz = SIZE(image)
if sz(0) ne 2 then begin
    MESSAGE,'Input image must be 2-D'
    RETURN,-1
end

if N_PARAMS() eq 1 then mx = 1.D0 else mx = DOUBLE(mx)
if N_PARAMS() eq 2 then my = 1.D0 else my = DOUBLE(my)
if N_PARAMS() eq 3 then sx = 0.D0 else sx = DOUBLE(sx)
if N_PARAMS() eq 4 then begin
    theta = 0.D0
    trans =1
end else theta = DOUBLE(theta*!DTOR)
if theta eq 0 then trans=1 
if N_PARAMS() eq 5 and theta eq 0 then xc=0 
if N_PARAMS() eq 5 and theta ne 0 then xc = DOUBLE(sz(1)/2.) else xc = DOUBLE(xc)
if N_PARAMS() eq 6 and theta eq 0 then yc=0 
if N_PARAMS() eq 6 and theta ne 0 then yc = DOUBLE(sz(1)/2.) else yc = DOUBLE(yc)

mxy = mx*my

if trans then P00 = xc else  $
  P00 = ( (-my*xc + mx*sx*yc)*COS(theta) + mxy*xc + mx*yc*SIN(theta) )/mxy
P10 = -sx*COS(theta)/my - SIN(theta)/my
P01 = COS(theta)/mx
P11 = 0.
P = [P00,P10,P01,P11]

if trans then Q00 = yc else $
  Q00 = ( mxy*yc - mx*yc*COS(theta) + (-my*xc+mx*sx*yc)*SIN(theta) )/mxy
Q10 = COS(theta)/my - sx*SIN(theta)/my
Q01 = SIN(theta)/mx
Q11 = 0.
Q = [Q00,Q10,Q01,Q11]

i=0
if KEYWORD_SET(interp) then i=1 ;bilinear 
if N_ELEMENTS(cubic) eq 0 then cubic = 0

if N_ELEMENTS(missing) eq 0 then return,POLY_2D(image,P,Q,i,CUBIC=cubic) else $
  return,POLY_2D(image,P,Q,i,CUBIC=cubic,MISSING=missing)

END



