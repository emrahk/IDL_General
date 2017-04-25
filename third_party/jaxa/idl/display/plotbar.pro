	PRO PLOTBAR, X, Y, BCOLOR=BCOLOR, XLOG=XLOG, YLOG=YLOG,		$
		XRANGE=XRANGE, XSTYLE=K_XSTYLE,				$
		YRANGE=YRANGE, YSTYLE=K_YSTYLE, _EXTRA=_EXTRA
;+
; Project     :	SOHO - CDS
;
; Name        :	PLOTBAR
;
; Purpose     :	Plot a bar graph filled in with a pattern.
;
; Category    :	Class3, Graphics
;
; Explanation :	
;
; Syntax      :	PLOTBAR, [ X ,]  Y
;
; Examples    :	
;
; Inputs      :	Y = array of values along the Y axis.
;
; Opt. Inputs :	X = optional array of values along the X axis.  Y(i) is plotted
;		    from X(i) to X(i+1), with the last point being plotted over
;		    a distance equal to its predecessor.  The procedure tests
;		    whether or not the second parameter passed is a vector to
;		    decide if X was passed.  If not passed, then INDGEN(Y) is
;		    assumed.
;
;		If !BCOLOR is nonzero, then it controls the color of the filled
;		in region.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	XLOG	= If set, then X axis is logarithmic.
;		YLOG	= If set, then Y axis is logarithmic.
;		BCOLOR	= Color to use instead of !BCOLOR for bar interiors.
;		Any other normal plotting keywords can also be used.
;
; Calls       :	POLYFILL
;
; Common      :	None.
;
; Restrictions:	The variables must not be of type string.
;
; Side effects:	None.
;
; Prev. Hist. :	
;	William Thompson	Applied Research Corporation
;	July, 1986		8201 Corporate Drive
;				Landover, MD  20785
;
;	William Thompson, December 1991, added keywords XTYPE and YTYPE.
;	W.T.T., May 1992, added BCOLOR keyword.
;	William Thompson, May 1992, added keywords XRANGE and YRANGE.
;	William Thompson, November 1992, modified to be compatible with
;		!P.MULTI.
;	William Thompson, January 1993, modified to use modern system parameter
;		names.
;	William Thompson, 30 April 1993, fixed bug with !P.MULTI.
;
; History     :	Version 1, 22-Jan-1996, William Thompson, GSFC
;			Incorporated into CDS library
;		Version 2, 22-May-2000, William Thompson, GSFC
;			Replaced several keywords with _EXTRA mechanism.
;			Renamed XTYPE, YTYPE with more modern XLOG, YLOG
;			Corrected handling of logarithmic axes.
;		Version 3, 30-Nov-2000, William Thompson, GSFC
;			Improved handling of logarithmic axes.
;		Version 4, 26-Apr-2001, William Thompson, GSFC
;			Corrected occasional problem with tickmarks
;		Version 5, 18-Dec-2002, William Thompson, GSFC
;			Corrected obsolete system variables !COLOR and !NOERAS
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
;
	IF N_PARAMS(0) EQ 1 THEN BEGIN			;Only Y array passed.
		XX = FINDGEN(N_ELEMENTS(X))
		YY = X
	END ELSE IF N_PARAMS(0) EQ 2 THEN BEGIN
		XX = X
		YY = Y
	END ELSE BEGIN
		PRINT,'*** PLOTBAR must be called with 1-2 parameters:'
		PRINT,'                   [ X ,]  Y'
		RETURN
	ENDELSE
;
	M = N_ELEMENTS(XX) < N_ELEMENTS(YY)
	IF M LE 1 THEN BEGIN
		PRINT,'*** Not enough points to plot, routine PLOTBAR.'
		RETURN
	ENDIF
;
;  Generate the arrays used in plotting.  Fill in X array so that last
;  bar has same width as previous one.
;
	I = FINDGEN(2*M)/2
	X_LAST = 2*XX(M-1) - XX(M-2)
	XX = [XX(I),X_LAST,X_LAST]
	IF KEYWORD_SET(YLOG) THEN BEGIN
	    Y0 = MIN(YY)
	    IF N_ELEMENTS(YSTYLE) EQ 1 THEN	$
		    IF NOT (YSTYLE AND 1) THEN Y0 = 0.9*Y0
	END ELSE Y0 = 0
	YY = [Y0,YY(I),Y0]
;
;  Do the initial plot, keeping track of the setting of !P.MULTI.
;
	PMULTI = !P.MULTI
	COMMAND = "PLOT,XX,YY,PSYM=0,/NODATA,LINESTYLE=0,_EXTRA=_EXTRA"
	COMMAND = COMMAND + ',XSTYLE=XSTYLE,YSTYLE=YSTYLE'
	XSTYLE = 4
	YSTYLE = 4
	IF N_ELEMENTS(K_XSTYLE) EQ 1 THEN XSTYLE = XSTYLE AND K_XSTYLE
	IF N_ELEMENTS(K_YSTYLE) EQ 1 THEN YSTYLE = YSTYLE AND K_YSTYLE
	IF N_ELEMENTS(XLOG)   EQ 1 THEN COMMAND = COMMAND + ",XLOG=XLOG"
	IF N_ELEMENTS(YLOG)   EQ 1 THEN COMMAND = COMMAND + ",YLOG=YLOG"
	IF N_ELEMENTS(XRANGE) EQ 1 THEN COMMAND = COMMAND + ",XRANGE=XRANGE"
	IF N_ELEMENTS(YRANGE) EQ 1 THEN COMMAND = COMMAND + ",YRANGE=YRANGE"
	TEST = EXECUTE(COMMAND)
;
;  For logarithmic Y, reset Y0 to be the floor of the plot.
;
	IF KEYWORD_SET(YLOG) THEN BEGIN
	    Y0 = 10.^!Y.CRANGE(0)
	    YY(0) = Y0
	    YY(N_ELEMENTS(YY)-1) = Y0
	ENDIF
;
	XMIN = !X.CRANGE(0)
	XMAX = !X.CRANGE(1)
	IF KEYWORD_SET(XLOG) THEN BEGIN
	    XMIN = 10.^XMIN
	    XMAX = 10.^XMAX
	ENDIF
	XX = XMIN > XX < XMAX
	YMIN = !Y.CRANGE(0)
	YMAX = !Y.CRANGE(1)
	IF KEYWORD_SET(YLOG) THEN BEGIN
	    YMIN = 10.^YMIN
	    YMAX = 10.^YMAX
	ENDIF
	YY = YMIN > YY < YMAX
	IF N_ELEMENTS(BCOLOR) NE 1 THEN BCOLOR = !BCOLOR
	IF BCOLOR EQ 0 THEN COLOR=!P.COLOR ELSE COLOR=BCOLOR
;
;  Fill in histogram and overplot boundary to restore color.
;
	POLYFILL,XX,YY,/DATA,COLOR=COLOR
	NOERAS = !P.NOERASE
	!P.MULTI = PMULTI
;
	XCRANGE = !X.CRANGE
	YCRANGE = !Y.CRANGE
	IF KEYWORD_SET(XLOG) THEN XCRANGE = 10.^XCRANGE
	IF KEYWORD_SET(YLOG) THEN YCRANGE = 10.^YCRANGE
	COMMAND = "PLOT,XX,YY,PSYM=0,LINESTYLE=0,/NOERASE,XTITLE=''," + $
		"YTITLE='',TITLE='',YSTYLE=1,_EXTRA=_EXTRA," +	$
		"XRANGE=XCRANGE,XSTYLE=1,YRANGE=YCRANGE"
	IF N_ELEMENTS(XLOG)  EQ 1 THEN COMMAND = COMMAND + ",XLOG=XLOG"
	IF N_ELEMENTS(YLOG)  EQ 1 THEN COMMAND = COMMAND + ",YLOG=YLOG"
	TEST = EXECUTE(COMMAND)
;
;  Modify !P.MULTI.  Normally, this would happen automatically, but this has
;  been disabled for this routine.
;
	K = !P.MULTI(0)
	NX = !P.MULTI(1) > 1
	NY = !P.MULTI(2) > 1
	IF (K LE 0) OR (K GT NX*NY) THEN K = NX*NY
	!P.MULTI(0) = (K - 1) MOD (NX*NY)
;
	OPLOT,[XMIN,XMAX],[Y0,Y0]			;Plot zero line.
;
	RETURN
	END
