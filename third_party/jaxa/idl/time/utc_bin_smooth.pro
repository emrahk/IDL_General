;+
; Project     :	STEREO - SSC
;
; Name        :	UTC_BIN_SMOOTH()
;
; Purpose     :	Bins time-series data as a form of smoothing
;
; Category    :	Time-series
;
; Explanation :	This procedure applies a form of smoothing to time-series data
;               by first rebinning the data into a specified bin size, and then
;               interpolating back to the original timestamps.  It should be
;               noted that this is not the same thing as convolving the data
;               with a squarewave smoothing function, except at the bin
;               points.  However, this procedure does execute reasonably
;               quickly, depending on the number of bin points.
;
;               This binning procedure is designed for cases where the
;               timestamps may not be evenly spaced, may not be monotonic, and
;               may even contain duplicate timestamps.  For data where the
;               timestamps are evenly spaced and monotonic, more traditional
;               smoothing procedures are probably preferred.
;
; Syntax      :	Result = UTC_BIN_SMOOTH( UTC, DATA, WIDTH )
;
; Examples    :	NewVec = UTC_BIN_SMOOTH( UTC, OldVec, 60 )      ;1 minute
;
; Inputs      :	UTC     = The date/time vector
;               DATA    = The data vector
;               WIDTH   = The smoothing width, in seconds
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the smoothed data vector, at the
;               same timestamps as the original data.
;
; Opt. Outputs:	None.
;
; Keywords    :	MISSING = Value signifying missing pixels.
;
;               Can also pass any keywords accepted by INTERPOL.
;
; Calls       :	ANYTIM2TAI, AVERAGE, INTERPOL
;
; Common      :	None.
;
; Restrictions:	UTC and DATA must have the same number of elements.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 30-Jun-2010, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
function utc_bin_smooth, utc, data, width, _extra=_extra
;
on_error, 2
;
;  Check the input parameters.
;
if n_params() lt 3 then message, $
  'Syntax: Result = UTCSMOOTH(UTC, DATA, WIDTH)'
if n_elements(utc) eq 0 then message, 'UTC is not defined'
if n_elements(utc) ne n_elements(data) then message, $
  'UTC and DATA must have the same number of elements'
;
;  Convert the input date/time vector to TAI seconds.
;
message = ''
tai0 = anytim2tai(utc, errmsg=message)
if message ne '' then message, message
;
;  Calculate the bin positions for the new data array.
;
tmax = max(tai0, min=tmin)
tai0 = tai0 - tmin
range = tmax - tmin
nsteps = ceil(range / width)
tai1 = dindgen(nsteps) * range / nsteps
;
;  Step through the bins, and calculate the average value in each bin.
;
data1 = dblarr(nsteps)
delta = width / 2.d0
for i = 0L, nsteps-1 do begin
    w = where((tai0 ge (tai1[i]-delta)) and (tai0 le (tai1[i]+delta)), count)
    if count gt 0 then data1[i] = average(data[w], _extra=_extra) else $
      data1[i] = !values.d_nan
endfor
;
;  Remove any missing bins.
;
w = where(finite(data1))
tai1 = tai1[w]
data1 = data1[w]
;
;  Interpolate back to the original time vector.
;
result = interpol(data1, tai1, tai0, _extra=_extra)
sz = size(data)
if sz[0] gt 1 then result = reform(result, sz[1:sz[0]], /overwrite)
;
return, result
end
