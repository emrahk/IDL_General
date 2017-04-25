;+
; Project     :	STEREO
;
; Name        :	WCS_CONVERT_FROM_COORD
;
; Purpose     :	Convert WCS coordinates from native to other system
;
; Category    :	Coordinates, WCS
;
; Explanation :	This routine converts the native solar coordinates of a FITS
;               file using the World Coordinate System into another solar
;               coordinate system.  The supported coordinate systems are:
;
;                       Helioprojective-Cartesian       (HPC)
;                       Helioprojective-Radial          (HPR)
;                       Heliocentric-Cartesian          (HCC)
;                       Heliocentric-Radial             (HCR)
;                       Stonyhurst-Heliographic         (HG)
;                       Carrington-Heliographic         (HG, /CARRINGTON)
;
;               The helioprojective coordinates are angular position as seen by
;               the observer, while heliocentric coordinates are the
;               equivalents in spatial units (e.g. kilometers).
;
;               Stonyhurst and Carrington heliographic coordinates are
;               distinguished by the /CARRINGTON keyword.
;
;               The actual work is done by individual routines such as
;               WCS_CONV_HPC_HPR, which can be called separately if desired.
;
; Syntax      :	WCS_CONVERT_FROM_COORD, WCS, COORD, SYSTEM, X, Y  [, Z ]
;
; Examples    :	WCS = FITSHEAD2WCS(HEADER)
;               COORD = WCS_GET_COORD(WCS)
;               WCS_CONVERT_FROM_COORD, WCS, COORD, 'HG', HGLN, HGLT
;
; Inputs      :	WCS     = World Coordinate System structure
;
;               COORD   = Array of coordinate values, from WCS_GET_COORD.
;
;               SYSTEM  = The two or three-letter abbreviation as described
;                         above for the coordinate system that the data should
;                         be converted to.
;
; Opt. Inputs :	None.
;
; Outputs     :	X       = The equivalent of X in the target coordinate system.
;                         For angular coordinate systems, this would be the
;                         longitude.  For heliocentric-radial coordinates, this
;                         would be the angle PHI.
;
;               Y       = The equivalent of Y in the target coordinate system.
;                         For angular coordinates, this would be the latitude.
;                         For heliocentric-radial coordinates, this would be
;                         the distance RHO.
;
; Opt. Outputs:	Z       = The equivalent of Z in the target coordinate system.
;                         For angular coordinate systems, this would be the
;                         radial distance.  If insufficient information is
;                         available to derive this parameter, then it will be
;                         returned as undefined.
;
; Keywords    :	LENGTH_UNITS = String describing the length units.  If not
;                         passed, then taken from WCS structure.  This is
;                         generally used when converting from angular
;                         coordinates into spatial X,Y,Z coordinates
;
;               ARCSECONDS = If set, then HPLN and HPLT are returned in
;                         arcseconds.  The default is to return all angles in
;                         degrees.
;
;               CARRINGTON = If set, then the output longitude is a Carrington
;                            longitude.  The default is Stonyhurst longitude.
;
;               INDEX_Z = The index of the Z axis data in the COORD array, from
;                         0 to NAXIS-1.  If not passed, then the routine tries
;                         to recognize the axis based on the coordinate system.
;                         Setting INDEX_Z=-1 disables the input Z axis.
;
;               POS_LONG = If set, then force the output longitude to be
;                         positive, i.e. between 0 and 360 degrees.  The
;                         default is to return values between +/- 180 degrees.
;                         Used for HG, HPR, or HCR coordinates
;
;               FACTOR  = Returns the conversion factor between data and
;                         meters, if applicable.
;
;               ZERO_CENTER = If set, and SYSTEM is 'HPR', then define the
;                         output longitude to be zero at disk center.  The
;                         default is -90 degrees at disk center to be
;                         compatible with WCS requirements.  In Thompson (2006)
;                         this is the distinction between theta_rho and
;                         delta_rho.
;
;               QUICK   = For conversion between HPC and HPR coordinates, if
;                         /QUICK is set, do a quick approximate calculation
;                         rather than a full-blown spherical calculation.  This
;                         is only appropriate for small angular distances close
;                         to the Sun.
;
; Calls       :	DELVARX, VALID_WCS, WCS_CONV_FIND_ANG_UNITS, WCS_CONV_CR_HG,
;               WCS_CONV_HCC_HCR, WCS_CONV_HCC_HG, WCS_CONV_HCC_HPC,
;               WCS_CONV_HCR_HCC, WCS_CONV_HCR_HPR, WCS_CONV_HG_CR,
;               WCS_CONV_HG_HCC, WCS_CONV_HPC_HCC, WCS_CONV_HPC_HPR,
;               WCS_CONV_HPR_HCR, WCS_CONV_HPR_HPC
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects: None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 12-Dec-2008, William Thompson, GSFC
;               Version 2, 18-Dec-2008, WTT, corrected typo
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_convert_from_coord, wcs, coord, type, x_out, y_out, z_out, $
                            carrington=carrington, index_z=index_z, $
                            arcseconds=arcseconds, factor=factor, _extra=_extra
on_error, 2
;
if n_params() lt 5 then message, $
  'Syntax: WCS_CONVERT_FROM_COORD, WCS, COORD, SYSTEM, X, Y,  [, Z ]'
;
;  Make sure that a valid WCS structure was passed.
;
if not valid_wcs(wcs) then message, 'Input not recognized as WCS structure'
;
;  The first dimension of COORD must be compatible with the WCS structure.
;
if n_elements(coord) eq 0 then message, 'COORD is not defined'
sz = size(coord)
if sz[0] eq 0 then message, 'COORD must be an array'
if sz[1] ne n_elements(wcs.ctype) then message, $
  'COORD not compatible with WCS structure'
;
;  Get the dimensions after the first.
;
ndim = sz[0] - 1
if ndim ge 1 then dim = sz[2:sz[0]] else dim = 1
;
;  Get the input X and Y arrays.
;
x_in = reform(coord[wcs.ix,*,*,*,*,*,*,*], dim)
y_in = reform(coord[wcs.iy,*,*,*,*,*,*,*], dim)
;
;  If the INDEX_Z keyword was not passed, then look for the input Z array,
;  based on the coordinate type as given by the WCS structure.
;
iz = -1
if n_elements(index_z) eq 1 then iz = index_z else begin
    case wcs.coord_type of
        'Helioprojective-Cartesian': zname = 'DIST'
        'Helioprojective-Radial':    zname = 'DIST'
        'Heliocentric-Cartesian':    zname = 'SOLZ'
        'Heliocentric-Radial':       zname = 'SOLZ'
        'Stonyhurst-Heliographic':   zname = 'HECR'
        'Carrington-Heliographic':   zname = 'HECR'
        else: message, 'Coordinate type ' + wcs.coord_type + ' not supported'
    endcase
;
    ctype = strupcase(strmid(wcs.ctype,0,4))
    w = where(ctype eq zname, count)
    if count gt 0 then iz = w[0]
endelse
;
;  Extract the array of Z values, if applicable.
;
if iz ge 0 then z_in = reform(coord[iz,*,*,*,*,*,*,*], dim) else $
  delvarx, z_in
;
;  Get the default conversion factors for angular units.
;
wcs_conv_find_ang_units, cx, cy, /to_degrees, wcs=wcs, _extra=_extra
;
;  Start out with Z_OUT and FACTOR undefined.
;
delvarx, z_out, factor
;
;  Perform the conversion, based on the coordinate type.  Start with
;  Helioprojective-Cartesion.
;
case wcs.coord_type of
    'Helioprojective-Cartesian': begin
        case strupcase(type) of
            'HPC': begin
                x_out = x_in * cx
                y_out = y_in * cy
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HPR': begin
                wcs_conv_hpc_hpr, x_in, y_in, x_out, y_out, wcs=wcs, $
                  _extra=_extra
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HCC': wcs_conv_hpc_hcc, x_in, y_in, x_out, y_out, z_out, $
              distance=z_in, wcs=wcs, factor=factor, _extra=_extra
            'HCR': begin
                wcs_conv_hpc_hcc, x_in, y_in, x_temp, y_temp, z_out, $
                  distance=z_in, wcs=wcs, factor=factor, _extra=_extra
                wcs_conv_hcc_hcr, x_temp, y_temp, x_out, y_out, _extra=_extra
            endcase
            'HG': begin
                wcs_conv_hpc_hcc, x_in, y_in, x_temp, y_temp, z_temp, $
                  distance=z_in, wcs=wcs, factor=factor, _extra=_extra
                wcs_conv_hcc_hg, x_temp, y_temp, x_out, y_out, z_out, $
                  wcs=wcs, solz=z_temp, carrington=carrington, _extra=_extra
            endcase
            else: message, 'Coordinate type ' + type + ' not supported'
        endcase
    endcase
;
    'Helioprojective-Radial': begin
        case strupcase(type) of
            'HPC': begin
                wcs_conv_hpr_hpc, x_in, y_in, x_out, y_out, wcs=wcs, $
                  _extra=_extra
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HPR': begin
                x_out = x_in * cx
                y_out = y_in * cy
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HCC': begin
                wcs_conv_hpr_hcr, y_in, y_temp, z_out, distance=z_in, $
                  wcs=wcs, factor=factor, _extra=_extra
                wcs_conv_hcr_hcc, x_in, y_temp, x_out, y_out, _extra=_extra
            endcase
            'HCR': begin
                wcs_conv_hpr_hcr, y_in, y_out, z_out, distance=z_in, wcs=wcs, $
                  factor=factor, _extra=_extra
                x_out = x_in * cx
                w = where_missing(y_out, count)
                if count gt 0 then flag_missing, x_out, w
            endcase
            'HG': begin
                wcs_conv_hpr_hcr, y_in, y_temp1, z_temp, distance=z_in, $
                  wcs=wcs, factor=factor, _extra=_extra
                wcs_conv_hcr_hcc, x_in, y_temp1, x_temp, y_temp, _extra=_extra
                wcs_conv_hcc_hg, x_temp, y_temp, x_out, y_out, z_out, $
                  wcs=wcs, solz=z_temp, carrington=carrington, _extra=_extra
            endcase
            else: message, 'Coordinate type ' + type + ' not supported'
        endcase
    endcase
;
    'Heliocentric-Cartesian': begin
        case strupcase(type) of
            'HPC': wcs_conv_hcc_hpc, x_in, y_in, x_out, y_out, z_out, $
              wcs=wcs, solz=z_in, factor=factor, _extra=_extra
            'HPR': begin
                wcs_conv_hcc_hcr, x_in, y_in, x_out, y_temp, _extra=_extra
                wcs_conv_hcr_hpr, y_temp, y_out, z_out, wcs=wcs, solz=z_in, $
                  factor=factor, _extra=_extra
                w = where_missing(y_out, count)
                if count gt 0 then flag_missing, x_out, w
            endcase
            'HCC': begin
                x_out = x_in * cx
                y_out = y_in * cy
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HCR': begin
                wcs_conv_hcc_hcr, x_in, y_in, x_out, y_out, _extra=_extra
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HG': wcs_conv_hcc_hg, x_in, y_in, x_out, y_out, z_out, $
              wcs=wcs, solz=z_in, carrington=carrington, factor=factor, $
              _extra=_extra
            else: message, 'Coordinate type ' + type + ' not supported'
        endcase
    endcase
;
    'Heliocentric-Radial': begin
        case strupcase(type) of
            'HPC': begin
                wcs_conv_hcr_hcc, x_in, y_in, x_temp, y_temp, _extra=_extra
                wcs_conv_hcc_hpc, x_temp, y_temp, x_out, y_out, z_out, $
                  wcs=wcs, solz=z_in, factor=factor, _extra=_extra
            endcase
            'HPR': begin
                wcs_conv_hcr_hpr, y_in, y_out, z_out, wcs=wcs, solz=z_in, $
                  factor=factor, _extra=_extra
                x_out = x_in * cx
                w = where_missing(y_out, count)
                if count gt 0 then flag_missing, x_out, w
            endcase
            'HCC': begin
                wcs_conv_hcr_hcc, x_in, y_in, x_out, y_out, _extra=_extra
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HCR': begin
                x_out = x_in * cx
                y_out = y_in * cy
                if n_elements(z_in) gt 0 then z_out = z_in
            endcase
            'HG': begin
                wcs_conv_hcr_hcc, x_in, y_in, x_temp, y_temp, _extra=_extra
                wcs_conv_hcc_hg, x_temp, y_temp, x_out, y_out, z_out, $
                  wcs=wcs, solz=z_in, carrington=carrington, factor=factor, $
                  _extra=_extra
            endcase
            else: message, 'Coordinate type ' + type + ' not supported'
        endcase
    endcase
;
    'Stonyhurst-Heliographic': begin
        if strupcase(type) ne 'HG' then wcs_conv_hg_hcc, x_in, y_in, x_temp, $
          y_temp, z_temp, wcs=wcs, carrington=0, hecr=z_in, factor=factor, $
          _extra=_extra
        case strupcase(type) of
            'HPC': wcs_conv_hcc_hpc, x_temp, y_temp, x_out, y_out, z_out, $
              wcs=wcs, solz=z_temp, _extra=_extra
            'HPR': begin
                wcs_conv_hcc_hcr, x_temp, y_temp, x_out, y_temp2, _extra=_extra
                wcs_conv_hcr_hpr, y_temp2, y_out, z_out, wcs=wcs, $
                  solz=z_temp, _extra=_extra
                w = where_missing(y_out, count)
                if count gt 0 then flag_missing, x_out, w
            endcase
            'HCC': begin
                x_out = temporary(x_temp)
                y_out = temporary(y_temp)
                if n_elements(z_temp) gt 0 then z_out = temporary(z_temp)
            endcase
            'HCR': begin
                wcs_conv_hcc_hcr, x_temp, y_temp, x_out, y_out, _extra=_extra
                if n_elements(z_temp) gt 0 then z_out = temporary(z_temp)
            endcase
            'HG': begin
                y_out = y_in * cy
                if n_elements(z_in) gt 0 then z_out = z_in
                if keyword_set(carrington) then $
                  wcs_conv_hg_cr, x_in, x_out, wcs=wcs, _extra=_extra else $
                  x_out = x_in * cx
            endcase
            else: message, 'Coordinate type ' + type + ' not supported'
        endcase
    endcase
;
    'Carrington-Heliographic': begin
        if strupcase(type) ne 'HG' then wcs_conv_hg_hcc, x_in, y_in, x_temp, $
          y_temp, z_temp, wcs=wcs, carrington=1, hecr=z_in, factor=factor, $
          _extra=_extra
        case strupcase(type) of
            'HPC': wcs_conv_hcc_hpc, x_temp, y_temp, x_out, y_out, z_out, $
              wcs=wcs, solz=z_temp, _extra=_extra
            'HPR': begin
                wcs_conv_hcc_hcr, x_temp, y_temp, x_out, y_temp2, _extra=_extra
                wcs_conv_hcr_hpr, y_temp2, y_out, z_out, wcs=wcs, $
                  solz=z_temp, _extra=_extra
                w = where_missing(y_out, count)
                if count gt 0 then flag_missing, x_out, w
            endcase
            'HCC': begin
                x_out = temporary(x_temp)
                y_out = temporary(y_temp)
                if n_elements(z_temp) gt 0 then z_out = temporary(z_temp)
            endcase
            'HCR': begin
                wcs_conv_hcc_hcr, x_temp, y_temp, x_out, y_out, _extra=_extra
                if n_elements(z_temp) gt 0 then z_out = temporary(z_temp)
            endcase
            'HG': begin
                y_out = y_in * cy
                if n_elements(z_in) gt 0 then z_out = z_in
                if keyword_set(carrington) then x_out = x_in * cx else $
                  wcs_conv_cr_hg, x_in, x_out, wcs=wcs, _extra=_extra
            endcase
            else: message, 'Coordinate type ' + type + ' not supported'
        endcase
    endcase
;
    else: message, 'Coordinate type ' + wcs.coord_type + ' not supported'
endcase
;
;  If the output coordinate system is Helioprojective-Cartesian, and
;  /ARCSECONDS is set, then convert to arcseconds.
;
if (strupcase(type) eq 'HPC') and keyword_set(arcseconds) then begin
    x_out = x_out * 3600
    y_out = y_out * 3600
endif
;
;  If NDIM is zero, then return the results as scalars.
;
if ndim eq 0 then begin
    x_out = x_out[0]
    y_out = y_out[0]
    if n_elements(z_out) eq 1 then z_out = z_out[0]
endif
;
return
end
