	PRO LABEL_LINE,X0,X1,Y0,LABEL,PSYM=PSYM,LEFT=LEFT,COLOR=COLOR,	$
		CHARSIZE=CHAR_SIZE,SYMSIZE=SYMSIZE,LINESTYLE=LINESTYLE,	$
		THICK=THICK,CHARTHICK=CHARTHICK
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	LABEL_LINE
; Purpose     :	
;	Plots a horizontal line (w/ or w/o symbols) with a label.
; Explanation :	
;	Plots a horizontal line (with or without symbols) with a label next to
;	it on a graph.
; Use         :	
;	LABEL_LINE, X0, Y0, PSYM, LABEL
; Inputs      :	
;	X0, X1	  = X-range of the horizontal line.
;	Y0	  = Y-height of the line.
;	LABEL	  = Character string label.
; Opt. Inputs :	
;	None.
; Outputs     :	
;	None.
; Opt. Outputs:	
;	None.
; Keywords    :	
;	PSYM	  = Plotting symbol to use.  Note that actual lines are drawn
;		    only if PSYM is zero or negative.  Positive values of PSYM
;		    only cause two plotting symbols to be drawn.
;	LINESTYLE = Line style to use.
;	LEFT	  = If set, then the label will be displayed to the left of the
;		    line.  Normally the label is displayed to the right.
;	COLOR	  = Color to use in drawing the label and the symbol.
;	THICK	  = Thickness to use in drawing the symbol.
;	CHARSIZE  = Character size to use in drawing the label.
;	CHARTHICK = Character thickness to use in drawing the label
;	SYMSIZE	  = Symbol size.
; Calls       :	
;	None.
; Common      :	
;	None.
; Restrictions:	
;	None.
; Side effects:	
;	None.
; Category    :	
;	Utilities, graphics.
; Prev. Hist. :	
;	William Thompson, Jan 1992.
;	William Thompson, Nov 1992, modified algorithm for getting the relative
;		character size.
;	William Thompson, 6 July 1993, added call to CONVERT_COORD so as to be
;		compatible with logarithmic plots.
; Written     :	
;	William Thompson, GSFC, January 1992.
; Modified    :	
;	Version 1, William Thompson, GSFC, 9 July 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 20 October 1993.
;		Brought label closer to line.
;	Version 3, 22-Jan-1998, William Thompson, GSFC
;		Added keywords THICK and CHARTHICK
; Version     :	
;	Version 3, 22-Jan-1998
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) NE 4 THEN BEGIN
		PRINT,'*** LABEL_LINE must be called with four parameters:'
		PRINT,'                  X0, X1, Y0, LABEL'
		RETURN
	ENDIF
;
;  Get the relative character size.
;
	IF N_ELEMENTS(CHAR_SIZE) EQ 1 THEN CHARSIZE = CHAR_SIZE	$
		ELSE CHARSIZE = !P.CHARSIZE
	IF CHARSIZE LE 0 THEN CHARSIZE = 1
;
;  Convert from data to device coordinates.
;
	DEV = CONVERT_COORD([X0,X1],[Y0,Y0],/DATA,/TO_DEVICE)
	XX0 = DEV(0,0)
	XX1 = DEV(0,1)
	YY0 = DEV(1,0)
;
;  Calculate the distance to offset the label.
;
	XX2 = !D.X_CH_SIZE * CHARSIZE
	YY2 = !D.Y_CH_SIZE * CHARSIZE
	IF KEYWORD_SET(LEFT) THEN BEGIN
		XX2 = (XX0 < XX1) - XX2
	END ELSE BEGIN
		XX2 = (XX0 > XX1) + XX2
	ENDELSE
	YY2 = YY0 - YY2/3
;
;  Draw the symbol and label it.
;
	COMMAND1 = 'OPLOT,[X0,X1],[Y0,Y0]'
	COMMAND2 = 'XYOUTS,XX2,YY2,LABEL,CHARSIZE=CHARSIZE,' +	$
		'ALIGNMENT=KEYWORD_SET(LEFT),/DEVICE'
	IF N_ELEMENTS(COLOR) EQ 1 THEN BEGIN
		COMMAND1 = COMMAND1 + ',COLOR=COLOR'
		COMMAND2 = COMMAND2 + ',COLOR=COLOR'
	ENDIF
	IF N_ELEMENTS(PSYM) EQ 1 THEN COMMAND1 = COMMAND1 + ',PSYM=PSYM'
	IF N_ELEMENTS(LINESTYLE) EQ 1 THEN	$
		COMMAND1 = COMMAND1 + ',LINESTYLE=LINESTYLE'
	IF N_ELEMENTS(THICK) EQ 1 THEN COMMAND1 = COMMAND1 + ',THICK=THICK'
	IF N_ELEMENTS(CHARTHICK) EQ 1 THEN	$
		COMMAND2 = COMMAND2 + ',CHARTHICK=CHARTHICK'
	IF N_ELEMENTS(SYMSIZE) EQ 1 THEN	$
		COMMAND1 = COMMAND1 + ',SYMSIZE=SYMSIZE'
	TEST = EXECUTE(COMMAND1)
	TEST = EXECUTE(COMMAND2)
;
	RETURN
	END
