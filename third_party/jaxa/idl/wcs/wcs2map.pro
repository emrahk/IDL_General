;+
; Project     :	SOHO - CDS
;
; Name        :	WCS2MAP
;
; Purpose     :	Convert a WCS structure into a SolarSoft image map
;
; Category    :	FITS, Coordinates, WCS, Image-processing
;
; Explanation :	Converts a World Coordinate System structure, plus associated
;               data array, into a SolarSoft image map structure.
;
; Syntax      :	WCS2MAP, DATA, WCS, MAP, ID=ID
;
; Examples    :	WCS2MAP, DATA, WCS, MAP, ID="EIT 195"
;
; Inputs      :	DATA = Data array associated with the WCS structure
;               WCS  = World Coordinate System structure from FITSHEAD2WCS
;
; Opt. Inputs :	None.
;
; Outputs     :	MAP = SolarSoft image map structure.
;
; Opt. Outputs:	None.
;
; Keywords    :	ID = Character string describing the contents of the data.
;               NO_COPY = avoid internal copy of data [Warning: input
;               data is destroyed]
;
; Calls       :	VALID_WCS, TAG_EXIST, ANYTIM2TAI
;
; Common      :	None.
;
; Restrictions:	The WCS must be marked as simple, i.e. wcs.simple=1
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 15-Apr-2005, William Thompson, GSFC
;               Version 2, 11-May-2010, WTT, Added tags L0, B0, RSUN
;               Version,3, 21-Aug-2012, Zarro (ADNET) - added NO_COPY
;
; Contact     :	WTHOMPSON
;-
;
pro wcs2map, data, wcs, map, id=id,no_copy=no_copy
on_error, 2
;
;  Check the input parameters.
;
if n_params() ne 3 then message, 'Syntax: WCS2MAP, DATA, WCS, MAP'
if not valid_wcs(wcs) then message, 'Input not recognized as WCS structure'
if n_elements(data) eq 0 then message, 'DATA array is undefined' 
;
;  Make sure that the data array matches the WCS structure.  Trailing
;  dimensions of 1 are allowed in either the DATA array or in the WCS
;  structure.
;
sz = size(data)
nn = n_elements(wcs.naxis) > sz[0]
dim1 = replicate(1L, nn)
if sz[0] gt 0 then dim1[0] = sz[1:sz[0]]
dim2 = replicate(1L, nn)
dim2[0] = wcs.naxis
w = where(dim1 ne dim2, count)
if count gt 0 then message, 'DATA array does not match WCS structure'
;
;  Make sure that the WCS is simple.
;
if not tag_exist(wcs, 'SIMPLE') then message, 'WCS not marked as simple'
if not wcs.simple then message, 'WCS not marked as simple'
;
;  Get the center pixel location, and its coordinates.
;
icen = (wcs.naxis - 1.)/ 2.
coord = wcs_get_coord(wcs, icen)
;
;  Get the ID string.
;
if not is_string(id) then id = ' '
;
;  Get the observation time and duration.
;
time = ''
dur = 0.
if tag_exist(wcs,'TIME') then begin
    if tag_exist(wcs.time, 'OBSERV_DATE') then begin
        time = anytim2utc(wcs.time.observ_date, /vms)
        if tag_exist(wcs.time, 'OBSERV_END') then dur = $
          anytim2tai(wcs.time.observ_end) - $
          anytim2tai(wcs.time.observ_date)
    endif
    if (dur eq 0) and tag_exist(wcs.time, 'exptime') then $
      dur = wcs.time.exptime
endif
;
;  Get the position keywords.
;
soho = 0
l0 = 0.0
if tag_exist(wcs, 'POSITION') then begin
    soho = wcs.position.soho
    if tag_exist(wcs.position, 'hgln_obs') then l0 = wcs.position.hgln_obs
    if tag_exist(wcs.position, 'hglt_obs') then b0 = wcs.position.hglt_obs
    if tag_exist(wcs.position, 'dsun_obs') then rsun = (648d3 / !dpi) * $
      asin(wcs_rsun() / wcs.position.dsun_obs)
endif
;
;  Use the time to derive the default values of B0 and RSUN
;
if (n_elements(b0) eq 0) or (n_elements(rsun) eq 0) then begin
    p0 = pb0r(time, /arcsec, soho=soho)
    if n_elements(b0) eq 0 then b0 = p0[1]
    if n_elements(rsun) eq 0 then rsun = p0[2]
endif
;
;  Form the MAP structure.
;
ix = wcs.ix
iy = wcs.iy
map = {xc: coord[ix],                   $
       yc: coord[iy],                   $
       dx: wcs.cdelt[ix],               $
       dy: wcs.cdelt[iy],               $
       time: time,                      $
       id: id,                          $
       roll_angle: wcs.roll_angle,      $
       roll_center: coord[[ix,iy]],     $
       dur: dur,                        $
       xunits: wcs.cunit[ix],           $
       yunits: wcs.cunit[iy],           $
       soho: soho,                      $
       l0: l0,                          $
       b0: b0,                          $
       rsun: rsun}

if keyword_set(no_copy) then map=create_struct( {data:temporary(data)},map) else map=create_struct({data:data},map) 
;
return
end
