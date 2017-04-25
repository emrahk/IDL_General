	PRO AMOEBA_F,FNAME,PARAM,ACCURACY=ACCURACY,MAX_ITER=MAX_ITER, $
		LAMBDA=LAMBDA0,CHISQR=CHISQR,N_ITER=ITER,NOPRINT=NOPRINT
;+
; Project     :	SOHO - CDS
;
; Name        :	AMOEBA_F
;
; Purpose     :	Reiteratively minimizes an arbitrary function
;
; Explanation :	Minimizes an arbitrary function via a least-squares reiterative
;		technique.
;
;		The procedure used is taken from Numerical Recipes.
;
; Use         :	AMOEBA_F, FNAME, PARAM
;
; Inputs      :	FNAME	= Name of function to be minimized (string variable).
;		PARAM	= Parameters of fit.  Passed as first guess.  Returned
;			  as fitted values.
;
; Opt. Inputs :	None.
;
; Outputs     :	PARAM	= Parameters of fit.  See note above.
;
; Opt. Outputs:	None.
;
; Keywords    :	ACCURACY = Accuracy to cut off at.  Defaults to 1E-5.
;		MAX_ITER = Maximum number of reiterations.  Defaults to 20.
;		LAMBDA	 = Initial step sizes for PARAM, or if scalar then
;			   fraction of PARAM.  Defaults to 1E-2.
;		NOPRINT	 = If set, then no printout is generated.
;		CHISQR	 = Returned value of chi-squared.  Only relevant if
;			   ERROR passed explicitly.
;		N_ITER	 = Number of iterations used.
;
; Calls       :	None.
;
; Common      :	None
;
; Restrictions:	The user defined function is passed by name as a character
;		string in the variable FNAME.  The function must have the form.
;
;				    Y = F(PARAM)
;
;		where PARAM is the vector containing the parameters of the fit.
;
;		Unless LAMBDA is passed as an array, the initial guess for
;		PARAM must not contain any zeroes.
;
; Side effects:	None.
;
; Category    :	Utilities, Curve_Fitting
;
; Prev. Hist. :	William Thompson, August, 1989.
;		William Thompson, June 1991, modified to use keywords.
;
; Written     :	William Thompson, GSFC, August 1989
;
; Modified    :	Version 1, William Thompson, GSFC, 9 January 1995
;			Incorporated into CDS library
;		Version 2, William Thompson, GSFC, 6 October 1995
;			Fixed typo.
;		Version 3, William Thompson, GSFC, 05-Jun-1998
;			Fixed bug where LAMBDA was not being properly accepted
;			if a vector.
;               Version 4, William Thompson, GSFC, 23-Dec-2005
;                       Use CALL_FUNCTION instead of EXECUTE
;		Version 5, William Thompson, GSFC, 19-Mar-2007
;			Allow for case where either PARAM or LAMBDA is set to
;			zero to keep a parameter constant.
;               Version 6, Richard Schwartz, GSFC, 17-Nov-2014
;                       Changed () to [] for IDL 8.4 compatibility
;
; Version     :	Version 6, 17-Nov-2014
;-
;
	ON_ERROR,2
;
;  Check the number of parameters passed.
;
	IF N_PARAMS(0) NE 2 THEN BEGIN
		PRINT,' This procedure must be called with two parameters:'
		PRINT,'                   FNAME, PARAMS'
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
;  Define NPAR from the input array.  Start ITER at zero.
;
	NPAR = N_ELEMENTS(PARAM)
	IF NPAR EQ 1 THEN PARAM = MAKE_ARRAY(PARAM)
	ITER = 0
;
;  Check the array or scalar LAMBDA.
;
	NLAMB = N_ELEMENTS(LAMBDA)
	IF (NLAMB NE NPAR) AND (NLAMB NE 1) THEN BEGIN
		PRINT,'*** LAMBDA must have 1 or ' + FIX(NPAR) +	$
			' elements, routine AMOEBA_F.'
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
;  Initialize the array containing chi-squared.
;
	CHI = 0.*[0,PARAM]
	FOR I = 0,NPAR DO BEGIN
		CHI[I] = CALL_FUNCTION(FNAME,P[*,I])
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
	CR = CALL_FUNCTION(FNAME,PR)
;
;  If an improvement was achieved, try an additional extrapolation.
;
	IF CR LE CHI[ILO] THEN BEGIN
		PRR = 2*PR - PBAR
		CRR = CALL_FUNCTION(FNAME,PRR)
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
		CRR = CALL_FUNCTION(FNAME,PRR)
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
				CHI[I] = CALL_FUNCTION(FNAME,PRR)
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
        DENOM = (P[*,IHI]^2 + P[*,ILO]^2)
	W = WHERE(DENOM NE 0)
	ERROR = TOTAL( (P[W,IHI] - P[W,ILO])^2 / DENOM[W] )
	BANG_C = !C
	CHI_HI = ABS(MAX(CHI))
	CHI_LO = ABS(MIN(CHI))
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
