	PRO FASTFIT,X,Y,FDER,PARAM,ERROR=ERR,WEIGHT=WEIGHT,POISSON=POISSON
;+
; Project     :	SOHO - CDS
;
; Name        :	FASTFIT
;
; Purpose     :	Least-squares fit of linear function without error analysis
;
; Explanation :	Fits a linear function to a series of data points via a
;		least-squares technique.
;
;		This routine differs from FITTER in that no error analysis is
;		performed, and the correlation matrix is not calculated.
;
; Use         :	FASTFIT, X, Y, FDER, PARAM
;
; Inputs      :	X	= Positions.
;		Y	= Data values.
;		FDER	= Array of partial derivatives of fitted function.
;			  This array will have the dimensions: FDER(
;			  N_ELEMENTS(X) , N_ELEMENTS(PARAM) )
;
; Opt. Inputs :	None.
;
; Outputs     :	PARAM	= Returned parameters of fit.
;
; Opt. Outputs:	None.
;
; Keywords :	POISSON	= If set, then a Poisson error distribution is assumed,
;			  and the weights are set accordingly to 1/Y.
;		ERROR	= Array of errors.  The weights are set accordingly to
;			  1/ERROR^2.  Overrides POISSON.
;		WEIGHT	= Array of weights to use in fitting.  Overrides
;			  POISSON and ERROR.
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
;			Incorporated into CDS library
;
; Version     :	Version 1, 9 January 1995
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) NE 4 THEN BEGIN
		PRINT,'*** FASTFIT must be called with four parameters:'
		PRINT,'                X, Y, FDER, PARAMS'
		RETURN
	ENDIF
;
;  From FDER, get the parameters NDATA and NPAR.
;
	S = SIZE(FDER)
	IF S(0) NE 2 THEN BEGIN
		PRINT,'*** Array must have two dimensions, name= FDER, routine FASTFIT.'
		RETURN
	ENDIF
	NDATA = S(1)
	NPAR  = S(2)
	IF N_ELEMENTS(X) NE NDATA THEN BEGIN
		PRINT,'*** Incorrect number of elements, name= X, routine FASTFIT.'
		RETURN
	END ELSE IF N_ELEMENTS(Y) NE NDATA THEN BEGIN
		PRINT,'*** Incorrect number of elements, name= Y, routine FASTFIT.'
		RETURN
	ENDIF
;
;  Calculate the weighting function WT.
;
	IF N_ELEMENTS(WEIGHT) NE 0 THEN BEGIN
		IF N_ELEMENTS(WEIGHT) NE NDATA THEN BEGIN
			PRINT,'*** Array WEIGHT must have ' + TRIM(NDATA) + $
				' elements, routine FASTFIT.'
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
				' elements, routine FASTFIT.'
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
	PARAM = TRANSPOSE(FDER) # (Y*WT)
;
;  Invert equations to find parameters.
;
	AINV = INVERT(ARRAY)
	PARAM = AINV # PARAM
	RETURN
	END
