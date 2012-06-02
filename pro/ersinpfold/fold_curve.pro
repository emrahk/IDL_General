; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;
;	FOLD_CURVE.PRO
;
; PURPOSE:
;
;	Fold a light curve over a particular period.
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;	FOLD_CURVE, x_in, y_in, e_in, phase_coeff, bins_per_cycle, x_out, y_out,
;		e_out, tot_time [, keywords]
;
; INPUTS:
;
;       x_in		:  Time array (2,N)
;	y_in		:  Count rate array (M,N)
;	e_in		:  Count rate errors (M,N)
;	phase_coeff	:  Period array of model parameters in increasing
;			   order.
;	bins_per_cycle	:  Number of bins per cycle 
;			   Note: Bin width cannot be less than the minimum time
;			         resolution of the light curve.
;				 Bin width = period/bins_per_cycle
;
; KEYWORD PARAMETERS:
;
;	epoch_time	:  Reference start time for folding.  If omitted,
;			   default time is the start time of the first bin.
;	plot		:  Set to yes or no for queuing for hardcopy.
;       
; OUTPUTS:
;
;       x_out		:  Phase array in cycles from 0 - 2
;	y_out		:  Folded light curve
;	e_out		:  Errors on folded light curve
;	tot_time	:  Total time of folded data
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;      
;
; RESTRICTIONS:
;	
;
; DEPENDENCIES:
;       
;
; PROCEDURE:
;        
;
; EXAMPLES:
;       
;
;
; MODIFICATION HISTORY:
;
;	Written, Peter.Woods@msfc.nasa.gov
;		(205) 544-1803
;-
;*******************************************************************************


PRO FOLD_CURVE, x_in, y_in, e_in, phase_coeff, bins_per_cycle, $
	x_out, y_out, e_out, tot_time, back_rate = back_rate, $
	epoch_time = epoch_time, plot = plot, units = units, $
	num_harm = num_harm, split_bin = split_bin,pcanorm=pcanorm

if not keyword_set(pcanorm) then pcanorm=0

phase_coeff = REFORM(DOUBLE(phase_coeff))
bins_per_cycle = LONG(bins_per_cycle)
	
have_epoch = N_ELEMENTS(epoch_time) NE 0
have_plot = N_ELEMENTS(plot) NE 0
have_units = N_ELEMENTS(units) NE 0

want_spbin = N_ELEMENTS(split_bin) NE 0

have_num_harm = N_ELEMENTS(num_harm) NE 0

IF have_num_harm THEN BEGIN
   num_harm = LONG(num_harm)
ENDIF ELSE BEGIN
   num_harm = 6L
ENDELSE

IF have_epoch THEN BEGIN
   epoch_time = DOUBLE(epoch_time)
ENDIF ELSE BEGIN
   epoch_time = DOUBLE(MIN(x_in))
ENDELSE

IF have_plot THEN BEGIN
   plot = 'YES'
ENDIF ELSE BEGIN
   plot = 'NO'
ENDELSE

IF have_units THEN BEGIN
   units = units
ENDIF ELSE BEGIN
   units = 'sec'
ENDELSE

have_back = N_ELEMENTS(back_rate) NE 0

IF have_back THEN BEGIN
   back_rate = back_rate
ENDIF ELSE BEGIN
   back_rate = 0.0d
ENDELSE


; Check format of input arrays

x_size = SIZE(x_in)
y_size = SIZE(y_in)
e_size = SIZE(e_in)

IF ((x_size[0] NE 2) OR (x_size[1] NE 2)) THEN BEGIN
   PRINT, '* * * ERROR: times array has incorrect format * * *'
   PRINT, ' '
   GOTO, exit
ENDIF

IF (y_size[0] NE 1) THEN BEGIN
   PRINT, '* * * ERROR: spectra array has incorrect format * * *'
   PRINT, ' '
   GOTO, exit
ENDIF

IF (e_size[0] NE 1) THEN BEGIN
   PRINT, '* * * ERROR: error array has incorrect format * * *'
   PRINT, ' '
   GOTO, exit
ENDIF

IF (e_size[1] NE y_size[1]) THEN BEGIN
   PRINT, '* * * ERROR: error array incompatible with spectra array * * *'
   PRINT, ' '
  GOTO, exit
ENDIF


; Ensure times array is in order of increasing time

;order_ind = SORT(x_in[0,*])

;x_in = x_in[*,order_ind]
x_res = REFORM( x_in[1,*] - x_in[0,*] )
x_mid = REFORM( x_in[0,*] ) + (x_res/2.0d)
;y_in = y_in[order_ind]
;e_in = e_in[order_ind]




; Calculate phase array

IF want_spbin THEN BEGIN
   rel_time = x_in - epoch_time
ENDIF ELSE BEGIN
   rel_time = x_mid - epoch_time
ENDELSE
phase = CALC_PHASES( rel_time, phase_coeff )

frac_phase = phase - FLOOR(phase)

; Find maximum time resolution and check to see if it is valid.

sec_per_day = 86400.0d

CASE units OF
   'sec' : BEGIN
   	period = 1.0d/phase_coeff[1]
	max_res = MAX(x_res)
	tot_time = TOTAL( x_res )
   END
   'day' : BEGIN
   	period = sec_per_day/phase_coeff[1]
	max_res = MAX(x_res) * sec_per_day
	tot_time = TOTAL( x_res * sec_per_day )
   END
   ELSE : BEGIN
   	PRINT, ' * * * FOLD_CURVE.PRO * * * '
	PRINT, ' Invalid units : ' + STRTRIM(units,2)
	PRINT, ' Choose from "sec" or "day" '
	PRINT, ' '
	stop
   END
END

IF (NOT(want_spbin) AND (max_res GT DOUBLE(period/bins_per_cycle))) THEN BEGIN
   PRINT, ' * * * WARNING * * *'
   PRINT, ' Your choice for bins_per_cycle '
   PRINT, ' causes oversampling (i.e. '
   PRINT, ' period/bins_per_cycle < time res)'
   PRINT, ' Maximum time res = ' + STRTRIM(max_res,2)
   PRINT, ' '
   PRINT, ' You may want to choose bin splitting '
   PRINT, ' Keyword : /SPLIT_BIN '
   PRINT, ' '
ENDIF


; Create output arrays

num_bins = LONG( 2 * bins_per_cycle )

x_out_beg = FINDGEN(num_bins)/FLOAT(bins_per_cycle)
x_out_end = (FINDGEN(num_bins) + 1.)/FLOAT(bins_per_cycle)
x_out = [TRANSPOSE(x_out_beg), TRANSPOSE(x_out_end)]

xx = x_out[*,0:(bins_per_cycle - 1)]
yy = DBLARR(bins_per_cycle)
ee = DBLARR(bins_per_cycle)

y_out = FLTARR(num_bins)
e_out = FLTARR(num_bins)


; Loop through either the number of phase bins or number of data points (bin 
; splitting) and calculate the rate and error of the folded profile

IF want_spbin THEN BEGIN
   
   num_dbins = y_size[1]

   cc = DBLARR(bins_per_cycle)
   ce = DBLARR(bins_per_cycle)
   nn = DBLARR(bins_per_cycle)
   
   FOR j = 0L, (num_dbins - 1L) DO BEGIN
   	p0 = frac_phase[0,j]
	p1 = frac_phase[1,j]
	FOR m = 0L, (bins_per_cycle - 1L) DO BEGIN
	   xx0 = xx[0,m]
	   xx1 = xx[1,m]
	   IF ((((xx0 GE p1) OR (xx1 LE p0)) AND (p1 GT p0)) OR $
	   	((p0 GT p1) AND ((xx0 GE p1) AND (xx1 LE p0)))) THEN BEGIN
	   	GOTO, next_xxbin
	   ENDIF
	   IF (p1 GT p0) THEN BEGIN
	   	CASE 1 OF
		   (xx0 LT p0) AND (xx1 LT p1) : deltap = xx1 -  p0
		   (xx0 GE p0) AND (xx1 GE p1) : deltap =  p1 - xx0
		   (xx0 LT p0) AND (xx1 GE p1) : deltap =  p1 -  p0
		   (xx0 GE p0) AND (xx1 LT p1) : deltap = xx1 - xx0
		ENDCASE
		frac = deltap/(p1 - p0)
	   ENDIF ELSE BEGIN
	   	CASE 1 OF
		   (xx0 LT p0) AND (xx1 GT p0) : deltap = xx1 -  p0
		   (xx0 GE p0) AND (xx1 GT p0) : deltap = xx1 - xx0
		   (xx0 LT p1) AND (xx1 GE p1) : deltap =  p1 - xx0
		   (xx0 LT p1) AND (xx1 LT p1) : deltap = xx1 - xx0
		ENDCASE
		frac = deltap/(p1 + 1.0 - p0)
	   ENDELSE
	   cc[m] = cc[m] + (y_in[j] * frac)
	   ce[m] = ce[m] + (e_in[j]^2 * frac)
	   nn[m] = nn[m] + frac
	   next_xxbin:
	ENDFOR
   ENDFOR
   
   yy = cc/nn
   ee = SQRT(ce)/nn
   
ENDIF ELSE BEGIN

   FOR k = 0L, (bins_per_cycle - 1L) DO BEGIN

   	ind = WHERE( (frac_phase GE xx[0,k]) AND (frac_phase LT xx[1,k]) )
   	IF (ind[0] EQ -1) THEN BEGIN
   	   PRINT, ' * * * ERROR * * * '
   	   PRINT, ' Check period array '
   	   PRINT, ' No phase points found for bin ' + STRTRIM(k,2)
	   PRINT, ' Bin range is 0 - ' + STRTRIM(bins_per_cycle-1,2)
   	   PRINT, ' '
   	ENDIF

   	num_points = DOUBLE( N_ELEMENTS(ind) )
   
   	yy[k] = TOTAL( y_in[ind] )/num_points
   	ee[k] = SQRT(TOTAL( e_in[ind]^2 ))/num_points
   
   ENDFOR

ENDELSE


; Fill y_out and e_out arrays

y_out = [yy, yy]
e_out = [ee, ee]



IF (plot EQ 'YES') THEN BEGIN

   new_chan:

   thick = 2.
   
   x_title = '!CPhase (cycles)'
   if pcanorm then y_title = 'Count Rate (counts/sec/PCU)!C' else y_title = 'Count Rate (counts/sec)!C'

   max_y = MAX( y_out + e_out )
   min_y = MIN( y_out - e_out )
   range_y = max_y - min_y
   ymin = min_y - (0.05 * range_y)
   ymax = max_y + (0.05 * range_y)

   filename = 'fold_prof.ps'

   ask = 0
   hc = 0

   replot:

   tag1 = 'Period =  ' + STRTRIM(STRING(period, FORMAT = "(G20.10)"),2) + ' sec'
   tag2 = 'Total exposure time =  ' + STRTRIM(STRING(tot_time, $
   	FORMAT = "(G15.4)"),2) + ' sec'


   PLOT, x_out[0,*], y_out, /NODATA, /YNOZERO, $
   	thick = thick, xtitle = x_title, ytitle = y_title, $
   	ystyle = 1, yrange = [ymin,ymax], $
   	position = [0.1,0.1,0.9,0.9]
   
   HIST_PLOT, x_out, y_out
   
   CROSS_PLOT, x_out, y_out, e_out
   
   XYOUTS, 0.1, -0.15, tag1, charthick = thick, /NORMAL
   XYOUTS, 0.1, -0.19, tag2, charthick = thick, /NORMAL


   IF (ask EQ 0) THEN hc = WIDMENU(['Hardcopy?','Yes','No'],init=1,title=0)

   IF ((ask EQ 0) AND (hc EQ 1)) THEN BEGIN
	SET_PLOT, 'PS'
	DEVICE, xsize = 6.0, xoffset = 1.5, ysize = 4.5, yoffset = 5.5, $
		/INCHES, filename = filename
	ask = 1
	GOTO, replot
   ENDIF  

   IF ((ask EQ 1) AND (hc EQ 1)) THEN BEGIN
	DEVICE, /CLOSE
	SET_PLOT, 'X'
   ENDIF

ENDIF



exit:


END
