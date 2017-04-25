	FUNCTION FORM_CHISQR, Z, ABSOLUTE=ABSOLUTE, LORENTZ=LORENTZ
;+
; Project     :	SOHO - CDS
;
; Name        :	FORM_CHISQR
;
; Purpose     :	Forms function to be minimized
;
; Explanation :	Called from fitting routines to form the function to be
;		minimized (normally chi-squared).
;
; Use         :	Result = FORM_CHISQR(Z)
;
; Inputs      :	Z	 = Array containing the difference between the fitted
;			   and measured values, divided by the error (sigma).
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the sum of the error estimates,
;		normally the squares of Z.
;
; Opt. Outputs:	None.
;
; Keywords    :	ABSOLUTE = If set, then the sum of the absolute differences is
;			   minimized instead of the sum of the squares.  This
;			   is equivalent to assuming a double-sided exponential
;			   distribution.
;		LORENTZ	 = If set, then a Lorentz distribution is used instead
;			   of a normal distribution.  Overrides ABSOLUTE.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	The statistical interpretation of the value of this function is
;		unclear if either ABSOLUTE or LORENTZ is set.
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
	IF N_PARAMS(0) NE 1 THEN MESSAGE, 'Syntax:  Result = FORM_CHISQR(Z)'
;
;  Calculate chi-squared.
;
	IF KEYWORD_SET(LORENTZ) THEN BEGIN
		CHISQR = TOTAL( ALOG( 1 + 0.5*Z^2 ) )
	END ELSE IF KEYWORD_SET(ABSOLUTE) THEN BEGIN
		CHISQR = TOTAL( ABS(Z) )
	END ELSE BEGIN
		CHISQR = TOTAL( Z^2 )
	ENDELSE
;
	RETURN, CHISQR
	END
