;+
; PROJECT:
;       SDAC
; NAME:
;	F_GAUSS_INTG
;
; PURPOSE:
;	This function returns the sum of a Gaussian and 2nd order polynomial.      
;
; CATEGORY:
;	E2 - CURVE AND SURFACE FITTING.
; CALLS:
;	GAUSS_INTG
; CALLING SEQUENCE:
;	out = F_GAUSS_INTG(X,A)
; EXAMPLES:
;        if a(4+i*3) ne 0.0 then line(0) =line + $
;         f_gauss_intg( x, [ f_div( a(4+i*3)/sqrt(2*!pi), a(6+i*3)),  a(5+i*3+ w2 )] )  
;
; INPUTS:
;	X = VALUES OF INDEPENDENT VARIABLE, 2 X N, LO AND HI EDGES
;	A = PARAMETERS OF EQUATION DESCRIBED BELOW.
; OUTPUTS:
;	None.
;
;
; OPTIONAL OUTPUT PARAMETERS:
;
; COMMON BLOCKS:
;	NONE.
; SIDE EFFECTS:
;	NONE.
; RESTRICTIONS:
;	NONE.
; PROCEDURE:
;	THIS GAUSSIAN IS EVALUATED BY INTEGRATING A GAUSSIAN OVER
;	AN INTERVAL AND DIVIDING BY THE INTERVAL WIDTH.
;	IT USES THE FUNCTION GAUSSINT TO INTEGRATE THE GAUSSIAN.
;	F = A(0)*EXP(-Z^2/2) + A(3) + A(4)*X + A(5)*X^2
;	Z = (X-A(1))/A(2)
;	F IS INTEGRATED FROM X_LO TO X_HI 
; MODIFICATION HISTORY:
;	changed gaussian to integrating gaussian over an interval
;	RAS, 21-MAR-95
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-
FUNCTION f_gauss_intg, x, a, _REF_EXTRA=_ref_extra

gauss_intg, x, a, f, _EXTRA=_ref_extra

RETURN, f

END

