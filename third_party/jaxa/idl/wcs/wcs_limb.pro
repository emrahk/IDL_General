;+
; Project     :	STEREO
;
; Name        :	WCS_LIMB
;
; Purpose     :	Calculate the heliographic coordinates of the limb.
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This routine calculates the heliographic coordinates of the
;               observer's limb based on the information in the WCS structure.
;
; Syntax      :	WCS_LIMB, WCS, LON, LAT
;
; Examples    :	The following example calculates the pixel positions of the
;               limb for the image associated with WCS0 onto the image
;               associated with WCS1.
;
;               wcs_limb, wcs0, lon, lat
;               wcs_convert_to_coord, wcs1, coord, 'hg', lon, lat
;               pix = wcs_get_pixel(wcs1, coord)
;
; Inputs      :	WCS = Structure from FITSHEAD2WCS.
;
;               If the WCS structure does not contain complete position
;               information, then certain simplifying assumptions are made:
;
;               If DSUN_OBS is missing, then the observer's distance is assumed
;               to be infinite.
;
;               If the observer's longitude or latitude are missing, then
;               they're assumed to be zero.
;
; Opt. Inputs :	None.
;
; Outputs     :	LON = Heliographic longitude values.
;               LAT = Heliographic latitude values.
;
; Opt. Outputs:	None.
;
; Keywords    :	CARRINGTON = If set, then the longitude and latitude values
;                            are returned in the Carrington coordinate system.
;                            The default is to return Stonyhurst values.
;
;               NVALUES = The number of longitude and latitude values to
;                         return.  The default is to return 361 values,
;                         i.e. one degree apart.  The first and last values are
;                         always the same, to complete the circle.
;
; Calls       :	TAG_EXIST, TAG_INDEX
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 12-Feb-2010, William Thompson, GSFC
;               Version 2, 19-Jan-2012, WTT, call WCS_CONV_FIND_HG_ANGLES
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_limb, wcs, lon, lat, carrington=carrington, nvalues=nvalues
;
dtor = !dpi / 180.d0
;
;  Determine the number of values to return.
;
if n_elements(nvalues) eq 0 then nvalues = 361
psi = 2. * !dpi * dindgen(nvalues) / (nvalues - 1)
;
;  Extract the position substructure from the WCS structure, and determine the
;  observer distance.  If unknown, then assume that the observer is at
;  infinity.
;
pos = wcs.position
if tag_exist(pos, 'dsun_obs') then $
  sin_alpha = wcs_rsun() / pos.dsun_obs else sin_alpha = 0.d0
cos_alpha = sqrt(1 - sin_alpha^2)
;
;  Define the limb in the observer's native coordinates.
;
xxx = replicate(sin_alpha, nvalues)
yyy = -cos_alpha * sin(psi)
zz  =  cos_alpha * cos(psi)
;
;  Correct for the observer's longitude.
;
wcs_conv_find_hg_angles, theta, phi, wcs=wcs, carrington=carrington
theta = theta * dtor
phi   = phi   * dtor
cos_phi = cos(phi)
sin_phi = sin(phi)
xx = xxx * cos_phi - yyy * sin_phi
y  = xxx * sin_phi + yyy * cos_phi
;
;  Correct for the observer's latitude.
;
cos_theta = cos(theta)
sin_theta = sin(theta)
x = xx * cos_theta - zz * sin_theta
z = xx * sin_theta + zz * cos_theta
;
;  Translate the positions into longitude and latitude values.
;
lon = atan(y, x) / dtor
lat = asin(z)    / dtor
;
end
