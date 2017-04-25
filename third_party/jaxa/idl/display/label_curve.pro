	PRO LABEL_CURVE,X0,Y0,X_1,Y_1,XVALS,YVALS,LABEL,LEFT=LEFT, $
		COLOR=COLOR,CHARSIZE=CHAR_SIZE
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	LABEL_CURVE
; Purpose     :	
;	Plots a label with a line from it to a curve.
; Explanation :	
;	Puts a label on a graph, and draws a line between the label and a
;	curve.  A line is extrapolated between the point X0, Y0, and the curve
;	XVALS, YVALS.  The procedure XYOUTS is then called to write out the
;	label.
; Use         :	
;	LABEL_CURVE, X0, Y0, X1, Y1, XVALS, YVALS, LABEL
;
;	X = FINDGEN(101)/100					;Generate curve
;	Y = SQRT(X)
;	PLOT, X, Y						;Plot it.
;	LABEL_CURVE, 0.5, 0.5, 0, 1, X, Y, "Sample curve"	;And label it.
;
; Inputs      :	
;	X0, Y0	 = Position of the label.  The line from the label to the curve
;		   starts here.
;	X1, Y1	 = Another point along the line, used to determine the
;		   direction of the line drawn from the label to the curve.
;		   This point may or may not end up on the actual line drawn.
;	XVALS	 = Array of X-values of points on the curve.
;	YVALS	 = Array of Y-values of points on the curve.
;	LABEL	 = Character string label.
; Opt. Inputs :	
;	None.
; Outputs     :	
;	None.
; Opt. Outputs:	
;	None.
; Keywords    :	
;	LEFT	 = If set, then the label will be displayed to the left of the
;		   point X0, Y0.  Normally the label is displayed to the right.
;	COLOR	 = Color to use in drawing the label and the line.
;	CHARSIZE = Character size to use in drawing the label.
; Calls       :	
;	None.
; Common      :	
;	None.
; Restrictions:	
;	None.
; Side effects:	
;	None.
; Category    :	
;	Utilities, Graphics.
; Prev. Hist. :	
;	William Thompson, June 1991.  Added keywords LEFT, COLOR, CHARSIZE.
;	W.T.T., Jan 1992, changed calling parameters so that X1, Y1 are passed
;			  instead of SLOPE.  Also, put small offset between
;			  label and line.
;	William Thompson, Nov 1992, modified algorithm for getting the relative
;		character size.
; Written     :	
;	William Thompson, GSFC.
; Modified    :	
;	Version 1, William Thompson, 9 June 1993.
;		Incorporated into CDS library.
;		Added call to CONVERT_COORD so as to be compatible with
;			logarithmic plots.
;	Version 2, William Thompson, GSFC, 20 October 1993.
;		Brought label closer to curve.
; Version     :	
;	Version 2, 20 October 1993.
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) NE 7 THEN BEGIN
		PRINT,'*** LABEL_CURVE must be called with seven parameters:'
		PRINT,'           X0, Y0, X1, Y1, XVALS, YVALS, LABEL'
		RETURN
	ENDIF
;
;  Make sure that both XVALS and YVALS are arrays.
;
	N = N_ELEMENTS(XVALS) < N_ELEMENTS(YVALS)
	IF N LT 2 THEN BEGIN
		PRINT,'*** Data curve XVALS,YVALS not long enough, routine LABEL_CURVE.'
		RETURN
	ENDIF
;
;  Calculate the slope from the two points.
;
	IF X0 EQ X_1 THEN BEGIN
		INF_SLOPE = 1
	END ELSE BEGIN
		INF_SLOPE = 0
		SLOPE = (Y_1 - Y0) / DOUBLE(X_1 - X0)
	ENDELSE
;
;  Find the point where the line drawn from X0, Y0 intercepts the curve XVALS,
;  YVALS.  Start by stepping through each pair of consecutive points in the
;  curve.
;
	I = 0
NEXT:
	I = I + 1
	IF I EQ N THEN GOTO,DONE
	XX0 = DOUBLE(XVALS(I-1))
	XX1 = DOUBLE(XVALS(I))
	YY0 = DOUBLE(YVALS(I-1))
	YY1 = DOUBLE(YVALS(I))
;
	IF XX0 EQ XX1 THEN BEGIN
		X1 = XX0
	END ELSE BEGIN
		A0 = (XX1*YY0 - XX0*YY1) / (XX1 - XX0)
		A1 = (YY1 - YY0) / (XX1 - XX0)
		IF INF_SLOPE THEN X1 = X0 ELSE	$
			X1 = (A0 - Y0 + SLOPE*X0) / (SLOPE - A1)
	ENDELSE
;
	IF INF_SLOPE THEN BEGIN
		IF XX0 EQ XX1 THEN BEGIN
			Y1 = YY0
		END ELSE BEGIN
			Y1 = YY0 + (YY1 - YY0) * (X1 - XX0) / (XX1 - XX0)
		ENDELSE
	END ELSE BEGIN
		Y1 = Y0 + SLOPE*(X1 - X0)
	ENDELSE
;
;  Check to see if the calculated point of intersection actually falls between
;  the two points in the curve being considered.
;
	IF XX0 GT XX1 THEN BEGIN
		TEMP = XX0
		XX0  = XX1
		XX1  = TEMP
	ENDIF
	IF YY0 GT YY1 THEN BEGIN
		TEMP = YY0
		YY0  = YY1
		YY1  = TEMP
	ENDIF
	IF ((X1 LT XX0) OR (X1 GT XX1) OR (Y1 LT YY0) OR (Y1 GT YY1))	$
		THEN GOTO,NEXT
;
;  Get the relative character size.
;
DONE:
	IF N_ELEMENTS(CHAR_SIZE) EQ 1 THEN CHARSIZE = CHAR_SIZE	$
		ELSE CHARSIZE = !P.CHARSIZE
	IF CHARSIZE LE 0 THEN CHARSIZE = 1
;
;  Convert from data to device coordinates.
;
	DEV = CONVERT_COORD(X0,Y0,/DATA,/TO_DEVICE)
	XX0 = DEV(0)
	YY0 = DEV(1)
;
;  Calculate the distance to offset the label.
;
	XX2 = !D.X_CH_SIZE * CHARSIZE
	YY2 = !D.Y_CH_SIZE * CHARSIZE
	IF KEYWORD_SET(LEFT) THEN XX2 = -XX2
	XX2 = XX0 + XX2
	YY2 = YY0 - YY2/3
;
;  Draw the line and label it.
;
	COMMAND1 = 'OPLOT,[X0,X1],[Y0,Y1]'
	COMMAND2 = 'XYOUTS,XX2,YY2,LABEL,ALIGNMENT=KEYWORD_SET(LEFT),/DEVICE'
	IF N_ELEMENTS(COLOR) EQ 1 THEN BEGIN
		COMMAND1 = COMMAND1 + ',COLOR=COLOR'
		COMMAND2 = COMMAND2 + ',COLOR=COLOR'
	ENDIF
	IF N_ELEMENTS(CHARSIZE) EQ 1 THEN	$
		COMMAND2 = COMMAND2 + ',CHARSIZE=CHARSIZE'
	TEST = EXECUTE(COMMAND1)
	TEST = EXECUTE(COMMAND2)
;
	RETURN
	END
