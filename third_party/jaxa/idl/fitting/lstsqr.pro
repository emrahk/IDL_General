	PRO LSTSQR,X,Y,FNAME,PARAM,PERR,ACCURACY=ACCURACY,ERROR=ERR,	$
		MAX_ITER=MAX_ITER,WEIGHT=WEIGHT,LAMBDA=LAMBDA,		$
		CHISQR=CHISQR,N_ITER=ITER,CMATRIX=COR,NOPRINT=NOPRINT,	$
		POISSON=POISSON
;+
; Project     :	SOHO - CDS
;
; Name        :	LSTSQR
;
; Purpose     :	Least-squares fit of arbitrary function to data points
;
; Explanation :	Fits an arbitrary function to a series of data points via a
;		least-squares reiterative technique.
;
; Use         :	LSTSQR, X, Y, FNAME, PARAM  [, PERR ]
;
; Inputs      :	X	 = Positions.
;		Y	 = Data values.
;		FNAME	 = Name of function to be fitted (string variable).
;		PARAM	 = Parameters of fit.  Passed as first guess.  Returned
;			   as fitted values.
;
; Opt. Inputs :	None.
;
; Outputs     :	PARAM	 = Parameters of fit.  See note above.
;
; Opt. Outputs:	PERR	 = Errors in PARAM.
;
; Keywords    :	ACCURACY = Accuracy to cut off at.  Defaults to 1E-5 (i.e. 5
;			   significant figures).
;		MAX_ITER = Maximum number of reiterations.  Defaults to 20.
;		POISSON	 = If set, then a Poisson error distribution is
;			   assumed, and the weights are set accordingly to 1/Y.
;		ERROR	 = Array of errors.  The weights are set accordingly to
;			   1/ERROR^2.  Overrides POISSON.
;		WEIGHT	 = Array of weights to use in fitting.  Overrides
;			   POISSON and ERROR.
;		LAMBDA	 = Initial value of LAMBDA.  Defaults to 1E-2.
;		NOPRINT	 = If set, then no printout is generated.
;		CHISQR	 = Returned value of chi-squared.  Only relevant if
;			   one of POISSON, ERROR, or WEIGHT keywords are used.
;		N_ITER	 = Number of iterations used.  One can compare this
;			   number against MAX_ITER to determine if convergence
;			   has occurred or not.  If less than MAX_ITER, then
;			   has converged.  However, if negative then a singular
;			   matrix was discovered.
;		CMATRIX	 = Correlation matrix.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	The user defined function is passed by name as a character
;		string in the variable FNAME.  The function must have the form.
;
;				Y = F(X,PARAM,FDER)
;
;		where X is the independent variable, PARAM is the vector
;		containing the parameters of the fit, and FDER is an output
;		array containing the partial derivatives of the function with
;		respect to each parameter in PARAM.  This array will have the
;		dimensions:
;
;			FDER( N_ELEMENTS(X) , N_ELEMENTS(PARAM) )
;
;		However, if FDER is returned by the function as a simple
;		scalar, or not returned at all, then LSTSQR will calculate it
;		itself, using numerical derivatives.
;
;		If numberical derivatives are used, then the initial guess for
;		PARAM must not contain any zeroes.
;
; Side effects:	If MAX_ITER is zero, then no iterations are made, and the
;		routine goes directly to the error analysis section.
;
; Category    :	Utitilies, Curve_Fitting
;
; Prev. Hist. :	William Thompson, June 1991, modified to use keywords.
;
; Written     :	William Thompson, GSFC, June 1991
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated into CDS library
;		Version 2, William Thompson, GSFC, 28 September 1995
;			Return N_ITER as negative if singular matrix
;			encountered.
;
; Version     :	Version 2, 28 September 1995
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) LT 4 THEN BEGIN
		PRINT,'*** LSTSQR must be called with 4-5 parameters:'
		PRINT,'         X, Y, FNAME, PARAMS  [, PERR ]'
		RETURN
	ENDIF
;
;  Set up the default parameters.
;
	ACCUR = 1E-5
	IF N_ELEMENTS(ACCURACY) EQ 1 THEN	$
		IF ACCURACY GT 0 THEN ACCUR = ACCURACY
;
	IF N_ELEMENTS(MAX_ITER) EQ 1 THEN NMAX = MAX_ITER ELSE NMAX = 20
;
	ALAMB = 1E-2
	IF N_ELEMENTS(LAMBDA) EQ 1 THEN		$
		IF LAMBDA GT 0 THEN ALAMB = FLOAT(LAMBDA)
;
;  Define NDATA and NPAR from the input arrays.  Start ITER at zero and find
;  the diagonal elements of the arrays. 
;
	NDATA = N_ELEMENTS(X)
	IF N_ELEMENTS(Y) NE NDATA THEN BEGIN
		PRINT,'*** Arrays X and Y must have the same number of ' + $
			'points, routine LSTSQR.'
		RETURN
	ENDIF
	NPAR = N_ELEMENTS(PARAM)
	IF NPAR EQ 1 THEN BEGIN		;Make sure PARAM is a vector.
		PARAM = [PARAM,PARAM]
		PARAM = PARAM(0:0)
	ENDIF
	ITER = 0
	DIAG = INDGEN(NPAR)*(NPAR+1)	;Subscripts of diagonal elements.
;
;  Calculate the weighting function WT.
;
	IF N_ELEMENTS(WEIGHT) NE 0 THEN BEGIN
		IF N_ELEMENTS(WEIGHT) NE NDATA THEN BEGIN
			PRINT,'*** Array WEIGHT must have ' + TRIM(NDATA) + $
				' elements, routine LSTSQR.'
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
				' elements, routine LSTSQR.'
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
;  Print the header.
;
	IF (NMAX GT 0) AND (NOT KEYWORD_SET(NOPRINT)) THEN BEGIN
		PRINT,FORMAT="(1H1,3X,'I',10X,'log',20X,'log',18X,'log',9X,'I')"
		PRINT,FORMAT="(1X,I4,9X,'ERROR',17X,'CHISQR',15X,'LAMBDA',I9)",$
			NMAX,NMAX
		PRINT,FORMAT="(2X,4(1H-),5X,10(1H-),5X,25(1H-),4X,9(1H-),5X,4(1H-))"
	ENDIF
;
;  Starting point for each iteration.
;
START_ITERATION:
	ITER = ITER + 1
	GPRIME = DBLARR(NPAR)
	ARRAY = DBLARR(NPAR,NPAR)
;
;  Calculate F and FDER.  If the program returns FDER with only one element, 
;  then use numerical derivatives.
;
	FDER = 0
	TEST = EXECUTE('F = ' + FNAME + '(X,PARAM,FDER)')
	IF N_ELEMENTS(FDER) LE 1 THEN BEGIN
		FDER = DBLARR(NDATA,NPAR)
		FOR IPAR = 0,NPAR-1 DO BEGIN
			PAR0 = PARAM(IPAR)
			PARAM(IPAR) = PAR0 * 1.001
			TEST = EXECUTE('FP = ' + FNAME + '(X,PARAM)')
			PARAM(IPAR) = PAR0 * 0.999
			TEST = EXECUTE('FM = ' + FNAME + '(X,PARAM)')
			PARAM(IPAR) = PAR0
			FDER(0,IPAR) = (FP - FM) / (0.002 * PAR0)
		ENDFOR
	ENDIF
;
;  Calculate chi-squared and set up simultaneous equations describing 
;  changes in parameters of fit.
;
	DELTA = F - Y
	G = TOTAL((DELTA^2)*WT)
     	GPRIME = TOTAL( (DELTA*WT) # FDER , 1 )
	ARRAY = TRANSPOSE(FDER) # ((WT # REPLICATE(1,NPAR)) * FDER)
	VEC = SQRT(ARRAY(DIAG))
	W = WHERE(VEC EQ 0,N_FOUND)
	IF N_FOUND GT 0 THEN BEGIN
	        PRINT,'*** Zero partial derivative detected, routine LSTSQR.'
	        RETURN
	ENDIF
	PDIF = GPRIME / VEC
	COR = ARRAY / (VEC # VEC)
	AINV = COR
	AINV(DIAG) = 1 + ALAMB
;
;  If the maximum number of iterations is = 0 then skip over the
;  iterations.
;
	IF NMAX LE 0 THEN BEGIN
		GNEW = G
		GOTO,CALCULATE_ERRORS
	ENDIF
;
;  Invert equations to find next iteration of parameters.
;
	IF N_ELEMENTS(AINV) EQ 1 THEN BEGIN
		IF AINV EQ 0 THEN GOTO, SINGULAR_MATRIX
		AINV = 1 / AINV
	END ELSE BEGIN
		IF DETERM(AINV) EQ 0 THEN GOTO, SINGULAR_MATRIX
		AINV = INVERT(AINV)
	ENDELSE
	PDIF = AINV # PDIF
;
	PDIF = PDIF / VEC
	ERROR = TOTAL( (PDIF^2) / ((PDIF^2) + (PARAM^2)) )
	POLD = PARAM
	PARAM = PARAM - PDIF
;
;  Calculate F and FDER.
;
	FDER = 0
	TEST = EXECUTE('F = ' + FNAME + '(X,PARAM,FDER)')
	IF N_ELEMENTS(FDER) LE 1 THEN BEGIN
		FDER = DBLARR(NDATA,NPAR)
		FOR IPAR = 0,NPAR-1 DO BEGIN
			PAR0 = PARAM(IPAR)
			PARAM(IPAR) = PAR0 * 1.001
			TEST = EXECUTE('FP = ' + FNAME + '(X,PARAM)')
			PARAM(IPAR) = PAR0 * 0.999
			TEST = EXECUTE('FM = ' + FNAME + '(X,PARAM)')
			PARAM(IPAR) = PAR0
			FDER(0,IPAR) = (FP - FM) / (0.002 * PAR0)
		ENDFOR
	ENDIF
	GNEW = TOTAL( ((F - Y)^2) * WT )
;
	IF ERROR GT 0 THEN ERRORLG = ALOG10(ERROR)/2 ELSE ERRORLG = -999
	IF G     GT 0 THEN GLG     = ALOG10(G)       ELSE GLG     = -999
	IF GNEW  GT 0 THEN GNEWLG  = ALOG10(GNEW)    ELSE GNEWLG  = -999
	IF ALAMB GT 0 THEN ALAMBLG = ALOG10(ALAMB)   ELSE ALAMBLG = -999
	FORMAT = "(I5,3F15.5,F13.3,I9)"
	IF NOT KEYWORD_SET(NOPRINT) THEN PRINT,FORMAT=FORMAT,ITER,ERRORLG, $
		GLG,GNEWLG,ALAMBLG,ITER
;
;  If an improvement was made in chi-squared, then divide ALAMB by 10, else
;  multiply by 10 and start over.  If the residual error is small enough, or
;  the number of iterations is large enough, then exit to calculate errors.
;
	IF (ERROR GT (ACCUR/(1.+ALAMB))^2) AND (ITER LT NMAX) THEN BEGIN
		IF GNEW GT G THEN BEGIN
			ALAMB = ALAMB*10
			PARAM = POLD
		END ELSE ALAMB = ALAMB/10
		GOTO,START_ITERATION
	ENDIF
	IF GNEW GT G THEN PARAM = POLD
;
;  Calculate errors.
;
CALCULATE_ERRORS:
	ARRAY = ARRAY / (VEC # VEC)
	IF N_ELEMENTS(ARRAY) EQ 1 THEN BEGIN
		AINV = ARRAY * VEC^2
		IF AINV EQ 0 THEN GOTO, SINGULAR_MATRIX
		AINV = 1 / AINV
	END ELSE BEGIN
		IF DETERM(AINV) EQ 0 THEN GOTO, SINGULAR_MATRIX
		AINV = INVERT(ARRAY) / (VEC # VEC)
	ENDELSE
	CHISQR = (G < GNEW) / ((NDATA - NPAR) > 1)
	SIGSQR = ((AINV # TRANSPOSE(FDER))^2) # WT
	IF NOT WT_PASSED THEN SIGSQR = SIGSQR * CHISQR
	PERR = SQRT(SIGSQR)
	RETURN
;
;  Singular matrix error point.  Signal by setting ITER negative.
;
SINGULAR_MATRIX:
	PRINT,'*** A singular matrix was encountered, routine LSTSQR.'
	CHISQR = (G < GNEW) / ((NDATA - NPAR) > 1)
	PERR = 0*PARAM
	ITER = -ITER
	RETURN
	END
