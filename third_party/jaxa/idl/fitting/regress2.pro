FUNCTION REGRESS2,X,Y,W,YFIT,A0,SIGMA,FTEST,R,RMUL,CHISQ,SIGMA0
;
;+
; NAME:
;	REGRESS
; PURPOSE:
;	Multiple linear regression fit.
;	Fit the function:
;	Y(i) = A0 + A(0)*X(0,i) + A(1)*X(1,i) + ... + 
;		A(Nterms-1)*X(Nterms-1,i)
; CATEGORY:
;	G2 - Correlation and regression analysis.
; CALLING SEQUENCE:
;	Coeff = REGRESS(X,Y,W,YFIT,A0,SIGMA,FTEST,R,RMUL,CHISQ,SIGMA0)
; INPUTS:
;	X = array of independent variable data.  X must 
;		be dimensioned (Nterms, Npoints) where there are Nterms 
;		coefficients to be found (independent variables) and 
;		Npoints of samples.
;	Y = vector of dependent variable points, must 
;		have Npoints elements.
;	W = vector of weights for each equation, must 
;		be a Npoints elements vector.  For no 
;		weighting, set w(i) = 1., for instrumental weighting 
;		w(i) = 1/standard_deviation(Y(i)), for statistical 
;		weighting w(i) = 1./Y(i)
;
; OUTPUTS:
;	Function result = coefficients = vector of 
;		Nterms elements.  Returned as a column 
;		vector.
;
; OPTIONAL OUTPUT PARAMETERS:
;	Yfit = array of calculated values of Y, Npoints 
;		elements.
;	A0 = Constant term.
;	Sigma = Vector of standard deviations for 
;		coefficients.
;	Ftest = value of F for test of fit.
;	Rmul = multiple linear correlation coefficient.
;	R = Vector of linear correlation coefficient.
;	Chisq = Reduced weighted chi squared.
;       SIGMA0 = standard deviation for A0
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	Adapted from the program REGRES, Page 172, 
;		Bevington, Data Reduction and Error Analysis for the 
;		Physical Sciences, 1969.
;
; MODIFICATION HISTORY:
;	Written, DMS, RSI, September, 1982.
;	Modified, SMR, RSI, March, 1991, made single variable regression not
;		fail on the invert command.
;       Modified, DMZ, ARC, May 1991, to compute standard deviation on A0
;-
;
;ON_ERROR,2              ;RETURN TO CALLER IF AN ERROR OCCURS
SY = SIZE(Y)		;GET DIMENSIONS OF X AND Y.
SX = SIZE(X)
IF (N_ELEMENTS(W) NE SY(1)) OR (SX(0) NE 2) OR (SY(1) NE SX(2)) THEN $
  message, 'Incompatible arrays.'
;
NTERM = SX(1)		;# OF TERMS
NPTS = SY(1)		;# OF OBSERVATIONS
;
SW = TOTAL(W)		;SUM OF WEIGHTS
YMEAN = TOTAL(Y*W)/SW	;Y MEAN
XMEAN = (X * (REPLICATE(1.,NTERM) # W)) # REPLICATE(1./SW,NPTS)
WMEAN = SW/NPTS
WW = W/WMEAN
;
NFREE = NPTS-1		;DEGS OF FREEDOM
SIGMAY = SQRT(TOTAL(WW * (Y-YMEAN)^2)/NFREE) ;W*(Y(I)-YMEAN)
XX = X- XMEAN # REPLICATE(1.,NPTS)	;X(J,I) - XMEAN(I)
WX = REPLICATE(1.,NTERM) # WW * XX	;W(I)*(X(J,I)-XMEAN(I))
SIGMAX = SQRT( XX*WX # REPLICATE(1./NFREE,NPTS)) ;W(I)*(X(J,I)-XM)*(X(K,I)-XM)
R = WX #(Y - YMEAN) / (SIGMAX * SIGMAY * NFREE)
ARRAY = (WX # TRANSPOSE(XX))/(NFREE * SIGMAX #SIGMAX)
IF (SX(1) EQ 1) THEN ARRAY = 1 / ARRAY ELSE ARRAY = INVERT(ARRAY)
A = (R # ARRAY)*(SIGMAY/SIGMAX)		;GET COEFFICIENTS
YFIT = A # X				;COMPUTE FIT
A0 = YMEAN - TOTAL(A*XMEAN)		;CONSTANT TERM
YFIT = YFIT + A0			;ADD IT IN
FREEN = NPTS-NTERM-1 > 1		;DEGS OF FREEDOM, AT LEAST 1.
CHISQ = TOTAL(WW*(Y-YFIT)^2)*WMEAN/FREEN ;WEIGHTED CHI SQUARED
SIGMA = SQRT(ARRAY(INDGEN(NTERM)*(NTERM+1))/WMEAN/(NFREE*SIGMAX^2)) ;ERROR TERM
RMUL = TOTAL(A*R*SIGMAX/SIGMAY)		;MULTIPLE LIN REG COEFF
IF RMUL LT 1. THEN FTEST = RMUL/NTERM / ((1.-RMUL)/FREEN) ELSE FTEST=1.E6
RMUL = SQRT(RMUL)

;-- computation of error on A0

diag=array(indgen(nterm)*(nterm+1))
vec=xmean/sigmax
first_term=total(diag*vec^2)
second_term=transpose(vec)#array#vec
sigma0=(1./npts + (first_term+second_term)/nfree)/wmean
sigma0=sqrt(sigma0)

RETURN,A
END
