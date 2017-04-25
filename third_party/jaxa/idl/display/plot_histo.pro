	PRO PLOT_HISTO,ARRAY,STEPS,HISTO,XLOG=XLOG,YLOG=YLOG,DELTA=DELTA, $
		BCOLOR=BCOLOR,MISSING=MISSING,_EXTRA=_EXTRA
;+
; Project     :	SOHO - CDS
;
; Name        :	PLOT_HISTO
;
; Purpose     :	Plots a histogram from the variable ARRAY.
;
; Category    :	Class3, Graphics
;
; Explanation :	Plots a histogram from the variable ARRAY.  Calls FORM_HISTO to
;		decide what the coarseness of the histogram should be.  Then
;		PLOTBAR is called to plot the histogram.
;
; Syntax      :	PLOT_HISTO, ARRAY  [, STEPS, HISTO ]
;
; Examples    :	PLOT_HISTO, ARRAY
;
; Inputs      :	ARRAY	= Array to plot histogram of.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	STEPS	= Values at which histogram is taken.  Each value
;			  represents histogram between STEP(I) and STEP(I+1).
;		HISTO	= Histogram values.
;
; Keywords    :	DELTA	= Distance between histogram steps.  If not passed,
;			  then FORM_HISTO chooses a suitable value.
;		XLOG	= If set, then X axis is logarithmic.
;		YLOG	= If set, then Y axis is logarithmic.
;		BCOLOR	= Color to use instead of !BCOLOR for bar interiors.
;               MISSING = Value flagging missing pixels.  Missing pixels can
;                         also be flagged as Not-A-Number.
;
; Calls       :	FORM_HISTO, PLOTBAR
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	
;	William Thompson	Applied Research Corporation
;	September, 1987		8201 Corporate Drive
;				Landover, MD  20785
;
;	William Thompson, December 1991, added keywords XTYPE and YTYPE.
;	William Thompson, May 1992, added keywords XRANGE and YRANGE.
;
; History     :	Version 1, 22-Jan-1996, William Thompson, GSFC
;			Incorporated into CDS library
;		Version 2, 22-May-2000, William Thompson, GSFC
;			Replaced several keywords with _EXTRA mechanism.
;			Renamed XTYPE, YTYPE with more modern XLOG, YLOG
;			Corrected handling of logarithmic axes.
;               Version 3, 19-Jun-2006, William Thompson, GSFC
;                       Added keyword MISSING.  Use FORM_HISTO,ERRMSG=...
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
;
;  Check the input parameters.
;
	IF N_PARAMS(0) EQ 0 THEN BEGIN
	    MESSAGE = 'Syntax:  PLOT_HISTO, ARRAY  [, STEPS, HISTO ]'
	    GOTO, HANDLE_ERROR
	ENDIF
;
;  Call FORM_HISTO to form the histogram, and PLOTBAR to plot it.
;
        MESSAGE = ''
	FORM_HISTO,ARRAY,STEPS,HISTO,DELTA=DELTA,MISSING=MISSING,ERRMSG=MESSAGE
        IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
	IF KEYWORD_SET(YLOG) THEN YY = HISTO > 0.1 ELSE YY = HISTO
	PLOTBAR,STEPS,YY,XLOG=XLOG,YLOG=YLOG,BCOLOR=BCOLOR,_EXTRA=_EXTRA
	RETURN
;
;  Error handling point.
;
HANDLE_ERROR:
	MESSAGE, MESSAGE, /CONTINUE
	RETURN
	END
