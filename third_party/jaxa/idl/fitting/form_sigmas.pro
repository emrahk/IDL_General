	PRO FORM_SIGMAS, Y, SIG, SIG_SET, POISSON=POISSON, ERROR=ERR
;+
; Project     :	SOHO - CDS
;
; Name        :	FORM_SIGMAS
;
; Purpose     :	Forms denominator in function to be minimized.
;
; Explanation :	Called from fitting routines to form the denominator in the
;		argument of the function to be minimized (normally
;		chi-squared).
;
; Use         :	FORM_SIGMAS, Y, SIG  [, /POISSON ]  [, ERROR=ERR ]
;
; Inputs      :	Y	 = Data values.  Must always be present, but only used
;			   if the POISSON switch is set.
;
; Opt. Inputs :	None.
;
; Outputs     :	SIG	 = Array of sigmas to be used in evaluating the
;			   function to be minimized.
;
; Opt. Outputs:	SIG_SET	 = A logical switch signalling that a non-trivial SIG
;			   array was returned.
;
; Keywords    :	POISSON	 = If set, then a Poisson error distribution is
;			   assumed, and the sigmas are set accordingly to 1/Y.
;		ERROR	 = Array of errors.  The sigmas are set accordingly to
;			   ABS(ERROR).  Overrides POISSON.
;
; Calls       :	None.
;
; Common      :	None
;
; Restrictions:	If passed, ERROR must have the same number of elements as Y.
;		Alternately, ERROR can be passed as a scalar value, and all the
;		values of SIG returned will be the same.
;
; Side effects:	If nothing but Y is passed, then SIG is returned as an array of
;		ones.
;
; Category    :	Utilities, Curve_Fitting
;
; Prev. Hist. :	William Thompson, December, 1992.
;
; Written     :	William Thompson, GSFC, December 1992
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated into CDS library
;
; Version     :	Version 1, 9 January 1995
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) LT 2 THEN MESSAGE,	$
		'Syntax:  FORM_SIGMAS, Y, SIG  [, SIG_SET ]'
;
;  Calculate the array SIG.
;
	IF N_ELEMENTS(ERR) NE 0 THEN BEGIN
		IF N_ELEMENTS(ERR) EQ 1 THEN BEGIN
			SIG = REPLICATE(ABS(ERR), N_ELEMENTS(Y))
			SIG_SET = 1
		END ELSE IF N_ELEMENTS(ERR) EQ N_ELEMENTS(Y) THEN BEGIN
			SIG = ABS(ERR)
			SIG_SET = 1
		END ELSE MESSAGE,'Array ERR must have ' +	$
			TRIM(N_ELEMENTS(Y)) + ' elements'
	END ELSE IF KEYWORD_SET(POISSON) THEN BEGIN
		SIG = SQRT(ABS(Y))
		SIG_SET = 1
	END ELSE BEGIN
		SIG = REPLICATE(1.D0,N_ELEMENTS(Y))
		SIG_SET = 0
	ENDELSE
;
	RETURN
	END
