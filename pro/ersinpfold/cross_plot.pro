; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;
;	CROSS_PLOT.PRO	
;
; PURPOSE:
;
;	Creates crosshair plots for data to include bin widths and errors.
;	NOTE :  The plot outline must be created first.  This procedure 
;		only overplots on existing plot windows.	
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
;	CROSS_PLOT, x, y, err, thick = thick	
;
; INPUTS:
;
;	x	:  2 * N array of start and stop values for each bin
;	y 	:  N array of bin values       
;	err 	:  N array of bin value errors       
;
; KEYWORD PARAMETERS:
;
;	thick		:  determines thickness of plot lines (default = 2)
;	linestyle	:  determines linestyle of plot lines (default = 0)
;	err_only	:  plots error bars only and does not plot bin width
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
;	Written, Peter.Woods@msfc.nasa.gov
;		(205) 544-1803
;-
;******************************************************************************


PRO  CROSS_PLOT, x, y, err, thick = thick, linestyle = linestyle, $
	err_only = err_only, width_only = width_only
	

want_err_only = N_ELEMENTS(err_only) NE 0
want_width_only = N_ELEMENTS(width_only) NE 0

xsize = SIZE(x)
dimx = xsize[0]
num_columns = xsize[dimx-1]

IF (num_columns GT 2) THEN BEGIN
   PRINT, '   *******   ERROR   *******   '
   PRINT, 'Input x values for CROSS_PLOT.PRO are not in the correct format'
   PRINT, 'x array should be 2 * N (or one-dim if using /ERR_ONLY)'
   GOTO, exit
ENDIF

have_linestyle = N_ELEMENTS(linestyle) NE 0
IF have_linestyle THEN BEGIN
   linestyle = linestyle
ENDIF ELSE BEGIN
   linestyle = 0
ENDELSE

have_thick = N_ELEMENTS(thick) NE 0
IF have_thick THEN BEGIN
   thick = thick
ENDIF ELSE BEGIN
   thick = 2
ENDELSE

y = REFORM(y)
err = REFORM(err)
bins = N_ELEMENTS(y)


; Plot bin widths

IF NOT(want_err_only) THEN BEGIN

   FOR i = 0L, (bins - 1) DO BEGIN
   	h = y[i]
   	w1 = x[0,i]
   	w2 = x[1,i]
   	OPLOT, [w1,w2], [h,h], thick = thick, linestyle = linestyle
   ENDFOR

ENDIF


; Plot bin errors

IF NOT(want_width_only) THEN BEGIN

   FOR i = 0L, (bins - 1) DO BEGIN
   	h1 = y[i] + err[i]
   	h2 = y[i] - err[i]
   	IF (num_columns EQ 2) THEN BEGIN
	   w = (x[0,i] + x[1,i])/2.
	ENDIF ELSE BEGIN
	   w = x[i]
	ENDELSE
   	OPLOT, [w,w], [h1,h2], thick = thick, linestyle = linestyle
   ENDFOR

ENDIF


exit:


END
