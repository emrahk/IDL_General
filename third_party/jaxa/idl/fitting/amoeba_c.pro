	PRO AMOEBA_C,X,Y,FNAME,PARAM,ACCURACY=ACCURACY,MAX_ITER=MAX_ITER, $
		POISSON=POISSON,ERROR=ERR,LAMBDA=LAMBDA0,CHISQR=CHISQR,	$
		N_ITER=ITER,NOPRINT=NOPRINT,ABSOLUTE=ABSOLUTE,LORENTZ=LORENTZ,$
		PRANGE=K_PRANGE
;+
; Project     :	SOHO - CDS
;
; Name        :	AMOEBA_C
;
; Purpose     :	Reiteratively fits an arbitrary function
;
; Explanation :	Fits an arbitrary function to a series of data points via a
;		least-squares reiterative technique.
;
;		The procedure used is taken from Numerical Recipes.
;
; Use         :	AMOEBA_C, X, Y, FNAME, PARAM
;
; Inputs      :	X	= Positions.
;		Y	= Data values.
;		FNAME	= Name of function to be fitted (string variable).
;		PARAM	= Parameters of fit.  Passed as first guess.  Returned
;			  as fitted values.
;
; Opt. Inputs :	None.
;
; Outputs     :	PARAM	= Parameters of fit.  See note above.
;
; Opt. Outputs:	None.
;
; Keywords    :	
;	ACCURACY = Accuracy to cut off at.  Defaults to 1E-5.
;	MAX_ITER = Maximum number of reiterations.  Defaults to 20.
;	POISSON	 = If set, then a Poisson error distribution is assumed, and
;		   the weights are set accordingly to 1/Y.
;	ERROR	 = Array of errors.  The weights are set accordingly to
;		   1/ERROR^2 (normal distribution).  Overrides POISSON.
;	LAMBDA	 = Initial step sizes for PARAM, or if scalar then fraction of
;		   PARAM.  Defaults to 1E-2.  When passed as an array, this
;		   parameter can be used to hold parameters constant by setting
;		   LAMBDA(I)=0 for those parameters.
;	NOPRINT	 = If set, then no printout is generated.
;	CHISQR	 = Returned value of chi-squared.  Only relevant if ERROR
;		   passed explicitly.
;	N_ITER	 = Number of iterations used.
;	ABSOLUTE = If set, then the sum of the absolute differences is
;		   minimized instead of the sum of the squares.  This is
;		   equivalent to assuming a double-sided exponential
;		   distribution.
;	LORENTZ	 = If set, then a Lorentz distribution is used instead of a
;		   normal distribution.  Not truely meaningful unless ERROR is
;		   passed.
;	PRANGE	 = Range of acceptable parameter values.  Must have the
;		   dimensions (NPAR,2), where PRANGE(*,0) are the minimum
;		   values and PRANGE(*,1) are the maximum values.  Only those
;		   ranges where PRANGE(*,1) are larger than PRANGE(*,0) are
;		   implemented--all other parameters are considered to be
;		   unbounded.
;
; Calls       :	FORM_CHISQR, FORM_SIGMAS
;
; Common      :	None
;
; Restrictions:	The user defined function is passed by name as a character
;		string in the variable FNAME.  The function must have the form.
;
;				    Y = F(X,PARAM)
;
;		where X is the independent variable, and PARAM is the vector
;		containing the parameters of the fit.
;
;		Unless LAMBDA is passed as an array, if the initial guess for
;		PARAM contains any zeroes, then those parameters will be kept
;		constant at zero.
;
; Side effects:	The statistical interpretation of CHISQR is unclear if either
;		ABSOLUTE or LORENTZ is set.
;
; Category    :	Utilities, Curve_Fitting
;
; Prev. Hist. :	
;	William Thompson, August, 1989.
;	William Thompson, June 1991, modified to use keywords.
;	William Thompson, December 1992, modified to use other fitting
;		strategies besides minimizing the root-mean-square.  Also
;		removed keyword WEIGHTS as this was incompatible with this
;		strategy.
;
; Written     :	William Thompson, GSFC, August 1989
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated into CDS library
;		Version 2, William Thompson, GSFC, 6 October 1995
;			Fixed typo.
;		Version 3, William Thompson, GSFC, 10 December 1997
;			Renamed to AMOEBA_C to avoid conflict with IDL/v5
;			routine of the same name.
;		Version 4, William Thompson, GSFC, 05-Jun-1998
;			Fixed bug where LAMBDA was not being properly accepted
;			if a vector.
;		Version 5, William Thompson, GSFC, 27-Apr-1999
;			Added keyword PRANGE.
;		Version 6, William Thompson, GSFC, 04-May-1999
;			Allow for case where either PARAM or LAMBDA is set to
;			zero to keep a parameter constant.
;   Version 7, William Thompson, GSFC, 23-Dec-2005
;     Use CALL_FUNCTION instead of EXECUTE
;   Version 8, Kim Tolbert, 23-Aug-2010
;     If MAX_ITER=0, just calculate chisquare from input parameters and return
;   Version 9, Richard Schwartz, GSFC, 17-Nov-2014
;     Changed () to [] for IDL 8.4 compatibility
;
; Version     :	Version 9, 17-Nov-2014
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) NE 4 THEN BEGIN
		PRINT,' This procedure must be called with four parameters:'
		PRINT,'                 X, Y, FNAME, PARAMS'
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
	LAMBDA = 1E-2
	IF N_ELEMENTS(LAMBDA0) EQ N_ELEMENTS(PARAM) THEN LAMBDA = LAMBDA0
	IF N_ELEMENTS(LAMBDA0) EQ 1 THEN	$
		IF LAMBDA0 GT 0 THEN LAMBDA = LAMBDA0
;
;  Define NDATA and NPAR from the input arrays.  Start ITER at zero.
;
	NDATA = N_ELEMENTS(X) < N_ELEMENTS(Y)
	NPAR = N_ELEMENTS(PARAM)
	IF NPAR EQ 1 THEN PARAM = MAKE_ARRAY(PARAM)
	ITER = 0
;
;  Calculate the sigmas to use for each data point.
;
	FORM_SIGMAS, Y, SIG, POISSON=POISSON, ERROR=ERR
	
; If # iterations is 0, just calculate chisqr from input params and return.	
	IF NMAX EQ 0 THEN BEGIN
	  F = CALL_FUNCTION(FNAME,X,PARAM)
	  CHISQR = FORM_CHISQR( (F - Y)/SIG, ABSOLUTE=ABSOLUTE, LORENTZ=LORENTZ)
	  RETURN
	ENDIF
;
;  Check the array or scalar LAMBDA.
;
	NLAMB = N_ELEMENTS(LAMBDA)
	IF (NLAMB NE NPAR) AND (NLAMB NE 1) THEN BEGIN
		PRINT,'*** LAMBDA must have 1 or ' + FIX(NPAR) +	$
			' elements, routine AMOEBA_C.'
		RETURN
	ENDIF
;
;  Calculate the array of parameters to start with.
;
	P = PARAM # REPLICATE(1.,NPAR+1)
	FOR I = 0,NPAR-1 DO BEGIN
		IF NLAMB EQ NPAR THEN P[I,I+1] = PARAM[I] + LAMBDA[I]	$
			ELSE P[I,I+1] = PARAM[I] * (1. + LAMBDA)
	ENDFOR
;
;  Determine the allowed parameter range, and make sure that all the parameters
;  are within that range.
;
	PR_COUNT = 0
	SZ = SIZE(K_PRANGE)
	IF SZ[0] EQ 2 THEN IF (SZ[1] EQ NPAR) AND (SZ[2] EQ 2) THEN BEGIN
	    PRANGE=K_PRANGE
	    W_PR = WHERE(PRANGE[*,1] GT PRANGE[*,0], PR_COUNT)
	    IF PR_COUNT GT 0 THEN FOR I = 0,PR_COUNT-1 DO BEGIN
		J = W_PR[I]
		P[J,*] = PRANGE[J,0] > P[J,*] < PRANGE[J,1]
	    ENDFOR
	ENDIF
;
;  Initialize the array containing chi-squared.
;
	CHI = 0.*[0,PARAM]
	FOR I = 0,NPAR DO BEGIN
		F = CALL_FUNCTION(FNAME,X,P[*,I])
		CHI[I] = FORM_CHISQR( (F - Y)/SIG, ABSOLUTE=ABSOLUTE,	$
			LORENTZ=LORENTZ)
	ENDFOR	
;
;  Print the header.
;
	IF (NMAX GT 0) AND (NOT KEYWORD_SET(NOPRINT)) THEN BEGIN
		PRINT,FORMAT="(1H1,3X,'I',10X,'log',20X,'log',16X,'I')"
		PRINT,FORMAT="(1X,I4,9X,'ERROR',17X,'CHISQR',7X,I9)",NMAX,NMAX
		PRINT,FORMAT="(2X,4(1H-),5X,10(1H-),5X,25(1H-),4X,4(1H-))"
	ENDIF
;
;  Starting point for all iterations.  Find the highest, next highest, and 
;  lowest values of CHI.
;
ITERATE:
	ITER = ITER + 1
	ILO = 0
	IF CHI[0] GT CHI[1] THEN BEGIN
		IHI  = 0
		INHI = 1
	END ELSE BEGIN
		IHI  = 1
		INHI = 0
	ENDELSE
	FOR I = 0,NPAR DO BEGIN
		IF CHI[I] LT CHI[ILO] THEN ILO = I
		IF CHI[I] GT CHI[IHI] THEN BEGIN
			INHI = IHI
			IHI  = I
		END ELSE IF (CHI[I] GT CHI[INHI]) AND (I NE IHI) THEN INHI = I
	ENDFOR
;
;  Find the average of P for all points other than IHI.
;
	PBAR = 0*PARAM
	FOR I = 0,NPAR DO IF I NE IHI THEN PBAR = PBAR + P[*,I]
	PBAR = PBAR / NPAR
;
;  Reflect from the high point through PBAR.
;
	PR = 2*PBAR - P[*,IHI]
	IF PR_COUNT GT 0 THEN PR[W_PR] =	$
		PRANGE[W_PR,0] > PR[W_PR] < PRANGE[W_PR,1]
	F = CALL_FUNCTION(FNAME,X,PR)
	CR = FORM_CHISQR( (F - Y)/SIG, ABSOLUTE=ABSOLUTE, LORENTZ=LORENTZ)
;
;  If an improvement was achieved, try an additional extrapolation.
;
	IF CR LE CHI[ILO] THEN BEGIN
		PRR = 2*PR - PBAR
		IF PR_COUNT GT 0 THEN PRR[W_PR] =	$
			PRANGE[W_PR,0] > PRR[W_PR] < PRANGE[W_PR,1]
		F = CALL_FUNCTION(FNAME,X,PRR)
		CRR = FORM_CHISQR( (F - Y)/SIG, ABSOLUTE=ABSOLUTE,	$
			LORENTZ=LORENTZ)
;
;  If an additional improvement was achieved, use the second extrapolation.
;
		IF CRR LT CHI[ILO] THEN BEGIN
			P[0,IHI] = PRR
			CHI[IHI] = CRR
;
;  Otherwise use the first extrapolation (reflection).
;
		END ELSE BEGIN
			P[0,IHI] = PR
			CHI[IHI] = CR
		ENDELSE
;
;  If the reflection yields a value between the highest value and the next 
;  highest value, use it.
;
	END ELSE IF CR GE CHI[INHI] THEN BEGIN
		IF CR LT CHI[IHI] THEN BEGIN
			P[0,IHI] = PR
			CHI[IHI] = CR
		ENDIF
;
;  Look for an intermediate lower point.  If it's an improvement use it.
;
		PRR = (P[*,IHI] + PBAR) / 2.
		IF PR_COUNT GT 0 THEN PRR[W_PR] =	$
			PRANGE[W_PR,0] > PRR[W_PR] < PRANGE[W_PR,1]
		F = CALL_FUNCTION(FNAME,X,PRR)
		CRR = FORM_CHISQR( (F - Y)/SIG, ABSOLUTE=ABSOLUTE,	$
			LORENTZ=LORENTZ)
		IF CRR LT CHI[IHI] THEN BEGIN
			P[0,IHI] = PRR
			CHI[IHI] = CRR
;
;  Nothing seems to help.  Contract about the lowest point.
;
		END ELSE BEGIN
			FOR I = 0,NPAR DO IF I NE ILO THEN BEGIN
				PR = (P[*,I] + P[*,ILO]) / 2.
				P[0,I] = PR
				F = CALL_FUNCTION(FNAME,X,PRR)
				CHI[I] = FORM_CHISQR( (F - Y)/SIG,	$
					ABSOLUTE=ABSOLUTE, LORENTZ=LORENTZ)
			ENDIF
		ENDELSE
;
;  The reflection yields an intermediate value.  Use it.
;
	END ELSE BEGIN
		P[0,IHI] = PR
		CHI[IHI] = CR
	ENDELSE
;
;  Print out the iteration information.
;
	DENOM = P[*,IHI]^2 + P[*,ILO]^2
	W = WHERE(DENOM NE 0)
	ERROR = TOTAL( (P[W,IHI] - P[W,ILO])^2 / DENOM[W] )
	BANG_C = !C
	CHI_HI = MAX(CHI)
	CHI_LO = MIN(CHI)
	I_LOW = !C
	!C = BANG_C
	IF ERROR  GT 0 THEN ERRORLG = ALOG10(ERROR)/2 ELSE ERRORLG = -999
	IF CHI_HI GT 0 THEN CHILOG  = ALOG10(CHI_HI)  ELSE CHILOG  = -999
	IF CHI_LO GT 0 THEN CLOLOG  = ALOG10(CHI_LO)  ELSE CLOLOG  = -999
	FORMAT = "(I5,3F15.5,I8)"
	IF NOT KEYWORD_SET(NOPRINT) THEN PRINT,FORMAT=FORMAT,ITER,ERRORLG, $
		CHILOG,CLOLOG,ITER
	IF (ERROR GT ACCUR^2) AND (ITER LT NMAX) THEN GOTO,ITERATE
;
;  The program has either converged or reached its maximum number of 
;  iterations.
;
	PARAM  = P[*,I_LOW]
	CHISQR = CHI[I_LOW]
	END
