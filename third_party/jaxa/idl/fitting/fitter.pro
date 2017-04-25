	PRO FITTER,X,Y,FDER,PARAM,PERR,ERROR=ERR,WEIGHT=WEIGHT,YZERO=YZERO, $
		CHISQR=CHISQR,CMATRIX=COR,POISSON=POISSON
;+
; Project     :	SOHO - CDS
;
; Name        :	FITTER
;
; Purpose     : Least-squares fit of linear function
;
; Explanation :	Fits a linear function to a series of data points via a
;		least-squares technique.
;
; Use         :	FITTER, X, Y, FDER, PARAM  [, PERR ]
;
; Inputs      :	X	= Positions.
;		Y	= Data values.
;		ERR	= Errors in Y.
;		FDER	= Array of partial derivatives of fitted function.
;			  This array will have the dimensions: FDER(
;			  N_ELEMENTS(X) , N_ELEMENTS(PARAM) )
;
; Opt. Inputs :	None.
;
; Outputs     :	PARAM	= Returned parameters of fit.
;
; Opt. Outputs:	PERR	= Errors in PARAM.
;
; Keywords :	POISSON	= If set, then a Poisson error distribution is assumed,
;			  and the weights are set accordingly to 1/Y.
;		ERROR	= Array of errors.  The weights are set accordingly to
;			  1/ERROR^2.  Overrides POISSON.
;		WEIGHT	= Array of weights to use in fitting.  Overrides
;			  POISSON and ERROR.
;		YZERO	= Amount to subtract from Y (only for use with
;			  REGRESS).
;		CHISQR	= Returned value of chi-squared.  Only relevant if
;			  ERROR passed explicitly.
;		CMATRIX	= Correlation matrix.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utilities, Curve_Fitting
;
; Prev. Hist. :	William Thompson, June 1991, modified to use keywords.
;
; Written     :	William Thompson, GSFC, June 1991
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated in CDS library
;
; Version     :	Version 1, 9 January 1995
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) LT 4 THEN BEGIN
		PRINT,' This procedure must be called with 4-5 parameters:'
		PRINT,'           X, Y, FDER, PARAMS  [, PERR ]'
		RETURN
	ENDIF
;
;  Set up the default parameters.
;
	IF N_ELEMENTS(YZERO)   EQ 1 THEN Y0 = YZERO   ELSE Y0 = 0
;
;  From FDER, get the parameters NDATA and NPAR.
;
	S = SIZE(FDER)
	IF S(0) NE 2 THEN BEGIN
		PRINT,'*** Array must have two dimensions, name= FDER, routine FITTER.'
		RETURN
	ENDIF
	NDATA = S(1)
	NPAR  = S(2)
	DIAG = INDGEN(NPAR)*(NPAR+1)	;Subscripts of diagonal elements.
	IF N_ELEMENTS(X) NE NDATA THEN BEGIN
		PRINT,'*** Incorrect number of elements, name= X, routine FITTER.'
		RETURN
	END ELSE IF N_ELEMENTS(Y) NE NDATA THEN BEGIN
		PRINT,'*** Incorrect number of elements, name= Y, routine FITTER.'
		RETURN
	ENDIF
;
;  Calculate the weighting function WT.
;
	IF N_ELEMENTS(WEIGHT) NE 0 THEN BEGIN
		IF N_ELEMENTS(WEIGHT) NE NDATA THEN BEGIN
			PRINT,'*** Array WEIGHT must have ' + TRIM(NDATA) + $
				' elements, routine FITTER.'
			RETURN
		ENDIF
		WT = WEIGHT
		WT_PASSED = 1
	END ELSE IF N_ELEMENTS(ERR) NE 0 THEN BEGIN
		IF N_ELEMENTS(ERR) EQ 1 THEN BEGIN
			WT = REPLICATE(1.D0/ABS(ERR)^2,NDATA)
			WT_PASSED = 1
		END ELSE IF N_ELEMENTS(ERR) EQ NDATA THEN BEGIN
			WT = 1.D0 / ABS(ERR)^2
			WT_PASSED = 1
		END ELSE BEGIN
			PRINT,'*** Array ERR must have ' + TRIM(NDATA) + $
				' elements, routine FITTER.'
			RETURN
		ENDELSE
	END ELSE IF KEYWORD_SET(POISSON) THEN BEGIN
		WT = 1.D0 / ABS(Y)
		WT_PASSED = 1
	END ELSE BEGIN
		WT = REPLICATE(1.D0,NDATA)
		WT_PASSED = 0
	ENDELSE
;
;  Set up simultaneous equations describing parameters of fit.
;
	ARRAY = TRANSPOSE(FDER) # ((WT # REPLICATE(1,NPAR)) * FDER)
	PARAM = TRANSPOSE(FDER) # ((Y - Y0)*WT)
	VEC = SQRT(ARRAY(DIAG))
	PARAM = PARAM / VEC
	COR = ARRAY / (VEC # VEC)
;
;  Invert equations to find parameters.
;
	AINV = INVERT(COR)
	PARAM = (AINV # PARAM) / VEC
;
;  Calculate chi-squared.
;
	CHISQR = TOTAL(((FDER # PARAM) - (Y - Y0))^2 * WT) /		       $
		((NDATA - NPAR) > 1)
;
;  Calculate the errors in the fitted parameters.
;
	AINV = AINV / (VEC # VEC)
	SIGSQR = ((AINV # TRANSPOSE(FDER))^2) # WT
	IF NOT WT_PASSED THEN SIGSQR = SIGSQR * CHISQR
	PERR = SQRT(SIGSQR)
	RETURN
	END
