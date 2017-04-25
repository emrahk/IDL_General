;+
; Project     :	STEREO
;
; Name        :	WCS_RECTIFY
;
; Purpose     :	Resample WCS images to rectify the axes.
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This procedure takes a data array and associated World
;               Coordinate System structure, and resamples the array to remove
;               all the cross terms in the PC or CD matrix.  This is the
;               N-dimensional equivalent of rotating a 2D axis to set the
;               CROTAn values to zero.
;
; Syntax      :	WCS_RECTIFY, DATA, WCS
;
; Inputs      :	DATA = Data array associated with the WCS structure
;               WCS  = World Coordinate System structure from FITSHEAD2WCS
;
; Opt. Inputs :	None.
;
; Outputs     :	DATA and WCS are modified.
;
; Opt. Outputs:	None.
;
; Keywords    :	MISSING = Value to fill missing pixels with.  If not passed,
;                         then the program first looks to see if SET_FLAG has
;                         been called to set a default value.  Otherwise,
;                         missing pixels are filled with IEEE Not-A-Number
;                         (NaN) values.
;
;               CUBIC   = Keyword passed to the INTERPOLATE routine--see that
;                         routine for more information.  Ignored if the array
;                         has more than two dimensions.
;
;               ERRMSG	= If defined and passed, then any error messages will
;			  be returned to the user in this parameter rather than
;			  depending on the MESSAGE routine in IDL.  If no
;			  errors are encountered, then a null string is
;			  returned.  In order to use this feature, ERRMSG must
;			  be defined first, e.g.
;
;				ERRMSG = ''
;				WCS_RECTIFY, DATA, WCS, ERRMSG=ERRMSG, ...
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	VALID_WCS, PRODUCT, WCS_GET_COORD, GET_IM_KEYWORD, TAG_EXIST,
;               REM_TAG, ADD_TAG
;
; Common      :	None.
;
; Restrictions:	If the data array has more than three dimensions, then the
;               routine defaults to nearest-neighbor interpolation.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 19-Apr-2005, William Thompson, GSFC
;               Version 2, 25-Apr-2005, William Thompson, GSFC
;                       Added call to INTERPOLATE
;               Version 3, 12-May-2005, William Thompson, GSFC
;                       Handle missing complex and dcomplex values
;               Version 4, 19-Aug-2008, WTT, Fix bug with negative CDELT.
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_rectify, data, wcs, missing=missing, errmsg=errmsg, cubic=cubic
on_error, 2
;
;  Check the input parameters.
;
if n_params() ne 2 then begin
    message = 'Syntax: WCS_RECTIFY, DATA, WCS'
    goto, handle_error
endif
if not valid_wcs(wcs) then begin
    message = 'Input not recognized as WCS structure'
    goto, handle_error
endif
if n_elements(data) eq 0 then begin
    message = 'DATA array is undefined' 
    goto, handle_error
endif
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
;  Check to see if there are any non-zero cross-terms.  If not, then the WCS is
;  already rectified.
;
n_axis = n_elements(wcs.naxis)
done = 1
if wcs.variation eq 'CD' then cc = wcs.cd else cc = wcs.pc
for i=0,n_axis-1 do begin
    for j=0,n_axis-1 do begin
        if (i ne j) and (cc[i,j] ne 0) then done = 0
    endfor
endfor
if done then begin
    print, 'Already done'
    return
endif
;
;  Get the current intermediate coordinates, and the data ranges along each
;  dimension.
;
n_elements=product(long64(wcs.naxis))
coord = reform(wcs_get_coord( wcs, /relative), [n_axis,n_elements])
cmin = dblarr(n_axis)
cmax = dblarr(n_axis)
for i=0,n_axis-1 do begin
    cmin[i] = min(coord[i,*], max=ccmax)
    cmax[i] = ccmax
endfor
;
;  Determine the step sizes to apply to the data.
;
if tag_exist(wcs, 'CDELT') then cdelt = wcs.cdelt else begin
    cdelt = dblarr(n_axis)
    for i=0,n_axis-1 do begin
        cdelt[i] = cd[i,i]
        if (cdelt[i] eq 0) and (wcs.naxis[i] gt 1) then $
          cdelt[i] = (cmax[i]-cmin[i]) / (wcs.naxis[i]-1)
        if cdelt[i] eq 0 then cdelt[i] = cmax[i] - cmin[i]
        if cdelt[i] eq 0 then cdelt[i] = 1
    endfor
endelse
;
;  If an axis decrements instead of increments, then reverse the values of cmin
;  and cmax.
;
w = where(cdelt lt 0, count)
if count gt 0 then for i=0,count-1 do begin
    ii = w[i]
    temp = cmin[ii]
    cmin[ii] = cmax[ii]
    cmax[ii] = temp
endfor
;
;  Calculate the minimum and maximum index for each dimension, and the
;  dimensions of the output array.
;
imin = floor(cmin / cdelt)
imax = ceil (cmax / cdelt)
naxis = imax - imin + 1
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
;  Determine the indices into the original array.  This is the inverse process
;  of WCS_GET_COORD.
;
n_elements = product(long64(naxis))
index = dindgen(n_elements)
coord = make_array(dimension=[n_axis,n_elements], /double)
nn = 1.d0
for i=0,n_axis-1 do begin
    coord[i,*] = ((long(index / nn) mod naxis[i]) + imin[i]) * cdelt[i]
    nn = nn * naxis[i]
endfor
if wcs.variation eq 'CD' then cd = wcs.cd else begin
    cd = dblarr(n_axis,n_axis)
    for i=0,n_axis-1 do cd[i,i] = cdelt[i]
    cd = cd # wcs.pc
endelse
cd = invert(cd,status,/double)
if status eq 1 then begin
    message = 'Unable to invert tranformation matrix'
    goto, handle_error
endif
coord = cd # coord
for i=0,n_axis-1 do coord[i,*] = coord[i,*] + (wcs.crpix[i] - 1)
;
;  Make sure that data is at least of type float.
;
if datatype(data,2) lt 4 then data = float(temporary(data))
;
;  If n_axis LE 3, then use interpolate.
;
case n_axis of
    1: output = reform(interpolate(data, cubic=cubic, missing=missing, $
                                   coord[0,*]), naxis)
    2: output = reform(interpolate(data, cubic=cubic, missing=missing, $
                                   coord[0,*],coord[1,*]), naxis)
    3: output = reform(interpolate(data, cubic=cubic, missing=missing, $
                                   coord[0,*],coord[1,*],coord[2,*]), naxis)
;
;  Otherwise, for now, we'll just do nearest-neighbor.
;
    else: begin
        output = make_array(value=missing, dimension=naxis)
        coord = round(coord)
        w = dindgen(n_elements)
        for i=0,n_axis-1 do $
          w = w[where((coord[i,w] ge 0) and (coord[i,w] lt wcs.naxis[i]))]
        command = 'output[w] = data[coord[0,w]'
        for i=1,n_axis-1 do command = command + ',coord[' + ntrim(i) + ',w]'
        command = command + ']'
        if not execute(command) then begin
            message = 'Unable to execute command ' + command
            goto, handle_error
        endif
    endcase
endcase
;
;  Update the WCS structure.
;
wcs.variation = 'PC'
wcs.crpix = -imin + 1
wcs.naxis = naxis
if tag_exist(wcs, 'CD', /top_level) then wcs = rem_tag(wcs, 'CD')
if tag_exist(wcs, 'CDELT', /top_level) then wcs.cdelt = cdelt else $
  wcs = add_tag(wcs, cdelt, 'CDELT', /top_level)
if tag_exist(wcs, 'ROLL_ANGLE', /top_level) then wcs.roll_angle = 0 else $
  wcs = add_tag(wcs, 0.d0, 'ROLL_ANGLE', /top_level)
pc = dblarr(n_axis,n_axis)
for i=0, n_axis-1 do pc[i,i] = 1
if tag_exist(wcs, 'PC', /top_level) then wcs.pc = pc else $
  wcs = add_tag(wcs, pc, 'PC', /top_level)
;
;  Update the data array.
;
data = temporary(output)
;
;  Before returning, check to see if the WCS can now be described as simple.
;
dummy = wcs_simple(wcs, /add_tag)
return
;
HANDLE_ERROR:
if n_elements(errmsg) ne 0 then errmsg = 'WCS_RECTIFY: ' + message else $
  message, message, /continue
end
