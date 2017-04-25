	PRO PLOT_ERR, X, Y, XERR=XERR, YERR=YERR, PSYM=PSYM, COLOR=COLOR, $
		BCOLOR=BCOLOR, LINESTYLE=LINESTYLE, THICK=THICK,	$
		SYMSIZE=SYMSIZE, UTPLOT=UTPLOT, _EXTRA=_EXTRA
;+
; Project     :	SOHO - CDS
;
; Name        :	PLOT_ERR
;
; Purpose     :	Plot data with error bars in both X and Y directions
;
; Explanation :	Plots data points with accompanying error bars in both the X
;		and Y directions.
;
;		A plot of X versus Y with error bars drawn from X-XERR to
;		X+XERR and from Y-YERR to Y+YERR is written to the output
;		device.  Optionally, one can give different sizes for the lower
;		and upper error bars.
;
;		If !BCOLOR is not zero, then that color is used for error bars.
;
; Use         :	PLOT_ERR, [ X, ]  Y  [, XERR=XERR]  [, YERR=YERR]
;
; Inputs      :	Y = array of Y values.
;
; Opt. Inputs :	X = array of X values.  If not passed, then the index of Y is
;		    used instead.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	XERR	  = Array of errors in X
;		YERR	  = array of errors in Y.
;
;		The error arrays can take one of two forms:
;
;		    * Same dimensions as the data arrays, in which case the
;		      error is applied in both the X and Y directions
;
;		    * An extra initial dimension of 2, in which case the
;		      first value is the size of the lower (or left) error bar,
;		      and the second value is the size of the upper (or right)
;		      error bar.
;
;		PSYM	  = Symbol to use for plotting.  Default is 7 (X).
;		SYMSIZE   = Symbol size
;		COLOR	  = Color to use for plotting.
;		BCOLOR	  = Color to use instead of !BCOLOR for error bars.
;		LINESTYLE = Line style
;		THICK	  = Line thickness
;		UTPLOT	  = If set, then the first (X) parameter is considered
;			    to be time in one of the CDS time formats.  This is
;			    only allowed if both X and Y are passed.  If used,
;			    then XERR is in seconds.
;
;		Also, most PLOT keywords are supported.
;
; Calls       :	DATATYPE, UTPLOT, OUTPLOT
;
; Common      :	None.
;
; Restrictions:	Requires that the system parameter !BCOLOR be defined.
;
; Side effects:	None.
;
; Category    :	Utilities, Plotting
;
; Prev. Hist. :	Based on an earlier routine called PLOTERR2.
;
; Written     :	William Thompson, GSFC, 19 April 1995
;
; Modified    :	Version 1, William Thompson, 19 April 1995
;		Version 2, William Thompson, GSFC, 20 April 1995
;			Added keyword UTPLOT.
;			Made determination of symmetrical/asymmetrical error
;			bars more robust.
;               Version 3 CDP, 30-Nov-95
;                       Cut linestyle from plot call so keyword is acted upon
;		Version 4, William Thompson, GSFC, 18 December 2002
;			Changed !COLOR to !P.COLOR
;
; Version     :	Version 4, 18 December 2002
;-
;
	ON_ERROR,2
;
;  Save the affected system parameters.
;
	PTHICK     = !P.THICK
	PLINESTYLE = !P.LINESTYLE
;
;  Check the number of parameters.
;
	IF N_PARAMS() EQ 0 THEN MESSAGE,	$
		'Syntax:  PLOT_ERR,  [ X, ]  Y  [, XERR=XERR]  [, YERR=YERR]'
;
;  Interpret the input parameters.  If X is passed as a time variable, then
;  convert it to a TAI time in seconds.
;
	PLOT_AS_TIME = 0
	IF N_PARAMS() EQ 1 THEN BEGIN
		XX = FINDGEN(N_ELEMENTS(X))
		YY = X
	END ELSE IF KEYWORD_SET(UTPLOT) THEN BEGIN
		IF DATATYPE(X,1) EQ 'Double' THEN X = XX ELSE XX = UTC2TAI(X)
		YY = Y
		PLOT_AS_TIME = 1
	END ELSE BEGIN
		XX = X
		YY = Y
	ENDELSE
;
;  Interpret the XERR and YERR keyword parameters.
;
	SZX = SIZE(XX)  &  SZXERR = SIZE(XERR)
	SZY = SIZE(YY)  &  SZYERR = SIZE(YERR)
;
	IF N_ELEMENTS(XERR) EQ 0 THEN BEGIN		;XERR not passed
		XLEFT  = XX
		XRIGHT = XX
	END ELSE IF (SZXERR(0) EQ SZX(0)) OR (SZXERR(1) NE 2) THEN BEGIN
		XLEFT  = XX-ABS(XERR)			;Symmetrical errors
		XRIGHT = XX+ABS(XERR)
	END ELSE BEGIN					;Asymmetrical errors
		XLEFT  = XX-ABS(XERR(0,*))
		XRIGHT = XX+ABS(XERR(1,*))
	ENDELSE
;
	IF N_ELEMENTS(YERR) EQ 0 THEN BEGIN		;YERR not passed
		YBOTTOM = YY
		YTOP    = YY
	END ELSE IF (SZXERR(0) EQ SZX(0)) OR (SZXERR(1) NE 2) THEN BEGIN
		YBOTTOM = YY-ABS(YERR)			;Symmetrical errors
		YTOP    = YY+ABS(YERR)
	END ELSE BEGIN					;Asymmetrical errors
		YBOTTOM = YY-ABS(YERR(0,*))
		YTOP    = YY+ABS(YERR(1,*))
	ENDELSE
;
;  Determine the total number of points to plot.
;
	N = N_ELEMENTS(XLEFT) < N_ELEMENTS(YBOTTOM)
	IF N LT 2 THEN MESSAGE, 'Not enough points to plot'
;
	XX      = XX(0:N-1)
	YY      = YY(0:N-1)
	XLEFT   = XLEFT(0:N-1)
	XRIGHT  = XRIGHT(0:N-1)
	YBOTTOM = YBOTTOM(0:N-1)
	YTOP    = YTOP(0:N-1)
;
;  Interpret the keyword parameters
;
	IF N_ELEMENTS(PSYM) NE 1 THEN PSYM_SEL = 7 ELSE	PSYM_SEL = PSYM
	IF N_ELEMENTS(SYMSIZE) NE 1 THEN SYMSIZE_SEL = !P.SYMSIZE ELSE	$
		SYMSIZE_SEL = SYMSIZE
	IF N_ELEMENTS(COLOR) NE 1 THEN COLOR_SEL = !P.COLOR ELSE	$
		COLOR_SEL = COLOR
	IF N_ELEMENTS(BCOLOR) EQ 1 THEN BCOLOR_SEL = BCOLOR ELSE	$
		IF !BCOLOR NE 0 THEN BCOLOR_SEL = !BCOLOR ELSE		$
		BCOLOR_SEL = COLOR_SEL
	IF N_ELEMENTS(LINESTYLE) EQ 1 THEN !P.LINESTYLE = LINESTYLE
	IF N_ELEMENTS(THICK) EQ 1 THEN !P.THICK = THICK
;
;  Determine the X and Y limits if not already set.
;
	XMIN = MIN(XLEFT)
	XMAX = MAX(XRIGHT)
	YMIN = MIN(YBOTTOM)
	YMAX = MAX(YTOP)
;
;  If doing a time plot, then convert the time parameters to CDS internal time
;  format.
;
	IF PLOT_AS_TIME THEN BEGIN
		XX     = TAI2UTC(XX)
		XLEFT  = TAI2UTC(XLEFT)
		XRIGHT = TAI2UTC(XRIGHT)
		XMIN   = TAI2UTC(XMIN)
		XMAX   = TAI2UTC(XMAX)
	ENDIF
;
;  Make the plot frame.
;
	IF PLOT_AS_TIME THEN BEGIN
		UTPLOT, [XMIN,XMAX], [YMIN,YMAX], COLOR=COLOR_SEL, /NODATA, $
			_EXTRA=_EXTRA
	END ELSE BEGIN
		PLOT, [XMIN,XMAX], [YMIN,YMAX], COLOR=COLOR_SEL, /NODATA, $
			_EXTRA=_EXTRA
	ENDELSE
;
;  Plot the X error bars.
;
	FOR I = 0,N-1 DO BEGIN
		XXX = [XLEFT(I),XRIGHT(I)]
		YYY = [YY(I),YY(I)]
		IF PLOT_AS_TIME THEN BEGIN
			OUTPLOT,XXX,YYY,PSYM=0,COLOR=BCOLOR_SEL
		END ELSE BEGIN
			OPLOT,XXX,YYY,PSYM=0,COLOR=BCOLOR_SEL
		ENDELSE
	ENDFOR
;
;  Plot the Y error bars.
;
	FOR I = 0,N-1 DO BEGIN
		XXX = [XX(I),XX(I)]
		YYY = [YBOTTOM(I),YTOP(I)]
		IF PLOT_AS_TIME THEN BEGIN
			OUTPLOT,XXX,YYY,PSYM=0,COLOR=BCOLOR_SEL
		END ELSE BEGIN
			OPLOT,XXX,YYY,PSYM=0,COLOR=BCOLOR_SEL
		ENDELSE
	ENDFOR
;
;  Overplot the data points on top of the error bars.
;
	IF PLOT_AS_TIME THEN BEGIN
		OUTPLOT,XX,YY,PSYM=PSYM_SEL,SYMSIZE=SYMSIZE_SEL,COLOR=COLOR_SEL
	END ELSE BEGIN
		OPLOT,XX,YY,PSYM=PSYM_SEL,SYMSIZE=SYMSIZE_SEL,COLOR=COLOR_SEL
	ENDELSE
;
;  Return the system parameters to their original values.
;
	!P.THICK     = PTHICK
	!P.LINESTYLE = PLINESTYLE
;
	RETURN
	END
