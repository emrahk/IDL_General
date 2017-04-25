;+
; Project     :	STEREO
;
; Name        :	WCS_2D_ROTATE
;
; Purpose     :	Rotate simple 2D images with WCS structure
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation : This routine is used to rotate simple two-dimensional images
;               with associated WCS structures.
;
; Syntax      :	WCS_2D_ROTATE, IMAGE, WCS
;
; Examples    :	FITS_READ, FILENAME, IMAGE, HEADER
;               WCS = FITSHEAD2WCS(HEADER)
;               WCS_2D_ROTATE, IMAGE, WCS
;
; Inputs      :	IMAGE   = Image to rotate
;
;               WCS     = WCS structure associated with image.
;
; Opt. Inputs :	None.
;
; Outputs     :	IMAGE and WCS are modified to incorporate the new image roll.
;
; Opt. Outputs:	None.
;
; Keywords    :	ROLL_ANGLE = Target roll angle of output data.  Default = 0.
;
;               MISSING = Value to fill missing values with.  If not passed,
;                         then missing values are filled with IEEE
;                         Not-A-Number (NaN) values.
;
;               INTERP  = If set, then bilinear interpolation is used.
;
;               CUBIC   = Cubic convolutional interpolation parameter.  See the
;                         documentation for ROT() for more information.
;
; Calls       :	VALID_WCS, TAG_EXIST, GET_IM_KEYWORD, DATATYPE, ROT, WCS_SIMPLE
;
; Common      :	None.
;
; Restrictions: Only relatively simple data are supported, i.e. those which can
;               be rotated with the IDL ROT() function.  Additional non-spatial
;               dimensions are allowed, but must not have any cross-terms with
;               the spatial dimensions in the PC matrix.  Also, the longitude
;               and latitude dimensions (X,Y) must immediately follow each
;               other.  The CD matrix variation is not allowed.
;
;               More complicated datasets can be addressed with the WCS_RECTIFY
;               and WCS_SIMPLIFY routines.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 05-Mar-2013, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_2d_rotate, data, wcs, roll_angle=roll_angle, missing=missing, $
                   _extra=_extra
on_error, 2
;
;  Check the input parameters.
;
if n_params() ne 2 then begin
    message = 'Syntax: WCS_2D_ROTATE, DATA, WCS'
    goto, handle_error
endif
if ~valid_wcs(wcs) then begin
    message = 'Input not recognized as WCS structure'
    goto, handle_error
endif
if n_elements(data) eq 0 then begin
    message = 'DATA array is undefined' 
    goto, handle_error
endif
if n_elements(roll_angle) gt 1 then begin
    message = 'ROLL_ANGLE must be a scalar'
    goto, handle_error
endif
if n_elements(roll_angle) eq 0 then roll_angle = 0
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
if count gt 0 then begin
    message = 'DATA array does not match WCS structure'
    goto, handle_error
endif
;
;  Make sure that this WCS can be characterized by a roll angle, and that the
;  CD matrix variation is not used.
;
if ~tag_exist(wcs,'roll_angle',/top_level) then begin
    message = 'WCS must be characterized by a roll angle'
    goto, handle_error
endif
if wcs.variation eq 'CD' then begin
    message = 'CD matrixes are not supported'
    goto, handle_error
endif
;
;  Make sure that the Y dimension immediately follows the X dimension, and that
;  the pixel sizes are the same.
;
ix = wcs.ix
iy = wcs.iy
if (iy - ix) ne 1 then begin
    message = 'Y axis must immediately follow X axis'
    goto, handle_error
endif
if wcs.cdelt[ix] ne wcs.cdelt[iy] then begin
    message = 'X and Y axes must have the same plate scale'
    goto, handle_error
endif
;
;  Check to see if there are any non-zero cross-terms between spatial and
;  non-spatial dimensions.  If there are, then this routine cannot be used.
;
n_axis = n_elements(wcs.naxis)
ok = 1
for i=0,n_axis-1 do begin
    for j=0,n_axis-1 do begin
        if (i ne j) and (wcs.pc[i,j] ne 0) and $
          (((i eq ix) and (j ne iy)) or ((i eq iy) and (j ne ix)) or $
           ((i ne ix) and (j eq iy)) or ((i ne iy) and (j eq ix))) then ok = 0
    endfor
endfor
if ok ne 1 then begin
    message = 'Data too complex'
    goto, handle_error
endif
;
;  Let NI represent all dimensions before the spatial dimensions, and NJ all
;  the dimensions after the spatial dimensions.
;
ni = 1L
nj = 1L
nx = dim2[ix]
ny = dim2[iy]
for i=0,ix-1 do ni = ni * dim2[i]
for i=iy+1,n_axis-1 do nj = nj * dim2[i]
;
;  Determine the value to use for missing data.
;
get_im_keyword, missing, !image.missing
if n_elements(missing) ne 1 then begin
    case datatype(data,2) of
        5: missing = !values.d_nan
        6: missing =  complex(!values.f_nan, !values.f_nan)
        9: missing = dcomplex(!values.d_nan, !values.d_nan)
        else: missing = !values.f_nan
    endcase
endif
;
;  Temporarily reformat the data array to use NI, NJ.
;
data = reform(data, [ni, nx, ny, nj], /overwrite)
;
;  Determine the angle to use in rolling the data.  Scale between 0 and 360.
;  If the plate scale is negative, then add 180 degrees to the angle, and
;  redefine the plate scale to be positive.
;
angle = roll_angle - wcs.roll_angle
cdelt = wcs.cdelt[ix]
if cdelt lt 0 then begin
    angle = angle + 180
    cdelt = abs(cdelt)
endif
while angle lt 0 do angle = angle + 360
angle = angle mod 360
;
;  Step through the non-spatial dimensions, and rotate the data.
;
x0 = wcs.crpix[ix] - 1
y0 = wcs.crpix[iy] - 1
for i=0,ni-1 do begin
    for j=0,nj-1 do begin
        temp = reform(data[i,*,*,j])
        case angle of
               0: dummy = dummy
              90: data[i,*,*,j] = rotate(temp,3)
             180: data[i,*,*,j] = rotate(temp,2)
             270: data[i,*,*,j] = rotate(temp,1)
            else: data[i,*,*,j] = rot(temp, angle, 1, x0, y0, /pivot, $
                                      missing=missing, _extra=_extra)
        endcase
    endfor
endfor
;
;  Change the WCS structure to reflect the roll.
;
wcs.roll_angle = roll_angle
wcs.cdelt[ix] = cdelt
wcs.cdelt[iy] = cdelt
angle = roll_angle * !dpi / 180.d0
cos_a = cos(angle)
sin_a = sin(angle)
wcs.pc[ix,ix] =  cos_a
wcs.pc[ix,iy] = -sin_a
wcs.pc[iy,ix] =  sin_a
wcs.pc[iy,iy] =  cos_a
;
;  Reformat the data array into its original dimensions.
;
data = reform(data, sz[1:sz[0]], /overwrite)
;
;  Before returning, check to see if the WCS can now be described as simple.
;
dummy = wcs_simple(wcs, /add_tag)
return
;
HANDLE_ERROR:
if n_elements(errmsg) ne 0 then errmsg = 'WCS_2D_ROTATE: ' + message else $
  message, message, /continue
;
end
