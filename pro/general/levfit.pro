FUNCTION LEVFIT, FUNCTION_NAME=Function_Name, X,D,W,A, LIST=LISTA, $
SIGMAA=SIGMAA, COVAR=COVAR, CHI_SQUARE=CHISQR, VERBOSE=verbose, CON=CON,$
CHISQR_ONLY=CHISQR_ONLY
;******************************************************************************
;         ** IMPORTANT NOTICE: COPYRIGHTS & ACKNOWLEDGEMENTS ** 
; Copyright (c) 1992, 1993 by: 
; (1) Philip Blanco- CASS, UCSD, 9500 Gilman Drive, La Jolla, CA92093-0111, USA
;     Phone: +1 (619) 534-2943  E-mail: pblanco@ucsd.edu
; (2) Science & Engineering Research Council of the United Kingdom (SERC).
;
; This software may not be copied in whole or in part without the written
; consent of the author. If your research benefits from this code, suitable
; acknowledgement in publications would be appreciated. Bug reports/comments 
; are always welcome. Thanks to R. Pina for ideas and improvements.
;******************************************************************************
;+ 
; NAME: LEVFIT.PRO
; Levenberg-Marquardt least squares fitting, adapted from CURVEFIT.PRO with
; some influence from Numerical Recipes.
;
; Returns: vector of model points from <Function_Name> evaluated at X
;
; Parameters (<=input, >=output, !=modified):
; X (FLOAT, vector(NPTS))  (<) - A row vector of independent variables.
; D (FLOAT, vector(NPTS))  (<) - A row vector of dependent variable.
; W (DOUBLE, vector(NPTS)) (<) - A row vector of weights
; A (DOUBLE, vector(NA))   (!) - On input, initial estimate of the model
;                                parameters. On output, the final estimate.
; Keywords:
; FUNCTION_NAME=Function_Name (String, default 'FUNCT') (<) - name of the
; analytic function (actually a procedure) to be fitted to the data.
; A call to FUNCT is defined as:
;	FUNCT, X, A, F, [dFdA], CO=CO
; where	X = Vector of NPOINT independent variables, input.
;       A = Vector of NTERMS function parameters, input.
;       F = Vector of NPOINT values of function, F(i) = funct(x(i)), output.
;       dFdA = Array, (NPOINT, NTERMS), of partial derivatives of funct.
;       dFdA(I,J) = DErivative of function at ith point with
;       respect to jth parameter.  Optional output parameter.
;       dFdA should not be calculated if the parameter is not supplied in call.
;       (See FUNCT.PRO in the IDL USERLIB as an example). Other variables
;        may of couse be specified using COMMON blocks.
;
; LIST=LISTA (LONG, vector(NTERMS<NA), default LINDGEN(NA)) (<) - List of 
; indices for the variable parameters in the fit. Those elements of A which
; are not specified in LISTA are kept fixed at their initial values.
;
; SIGMAA=SIGMAA (DOUBLE, vector(NA)) (>) - Sigmas of the fitted parameters
;
; COVAR=COVAR (DOUBLE, array(NTERMS,NTERMS)) (>) - covariance matrix of the fit
;
; CHI_SQUARE=CHISQR (DOUBLE) (>) - Chi-squared for the final fit. If this is
; not a minumum (fit did not converge) a warning is output to the user.
;
; CON=CON (DOUBLE, vector(?)) - Constraints to apply to the fit
;
; CHISQR_ONLY=CHISQR_ONLY - If this keyword is set then the program just
; computes the value of chi-squared for the initial parameter guess and
; stops.
;
; VERBOSE=verbose (Logical, default 0) (<) - Verbosity level. If set to 1, the
; final best fit parameters are reported. If set to 2, Chi-squared is reported
; for each iteration. If set to 3, parameter values for each iteration are
; reported (useful for debugging).
;
; History:
; 16 Sep 93 - written by P. R. Blanco, CASS/UCSD
;  6 Oct 93 - added correction to bug that caused LEVFIT to crash if 
; there was only one variable parameter (ie. NTERMS EQ 1).
;  9 Oct 95 - Modified to allow for use of "con" keyword to constrain fits. LRW
; 28 Oct 95 - Program now produces an error and terminates when fit fails to
;	      converge after MAXITER iterations.  LRW
; 30 Oct 95 - Set up now so chisqr must not increase between iterations.  LRW
; ?? ??? 95 - Changed convergence criterion to depend on how chisqr is 
;	      changing instead of how the parameter values are changing.  LRW
; 10 Nov 95 - Added CHISQR_ONLY keyword option.  LRW
; 10 Nov 95 - Corrected code so that flambda is set equal to zero before
;             final covariance matrix reported.  LRW
; 21 Nov 95 - Program will not stop but only print a warning message if 
;	      zero degrees of freedom.  LRW
;
USAGE='fit=LEVFIT(Function_name=f, X,Data,Weights,A,[LIST=list], '$
     +'[Sigmaa=<sigmaa>],[COVAR=<covar>],[CHI_SQUARE=<chisqr>], [VERBOSE=v]'$
     +'[CON=<con>],[CHISQR_ONLY=<chisqr>]'
;-
IF N_PARAMS() LT 4 THEN BEGIN
   PRINT, 'Usage: '+USAGE
   RETURN, 0
ENDIF
;
A=DOUBLE(A) & NA=N_ELEMENTS(A)
W=DOUBLE(W)
;
; Set up defaults
;
IF N_ELEMENTS(function_name) LE 0 THEN function_name = "FUNCT"
IF N_ELEMENTS(LISTA) EQ 0 THEN LISTA=LINDGEN(NA)
;
NPTS=MIN([N_ELEMENTS(X),N_ELEMENTS(D),N_ELEMENTS(W)])
NTERMS = N_ELEMENTS(LISTA)	                    
N_doF =  N_ELEMENTS(D)-NTERMS      
if N_doF eq 0 then print,'LEVFIT: warning - zero degrees of freedom'
IF N_doF LT 0 THEN MESSAGE, 'Not enough data points, N_doF= '+STRTRIM(N_doF,2)
;
; Partial derivatives of function wrt. parameters
dFdA=DBLARR(NPTS, NA)
;
; Partial derivatives wrt. parameters to be varied:
DFDA_FIT=DBLARR(NPTS, NTERMS)
;
; Create 2-D weight array with NTERMS rows of the vector W
WEIGHTS_2D= W # (REPLICATE(1.0D0, NTERMS))
;
; If only 1 parameter to be fit then we have to force 1-D arrays of
; dimension NPTS into 2-D arrays of dimensions NPTS by 1. (So that
; the matrix algebra will work later on).
;
IF (NTERMS EQ 1) THEN BEGIN
   WEIGHTS_2D = REFORM(WEIGHTS_2D, [NPTS,1], /OVER)
   DFDA_FIT = REFORM(DFDA_FIT, [NPTS,1], /OVER)
ENDIF
;  
; Create subscripts of diagonal elements             
DIAG = INDGEN(NTERMS)*(NTERMS+1)  
;
; Evaluate the function to see if everything is OK
IF KEYWORD_SET(CON) THEN CALL_PROCEDURE, Function_name,X,A, DFIT, CON=CON $
                    ELSE CALL_PROCEDURE, Function_name,X,A, DFIT
CHISQR=TOTAL(W*(D-DFIT)^2)
IF KEYWORD_SET(chisqr_only) THEN BEGIN
  chisqr_only=chisqr
  return,0
ENDIF
IF KEYWORD_SET(verbose) THEN PRINT, 'Initial Chi-squared = ', +STRTRIM(CHISQR)
;
; Set initial trial values
;
ATRY=A
FLAMBDA=0.001     ; reasonable value for LAMBDA
CHISQR_TOL=1.0e-6 ; Tolerance for change in chisqr/dof
MAXITER=300       ; maximum number of iterations
CCOUNT=0	  ; Exit loop when CCOUNT EQ 5
;
; Now iterate to find a better solution 
;
FOR ITER=0, MAXITER DO BEGIN	
    IF KEYWORD_SET(CON) THEN $
       CALL_PROCEDURE, Function_name,X,A, DFIT, dFdA, CON=CON ELSE $
       CALL_PROCEDURE, Function_name,X,A, DFIT, dFdA
;
; Load the active partial derivative array
;
    IF N_ELEMENTS(LISTA) EQ 0 THEN DFDA_FIT=DFDA $
    ELSE FOR I=0,NTERMS-1 DO DFDA_FIT(*,I)=dFdA(*,LISTA(I))
;
; Evaluate ALPHA and BETA matrices
;
    BETA = (D-DFIT)*W # dFdA_FIT
    ALPHA = TRANSPOSE(dFdA_FIT) # (WEIGHTS_2D * dFdA_FIT)
;
; (Perform any re-weighting on the weights W here, and remember to update
; WEIGHTS_2D)
;
    CHISQ1=TOTAL(W*(D-DFIT)^2)
;
    REPEAT BEGIN
;
; Invert modified curvature matrix to find better parameters....
;
       C = SQRT(ALPHA(DIAG) # ALPHA(DIAG))
;
;      first normalize by array of diagonal elements
;
       ZEROS = WHERE(C EQ 0.0, NZ)              ; avoid division by zero
       IF (NZ GT 0) THEN BEGIN
          C(ZEROS) = 1.0                       
          ARRAY = ALPHA / C                    
	  ARRAY(ZEROS) = 0.0                    ; fix divisions by zero
       ENDIF $
       ELSE ARRAY  = ALPHA / C                  ; normal case

       ARRAY(DIAG) = ARRAY(DIAG)*(1.+FLAMBDA)  ; augment diagonal elements
;
; Trap the special case of NTERMS EQ 1, since ARRAY will not be 2-D
       IF NTERMS GT 1 THEN ARRAY = INVERT(ARRAY) ELSE ARRAY=1./ARRAY
;
; Create a new estimate of the variable parameters
       ATRY(LISTA) = A(LISTA)+ ARRAY/C # TRANSPOSE(BETA) 
;
; Test these new parameters for an improvement in Chi-squared, but do NOT
; evaluate partial derivatives at this stage
       IF KEYWORD_SET(CON) THEN $
            CALL_PROCEDURE, Function_name, X, ATRY, DFIT, CON=CON ELSE $
            CALL_PROCEDURE, Function_name, X, ATRY, DFIT
       CHISQR = TOTAL(W*(D-DFIT)^2) 
;
; Print out the results according to verbosity supplied on entry
       IF KEYWORD_SET(VERBOSE) THEN BEGIN 
        IF (VERBOSE GT 1) THEN PRINT, STRTRIM(ITER,2)+ $
         ': Chi-squared = '+STRTRIM(CHISQR,2) + ' Lambda= '+STRTRIM(FLAMBDA,2)
        IF (VERBOSE GT 2) THEN PRINT, FLOAT(ATRY(LISTA))
       ENDIF
;
       FLAMBDA=FLAMBDA*10.0                     ; assume fit got worse
;
    ENDREP UNTIL (CHISQR LE CHISQ1)
;
; Now we have an improvement, update the parameters and decrease FLAMBDA
    FLAMBDA=FLAMBDA/100.
    AOLD_FIT=A(LISTA)
    A(LISTA)=ATRY(LISTA)

;
; Jump out of loop if chisqr/dof hasn't improved much in last 3 iterations
    if N_doF eq 0 then begin   
      if (chisq1-chisqr) lt chisqr_tol then $
         if (ccount ge 5) then goto, done else ccount=ccount+1 $
      else ccount=0
    endif else begin
      IF (CHISQ1-CHISQR)/N_doF LT CHISQR_TOL THEN $
         IF (CCOUNT GE 5) THEN GOTO, DONE ELSE CCOUNT=CCOUNT+1 $
      ELSE CCOUNT=0
    endelse
;
ENDFOR  
MESSAGE,'Failed to converge after '+STRTRIM(MAXITER,2)+ ' iterations.'
;
DONE:   

; Re-compute ARRAY with FLAMBDA set to zero.
C = SQRT(ALPHA(DIAG) # ALPHA(DIAG))
;
;      first normalize by array of diagonal elements
;
ZEROS = WHERE(C EQ 0.0, NZ)              ; avoid division by zero
IF (NZ GT 0) THEN BEGIN
   C(ZEROS) = 1.0                       
   ARRAY = ALPHA / C                    
   ARRAY(ZEROS) = 0.0                    ; fix divisions by zero
ENDIF $
ELSE ARRAY  = ALPHA / C                  ; normal case
;
; Trap the special case of NTERMS EQ 1, since ARRAY will not be 2-D
IF NTERMS GT 1 THEN ARRAY = INVERT(ARRAY) ELSE ARRAY=1./ARRAY

ZEROS = WHERE(ALPHA EQ 0.0, NZ)     ; avoid division by zero
IF (NZ GT 0) THEN BEGIN
   ALPHA(ZEROS) = 1.0     
   COVAR= ARRAY / ALPHA
   COVAR(ZEROS) = 0.0      ; fix division by zero
ENDIF $
ELSE COVAR = ARRAY / ALPHA ; normal case

;
; Return the Sigmas separately from the covariance matrix
;
SIGMAA=FLTARR(NA)
SIGMAA(LISTA) = SQRT( COVAR(DIAG) ) 
IF KEYWORD_SET(VERBOSE) THEN BEGIN
   PRINT, 'Chi-squared= '+STRTRIM(CHISQR,2)+' for '+STRTRIM(N_doF,2)+ $
          ' degrees of freedom-'
   PRINT, '   '+STRTRIM(FLOAT(A),2)
   PRINT, '+/-'+STRTRIM(SIGMAA,2)
ENDIF
;
RETURN, DFIT		
END
