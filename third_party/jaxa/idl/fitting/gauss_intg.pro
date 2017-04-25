;+
; PROJECT:
;       SDAC
;
; NAME:
;	GAUSS_INTG
;
; PURPOSE:
;	This procedure sums a Gaussian and 2nd order polynomial.
;	AND OPTIONALLY RETURN THE VALUE OF IT'S PARTIAL DERIVATIVES.
;	THIS GAUSSIAN IS EVALUATED BY INTEGRATING A GAUSSIAN OVER
;	AN INTERVAL AND DIVIDING BY THE INTERVAL WIDTH.
;	IT USES THE FUNCTION GAUSSINT TO INTEGRATE THE GAUSSIAN.
;
;
; CATEGORY:
;	FITTING, MATH, UTILITY, NUMERICAL ANALYSIS - CURVE AND SURFACE FITTING.
; CALLS:
;	F_PDER, EDGE_PRODUCTS, F_GAUSS_INTG
; CALLING SEQUENCE:
;	GAUSS_INTG,X,A,F,PDER
; EXAMPLE:
;       gauss_intg, x, a, f
; INPUTS:
;	X = VALUES OF INDEPENDENT VARIABLE, 2 X N, LO AND HI EDGES
;	A = PARAMETERS OF EQUATION DESCRIBED BELOW.
;
; INPUT KEYWORDS:
;       SIGTHRESH - number of sigmas defining region of integration
;                   for gaussian.  Only regions whose limits are
;                   within +/- sigthresh will be evaluated.
;
; OUTPUTS:
;	F = VALUE OF FUNCTION AT EACH X(I).
;
; OPTIONAL OUTPUT PARAMETERS:
;	PDER = (N_ELEMENTS(X),6) ARRAY CONTAINING THE
;		PARTIAL DERIVATIVES.  P(I,J) = DERIVATIVE
;		AT ITH POINT W/RESPECT TO JTH PARAMETER.
; COMMON BLOCKS:
;	NONE.
; SIDE EFFECTS:
;	NONE.
; RESTRICTIONS:
;	NONE.
; PROCEDURE:
;	This procedure sums a Gaussian and 2nd order polynomial.
;	AND OPTIONALLY RETURN THE VALUE OF IT'S PARTIAL DERIVATIVES.
;	THIS GAUSSIAN IS EVALUATED BY INTEGRATING A GAUSSIAN OVER
;	AN INTERVAL AND DIVIDING BY THE INTERVAL WIDTH.
;	IT USES THE FUNCTION GAUSSINT TO INTEGRATE THE GAUSSIAN.
;	F = A(0)*EXP(-Z^2/2) + A(3) + A(4)*X + A(5)*X^2
;	Z = (X-A(1))/A(2)
;	F IS INTEGRATED FROM X_LO TO X_HI
; MODIFICATION HISTORY:
;	changed gaussian to integrating gaussian over an interval
;	RAS, 21-MAR-95
;	RAS, 4-NOV-2011, changed () to [] for array ref
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-
PRO GAUSS_INTG, XIN, $
                AIN, $
                F, $
                PDER, $
                SIGTHRESH=sigthresh, $
                _EXTRA=_extra

;get the width and make sure it is 2xN
edge_products, xin, mean=x, width=dx

a = fltarr(6)
a[0] = ain

checkvar, sigthresh, 5.

f = dx * 0.

z1 = f_div( ( x-dx/2-a[1] ), a[2] )
z2 = f_div( ( x+dx/2-a[1] ), a[2] )
use = Where( z1 LE sigthresh AND z2 GE -sigthresh, n_use )
IF n_use GT 0 THEN BEGIN
    f[ use ]  = a[0] * $
      f_div( ( gaussint( z2[use] < sigthresh ) - $
               gaussint( z1[use] > ( -sigthresh ) ) ) * sqrt(2.*!pi), $
             z2[use]-z1[use])
ENDIF

if total(abs(a[3:5]) ge 0) then f = f + A[3] + A[4]*X + A[5]*X^2
IF N_PARAMS(0) LE 3 THEN RETURN ;NEED PARTIAL?
;
PDER = FLTARR(N_ELEMENTS(X),6)  ;YES, MAKE ARRAY.
PDER[0,0] = EZ                  ;COMPUTE PARTIALS
pder[*,1] = f_pder( funct='f_gauss_intg',param=a,data=xin,npar=1)
pder[*,2] = f_pder( funct='f_gauss_intg',param=a,data=xin,npar=2)
PDER[*,3] = 1.
PDER[0,4] = X
PDER[0,5] = X^2

END
