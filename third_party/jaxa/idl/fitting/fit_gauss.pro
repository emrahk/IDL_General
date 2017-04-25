	FUNCTION FIT_GAUSS,X,Y,A,ASIG,ACCURACY=ACCURACY,ERROR=ERR,	$
		MAX_ITER=MAX_ITER,WEIGHT=WEIGHT,LAMBDA=LAMBDA,		$
		CHISQR=CHISQR,N_ITER=ITER,CMATRIX=COR,NOPRINT=NOPRINT,	$
		POISSON=POISSON
;+
; Project     :	SOHO - CDS
;
; Name        :	FIT_GAUSS
;
; Purpose     :	Fits a gaussian plus a quadratic to data points
;
; Explanation :	Fit Y=F(X) where:
;	 	F(X) = A0*EXP(-Z^2/2) + A3 + A4*X + A5*X^2
; 			and Z=(X-A1)/A2
;		A0 = height of exp, A1 = center of exp, A2 = Gaussian width,
;		A3 = constant term, A4 = linear term, A5 = quadratic term.
;	 	Estimate the parameters A0,A1,A2,A3 and then call LSTSQR.
;
;		If the (max-avg) of Y is larger than (avg-min) then it is
;		assumed the line is an emission line, otherwise it is assumed
;		there is an absorbtion line.  The estimated center is the max
;		or min element.  The height is (max-avg) or (avg-min)
;		respectively.  The width is foun by searching out from the
;		extrem until a point is found < the 1/e value.
;
; Use         :	YFIT = FIT_GAUSS( X, Y  [, A  [, ASIG  [, CHISQR ]]] )
;
; Inputs      :	X = independent variable, must be a vector.
;		Y = dependent variable, must have the same number of points
;		    as X.
;
; Opt. Inputs :	None.
;
; Outputs     :	YFIT = fitted function.
;
; Opt. Outputs:	A    = Coefficients -- a six element vector as described above.
;		ASIG = Estimated errors in A.
;
; Keywords    :	
;	ACCURACY = Accuracy to cut off at.  Defaults to 1E-5.
;	MAX_ITER = Maximum number of reiterations.  Defaults to 20.
;	POISSON	 = If set, then a Poisson error distribution is assumed, and
;		   the weights are set accordingly to 1/Y.
;	ERROR	 = Array of errors.  The weights are set accordingly to
;		   1/ERROR^2.  Overrides POISSON.
;	WEIGHT	 = Array of weights to use in fitting.  Overrides POISSON and
;		   ERROR.
;	LAMBDA	 = Initial value of LAMBDA.  Defaults to 1E-2.
;	NOPRINT	 = If set, then no printout is generated.
;	CHISQR	 = Returned value of chi-squared.  Only relevant if ERROR
;		   passed explicitly.
;	N_ITER	 = Number of iterations used.
;	CMATRIX	 = Correlation matrix.
;
; Calls       :	LSTSQR
;
; Common      :	None.
;
; Restrictions:	The peak or minimum of the gaussian must be the largest or
;		respectively the smallest point in the Y vector.
;
; Side effects:	None.
;
; Category    :	Utilities, Curve_Fitting
;
; Prev. Hist. :	
;	DMS, RSI, Dec, 1983.
;	Modified to use LSTSQR, William Thompson, Feb. 1990.
;	William Thompson, June 1991, modified to use keywords.
;
; Written     :	David M. Stern, RSI, December 1983
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated into CDS library
;
; Version     :	Version 1, 9 January 1995
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters.
;
	IF N_PARAMS(0) LT 2 THEN BEGIN
		PRINT,'*** FIT_GAUSS must be called with 2-4 parameters:'
		PRINT,'            X, Y  [, A  [, AERR ]]'
		RETURN,0
	ENDIF
;
	N = N_ELEMENTS(Y)		;# of points.
	C = POLY_FIT(X,Y,1,YF)		;Fit a straight line.
	YD = Y-YF			;Difference.

	YMAX=MAX(YD) & XMAX=X(!C) & IMAX=!C	;X,Y and subscript of extrema.
	YMIN=MIN(YD) & XMIN=X(!C) & IMIN=!C
	A=FLTARR(6)			;Coefficient vector.
	IF ABS(YMAX) GT ABS(YMIN) THEN I0=IMAX ELSE I0=IMIN ;Emiss or absorp?
	I0 = I0 > 1 < (N-2)		;Never take edges.
	DY=YD(I0)			;Diff between extreme and mean.
	DEL = DY/EXP(1.)		;1/e value.
	I=0
	WHILE ((I0+I+1) LT N) AND $	;Guess at 1/2 width.
		((I0-I) GT 0) AND $
		(ABS(YD(I0+I)) GT ABS(DEL)) AND $
		(ABS(YD(I0-I)) GT ABS(DEL)) DO I=I+1
	A = [YD(I0), X(I0), ABS(X(I0)-X(I0+I)), C(0), C(1), 0.] ;Estimates.
	!C=0				;Reset cursor for plotting.
;
;  Call LSTSQR to fit for Gaussian.
;
	LSTSQR,X,Y,'GAUSS_FUNCT',A,ASIG,ACCURACY=ACCURACY,ERROR=ERR,	$
		MAX_ITER=MAX_ITER,WEIGHT=WEIGHT,LAMBDA=LAMBDA,		$
		CHISQR=CHISQR,N_ITER=ITER,CMATRIX=COR,NOPRINT=NOPRINT,	$
		POISSON=POISSON
;
	RETURN,GAUSS_FUNCT(X,A)		;Return value of function.
	END
