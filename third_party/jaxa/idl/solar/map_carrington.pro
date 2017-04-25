FUNCTION map_carrington, image, xycen, date, ps, xyref, PHIK=phik
;+
;NAME:
;     MAP_CARRINGTON.PRO
;PURPOSE:
;     Project a solar image onto an area preserving longitude,SIN(latitude)
;     cylindrical map. The projection is referred to as a Lambert
;     projection in geographic literature and as a Carrington projection
;     in heliographic work. Meridians and latitude lines are perpendicular
;     the output image.
;     Preserves pixel scale so it returns an image that may be
;     substantially larger than the input image if the input image
;     is near the limb.
;     Assumes the Sun is a sphere and that image is oriented solar-north
;     (P angle = 0).
;CATEGORY: mapping
;CALLING SEQUENCE:
;     image = map_carrington(image,xycen,date,ps)
;
;INPUTS:
; IMAGE = image to be mapped onto a cylindrical projection
; XYCEN = FLTARR(2): E/W & N/S arcsecond angle of image center from Solar
;         disk center. W and N are positive.
; DATE  = date of image in any of the accepted CDS date forms
; PS    = platescale: arcseconds/pixel image scale.
; XYREF = LONARR[2], coordinates of a reference point in the original
;         image. If provided, the point is returned as the coordinates
;         in the remapped image. Useful for keeping track of a
;         sunspot, etc.
;
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS:
; PHIK = latitude of unity linear scale in cylindrical equal area
;        projection, in degrees. See "Map Projections" by Bugayevskiy and
;        Snyder, Ch. 2.
;
;OUTPUTS:
; Warped image using cubic interpolation in POLY_2D. Note that the
; platescale of the warped image is the same as the input image. This
; means that the warped image may be substantially larger in format
; than the original, especially for near-limb images.
;
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     Assumes image is oriented with Solar North UP.
;     Does not remap any pixels that are off the limb of the
;     Sun for the date given.
;PROCEDURE:
;EXAMPLE:
;     for TRACE images:
;     IDL> read_trace,filename,-1,index,image
;     IDL> traceplate = 0.4993  ;arcsec per pixel
;     IDL> warp_image =
;           map_carrington(image,[index.xcen,index,ycen],index.date,traceplate)
;
;MODIFICATION HISTORY:
; Written by Tom Berger, LMSAL, 8.13.02
; Added reference point capability, TEB 8.16.02
; Doc header only (syntax due to bad comment wraparound), SLFreeland 6-feb-2006
;-

;Constants:
arcsec2rad = !DTOR/3600
sz =  SIZE(image)
xs =  sz[1]
ys =  sz[2]

;paramaters and keywords:
IF N_ELEMENTS(xyref) GT 0 THEN BEGIN
   xref = xyref[0]
   yref = xyref[1]
   refpoint = 1
END ELSE refpoint = 0
IF KEYWORD_SET(phik) THEN phi = phik*!DTOR ELSE phi = 0.

;Get solar parameters for date of observation:
rbp =  GET_RB0P(date)
srad = DOUBLE(rbp[0])        ;solar radius in arcseconds
b0 =  DOUBLE(rbp[1]*!DTOR)   ;B0 angle in radians
p = 0                        ;NOTE! Assumes solar north is up in image! P
angle = 0.

;arcsec from DiskCenter (DC) arrays:
x =  (LINDGEN(xs, ys) MOD xs) - xs/2
x =  xycen[0] + ps*x
y =  (LINDGEN(xs, ys)/xs) - ys/2
y =  xycen[1] + ps*y
;rho1 and rho angles in SMART, "Spherical Astronomy", sec. 103
rho1 =  SQRT(x^2 + y^2)
offlimb =  WHERE(rho1 GT srad, noff)
IF noff GT 0 THEN rho1[offlimb] =  -1e7
rho =  ASIN((rho1/srad) > (-1)) - rho1*arcsec2rad
;error in not using SIN(rho1)/SIN(srad) ~3.5x10-6 near the limb.
IF noff GT 0 THEN rho[offlimb] = -1

theta = ATAN(DOUBLE(x),y)

;Smart, equation 43, sec. 103
slat = SIN(b0)*COS(rho) + COS(b0)*SIN(rho)*COS(theta)
bad = WHERE(slat GT 1.0d0,nb)
if nb GT 0 then slat[bad] = 1.0d0
bad = WHERE(slat LT -1.0d0,nb)
if nb GT 0 then slat[bad] = -1.0d0
lat = ASIN(slat)
;eqn. 44
slon =  SIN(rho)*SIN(theta)/COS(lat) ;sign of theta makes longitude decrease
;                                                          to -90 east of DC.
b = WHERE(slon GT 1.0d0, nb)
IF nb GT 0 THEN slon[bad] = 1.0d0
bad =  WHERE(slon LT -1.0d0, nb)
IF nb GT 0 THEN slon[bad] = -1.d0
lon = ASIN(slon)
;This really screws thing up:
;IF noff GT 0 THEN BEGIN
;   lon[offlimb] = -2*!pi
;   lat[offlimb] = -2*!pi
;END


;Cylindrical projection:
;new x-values based on longitude, image pixel units:
;limit the projection to useful range:
lon = lon > (-80*!DTOR) < 80*!DTOR
lat = lat > (-80*!DTOR) < 80*!DTOR
xn = srad*lon*COS(phi)/ps
yn = srad*SIN(lat)/COS(phi)/ps
xn = FIX(xn - MIN(xn))
yn = FIX(yn - MIN(yn))
;Map all off-limb points to (0,0) to guard against runaway warping:
IF noff GT 0 THEN BEGIN
   xn[offlimb] = 0
   yn[offlimb] = 0
END
;Final range of values:
xr = MAX(xn) - MIN(xn) + 1
yr = MAX(yn) - MIN(yn) + 1

;Get the DC and reference points in the new image:
xcen = xn[xs/2, ys/2]
ycen = yn[xs/2, ys/2]
xycen[0] = xycen[0] + (xcen - xr/2)*ps
xycen[1] = xycen[1] + (ycen - yr/2)*ps
IF refpoint THEN BEGIN
   xyref[0] = xn[xref, yref]
   xyref[1] = yn[xref, yref]
END

;Get the polynomial warping arrays:
;redo the coordinate arrays in image pixel coordinates:
x =  (LINDGEN(xs, ys) MOD xs)
y =  (LINDGEN(xs, ys)/xs)
;ni x ni subsampling of the arrays to speed things up:
ni = 100.
ngx = xs/ni
ngy = ys/ni
gx = ROUND( (FINDGEN(ni)*ngx + ngx/2)#(INTARR(ni)+1) )
gy = ROUND( (INTARR(ni)+1)#(FINDGEN(ni)*ngy + ngy/2) )
sam =  REFORM(gy*xs + gx, ni*ni)
POLYWARP, x[sam], y[sam], xn[sam], yn[sam], 3, p, q
;POLYWARP, x, y, xn, yn, 3, p, q

RETURN, POLY_2d(image, p, q, 2, xr, yr, CUBIC=-0.5)
END

