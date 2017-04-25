;+
; Project     :	STEREO
;
; Name        :	WCS_CONV_HG_HPC
;
; Purpose     :	Convert Helioprojective-Cartesian to Heliographic coordinates
;
; Category    :	Coordinates, WCS
;
; Explanation : This routine converts Heliographic (HG) coordinates into
;               Helioprojective-Cartesian (HPC) coordinates, using equations
;               11 and 16 in Thompson (2006), A&A, 449, 791-803.
;
; Syntax      :	WCS_CONV_HG_HPC, HGLN, HGLT, HPLN, HPLT  [, DISTANCE ]  [, HECR=HECR ]
;
; Examples    :	WCS_CONV_HG_HPC, HPLN, HPLT, HGLN, HGLT, WCS=WCS
;
; Inputs      :	HPLN    = Helioprojective-cartesian longitude (Theta_X)
;               HPLT    = Helioprojective-cartesian latitude  (Theta_Y)
;
; Opt. Inputs :	None.
;
; Outputs     :	HGLN    = Heliographic longitude
;               HGLT    = Heliographic latitude
;
;               HGLN and HGLT are returned in degrees.
;
;               If the /CARRINGTON keyword keyword is set, then these are
;               actually CRLN, CRLT.
;
; Opt. Outputs:	DISTANCE= The distance of the point from the observer, in the
;                         same units as HECR.
;
; Keywords    :	HECR    = Heliocentric distance.  If not passed, then the
;                         points are assumed to be on the solar surface.  Any
;                         points calculated as above the limb will be returned
;                         as Not-A-Number (NaN).
;
;               WCS     = World Coordinate System structure.  Used to determine
;                         DSUN.  See WCS_CONV_FIND_DSUN for more information.
;
;               DSUN_OBS = Solar distance, in meters, if WCS not passed.
;
;               LENGTH_UNITS = String describing the length units.  Only used
;                         if the distance values are not passed.  Can be any
;                         string recognized by wcs_parse_units, e.g. "m", "km",
;                         "AU", "solRad", etc.  The default is meters (m).
;
;               ANG_UNITS = String describing the input angular units.  See
;                           WCS_CONV_FIND_ANG_UNITS for more information.
;
;               CARRINGTON = If set, then the longitude is a Carrington
;                            longitude.  The default is Stonyhurst longitude.
;
;               ARCSECONDS = If set, then HPLN and HPLT are returned in
;                         arcseconds.
;
;               FACTOR  = Returns the conversion factor between data and meters
;
; Calls       :	WCS_CONV_HG_HCC, WCS_CONV_HCC_HPC
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects: None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 15-Dec-2008, William Thompson, GSFC
;               Version 2, 09-Dec-2011, WTT, updated header
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_conv_hg_hpc, hgln, hglt, hpln, hplt, distance, factor=factor, $
                     _extra=_extra
on_error, 2
;
if n_params() lt 4 then message, $
  'Syntax: WCS_CONV_HG_HPC, HGLN, HGLT, HPLN, HPLT [, DISTANCE ]'
if n_elements(hgln) eq 0 then message, 'HGLN not defined'
if n_elements(hglt) ne n_elements(hgln) then message, $
  'HGLN and HGLT must have the same number of elements'
;
;  Perform the conversion via HCC intermediate coordinates.
;
wcs_conv_hg_hcc, hgln, hglt, x_temp, y_temp, z_temp, factor=factor, $
  _extra=_extra
wcs_conv_hcc_hpc, x_temp, y_temp, hpln, hplt, distance, solz=z_temp, $
  _extra=_extra
;
return
end
