; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;
;	HIST_PLOT.PRO	
;
; PURPOSE:
;
;	Creates histogram plot of data (i.e. light curves).  Allows for data
;	gaps and multiple time resolutions.
;	NOTE :  The plot outline must be created first.  This procedure 
;		only overplots on existing plot windows.	
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
;	HIST_PLOT, x, y, thick = thick, tolerance = tolerance	
;
; INPUTS:
;
;	x	:  2 * N array of start and stop values for each bin
;	y 	:  N array of bin values       
;
; KEYWORD PARAMETERS:
;
;	thick		:  determines thickness of plot lines (default = 2)
;	tolerance	:  tolerance error for bin widths (default = 2.0e-4)
;       
; OUTPUTS:
;
;	NONE       
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
;
;-
;******************************************************************************


PRO  HIST_PLOT, x, y, thick = thick, tolerance = tolerance, $
	linestyle = linestyle


have_thick = N_ELEMENTS(thick) NE 0
IF have_thick THEN BEGIN
   thick = thick
ENDIF ELSE BEGIN
   thick = 2
ENDELSE

have_linestyle = N_ELEMENTS(linestyle) NE 0
IF have_linestyle THEN BEGIN
   linestyle = linestyle
ENDIF ELSE BEGIN
   linestyle = 0
ENDELSE

have_tolerance = N_ELEMENTS(tolerance) NE 0
IF have_tolerance THEN BEGIN
   tolerance = tolerance
ENDIF ELSE BEGIN
   tolerance = 2.0e-4
ENDELSE



y = REFORM(y)
bins = N_ELEMENTS(y)



; Search for data gaps

x_start = REFORM( x[0,1:*] )
x_stop = REFORM( x[1,0:bins - 2] )
x_diff = x_start - x_stop

gap_ind = WHERE( ABS(x_diff) GT tolerance ) + 1

num_gaps = N_ELEMENTS(gap_ind)


; Determine the number of data resolutions

xres = REFORM( x[1,*] - x[0,*] )
xres1 = xres[1:*]
xres2 = xres[0:bins - 2]

xres_diff = xres1 - xres2

change_data_ind = WHERE( ABS(xres_diff) GT tolerance )
IF (change_data_ind[0] EQ -1) THEN BEGIN
   data_type_ind = [0]
ENDIF ELSE BEGIN
   data_type_ind = [0, (change_data_ind + 1)]
ENDELSE


data_res = FLTARR(N_ELEMENTS(data_type_ind))
FOR i = 0, (N_ELEMENTS(data_res) - 1) DO BEGIN
   IF (i LT (N_ELEMENTS(data_res) - 1)) THEN BEGIN
	res_sta = data_type_ind[i]
	res_end = data_type_ind[i+1] - 1
   ENDIF ELSE BEGIN
	res_sta = data_type_ind[i]
	res_end = N_ELEMENTS(xres) - 1
   ENDELSE
   num_bins = FLOAT(res_end - res_sta + 1)
   data_res[i] = DOUBLE(TOTAL(xres[res_sta:res_end])/num_bins)
ENDFOR

num_data_types = N_ELEMENTS(data_res)
 

; Determine the total number of separate intervals to plot.

interval_ind = data_type_ind
FOR i = 0, (N_ELEMENTS(gap_ind) - 1) DO BEGIN
   duplicate = WHERE(data_type_ind EQ gap_ind[i])
   IF (duplicate[0] EQ -1) THEN interval_ind = [interval_ind, gap_ind[i]]
ENDFOR

interval_ind = interval_ind(SORT(interval_ind))
num_int = N_ELEMENTS(interval_ind)

index_int = LONARR(3, num_int)
FOR i = 0, (num_int - 1) DO BEGIN
   IF (i NE (num_int - 1)) THEN BEGIN
   	first = interval_ind[i]
   	last = interval_ind[i+1] - 1
   ENDIF ELSE BEGIN
   	first = interval_ind[i]
   	last = bins - 1
   ENDELSE
   gap_find = WHERE( gap_ind EQ (last + 1) )
   IF (gap_find[0] EQ -1) THEN BEGIN
   	gap_flag = -1
   ENDIF ELSE BEGIN
	gap_flag = 1
   ENDELSE
	
   index_int[0,i] = first
   index_int[1,i] = last
   index_int[2,i] = gap_flag
ENDFOR


; Plot each interval.

FOR i = 0, (num_int - 1) DO BEGIN

   start = index_int[0,i]
   stop = index_int[1,i]
   have_gap = index_int[2,i]

   xx = REFORM( x[0,start:stop] ) + (xres[start:stop]/2.)
   yy = y[start:stop]

   OPLOT, xx, yy, psym = 10, thick = thick, linestyle = linestyle


   ; Plot last half of endpoint bins for each interval

   x1a = x[0,start]
   x1b = x[0,start] + (xres[start]/2.)
   x2a = x[0,stop] + (xres[stop]/2.)
   x2b = x[1,stop] 
   y1 = y[start]
   y2 = y[stop]

   OPLOT, [x1a, x1b], [y1, y1], thick = thick, linestyle = linestyle
   OPLOT, [x2a, x2b], [y2, y2], thick = thick, linestyle = linestyle


   ; Connect intervals if no gap exists

   IF ((have_gap EQ -1) AND (stop LT bins - 1)) THEN BEGIN

	x3 = x[1,stop]
	y3a = y[stop]
	y3b = y[stop + 1]

	OPLOT, [x3, x3], [y3a, y3b], thick = thick, linestyle = linestyle

   ENDIF

ENDFOR


END
