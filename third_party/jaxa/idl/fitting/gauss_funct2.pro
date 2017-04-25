;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: gauss_funct2.pro
; Created by:    Liyun Wang, NASA/GSFC, October 7, 1994
;
; Last Modified: Fri Oct  7 15:34:06 1994 (lwang@orpheus.gsfc.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO	GAUSS_FUNCT2,X,A,F,PDER
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;	GAUSS_FUNCT2
;
; PURPOSE:
;	Evaluate the sum of a gaussian and a 2nd order polynomial.
;
; EXPLANATION:
;	This routine evaluate the sum of a gaussian and a 2nd order polynomial
;	and optionally return the value of it's partial derivatives.
;	normally, this function is used by CURVEFIT to fit the
;	sum of a line and a varying background to actual data.
;
; CATEGORY:
;	E2 - CURVE AND SURFACE FITTING.
;
; CALLING SEQUENCE:
;	GAUSS_FUNCT2,X,A,F,PDER
;
; INPUTS:
;	X = VALUES OF INDEPENDENT VARIABLE.
;	A = PARAMETERS OF EQUATION DESCRIBED BELOW.
;
; OUTPUTS:
;	F = VALUE OF FUNCTION AT EACH X(I).
;
; OPTIONAL OUTPUT PARAMETERS:
;	PDER = (N_ELEMENTS(X),6) ARRAY CONTAINING THE
;		PARTIAL DERIVATIVES.  P(I,J) = DERIVATIVE
;		AT ITH POINT W/RESPECT TO JTH PARAMETER.
;
; COMMON BLOCKS:
;	NONE.
;
; SIDE EFFECTS:
;	NONE.
;
; RESTRICTIONS:
;	NONE.
;
; PROCEDURE:
;	F = A(0)*EXP(-Z^2/2) + A(3) + A(4)*X + A(5)*X^2
;	Z = (X-A(1))/A(2)
;
; MODIFICATION HISTORY:
;	WRITTEN, DMS, RSI, SEPT, 1982.
;	Modified, DMS, Oct 1990.  Avoids divide by 0 if A(2) is 0.
;	Modified, JRL, LPARL, Nov, 1988  - If n_elements(A) is 4 or 5,
;					   then a constant or linear
;					   background term is calculated.
;	Modified, JRL, LPARL, Aug, 1990	 - Allow for no background term
;	Modified, SLF, ISAS,  4-Sep-92   - Split gaussfit2/gauss_funct2
;       Liyun Wang, NASA/GSFC, October 7, 1994, incoporated into CDS library
;         
;-
   ON_ERROR,2			;Return to caller if an error occurs
   IF a(2) NE 0.0 THEN Z = (X-A(1))/A(2) $ ;GET Z
   ELSE z = 10.
   EZ = EXP(-Z^2/2.)*(ABS(Z) LE 7.) ;GAUSSIAN PART IGNORE SMALL TERMS
;;	F = A(0)*EZ + A(3) + A(4)*X + A(5)*X^2 ;FUNCTIONS.
   F = A(0)*EZ
   CASE N_ELEMENTS(a) OF
      4: F = F + A(3) 
      5: F = F + A(4)*X 
      6: F = F + A(4)*X + A(5)*X^2 ;FUNCTIONS.
      ELSE:
   ENDCASE
   IF N_PARAMS(0) LE 3 THEN RETURN ;NEED PARTIAL?
;
;	PDER = FLTARR(N_ELEMENTS(X),6) ;YES, MAKE ARRAY.
   PDER = FLTARR(N_ELEMENTS(X),N_ELEMENTS(a)) ;YES, MAKE ARRAY.
   PDER(0,0) = EZ		;COMPUTE PARTIALS
   PDER(0,1) = A(0) * EZ * Z/A(2)
   PDER(0,2) = PDER(*,1) * Z
;	PDER(*,3) = 1.
;	PDER(0,4) = X
;	PDER(0,5) = X^2
   IF N_ELEMENTS(a) GE 4 THEN PDER(0,3) = 1.
   IF N_ELEMENTS(a) GE 5 THEN PDER(0,4) = X
   IF N_ELEMENTS(a) GE 6 THEN PDER(0,5) = X^2
   RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'gauss_funct2.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
