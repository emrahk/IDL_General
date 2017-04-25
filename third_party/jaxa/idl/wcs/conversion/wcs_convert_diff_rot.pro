;+
; Project     :	STEREO
;
; Name        :	WCS_CONVERT_DIFF_ROT
;
; Purpose     :	Apply differential rotation to solar longitudes
;
; Category    :	Coordinates, WCS
;
; Explanation : This routine takes heliographic coordinates (either Stonyhurst
;               or Carrington) from one WCS structure, and applies a
;               differential rotation model (via diff_rot.pro) to match the
;               time of another WCS structure.
;
; Syntax      :	WCS_CONVERT_DIFF_ROT, WCS_IN, WCS_OUT, LONGITUDE, LATITUDE
;
; Examples    :	The following example shows how to convert coordinates between
;               a STEREO/EUVI and SOHO/EIT image.
;
;               COORD_EUVI = WCS_GET_COORD(WCS_EUVI, PIXEL_EUVI)
;               WCS_CONVERT_FROM_COORD, WCS_EUVI, COORD_EUVI, 'HG', HGLN, HGLT
;               WCS_CONVERT_DIFF_ROT, WCS_EUVI, WCS_EIT, HGLN, HGLT
;               WCS_CONVERT_TO_COORD, WCS_EIT, COORD_EIT, 'HG', HGLN, HGLT
;               PIXEL_EIT = WCS_GET_PIXEL(WCS_EIT, COORD_EIT)
;
;               Some care needs to be taken in determining which WCS structure
;               is the input, and which is the output.  The following example
;               demonstrates the use of this routine in extracting values from
;               an SDO/AIA image into a heliographic map to match the time of a
;               STEREO/EUVI image.
;
;               LON = REBIN( REFORM(FINDGEN(360)+0.5, 360,1), 360, 180)
;               LAT = REBIN( REFORM(FINDGEN(180)-89.5,1,180), 360, 180)
;               WCS_CONVERT_DIFF_ROT, WCS_EUVI, WCS_AIA, LON, LAT
;               WCS_CONVERT_TO_COORD, WCS_AIA, COORD_AIA, 'HG', LON, LAT
;               PIXEL_AIA = WCS_GET_PIXEL(WCS_AIA, COORD_AIA)
;
;               In the above example, WCS_AIA is the output coordinate system,
;               because it is used to derive pixel coordinates in the AIA image
;               for longitudes and latitudes rotated from the target time of
;               the EUVI image.
;
; Inputs      :	WCS_IN  = WCS structure for input observation
;               WCS_OUT = WCS structure for output observation
;               LONGITUDE = Heliographic longitude, in degrees
;               LATITUDE  = Heliographic latitude, in degrees
;
; Opt. Inputs :	None.
;
; Outputs     :	LONGITUDE = The updated longitude values are returned in place
;
; Opt. Outputs:	None.
;
; Keywords    :	CARRINGTON = If set, then the longitude and latitude are in the
;                            Carrington coordinate system.  Otherwise, they are
;                            in the Stonyhurst coordinate system.
;
;               Can also pass /ALLEN or /HOWARD to diff_rot.pro.
;
; Calls       :	TAG_EXIST, ANYTIM2TAI, DIFF_ROT
;
; Common      :	None.
;
; Restrictions:	The underlying routine, diff_rot.pro, is slightly more accurate
;               when used with Carrington rather than Stonyhurst coordinates.
;
; Side effects:	
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 9-Mar-2009, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_convert_diff_rot, wcs_in, wcs_out, longitude, latitude, $
                       carrington=carrington, _extra=_extra
;
;  Get the start and end times from the WCS structures.
;
if tag_exist(wcs_in.time, 'observ_avg') then $
  t0 = wcs_in.time.observ_avg else $
  t0 = wcs_in.time.observ_date
;
if tag_exist(wcs_out.time, 'observ_avg') then $
  t1 = wcs_out.time.observ_avg else $
  t1 = wcs_out.time.observ_date
;
;  Calculate the time difference in days.
;
dd = (anytim2tai(t1) - anytim2tai(t0)) / 86400
;
;  Apply the differential rotation rate.
;
synodic = 1 - keyword_set(carrington)
longitude = longitude + diff_rot(dd, latitude, synodic=synodic, $
                                 carrington=carrington, sidereal=0, rigid=0, $
                                 _extra=_extra)
;
end
