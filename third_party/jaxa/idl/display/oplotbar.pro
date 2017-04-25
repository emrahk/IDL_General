	PRO OPLOTBAR,X,Y,BCOLOR=BCOLOR
;+
; Project     :	SOHO - CDS
;
; Name        :	OPLOTBAR
;
; Purpose     :	Overplot a bar graph filled in with a pattern.
;
; Category    :	Class3, Graphics
;
; Explanation :	
;
; Syntax      :	OPLOTBAR, [ X ,]  Y
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
; Keywords    :	BCOLOR	= Color to use instead of !BCOLOR for bar interiors.
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
;	W.T.T., May 1992, added BCOLOR keyword.
;
; History     :	Version 1, 22-Jan-1996, William Thompson, GSFC
;			Incorporated into CDS library
;		Version 2, 14-May-2001, William Thompson, GSFC
;			Use modern system variables.
;		Version 3, 18-Dec-2002, William Thompson, GSFC
;			Changed !COLOR to !P.COLOR
;
; Contact     :	WTHOMPSON
;-
;
	ON_ERROR,2
;
	IF N_PARAMS(0) EQ 1 THEN BEGIN			;Only Y is passed.
		XX = FINDGEN(N_ELEMENTS(X))
		YY = X
	END ELSE IF N_PARAMS(0) EQ 2 THEN BEGIN
		XX = X
		YY = Y
	END ELSE BEGIN
		PRINT,'*** OPLOTBAR must be called with 1-2 parameters:'
		PRINT,'                    [ X ,]  Y'
		RETURN
	ENDELSE
;
	M = N_ELEMENTS(XX) < N_ELEMENTS(YY)
	IF M LE 1 THEN BEGIN
		PRINT,'*** Not enough points to plot, routine OPLOTBAR.'
		RETURN
	ENDIF
;
;  Generate the arrays used in plotting.  Fill in X array so that last
;  bar has same width as previous one.
;
	I = FINDGEN(2*M)/2
	X_LAST = XX(M-1) + ( XX(M-1) - XX(M-2) )
	XX = !X.CRANGE(0) > [XX(I),X_LAST,X_LAST] < !X.CRANGE(1)
	YY = !Y.CRANGE(0) > [0,YY(I),0] < !Y.CRANGE(1)
;
	IF N_ELEMENTS(BCOLOR) NE 1 THEN BCOLOR = !BCOLOR
	IF BCOLOR EQ 0 THEN COLOR = !P.COLOR ELSE COLOR = BCOLOR
	IF !D.NAME NE 'TEK' THEN BEGIN
		POLYFILL,XX,YY,/DATA,COLOR=COLOR	;Fill in histogram.
		OPLOT,XX,YY,PSYM=0,LINESTYLE=0		;Plot boundary
	ENDIF
	OPLOT, !X.CRANGE, [0,0], PSYM=0, LINESTYLE=0	;Plot zero line.
;
	RETURN
	END
