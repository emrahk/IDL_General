	PRO REGRESS_FIT,X,Y,FDER,A0,PARAM,PERR,ERROR=ERR,WEIGHT=WEIGHT,	$
		POISSON=POISSON,CHISQR=CHISQR,CMATRIX=COR
;+
; Project     :	SOHO - CDS
;
; Name        :	REGRESS_FIT
;
; Purpose     :	Linear regression routine for functions with constant term
;
; Explanation :	This subroutine performs the same function as subroutine FITTER
;		with the proviso that the function to be fitted consists of a
;		constant DC-level term A0 and terms PAR(I) multiplying
;		nontrivial functions FDER(X,I) in the variable X.  This allows
;		a more efficient computation to be made.
;
; Use         :	REGRESS_FIT, X, Y, FDER, A0, PARAM  [, PERR ]
;
; Inputs      :	X	= Positions.
;		Y	= Data values.
;		FDER	= Array of partial derivatives of fitted function
;			  w.r.t. PARAM (not A0).  This array will have the
;			  dimensions: FDER( N_ELEMENTS(X) , N_ELEMENTS(PARAM) )
;
; Opt. Inputs :	None.
;
; Outputs     :	A0	= Constant DC-level term.
;		PARAM	= Returned parameters of fit.
;
; Opt. Outputs:	PERR	= Errors in PARAM.
;
; Keywords    :	POISSON	= If set, then a Poisson error distribution is
;			  assumed, and the weights are set accordingly to 1/Y.
;		ERROR	= Array of errors.  The weights are set accordingly to
;			  1/ERROR^2.  Overrides POISSON.
;		WEIGHT	= Array of weights to use in fitting.  Overrides
;			  POISSON and ERROR.
;		CHISQR	= Returned value of chi-squared.  Only relevant if
;			  ERROR passed explicitly.
;		CMATRIX	= Correlation matrix.
;
; Calls       :	FITTER
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utilities, Curve_fitting
;
; Prev. Hist. :	William Thompson, June 1991, modified to use keywords.
;
; Written     :	William Thompson, GSFC, June 1991
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated into CDS library
;		Version 2, William Thompson, GSFC, 13 December 1996
;			Renamed to REGRESS_FIT
;
; Version     :	Version 2, 13 December 1996
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) LT 5 THEN BEGIN
		PRINT,' This procedure must be called with 5-6 parameters:'
		PRINT,'         X, Y, FDER, A0, PARAMS  [, PERR ]'
		RETURN
	ENDIF
;
;  From FDER, get the parameter NDATA.
;
	S = SIZE(FDER)
	IF S(0) NE 2 THEN MESSAGE, 'FDER must have two dimensions'
	NDATA = S(1)
;
	Y0 = AVG(Y)
	A0 = Y0
	F0 = AVG(FDER,0)
	FDER0 = FDER - (REPLICATE(1,NDATA) # F0)
	FITTER,X,Y,FDER0,PARAM,PERR,POISSON=POISSON,ERROR=ERR,WEIGHT=WEIGHT, $
		CHISQR=CHISQR,YZERO=Y0
	A0 = A0 - TOTAL(PARAM*F0)
;
	RETURN
	END
