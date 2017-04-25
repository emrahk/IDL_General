function get_zenang,item, lat, lon, radians=radians, degrees=degrees
;+
;   Name: get_zenang
;
;   Purpose: Return solar Zenith angle (see ssw_pos2zenith wrapper)
;
;   Input Parameters:
;      item - something containing a UT time, any SSW format
;      lat,lon - latitude and longitude (westward negative) in degrees
;
;   Output:
;      function returns solar zenith angle - degrees is default
;
;   Keyword Parameters:
;      radians - if set, function returns angle in radians
;      degrees - if set, function returns angle in degrees (DEFAULT)
;  
;   History:
;      16-March-2000 - G.L.Slater, LMSAL
;      16-March-2000 - S.L.Freeland, LMSAL some doc, made DEGREES default
;       6-April-2000 - incorporate Roger J. Thomas modifications
;-
d2rad = !dpi/180.d0		; deg to rad conv
h2rad = !dpi/12.d0		; RA to rad conv

jd = tim2jd(item)		; Julian date
ct2lst, lst, lon, dummy, jd	; Get sidereal time

; Compute RA and Dec:
ra_zen = lst * h2rad
dec_zen = lat*d2rad

sunpos,jd,ra_sun,dec_sun,/rad

th1 = !pi/2 - dec_zen
th2 = !pi/2 - dec_sun
ph1 = ra_zen
ph2 = ra_sun

sth1 = sin(th1)
cth1 = cos(th1)
sph1 = sin(ph1)
cph1 = cos(ph1)

sth2 = sin(th2)
cth2 = cos(th2)
sph2 = sin(ph2)
cph2 = cos(ph2)

x1 = sth1*cph1
y1 = sth1*sph1
z1 = cth1

x2 = sth2*cph2
y2 = sth2*sph2
z2 = cth2

zenang = acos(x1*x2 + y1*y2 + z1*z2)
if not keyword_set(radians) then zenang = zenang*!radeg ; default=degrees

return, zenang
end
