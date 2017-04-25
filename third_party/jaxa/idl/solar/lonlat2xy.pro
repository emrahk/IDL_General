;+

function lonlat2xy,helio0,date0, arcmin=arcmin, b0=b0in, radius=sunrin, $
                   behind =behind

; NAME:
;	LONLAT2XY
; PURPOSE:
;	Computes arcsecs-from-suncenter coordinates from 
;	heliographic coordinate inputs (inverse of xy2latlon). 
; CALLING SEQUENCE: 
;	arcvec = latlon2xy(helio, date [,/arcmin])
; INPUT:
;       helio	- is a vector of heliocentric coordinates.  It should be 2xN.
;                       (0,*) = longitude (degrees) W positive
;                       (1,*) = latitude (degrees) N positive
;		  They can also be strings in the form 'N30W23'.
;	date	- Unless the date is supplied, today's date is used.
;                 This will affect the Solar axial tilt, B0.  Ignored
;                 if both b0 and radius keywords are set.
; OUTPUT:
;	arcvec	- The angle in arcseconds as viewed from the earth.
;                       (0,*) = E/W direction with W positive
;                       (1,*) = N/S direction with N positive
; OPTIONAL KEYWORD INPUT:
;       b0 = b0 angle in radians
;       radius = solar radius in arsec (arsec even when /arcmin is set)
;       behind = Flag array, 1 if behind limb, 0 if in front.
;	arcmin	- If set, output is in arcminutes, rather than 
;		  arcseconds.
; OPTIONAL KEYWORD OUTPUT:
; CAUTIONS: 	x and y are in solar coordinates (solar W and solar N).  There
;               is no P-angle here.
; CALLS: ANYTIM, GET_RB0P                                               
; HISTORY: 
;       T. Metcalf 2001-Oct-17  This is an exact replacement for conv_h2a which
;                               is only approximate.
;       T. Metcalf 2001-Nov-13  Switched to a more robust calculation of
;                               theta.
;       T. Metcalf 2002-apr-03  Added b0 and radius keywords.
;       T. Metcalf 2002-Apr-08  Added test for acos out of range and changed
;                               anytim2ints call to anytim call to avoid
;                               date format confusions.
;       T. Metcalf 2002-Apr-11  Added behind keyword
;       T. Metcalf 2005-Mar-11  When date is to be ignored, never use it.
;-


arcsec2rad = 4.84813681d-6

siz = size(helio0)
typ = siz( siz(0)+1 )
if (typ eq 7) then helio = conv_hs2h(helio0) else helio = helio0
we = reform(helio[0,*])
ns = reform(helio[1,*])
nout = n_elements(ns)

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
   ans  = get_rb0p(date)
   if n_elements(b0in) LE 0 then b0 = reform(ans(1,*)) else b0 = b0in
   if n_elements(sunrin) LE 0 then sunr = reform(ans(0,*)) else sunr = sunrin
endif else begin
   b0 = b0in
   sunr = sunrin
endelse

if n_elements(b0) EQ 1 then b0   = b0[0]
if n_elements(sunr) EQ 1 then sunr = sunr[0]

lon = we*!dpi/180.0d0
lat = ns*!dpi/180.0d0

we=0				;reduce memory requirements
ns=0

cb0 = cos(b0)
clat = cos(lat)
clon = cos(lon)
sb0 = sin(b0)
slat = sin(lat)
slon = sin(lon)

crho = clat*cb0*clon + slat*sb0
badplus = where(crho GT 1.0d0,nbadplus)
badminus = where(crho LT -1.0d0,nbadminus)
if nbadplus GT 0 then crho[badplus] = 1.0d0
if nbadminus GT 0 then crho[badminus] = -1.0d0
rho = acos(crho)

; theta is the position angle CCW from north

;theta = -atan(sb0*clat*slon,crho*cb0-clat*clon)
theta = -atan(cb0*clat*slon,slat-sb0*crho)

; iteratively solve for rho1
ssunr = sin(sunr*arcsec2rad)
rho1 = asin(ssunr*sin(rho))
for i=0,5 do rho1 = asin(ssunr*sin(rho+rho1))

y = +rho1*cos(theta)/arcsec2rad
x = -rho1*sin(theta)/arcsec2rad

if keyword_set(arcmin) then begin
   x = x/60.0
   y = y/60.0
endif

blss = where(rho GT ((!dpi/2.0d0)-rho1),nblss)
behind = byte(rho) & behind[*] = 0
if nblss GT 0 then behind[blss] = 1b

xy = double(helio)
xy[0,*] = x
xy[1,*] = y

return, xy

end

