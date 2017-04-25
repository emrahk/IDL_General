	PRO LABEL_SYMBOL,X0,Y0,PSYM,LABEL,LEFT=LEFT,COLOR=COLOR,	$
		CHARSIZE=CHAR_SIZE,SYMSIZE=SYMSIZE
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	LABEL_SYMBOL
; Purpose     :	
;	Plots a symbol with a label next to it on a graph.
; Explanation :	
;	A plotting symbol is drawn on the plot, and then the procedure XYOUTS
;	is called to write out the label.
; Use         :	
;	LABEL_SYMBOL, X0, Y0, PSYM, LABEL
; Inputs      :	
;	X0, Y0	 = Position of the symbol.
;	PSYM	 = Plotting symbol to use.
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
;	COLOR	 = Color to use in drawing the label and the symbol.
;	CHARSIZE = Character size to use in drawing the label.
;	SYMSIZE	 = Symbol size.
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
;		Brought label closer to symbol.
; Version     :	
;	Version 2, 20 October 1993.
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) NE 4 THEN BEGIN
		PRINT,'*** LABEL_SYMBOL must be called with four parameters:'
		PRINT,'                  X0, Y0, PSYM, LABEL'
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
	DEV = CONVERT_COORD(X0,Y0,/DATA,/TO_DEVICE)
	XX0 = DEV(0)
	YY0 = DEV(1)
;
;  Calculate the distance to offset the label.
;
	XX1 = !D.X_CH_SIZE * CHARSIZE
	YY1 = !D.Y_CH_SIZE * CHARSIZE
	IF KEYWORD_SET(LEFT) THEN XX1 = -XX1
	XX1 = XX0 + XX1
	YY1 = YY0 - YY1/3
;
;  Draw the symbol and label it.
;
	COMMAND1 = 'OPLOT,[X0,X0],[Y0,Y0],PSYM=PSYM'
	COMMAND2 = 'XYOUTS,XX1,YY1,LABEL,CHARSIZE=CHARSIZE,' +	$
		'ALIGNMENT=KEYWORD_SET(LEFT),/DEVICE'
	IF N_ELEMENTS(COLOR) EQ 1 THEN BEGIN
		COMMAND1 = COMMAND1 + ',COLOR=COLOR'
		COMMAND2 = COMMAND2 + ',COLOR=COLOR'
	ENDIF
	IF N_ELEMENTS(SYMSIZE) EQ 1 THEN	$
		COMMAND1 = COMMAND1 + ',SYMSIZE=SYMSIZE'
	TEST = EXECUTE(COMMAND1)
	TEST = EXECUTE(COMMAND2)
;
	RETURN
	END
