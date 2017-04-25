;+
; Project     :	SOHO - CDS
;
; Name        :	FORM_HISTO_2D
;
; Purpose     :	Forms a histogram from the variable ARRAYX.
;
; Category    :	Class4, Graphics
;
; Explanation :	Forms a 2D histogram from the paired variables ARRAYX and
;               ARRAYY.  Decides what the coarseness of the histogram should
;               be in each dimension.
;
;		The arrays are scaled into temporary variables to run from zero
;		and some reasonable number, depending on the number of elements
;		of each array.  This number is the coarseness of the histogram,
;		i.e. the number of histogram bins.  The more elements in the
;		arrays , the larger this number will be.  However, it will not
;		exceed 100.  The HISTOGRAM function is then used on a suitable
;		combination of these temporary variables.
;
;		If the optional parameter DELTA is passed, then FORM_HISTO uses
;		this value to determine the spacing of the histogram bins,
;		rather than calculating it's own bin spacing as described
;		above.
;
; Syntax      :	FORM_HISTO_2D, ARRAYX, ARRAYY, STEPSX, STEPSY, HISTO
;
; Examples    :	X = RANDOMN(SEED,10000)
;               Y = RANDOMN(SEED,10000)
;               FORM_HISTO_2D, X, Y, SX, SY, HISTO, ORIGIN=ORIGIN, SCALE=SCALE
;               PLOT_IMAGE, HISTO, ORIGIN=ORIGIN, SCALE=SCALE
;
; Inputs      :	ARRAYX	= X array to form histogram from.
;               ARRAYY  = Y array to form histogram from.
;
; Opt. Inputs :	None.
;
; Outputs     :	STEPSX	= Values along X axis at which histogram is taken.
;                         Each value represents histogram between STEP(I) and
;                         STEP(I+1).
;               STEPSY  = Same for Y axis.
;		HISTO	= Histogram values.
;
; Opt. Outputs:	None.
;
; Keywords    :	DELTA	= Distance between histogram steps.    Can be a
;			  two-element vector for separate X and Y values.  If
;			  not passed, then the routine chooses suitable values.
;
;		CENTER  = If set, then the STEPSX and STEPSY arrays refer to
;                         the center of the pixels, rather than the beginning.
;                         This allows one to use commands such as
;
;                               CONTOUR, HISTO, STEPSX, STEPSY
;
;                         and match the output from PLOT_IMAGE.
;
;               MISSING = Value flagging missing pixels.  Missing pixels can
;                         also be flagged as Not-A-Number.
;
;               ORIGIN  = Returns the origin of the histogram, for use in
;                         PLOT_IMAGE.
;
;               SCALE   = Returns the scale of the histogram, for use in
;                         PLOT_IMAGE.
;
;               ERRMSG  = If defined and passed, then any error messages will
;                         be returned to the user in this parameter rather than
;                         depending on the MESSAGE routine in IDL.  If no
;                         errors are encountered, then a null string is
;                         returned.  In order to use this feature, ERRMSG must
;                         be defined first, e.g.
;
;                               ERRMSG = ''
;                               FORM_HISTO_2D, ERRMSG=ERRMSG, ...
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	WHERE_NOT_MISSING
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	Based on FORM_HISTO
;
; History     :	Version 1, 12-Oct-2006, William Thompson, GSFC
;               Version 2, 12-Jan-2007, William Thompson, GSFC
;                       Corrected bug with occasional array size mismatch
;
; Contact     :	WTHOMPSON
;-
;
pro form_histo_2d, arrayx, arrayy, stepsx, stepsy, histo, delta=delta, $
                   missing=missing, origin=origin, scale=scale, $
                   center=center, errmsg=errmsg
;
on_error,2
continue = 0
;
;  Check the number of parameters.
;
if n_params(0) ne 5 then begin
    message = 'Syntax:  FORM_HISTO_2D, ARRAYX, ARRAYY, STEPSX, STEPSY, HISTO'
    goto, handle_error
endif
;
;  Make sure that ARRAYX and ARRAYY are defined and have the same number of
;  elements.
;
if n_elements(arrayx) eq 0 then begin
    message = 'ARRAYX not defined'
    goto, handle_error
endif
if n_elements(arrayy) eq 0 then begin
    message = 'ARRAYY not defined'
    goto, handle_error
endif
if n_elements(arrayx) ne n_elements(ARRAYY) then begin
    message = 'Dimensions of ARRAYX and ARRAYY do not agree'
    goto, handle_error
endif
;
;  Filter out any missing pixels.
;
w = where_not_missing(arrayx, missing=missing, count)
if count le 2 then begin
    message = 'not enough points to form histogram'
    goto, handle_error
endif
atempx = arrayx[w]
atempy = arrayy[w]
;
w = where_not_missing(atempy, missing=missing, count)
if count le 2 then begin
    message = 'not enough points to form histogram'
    goto, handle_error
endif
atempx = arrayx[w]
atempy = arrayy[w]
;
;  Get the maximum and minimum values of ARRAYX.
;
ax_max = 1.*max(atempx, min=ax_min)
ax_min = 1.*ax_min
if ax_max eq ax_min then begin
    message = 'No histogram generated--all elements equal to ' + trim(ax_max)
    continue = 1
    goto, handle_error
end else if (ax_max - ax_min) lt (1e-4 * abs(ax_min)) then begin
    message = 'No histogram generated--range ' + TRIM(AX_MIN) + ' to ' + $
      TRIM(AX_MAX) + ' too narrow'
    continue = 1
    goto, handle_error
endif
;
;  Get the maximum and minimum values of ARRAYY.
;
ay_max = 1.*max(atempy, min=ay_min)
ay_min = 1.*ay_min
if ay_max eq ay_min then begin
    message = 'No histogram generated--all elements equal to ' + trim(ay_max)
    continue = 1
    goto, handle_error
end else if (ay_max - ay_min) lt (1e-4 * abs(ay_min)) then begin
    message = 'No histogram generated--range ' + TRIM(AY_MIN) + ' to ' + $
      TRIM(AY_MAX) + ' too narrow'
    continue = 1
    goto, handle_error
endif
;
;  If passed, then check the value of DELTA.
;
if n_elements(delta) ne 0 then begin
    if n_elements(delta) gt 2 then begin
        message = 'DELTA must have 1 or 2 elements'
        goto, handle_error
    end else if min(delta) le 0 then begin
        message = 'DELTA must be positive'
        goto, handle_error
    endif
    deltax = delta[0]
    if n_elements(delta) eq 2 then deltay=delta[1] else deltay=deltax
;
;  If DELTA was not passed, then determine the approximate number of histogram
;  levels from the number of elements of ARRAYX and ARRAYY.
;
end else begin
    n = float(n_elements(w))
    n = n < 100. < (7.*alog10(n) + n/8.)
;
;  Use N to determine the spacing of the histogram levels along X.  Break this
;  number down into mantissa and exponent.
;
    deltax = (ax_max - ax_min) / (n - 1)
    power = fix(alog10(deltax))
    if power gt alog10(deltax) then power = power - 1
    deltax = deltax / 10.^power
;
;  Ensure that the spacing of the histogram levels is either 1,2 or 5 times 
;  some power of ten.
;
    val = [10,5,2]
    value = 1
    for i = 0,2 do if val(i) gt deltax then value = val(i)
    deltax = value * 10.^power
;
;  If ARRAYX is of some integer type (byte, integer or long), then ensure that 
;  DELTAX is at least one.
;
    type = size(arrayx)
    type = type(type(0) + 1)
    if ((type eq 1) or (type eq 2) or (type eq 3)) then	$
      deltax = deltax > 1
;
;  Use N to determine the spacing of the histogram levels along Y.  Break this
;  number down into mantissa and exponent.
;
    deltay = (ay_max - ay_min) / (n - 1)
    power = fix(alog10(deltay))
    if power gt alog10(deltay) then power = power - 1
    deltay = deltay / 10.^power
;
;  Ensure that the spacing of the histogram levels is either 1,2 or 5 times 
;  some power of ten.
;
    val = [10,5,2]
    value = 1
    for i = 0,2 do if val(i) gt deltay then value = val(i)
    deltay = value * 10.^power
;
;  If ARRAYY is of some integer type (byte, integer or long), then ensure that 
;  DELTAY is at least one.
;
    type = size(arrayy)
    type = type(type(0) + 1)
    if ((type eq 1) or (type eq 2) or (type eq 3)) then	$
      deltay = deltay > 1
endelse
;
;  Find the nearest multiple of DELTAX which is LE the minimum of ARRAYX.
;
ax_min = deltax * floor(ax_min / deltax)
ay_min = deltay * floor(ay_min / deltay)
;
;  Form the histogram, and the variables STEPSX and STEPSY.
;
tempx = long((atempx - ax_min) / deltax)
tempy = long((atempy - ay_min) / deltay)
;nx = ceil((ax_max-ax_min)/deltax)
;ny = ceil((ay_max-ay_min)/deltay)
nx = max(tempx) + 1
ny = max(tempy) + 1
stepsx = findgen(nx)*deltax + ax_min
stepsy = findgen(ny)*deltay + ay_min
temp = tempx + nx*tempy
histo = lonarr(nx,ny)
histo[0] = histogram(temp,min=0)
;
;  Calculate the ORIGIN and SCALE parameters, and return.
;
scale = [(stepsx[nx-1]-stepsx[0])/(nx-1.), (stepsy[ny-1]-stepsy[0])/(ny-1.)]
origin = [stepsx[0], stepsy[0]] + scale/2.
if keyword_set(center) then begin
    stepsx = stepsx + deltax/2.
    stepsy = stepsy + deltay/2.
endif
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then $
  message, message, continue=continue else $
  errmsg = 'FORM_HISTO_2D: ' + MESSAGE
return
end
