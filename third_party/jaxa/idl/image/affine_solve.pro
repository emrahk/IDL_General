;==================================================

PRO AFFINE_SOLVE, xin, xpin, $
            mx, my, sx, theta, xc, yc,$
            VERBOSE=blab

;==================================================
;+
; NAME:
;	AFFINE_SOLVE
;
; PURPOSE:
;	Calculate the parameters of a general affine image
;       transformation given a set of points from two images:
;       one of the images is assumed to be the reference image,
;       the other is assumed to be an image translated, rotated,
;       scaled, and possibly sheared relative to the reference image.
;
;       The form of the general transformation is affine:
;       X = tranformed coordinates = [T+ M S R T-] X'
;       where, in homogeneous coordinates,
;
;              X  = TRANSPOSE[x, y, 1]: test image vector
;              T+ = [[1,0,x0],[0,1,y0],[0,0,1]]: translatation of (0,0) back to (x0,y0) 
;              M  = [[mx,0,0],[0,my,0],[0,0,1]]:scale
;              S  = [[1,sx,0],[0,1,0],[0,0,1]]: horizontal shear
;              R  = [[cos(t),-sin(t),0],[sin(t),cos(t),0],[0,0,1]]:
;                   rotate clockwise by angle t about origin.
;              T- = [[1,0,-x0],[0,1,-y0],[0,0,1]]:center of rotation to (0,0)
;              X' = TRANSPOSE[x',y',1]: reference image vector
;	
; CATEGORY:
;	Z3 - Image processing, geometric transforms, image registration.
;
; CALLING SEQUENCE:
;	AFFINE_SOLVE, xin,xrefin,sx,sy,s,theta,x0,y0
;
; INPUTS:
;	XIN:    2xN dimensional array of points taken from image1 
;               which correspond to the same points in the reference image.
;               Xi = XIN(0,*)
;		Yi = XIN(1,*)
;               N is the number of points. 
;
;	XPIN:   2xN dimensional array of points from the "reference image"
;               which correspond to points in the image. 
;               
; KEYWORDS:
;       VERBOSE: If set, print the transformation elements to the screen.
;
; OUTPUTS:
;       MX, MY: Magnification factors in x and y axes, respectively.
;
;       SX:      Horizontal shearing factor.
;
;       THETA:  Rotation angle in degrees. 
;
;       XC,YC:  Center of rotation vector elements OR translation
;               vector elements.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	N, the number of matched points in the transformed and reference
;       images should be large (greater than 20), should be taken from
;       widely spaced locations in the image field-of-view, and should
;       be measured to within 1-pixel for greatest accuracy.
;
;       Off-center rotation and translation require a two-stage approach
;       for image registration. i.e. in the first stage, apply the parameters 
;       given by this routine to the test image. A second set of points
;       is then selected from the image and the reference image, and 
;       a second run of this program should output a final translation
;       to be applied to the test image to bring it in registration with
;       the reference image. This is tested for and the user is alerted.
;
; PROCEDURE:
;	Using least squares estimation, determine the elements 
;       of the general affine transformation (rotation and/or scaling
;       and/or translation and/or shearing) of an image onto a reference 
;       image. 
;
;	See:	Image Processing for Scientific Applications
;               Bernd J\"ahne
;		CRC Press, 1997, Chapter 8.
;
;       Use AFFINE.PRO (or ROT.PRO if no shear is found) to apply the 
;       transformation to the test image after computing them with this routine.
;
; MODIFICATION HISTORY:
;	Written: T. Berger, LMATC, 24-Feb-1998.
;       Added no rotation/translation test. TEB, 2-March-98.
;       10-March-1998 - S.L.Freeland - Backward compatible for IDL V<5
;-



ON_ERROR,2

x = xin
xp = xpin  

n1 = (SIZE(x))(1)
n2 = (SIZE(xp))(1)
if n2 ne n1 then begin
    MESSAGE,'Number of points must be the same in both input arrays'
    RETURN
end

y = DOUBLE(x(*,1))
x = DOUBLE(x(*,0))
yp = DOUBLE(xp(*,1))
xp = DOUBLE(xp(*,0))


;Least squares solution for matrix elements: see Notebook 5, p. 132.
AT = DBLARR(2*n1,6)
zerow = [REPLICATE(0,n1)]
onerow = [REPLICATE(1,n1)]
AT(INDGEN(n1)*2,*) = [[x],[y],onerow,zerow,zerow,zerow]
AT(INDGEN(n1)*2+1,*) = [zerow,zerow,zerow,[x],[y],onerow]
A = TRANSPOSE(AT)
b = TRANSPOSE(DBLARR(2*n1))
b(INDGEN(n1)*2) = xp
b(INDGEN(n1)*2+1) = yp
xb = INVERT(AT##A,/DOUBLE)##AT##REFORM(b)

;Solve for transformation elements:
theta = -ATAN(xb(3),xb(4))
mx = xb(3)*(xb(1)*xb(3)-xb(0)*xb(4))/SIN(theta)/(xb(3)^2+xb(4)^2)
my = -xb(3)/SIN(theta)
sx = (xb(0)*xb(3)+xb(1)*xb(4))/(xb(0)*xb(4)-xb(1)*xb(3))
;Translation solution: 
det = xb(0)*xb(4)-xb(1)*xb(3)
denom = (xb(0)+xb(4)) - det - 1.
xc = -(xb(2) - xb(2)*xb(4)+xb(1)*xb(5))/denom
yc = -(xb(2)*xb(3)+xb(5)-xb(0)*xb(5))/denom

trans=0
if theta lt 5e-03 then begin  ;no rotation - use simple translation solve:
    trans=1
    xc = xb(2)
    yc = xb(5)
end 

;Return the transformation FROM x TO xp:
; ie. rotate image by theta degrees counterclockwise to get to reference image
theta = theta/!dtor
if theta gt 0 then dir='clockwise' else dir='counterclockwise'

if KEYWORD_SET(blab) then begin

    stheta = STRCOMPRESS(ABS(theta),/re)
    sxc = STRCOMPRESS(xc,/re)
    syc = STRCOMPRESS(yc,/re)
    smx = STRCOMPRESS(mx,/re)
    smy = STRCOMPRESS(my,/re)
    ssx = STRCOMPRESS(sx,/re)
    PRINT,''
    PRINT,'Relative to the reference image, the test image is:'

    if not trans then begin
        PRINT,'     Rotated ',stheta,' degrees ',dir 
        PRINT,'     with the center of rotation at'
        PRINT,'           xc = ',sxc
        PRINT,'           yc = ',syc
    end else begin
        PRINT,'     Rotated ',stheta,' degrees ',dir 
        PRINT,'     Translated by'
        PRINT,'           dx = ',sxc
        PRINT,'           dy = ',syc
    end
    PRINT,'     Scaled by a factor of ',smx,' horizontally'
    PRINT,'     Scaled by a factor of ',smy,' vertically'
    PRINT,'     Sheared horizontally by a factor of = ',ssx
    PRINT,''
end

RETURN
END



