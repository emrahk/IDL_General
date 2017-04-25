;+
; Project     :	STEREO
;
; Name        :	WCS_CONV_HPC_HG
;
; Purpose     :	Convert Helioprojective-Cartesian to Heliographic coordinates
;
; Category    :	Coordinates, WCS
;
; Explanation : This routine converts Helioprojective-Cartesian (HPC)
;               coordinates into Heliographic (HG) coordinates, using equations
;               15 and 12 in Thompson (2006), A&A, 449, 791-803.
;
; Syntax      :	WCS_CONV_HPC_HG, HPLN, HPLT, HGLN, HGLT  [, HECR ]  [, DISTANCE=DISTANCE ]
;
; Examples    :	WCS_CONV_HPC_HG, HPLN, HPLT, HGLN, HGLT, WCS=WCS
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
; Opt. Outputs:	HECR    = Heliocentric distance, in the same units as DISTANCE
;
; Keywords    :	DISTANCE= The distance of the point from the observer.  If not
;                         passed, then the points are assumed to be on the
;                         solar surface.  Any points calculated as above the
;                         limb will be returned as Not-A-Number (NaN).
;
;               WCS     = World Coordinate System structure.  Used to determine
;                         DSUN.  See WCS_CONV_FIND_DSUN for more information.
;
;               DSUN_OBS = Solar distance, in meters, if neither WCS nor
;                          DISTANCE passed.
;
;               LENGTH_UNITS = String describing the length units.  Only used
;                         if the distance values are not passed.  Can be any
;                         string recognized by wcs_parse_units, e.g. "m", "km",
;                         "AU", "solRad", etc.  The default is meters (m).
;
;               ANG_UNITS = String describing the input angular units.  See
;                           WCS_CONV_FIND_ANG_UNITS for more information.
;
;               POS_LONG = If set, then force the output longitude to be
;                         positive, i.e. between 0 and 360 degrees.  The
;                         default is to return values between +/- 180 degrees.
;
;               CARRINGTON = If set, then the longitude is a Carrington
;                            longitude.  The default is Stonyhurst longitude.
;
;               FACTOR  = Returns the conversion factor between data and meters
;
; Calls       :	WCS_CONV_HPC_HCC, WCS_CONV_HCC_HG
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
pro wcs_conv_hpc_hg, hpln, hplt, hgln, hglt, hecr, factor=factor, _extra=_extra
on_error, 2
;
if n_params() lt 4 then message, $
  'Syntax: WCS_CONV_HG_HPC, HPLN, HPLT, HGLN, HGLT [, HECR ]'
if n_elements(hpln) eq 0 then message, 'HPLN not defined'
if n_elements(hplt) ne n_elements(hpln) then message, $
  'HPLN and HPLT must have the same number of elements'
;
;  Perform the conversion via HCC intermediate coordinates.
;
wcs_conv_hpc_hcc, hpln, hplt, x_temp, y_temp, z_temp, factor=factor, $
  _extra=_extra
wcs_conv_hcc_hg, x_temp, y_temp, hgln, hglt, hecr, solz=z_temp, $
  _extra=_extra
;
return
end
