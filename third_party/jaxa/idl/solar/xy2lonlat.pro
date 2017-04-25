;+
FUNCTION xy2lonlat, ang, date0, arcmin=arcmin, b0=b0in, radius=sunrin, $
	_extra = extra
; NAME:
;        xy2lonlat
; PURPOSE:
;          Converts arcsec-from-suncenter coordinates to heliographic
;	   coordinates (inverse of latlon2xy).
; METHOD:
; CALLING SEQUENCE:
; INPUT:
;	ang	- is a vector of angles from sun center in default units of
;		  arcseconds.  It should be 2xN.
;			(0,*) = angle in E/W direction with W positive
;			(1,*) = angle in N/S direction with N positive
;	date	- Unless the date is supplied, today's date is used.
;		  This will affect the Solar axial tilt, B0.  If the B0
;                 and radius keywords are set, then date is ignored and
;                 need not be passed in.
;
; OUTPUT:
;	lonlat  - Heliographic coordinates in decimal degrees.
;                       (0,*) = longitude (degrees) W positive
;                       (1,*) = latitude (degrees) N positive
;		  If the input coordinates are off the solar limb,
;		  the output is the radial projection back to the nearest
;		  point on the limb.
;		  Output is DOUBLE)
; OPTIONAL KEYWORD INPUT:
;       b0 = the B0 angle in radians
;       radius = the solar radius in arc seconds.
;	arcmin	- when set the input is in arcminutes.
;	quiet  - passed by _extra to get_rb0p, if set stops message about source for b0, p
; OPTIONAL KEYWORD OUTPUT:
; CAUTIONS:    - Points off the limb are projected back to the limb.
;              - The x and y are in solar coordinates (solar W and solar N).
;                There is no P-angle here.
; HISTORY:
;     T. Metcalf 2001-Oct-17  This is an exact replacement for conv_a2h which
;                             is only approximate.
;     T. Metcalf 2001-Oct-18  Use atan to find the longitude
;     T. Metcalf 2002-Apr-03  Added B0 and radius keywords.
;     T. Metcalf 2002-Apr-08  Added test for asin out of range.  Changed
;                             anytim2ints call to anytim call to avoid
;                             time format confusions.
;     T. Metcalf 2005-Mar-11  When date is to be ignored, never use it.
;	  R. Schwartz 2013-Dec-13 Added _extra passed into get_rb0p()
;-

nout = n_elements(ang)/2

;-------------------- Get the Date
;


if n_elements(b0in) LE 0 OR n_elements(sunrin) LE 0 then begin
   if (n_elements(date0) eq 0) then date = anytim(!stime,/yohkoh) $
   else date = anytim(date0,/yohkoh)
   if ((n_elements(date) ne nout) and (n_elements(date) ne 1)) then begin
       message, 'Improper number of dates.  Using first date for all points.', $
                /info
       date = date[0]
    endif
   ans  = get_rb0p(date, _extra=extra)
   if n_elements(b0in) LE 0 then b0 = reform(ans(1,*)) else b0 = b0in
   if NOT keyword_set(sunrin) LE 0 then sunr = reform(ans(0,*)) else sunr = sunrin
endif else begin
   b0 = b0in
   sunr = sunrin
endelse

if n_elements(b0) EQ 1 then b0   = b0[0]
if n_elements(sunr) EQ 1 then sunr = sunr[0]

if n_elements(b0) ne nout and n_elements(b0) ne 1 then $
   message,'Improper number of b0 angles'
if n_elements(sunr) ne nout and n_elements(sunr) ne 1 then $
   message,'Improper number of radii'

x = double(ang[0,*])
y = double(ang[1,*])
b0 = double(b0)
sunr = double(sunr)

if keyword_set(arcmin) then begin
   x = x * 60.d0
   y = y * 60.d0
endif

rho = sqrt(x^2+y^2)<sunr   ; don't let rho off the limb
outrho = rho/sunr

arcsec2rad = 4.84813681d-6
rho = asin(sin(rho*arcsec2rad)/sin(sunr*arcsec2rad)) - rho*arcsec2rad
theta = atan(x,y)
srho = sin(rho)
crho = cos(rho)
ctheta = cos(theta)
sb0 = sin(b0)
cb0 = cos(b0)

slat = sb0*crho+cb0*srho*ctheta
badplus = where(slat GT 1.0d0,nbadplus)
badminus = where(slat LT -1.0d0,nbadminus)
if nbadplus GT 0 then slat[badplus] = 1.0d0
if nbadminus GT 0 then slat[badminus] = -1.0d0
lat = asin(slat)
;lat = asin(sb0*crho+cb0*srho*ctheta)
lon = atan(srho*sin(theta),(crho*cb0-srho*sb0*ctheta))

lonlat = double(ang)
lonlat[0,*] = lon*(180.0d0/!dpi)
lonlat[1,*] = lat*(180.0d0/!dpi)

return, lonlat

end
